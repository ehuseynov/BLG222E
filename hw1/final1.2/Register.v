`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Istanbul Technical University
// Engineer: Emil Huseynov, Nahid Aliyev
// 
// Create Date: 27/03/2024 
// Design Name: 
// Module Name: register_16bit
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

// Part 1: Design a 16-bit register 
module Register(I, E, FunSel, Clock, Q);
    input wire [15:0] I;
    input wire E;
    input wire [2:0] FunSel;
    input wire Clock;
    output reg [15:0] Q;
    
    
    always @(posedge Clock) begin
        if (E) begin
            case(FunSel)
                3'b000: Q <= Q-1;       //Decrement
                3'b001: Q <= Q+1;       //Increment
                3'b010: Q <= I;         //Load
                3'b011: Q <= 0;         //Clear
                3'b100: begin                      // Write Low, Clear High
                        Q[15:8] <= 8'b0;
                        Q[7:0] <= I[7:0];
                        end
                3'b101: Q[7:0] <= I[7:0];          // Only Write Low
                3'b110: Q[15:8] <= I[15:8];        // Only Write High
                3'b111: begin                      // Sign Extend Low and Write Low
                        Q[15:8] <= {8{I[7]}};
                        Q[7:0] <= I[7:0];
                        end
                default: Q <= 0;
            endcase
        end
    end
endmodule



















