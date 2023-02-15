`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: WPI
// Engineer: Jacob Nguyen
// 
// Create Date: 08/28/2022 05:57:48 PM
// Design Name: Seven Segment
// Module Name: seven_seg
// Project Name: ECE 3829 Lab 3
// Target Devices: Basys 3 Board
// Tool Versions: 2021.1
// Description: 
// Converts numbers and displays numbers to Seven Segment display
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module seven_seg(
    input [3:0] displayA, // Data of display A
    input [3:0] displayB, // Data of display B
    input [3:0] displayC, // Data of display C
    input [3:0] displayD, // Data of display D
    input clk,
    input reset_n,
    output reg [6:0] sevenSeg, // 7 segment display
    output reg [3:0] sevenSegan // 7 segment enable
    );
    
    reg [3:0] disp; // Number to be displayed on 7 segment
    reg [15:0] counter; // 2^16 = 65536
    reg [3:0] displaySelect; // Enabling the current display
    
    parameter delay = 25000; // 1ms delay for the 25MHz clock
    parameter off = 7'b1111111; // All segments off
    
    always @ (posedge clk) begin
        if (reset_n == 0) begin
            counter <= 0; // Counter reset
            displaySelect <= 4'b0001; // Display starts at D
        end
        else if (counter == delay) begin
            counter <= 0; // Counter reset and display shifts after 10 ms
            displaySelect <= {displaySelect[2:0], displaySelect[3]}; // Shift display enable left every 10ms, back to D after A
        end
        else begin
            counter <= counter + 1; // Counter increments every 1/25MHz
        end
    end
    
    always @ (*) begin // Enables four seven segment displays when selected, turned off if reset active
        if(reset_n == 0)begin
            sevenSegan = 4'b1111;
            disp = 4'b1111;
        end
        else begin
        case (displaySelect)
            4'b0001: begin
                sevenSegan = 4'b1110;
                disp = displayD;
            end
            4'b0010: begin
                sevenSegan = 4'b1101;
                disp = displayC;
            end
            4'b0100: begin
                sevenSegan = 4'b1011;
                disp = displayB;
            end
            4'b1000: begin
                sevenSegan = 4'b0111;
                disp = displayA;
            end
        endcase
        end
    end
    
      
    always @ (posedge clk) begin // Converts 4-bit hex number to be displayed on 7 segment
        if(reset_n == 0) begin
            sevenSeg = off;
        end
        else begin
            case(disp)
                4'h0: sevenSeg = 7'b1000000; // 0
                4'h1: sevenSeg = 7'b1111001; // 1
                4'h2: sevenSeg = 7'b0100100; // 2
                4'h3: sevenSeg = 7'b0110000; // 3
                4'h4: sevenSeg = 7'b0011001; // 4
                4'h5: sevenSeg = 7'b0010010; // 5
                4'h6: sevenSeg = 7'b0000010; // 6
                4'h7: sevenSeg = 7'b1111000; // 7
                4'h8: sevenSeg = 7'b0000000; // 8
                4'h9: sevenSeg = 7'b0011000; // 9
                4'hA: sevenSeg = 7'b0001000; // A
                4'hB: sevenSeg = 7'b0000011; // B
                4'hC: sevenSeg = 7'b1000110; // C
                4'hD: sevenSeg = 7'b0100001; // D
                4'hE: sevenSeg = 7'b0000110; // E
                4'hF: sevenSeg = 7'b0001110; // F
            endcase
        end
    end
    
endmodule
