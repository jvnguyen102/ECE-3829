`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: WPI
// Engineer: Jacob Nguyen
// 
// Create Date: 09/22/2022 05:09:17 PM
// Design Name: ECE 3829 Lab 3 Top Module
// Module Name: top_lab3
// Project Name: ECE 3829 Lab 3
// Target Devices: Basys 3 Board
// Tool Versions: 2021.1
// Description: Top module for ECE 3829 Lab 3
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_lab3(
    input clk, // 100MHz Clock
    input btnC, // Up Button
    input JA2, // SPI Input
    output JA3, // SLCK
    output JA0, // Chip Select
    output [6:0] seg, // Seven-seg display
    output [3:0] an // Seven-seg enable
    );

    // Parameters
    // Last 2 digits of WPI ID
    parameter [3:0] wpiIDA = 4'd9; 
    parameter [3:0] wpiIDB = 4'd4;

    // Wires
    wire clk_10MHz;
    wire reset_n;
    wire [7:0] actual; // 8-bit number
    wire sync_locked;

    // Seven-segment display
    seven_seg seven_segi(
    .displayA(wpiIDA),
    .displayB(wpiIDB),
    .displayC(actual[7:4]),
    .displayD(actual[3:0]),
    .clk(clk_10MHz),
    .reset_n(reset_n),
    .sevenSeg(seg),
    .sevenSegan(an));

    // Clock Gen
    clkgen clkgeni(
    .clk(clk),
    .sync_locked(sync_locked),
    .locked_dd(reset_n));

    // Light Sensor
    light_sensor #(.TERM_COUNT(10_000_000), .SIZE(32)) light_sensori(
    .clk(clk_10MHz),
    .reset_n(reset_n),
    .JA2(JA2),
    .JA0(JA0),
    .JA3(JA3),
    .actual(actual));

    // Clock Wizard Instanciation for 10MHz output clk
    clk_mmcm_wiz clk_mmcm_wizi(
    .clk_10MHz(clk_10MHz), // clk_10Mhz
    // Status and Control signals
    .reset(btnC), // Input reset
    .locked(sync_locked), // Output locked
    .clk_in1(clk)); // Input clk_in1
endmodule
