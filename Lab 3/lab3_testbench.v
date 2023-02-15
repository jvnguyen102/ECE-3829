`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: WPI
// Engineer: Jacob Nguyen
// 
// Create Date: 09/21/2022 12:01:25 PM
// Design Name: Lab 3 Testbench
// Module Name: lab3_testbench
// Project Name: ECE 3829 Lab 3 
// Target Devices: Basys 3 Board
// Tool Versions: 2021.1
// Description: Testbench for ECE 3829 Lab 3
//
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module lab3_testbench(
   );
reg clk_10MHz;
reg reset_n;
reg [7:0]expected;
reg SD0;

wire CS_N;
wire SCLK;
wire [7:0]actual;

integer i;
integer seed = 1;

parameter C_CLK_HALF_PER = 50;
parameter MAX = 255;
parameter MIN = 0;

always begin 
    #C_CLK_HALF_PER clk_10MHz <= ~clk_10MHz;
end

initial begin
    reset_n = 0;
    clk_10MHz = 1'b0;
    expected = $dist_uniform(seed, MIN, MAX);
    #500
    reset_n = 1;
    for (i = 0; i < 4; i = i + 1) begin
        expected = $dist_uniform(seed, MIN, MAX);
        if (expected == actual) begin
            $display ("Pass: expected value %h, Real Time: %h", expected, $realtime);
        end
        else begin
            $display ("Fail: output value %h, expected value %h", actual, expected);
        end
    end
    #60000000;
    $stop;
end

light_sensor #(.TERM_COUNT(1000)) uuti(
    .clk(clk_10MHz),
    .reset_n(reset_n),
    .JA2(SDO),
    .JA0(CS_N),
    .JA3(SCLK),
    .actual(actual));
endmodule
