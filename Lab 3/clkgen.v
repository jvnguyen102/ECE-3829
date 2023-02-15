`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: WPI
// Engineer: Jacob Nguyen
// 
// Create Date: 09/22/2022 05:11:42 PM
// Design Name: Clock Gen
// Module Name: clkgen
// Project Name: ECE 3829 Lab 3
// Target Devices: Basys 3 Board
// Tool Versions: 2021.1
// Description: Clock gen for light sensor
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module clkgen(
    input clk,
    input sync_locked,
    output reg locked_dd
    );

    reg locked_d;

    // Two stage Synchronizer w/o a reset to remove Metastability
    always @ (posedge clk) begin
        locked_d <= sync_locked;
        locked_dd <= locked_d;
    end
endmodule
