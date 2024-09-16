`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Istanbul Technical University
// Engineer: Emil Huseynov, Nahid Aliyev
// 
// Create Date: 27/03/2024 
// Design Name: 
// Module Name: RegisterFile
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

// Part 2b: 4 8-bit general purpose and 4 8-bit temporary registers
module RegisterFile(I, OutASel, OutBSel, FunSel, RegSel, ScrSel, Clock, OutA, OutB);
    input wire [15:0] I;		// Input bus
    input wire Clock;
    input wire [2:0] OutASel;	// Output select signals
    input wire [2:0] OutBSel;	// Output select signals
    input wire [2:0] FunSel;	// Function select signal
    input wire [3:0] RegSel;	// Register select signals
    input wire [3:0] ScrSel;	// Register select signals

    output reg [15:0] OutA; 	// Output buses
    output reg [15:0] OutB;		// Output buses
    
    wire [15:0] r1, r2, r3, r4;	// Register declarations
    wire [15:0] s1, s2, s3, s4;	// Register declarations
    
    
    Register R1(.I(I), .E(~RegSel[3]), .FunSel(FunSel), .Q(r1), .Clock(Clock));
    Register R2(.I(I), .E(~RegSel[2]), .FunSel(FunSel), .Q(r2), .Clock(Clock));
    Register R3(.I(I), .E(~RegSel[1]), .FunSel(FunSel), .Q(r3), .Clock(Clock));
    Register R4(.I(I), .E(~RegSel[0]), .FunSel(FunSel), .Q(r4), .Clock(Clock));  

    Register S1(.I(I), .E(~ScrSel[3]), .FunSel(FunSel), .Q(s1), .Clock(Clock));
    Register S2(.I(I), .E(~ScrSel[2]), .FunSel(FunSel), .Q(s2), .Clock(Clock));
    Register S3(.I(I), .E(~ScrSel[1]), .FunSel(FunSel), .Q(s3), .Clock(Clock));
    Register S4(.I(I), .E(~ScrSel[0]), .FunSel(FunSel), .Q(s4), .Clock(Clock));  


always @(*) begin
    case (OutASel)
        3'b000: OutA = r1;
        3'b001: OutA = r2;
        3'b010: OutA = r3;
        3'b011: OutA = r4;
        3'b100: OutA = s1;
        3'b101: OutA = s2;
        3'b110: OutA = s3;
        3'b111: OutA = s4;
        default: OutA = 16'b0; // Default case for safety
    endcase

    case (OutBSel)
        3'b000: OutB = R1.Q;
        3'b001: OutB = r2;
        3'b010: OutB = r3;
        3'b011: OutB = r4;
        3'b100: OutB = s1;
        3'b101: OutB = s2;
        3'b110: OutB = s3;
        3'b111: OutB = s4;
        default: OutB = 16'b0; // Default case for safety
    endcase
end
endmodule











