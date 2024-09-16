`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Istanbul Technical University
// Engineer: Emil Huseynov, Nahid Aliyev
// 
// Create Date: 27/03/2024 
// Design Name: 
// Module Name: instructor_register
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// Part 2a: Design a 16-bit IR register
module InstructionRegister( I, Write, LH, Clock, IROut);
    input wire [7:0] I;          // 8-bit input
    input wire LH;              // Control signal to load LSB or MSB
    input wire Write;            // Write enable signal
    input wire Clock;

    output reg [15:0] IROut;
    
    
    
    always @(posedge Clock) begin
        if (Write) begin
            if (LH) begin      // Load I into MSB of IR, retain LSB
                IROut[15:8] <= I;
            end else begin      // Load I into LSB of IR, retain MSB
                IROut[7:0] <= I;
            end
        end
    // If Write is not enabled, retain the current value of IR (do nothing)
    end
 
endmodule









