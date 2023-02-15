`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: WPI
// Engineer: Jacob Nguyen 
// 
// Create Date: 09/12/2022 04:19:33 PM
// Design Name: Top Module Lab 2
// Module Name: top_lab2
// Project Name: ECE 3829 Lab 2
// Target Devices: Basys 3 Board
// Tool Versions: 2021.1
// Description: Lab 2 Top Module
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_lab2(
    input clk, // 100 MHz input clock
    input btnC, // Reset signal
    input btnU,
    input [1:0] sw,
    output [6:0] seg,
    output [3:0] an,
    output [3:0] vgaRed,
    output [3:0] vgaGreen,
    output [3:0] vgaBlue,
    output Hsync,
    output Vsync
    );
    
    // Last 4 Digits of WPI ID
    parameter [3:0] idA = 4'd1;
    parameter [3:0] idB = 4'd9;
    parameter [3:0] idC = 4'd9;
    parameter [3:0] idD = 4'd4;
    
    wire clk_25Mhz; // 25 MHz clock
    wire reset; // Active high reset
    wire reset_n; // Active low reset
    wire sw1Debounce; // Switch 1 signal debounce
    wire sw0Debounce; // Switch 0 signal debounce
    wire btnUDebounce; // Up button debounce
    wire blank; // Blank VGA screen
    wire [1:0] sw_debounce = {sw1Debounce, sw0Debounce}; // Register of both debounced switch inputs
    wire [10:0] hcount; // Pixel horizontal position
    wire [10:0] vcount; // Pixel vertical position
    
    assign reset = ~reset_n; // VGA reset is active high
    
    // Clock module converting 100 MHz input clock to 25 MHz output clock
    clk_mmcm_wiz clk_mmcm_wizi(
    .clk_25Mhz(clk_25Mhz), // Output clk_25_Mhz
    // Status and control signals
    .reset(btnC), // Input reset
    .locked(reset_n), // Output locked
    // Clock in ports
    .clk_in1(clk) // input clk_in1
    );
    
    // Seven Segment Display
    seven_seg seven_seg_i(
    .displayA(idA),
    .displayB(idB),
    .displayC(idC),
    .displayD(idD),
    .clk(clk_25Mhz),
    .reset_n(reset_n),
    .sevenSeg(seg),
    .sevenSegan(an)
    );
    
    // sw[1] debounce
    debounce debounce_i(
    .in(sw[1]),
    .reset_n(reset_n),
    .clk(clk_25Mhz),        
    .out(sw1Debounce)
    );
    
    // sw[0] debounce
    debounce debounce_ii(
    .in(sw[0]),
    .reset_n(reset_n),
    .clk(clk_25Mhz),        
    .out(sw0Debounce)
    );
    
    // btnU debounce
    debounce debounce_iii(
    .in(btnU),
    .reset_n(reset_n),
    .clk(clk_25Mhz),        
    .out(btnUDebounce)
    );
    
    // VGA Controller
    vga_controller_640_60 vga_controller_640_60i(
    .pixel_clk(clk_25Mhz),
    .rst(reset),
    .HS(Hsync),
    .VS(Vsync),
    .hcount(hcount),
    .vcount(vcount),
    .blank(blank)
    );
    
    vga_display vga_display_i(
    .sw(sw_debounce),
    .clk(clk_25Mhz),
    .reset_n(reset_n),
    .button(btnUDebounce),
    .blank(blank),
    .hcount(hcount),
    .vcount(vcount),
    .vgaRed(vgaRed),
    .vgaGreen(vgaGreen),
    .vgaBlue(vgaBlue)
    );
    
endmodule
