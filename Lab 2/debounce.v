`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: WPI
// Engineer: Jacob Nguyen
// 
// Create Date: 09/12/2022 07:20:46 PM
// Design Name: Debounce
// Module Name: debounce
// Project Name: ECE 3829 Lab 2
// Target Devices: Basys 3 Board
// Tool Versions: 2021.1
// Description: Button input debounce
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module debounce(
    input in, // Input button
    input reset_n, // Active low reset
    input clk, // 25 MHz clock signal
    output out // Button output
    );
    
    parameter TERMINAL_COUNT = 250000; // 1 msec * 25 MHz = 250000 clk
    
    wire toggle; // If input is changed, toggle = 1
    
    reg [17:0] count; // Current clock tick count, 2^18 = 262,144
    reg lastIn; // Input reading from last clock
    reg btnOut; // Reg for output debounce
    
    assign toggle = (lastIn != in) ? 1 : 0; // If input on the last clock tick does not match doesn't match, toggle
    assign out = btnOut; // Out always = btnOut
    
    always @ (posedge clk) begin
        if (reset_n == 0 || count >= TERMINAL_COUNT) begin
            btnOut <= in; // If reset pressed or terminal count reached, btnOut = in
            count <= 0; // If reset pressed or terminal count reached, reset count
        end
        else if(toggle == 1) begin
            count <= 0; // If input toggled, reset count        
        end        
        else begin
            count <= count + 1; // Counter incremented
        end
    end
    
    always @ (posedge clk) begin
        lastIn <= in; // lastIn is updated each clock tick
    end
    
endmodule
