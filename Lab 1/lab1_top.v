`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: WPI
// Engineer: Jacob Nguyen
// 
// Create Date: 08/29/2022 07:53:03 PM
// Design Name: Lab 1 Top Module
// Module Name: lab1_top
// Project Name: ECE 3829 Lab 1
// Target Devices: Basys 3 Board
// Tool Versions: 2021.1
// Description: 
// This top module instantiates input_select and seven_seg modules with port connections made by name association
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module lab1_top(
    input [15:0] sw, // Switches 0-15 on bottom of board
    input btnU, // Up button
    input btnD, // Down button
    input btnL, // Left button
    input btnR, // Right button
    output [15:0] led, // LEDs 0-15 on bottom of board
    output [6:0] seg, // 7 Segment Display
    output [3:0] an // 7 Segment enable
    );
    
    wire [3:0] dispA, dispB, dispC, dispD; // Numbers on each display
    wire [3:0] button;
    
    assign button[3] = btnU; // Assign button inputs
    assign button[2] = btnL;
    assign button[0] = btnR;
    assign button[1] = btnD;
    
    // Instantiate modules
    input_select input_select1(.mode(sw[15:14]), .slider(sw[13:0]), .Aout(dispA), .Bout(dispB), .Cout(dispC), .Dout(dispD));
    seven_seg seven_seg_1(.displayA(dispA), .displayB(dispB), .displayC(dispC), .displayD(dispD), .buttons(button), .sevenSeg(seg), .sevenSegan(an)); 
    
    // LEDs turn on to corresponding switch
    assign led[15:0] = sw[15:0];
    
endmodule
