`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: WPI
// Engineer: Jacob Nguyen
// 
// Create Date: 09/12/2022 06:02:54 PM
// Design Name: VGA Display
// Module Name: vga_display
// Project Name: ECE 3829 Lab 2
// Target Devices: Basys 3 Board
// Tool Versions: 2021.1
// Description: Display VGA outputs depending on sw[1:0]
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module vga_display(
    input [1:0] sw, // Slide switches to select display on monitor
    input clk, // 25 MHz clock signal
    input reset_n, // Reset count, active low
    input button, // Input for moving block
    input blank, // Display blank screen
    input [10:0] hcount, // Pixel horizontal position
    input [10:0] vcount, // Pixel vertical position
    output [3:0] vgaRed, // Red input for VGA
    output [3:0] vgaGreen, // Green input for VGA
    output [3:0] vgaBlue // Blue input for VGA
    );
    
    // Parameters and regs
    parameter [11:0] RED = 12'b1111_0000_0000;
    parameter [11:0] GREEN = 12'b0000_1111_0000;
    parameter [11:0] BLUE = 12'b0000_0000_1111;
    parameter [11:0] BLACK = 12'b0000_0000_0000;
    parameter [11:0] WHITE = 12'b1111_1111_1111;
    parameter [11:0] YELLOW = 12'b1111_1111_0000;
    parameter screenHorz = 640; // Horizontal size
    parameter screenVert = 480; // Vertical size
    parameter halfScreenHorz = 320; // Half of Horizontal size
    parameter MAX_COUNT = 12_500_000 - 1; // 2Hz clock using 25MHz input clock
    
    reg [11:0] vgaRGB; // RGB to VGA
    reg [10:0] blockPos = 0; // Moving block position 2^10 = 1024
    reg [24:0] counter = 0; // Counter to create 2MHz clock to update moving block position 2^24 = 16.777e6
    
    // VGA color assignments
    assign vgaRed = vgaRGB[11:8]; // 4 most significant bits of vgaRGB to VGA red
    assign vgaGreen = vgaRGB[7:4]; // Middle 4 bits of vgaRGB to VGA green
    assign vgaBlue = vgaRGB[3:0]; // 4 least significant bits of vgaRGB to VGA blue
    
always @ (posedge clk) begin
    if (reset_n == 0 || button == 0) begin // If reset pressed or button not pressed
        blockPos <= 0; // Reset counter to top of screen
        counter <= 0; // Reset counter            
    end
    else begin
        if (counter >= MAX_COUNT) begin // If counter reaches max count
            counter = 0; // Reset
            if (blockPos >= 480) begin // If block reaches bottom side of screen
                blockPos <= 0; // Reset block position to top side of screen
            end
            else begin
                blockPos <= blockPos + 32; // Move block down by 16 pixels
            end
        end
        else begin // Max count not reached
            counter <= counter + 1; // Increment counter
        end
    end
end

always @ (posedge clk) begin
    if (blank == 1) begin
        vgaRGB = BLACK; // Black screen
    end
    // Moving block
    else if (button == 1) begin // Block move pressed
        vgaRGB <= BLUE; // Cover entire screen blue
        if (vcount >= blockPos && vcount <= blockPos + 32) begin // Draw 32x32 block
            if (hcount >= halfScreenHorz - 16 && hcount <= (halfScreenHorz + 16)) begin
                vgaRGB <= RED;
            end                
        end
        else begin
            vgaRGB <= BLUE; // Uncovered block area with blue
        end
    end
    else if (sw == 2'b00) begin // Switch 1 and 0 off
         vgaRGB = YELLOW; // Yellow screen
    end
    else if (sw == 2'b01) begin // Switch 1 off, switch 0 on
        if (hcount[4] == 1) begin // Alternating vertical red and white stripes, 16 bits wide
            vgaRGB = RED;
        end
        else begin
            vgaRGB = WHITE;
        end
    end
    else if (sw == 2'b10) begin // Switch 1 on, switch 0 off
         if (vcount <= 128) begin // Display a 128x128 pixel green block in top right corner
             if (hcount >= (screenHorz - 128)) begin
                 vgaRGB = GREEN;
             end
             else begin
                 vgaRGB = BLACK; // Black background
             end
         end
    end
    else if (sw == 2'b11) begin // Switch 1 on, switch 0 on
        if (vcount <= (screenVert - 32)) begin // Display a horizontal blue stripe 32-pixels wide on bottom of screen
            vgaRGB = BLACK; // Black background
        end
        else begin
            vgaRGB = BLUE;
        end
    end                        
end 

endmodule
