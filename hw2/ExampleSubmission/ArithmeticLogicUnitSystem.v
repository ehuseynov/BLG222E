`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Istanbul Technical University
// Engineer: Emil Huseynov, Nahid Aliyev
// 
// Create Date: 27/03/2024 
// Design Name: 
// Module Name: ALU_System
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


// Part 4: implement the organization 
module ArithmeticLogicUnitSystem (RF_OutASel, ALU_WF ,RF_OutBSel, RF_FunSel, RF_RegSel, RF_ScrSel, ALU_FunSel, ARF_OutCSel, ARF_OutDSel, ARF_FunSel, ARF_RegSel, IR_LH, IR_Write, Mem_WR, Mem_CS, MuxASel, MuxBSel, MuxCSel, Clock);

    input wire [2:0] RF_OutASel; 
    input wire [2:0] RF_OutBSel; 
    input wire [2:0] RF_FunSel;
    input wire [3:0] RF_RegSel;
    input wire [3:0] RF_ScrSel;

    input wire [4:0] ALU_FunSel;
    input wire ALU_WF;

    input wire [1:0] ARF_OutCSel; 
    input wire [1:0] ARF_OutDSel; 
    input wire [2:0] ARF_FunSel;
    input wire [2:0] ARF_RegSel;

    input wire IR_LH;
    input wire IR_Write;

    input wire Mem_WR;
    input wire Mem_CS;

    input wire [1:0] MuxASel;
    input wire [1:0] MuxBSel;
    input wire MuxCSel;

    input wire Clock;

    /////////////////////

    wire [7:0] MemOut; //memory_out

    reg [15:0] MuxBOut; 
    reg [15:0] MuxAOut;
    reg [7:0] MuxCOut;

    wire [15:0] OutC, Address; //ARF_OutC, ARF_OutD
    wire [15:0] OutA, OutB; //rf_outA, rf_outB

    wire [15:0] IROut; //ir_out

    wire [15:0] ALUOut;  //alu_out
    wire [3:0] ALUOutFlag; //alu_out_flag
    
    //////////////////////////
    
    Memory MEM(.Address(Address), .Data(ALUOut), .WR(Mem_WR), .CS(Mem_CS), .Clock(Clock), .MemOut(MemOut));
    
    AddressRegisterFile ARF(.I(MuxBOut), .Clock(Clock), .OutCSel(ARF_OutCSel), .OutDSel(ARF_OutDSel),
    .FunSel(ARF_FunSel), .RegSel(ARF_RegSel), .OutC(OutC), .OutD(Address));

    RegisterFile RF(.I(MuxAOut), .Clock(Clock), .OutASel(RF_OutASel), .OutBSel(RF_OutBSel),
    .FunSel(RF_FunSel), .RegSel(RF_RegSel), .ScrSel(RF_ScrSel), .OutA(OutA), .OutB(OutB));
    
    InstructionRegister IR(.I(MemOut), .LH(IR_LH), .IROut(IROut), .Write(IR_Write), .Clock(Clock));

    ArithmeticLogicUnit ALU(.A(OutA), .WF(ALU_WF) , .B(OutB), .FunSel(ALU_FunSel), .ALUOut(ALUOut), .FlagsOut(ALUOutFlag), .Clock(Clock));
    

    always@(*) begin
        case(MuxASel)
        2'b00: MuxAOut <= ALU.ALUOut; 
        2'b01: MuxAOut <= ARF.OutC;
        2'b10: MuxAOut <= MEM.MemOut;
        2'b11: MuxAOut <= IR.IROut[7:0]; 
        default: MuxAOut <= 7'bZ;
        endcase
        case(MuxBSel)
        2'b00: MuxBOut <= ALU.ALUOut;
        2'b01: MuxBOut <= ARF.OutC; 
        2'b10: MuxBOut <= MEM.MemOut; 
        2'b11: MuxBOut <= IR.IROut[7:0];
        default: MuxBOut <= 7'bZ;
        endcase
        case(MuxCSel)
        0: MuxCOut <= ALU.ALUOut[7:0];
        1: MuxCOut <= ALU.ALUOut[15:8];
        default: MuxCOut <= 7'bZ;
        endcase
    end
endmodule