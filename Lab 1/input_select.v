`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: WPI
// Engineer: Jacob Nguyen
// 
// Create Date: 08/27/2022 04:04:25 PM
// Design Name: Input Select
// Module Name: input_select
// Project Name: ECE 3829 Lab 1
// Target Devices: Basys 3 Board
// Tool Versions: 2021.1
// Description: 
// Input select for Lab 1 that contains pme 2=bit mode select input, one 14-bit slider value input, and four 4-bit display value input_select
// 4 different modes described in the lab are mapped to Mode 0, 1, 2 and 3
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module input_select(
    input [1:0] mode,
    input [13:0] slider,
    output reg [3:0] Aout, // Left-most 7-seg display, A
    output reg [3:0] Bout, // 2nd 7-seg display, B
    output reg [3:0] Cout, // 3rd 7-seg display, C
    output reg [3:0] Dout // Right-most 7-seg display, D
    );
    
    reg [7:0] times2; // Register for mode 2 to keep output
    reg [4:0] sum; // Register for mode 3 to keep output
    
    always @ (*)
        case(mode)
        2'b00: // Mode 0: display last 4 of WPI ID
            begin
            Aout = 4'd1; // Display decimal values "1994"
            Bout = 4'd9;
            Cout = 4'd9;
            Dout = 4'd4;
            end
        2'b01: // Mode 1: display values of sliders in hex
            begin
            Aout = slider[13:12];
            Bout = slider[11:8];
            Cout = slider[7:4];
            Dout = slider[3:0];
            end
        2'b10: // Mode 2:
            begin
            times2 = (slider[13:8] << 1); // Multiply slider values by 2 (shift left by 1)
            Aout = slider[13:12];
            Bout = slider[11:8];
            Cout = times2[6:4];
            Dout = times2[3:0]; 
            end
        2'b11: // Mode 3
            begin
            sum = (slider[7:4] + slider[3:0]); // Add both slider values
            Aout = slider[7:4];
            Bout = slider[3:0];
            Cout = sum[4];
            Dout = sum[3:0];
            end
        endcase
        
endmodule
