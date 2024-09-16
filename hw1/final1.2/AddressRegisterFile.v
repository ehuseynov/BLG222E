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


module AddressRegisterFile(I, Clock, OutCSel, OutDSel, FunSel, RegSel, OutC, OutD); //clock deleted
    input wire [15:0] I;
    input wire Clock;
    input wire [1:0] OutCSel;
    input wire [1:0] OutDSel;
    input wire [2:0] FunSel;
    input wire [2:0] RegSel;
    
    output reg [15:0] OutC;
    output reg [15:0] OutD;
    
    wire [15:0] pc, ar, sp;
    
    Register PC(.I(I), .E(~RegSel[2]), .FunSel(FunSel), .Q(pc), .Clock(Clock)); 
    Register AR(.I(I), .E(~RegSel[1]), .FunSel(FunSel), .Q(ar), .Clock(Clock));
    Register SP(.I(I), .E(~RegSel[0]), .FunSel(FunSel), .Q(sp), .Clock(Clock));
    
    always@(*) begin
       // #0.01;
        case(OutCSel)
            2'b00: OutC = pc;
            2'b01: OutC = pc;
            2'b10: OutC = ar;
            2'b11: OutC = sp;
        endcase
        case(OutDSel)
            2'b00: OutD = pc;
            2'b01: OutD = pc;
            2'b10: OutD = ar;
            2'b11: OutD = sp;
        endcase
    end
endmodule