`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: WPI
// Engineer: Jacob Nguyen
// 
// Create Date: 09/21/2022 12:00:44 PM
// Design Name: Light Sensor
// Module Name: light_sensor
// Project Name: ECE 3829 Lab 3
// Target Devices: Basys 3 Board
// Tool Versions: 2021.1
// Description: BFM Light sensor module
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module light_sensor
#( parameter TERM_COUNT = 10_000_000,
 parameter SIZE = 32)(
    input clk, // 10MHz clk
    input reset_n,
    input JA2, // SD0
    output reg JA0, // Chip Select
    output reg JA3, // sclk
    output reg [7:0]actual // 8-bit sensor reading
    );
    
// Registers
reg [1:0]state; // State reg for FSM
reg [32:0]counter; // 1 sec delay
reg [4:0]sclk_counter; // 5-bit chip select counter
reg [7:0]intermediateOut; // Intermediate output to transfer data to output

wire rising_edge;
wire falling_edge;
    
// Parameters
localparam C_RISE_EDGE = 0;
localparam C_FALL_EDGE = 5;
localparam RESET = 2'b00;
localparam WAIT = 2'b01;
localparam READ = 2'b10;
    
assign rising_edge = (counter == C_RISE_EDGE) ? 1'b1 : 1'b0;
assign falling_edge = (counter == C_FALL_EDGE) ? 1'b1 : 1'b0;

// Clock Frequency Divider
always @ (posedge clk) begin        
    if (counter >= 10 && state == READ) begin // Reset counter if 10 and in read
        counter <= 0;
    end
    else begin
        counter <= counter + 1; // Counter += 1
    end
end
    
always @ (posedge clk) begin 
    if (reset_n == 0) begin
        state <= RESET; // Reset state 
    end       
    case (state)
        RESET : begin // Initialize interface
            JA0 <= 1; // Chip select high
            state <= WAIT;
        end
        WAIT : begin // Wait state to reset clock frequency divider and to control sampling time
            if (counter >= TERM_COUNT) begin 
                sclk_counter <= 0; 
                state <= READ; 
            end
        end
        READ : begin
            JA0 <= 0; // Chip select low
            if (rising_edge) begin
                JA3 <= 1;
            end
            else if (falling_edge) begin
                JA3 <= 0;
                sclk_counter <= sclk_counter + 1;
            end    
            if (sclk_counter >= 4 && sclk_counter <= 11 && rising_edge) begin // Read samples
                if (JA0 == 1) begin // No readings if high
                    actual <= 0;
                end
                if (JA0 == 0) begin // Fill temp register if chip select low
                    intermediateOut <= {intermediateOut[6:0], JA2}; 
                end
            end
            if (sclk_counter >= 16) begin // sclk delay to display to 7-seg
                actual <= intermediateOut;
                state <= RESET;
            end 
        end
    endcase
end

endmodule
