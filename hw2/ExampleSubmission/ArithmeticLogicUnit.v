`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Istanbul Technical University
// Engineer: Emil Huseynov, Nahid Aliyev
// 
// Create Date: 27/03/2024 
// Design Name: 
// Module Name: ArithmeticLogicUnit
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


//part 3 ALU
module ArithmeticLogicUnit (A, B, FunSel, ALUOut,  FlagsOut, WF, Clock);
    input wire [15:0] A, B;
    input wire [4:0] FunSel;
    input wire WF;
    input wire Clock;
    output wire [15:0] ALUOut;
    output reg [3:0] FlagsOut; //zero, carry, negative, and overflow
    reg [3:0] tempFlagsOut; 
    reg [16:0] temp;
    assign ALUOut = temp;
    always@(*) begin 
    tempFlagsOut=FlagsOut;   
        case(FunSel)
            5'b00000: begin
            temp[7:0] = A;
            if (WF == 1) begin
                tempFlagsOut[3] = (temp[7:0] == 0);
                tempFlagsOut[1] = (temp[7] == 1);
            end
            end
            5'b00001: begin
            temp[7:0] = B;
            if (WF == 1) begin
                tempFlagsOut[3] = (temp[7:0] == 0);
                tempFlagsOut[1] = (temp[7] == 1);
            end
            end
            5'b00010: begin
            temp[7:0] = ~A;
            if (WF == 1) begin
                tempFlagsOut[3] = (temp[7:0] == 0);
                tempFlagsOut[1] = (temp[7] == 1);
            end
            end
            5'b00011: begin
            temp[7:0] = ~B;
            if (WF == 1) begin
                tempFlagsOut[3] = (temp[7:0] == 0);
                tempFlagsOut[1] = (temp[7] == 1);
            end
            end        
            5'b00100: begin
            temp[7:0] = A + B; //ADD
            if (WF == 1) begin
                tempFlagsOut[3] = (temp[7:0] == 0);
                tempFlagsOut[2] = (temp[7] == 1);
                tempFlagsOut[1] = (temp[7] == 1);
                tempFlagsOut[0] = (A[7] == B[7] && A[7] != temp[7]);
            end
            end    
            5'b00101: begin
            temp[7:0] = A + B + tempFlagsOut[1]; //add with carry
            if (WF == 1) begin
                tempFlagsOut[3] = (temp[7:0] == 0);
                tempFlagsOut[2] = (temp[8] == 1);
                tempFlagsOut[1] = (temp[7] == 1);
                tempFlagsOut[0] = (A[7] == B[7] && A[7] != temp[7]);
            end
            end  
            5'b00110: begin
            temp[7:0] = A - B; //SUB
            if (WF == 1) begin
                tempFlagsOut[3] = (temp[7:0] == 0);
                tempFlagsOut[2] = (temp[7] == 1);
                tempFlagsOut[1] = (temp[7] == 1);
                tempFlagsOut[0] = (A[7] == B[7] && A[7] != temp[7]);
            end
            end  
            5'b00111: begin
            temp[7:0] = A & B; //AND
            if (WF == 1) begin
                tempFlagsOut[3] = (temp[7:0] == 0);
                tempFlagsOut[1] = (temp[7] == 1);
            end
            end  
            5'b01000: begin
            temp[7:0] = A | B; //OR
            if (WF == 1) begin
                tempFlagsOut[3] = (temp[7:0] == 0);
                tempFlagsOut[1] = (temp[7] == 1);
            end
            end
            5'b01001: begin
            temp[7:0] = A ^ B; //XOR
            if (WF == 1) begin
                tempFlagsOut[3] = (temp[7:0] == 0);
                tempFlagsOut[1] = (temp[7] == 1);
            end
            end
            5'b01010: begin
            temp[7:0] = ~(A & B); //NAND
            if (WF == 1) begin
                tempFlagsOut[3] = (temp[7:0] == 0);
                tempFlagsOut[1] = (temp[7] == 1);
            end
            end
            5'b01011: begin
                temp[7:0] = A << 1; //logical shift left
                if (WF == 1) begin
                    tempFlagsOut[3] = (temp[7:0] == 0);
                    tempFlagsOut[2] = (temp[0] == 1);
                    tempFlagsOut[1] = (temp[7] == 1);
                end
            end
            5'b01100: begin
                temp[7:0] = A >> 1; //logical shift right
                if (WF == 1) begin
                    tempFlagsOut[3] = (temp[7:0] == 0);
                    tempFlagsOut[2] = (temp[7] == 1);
                    tempFlagsOut[1] = (temp[7] == 1);
                end
            end
            5'b01101: begin
                temp[7:0] = A >>> 1; //arithmetical shift right
                if (WF == 1) begin
                    tempFlagsOut[3] = (temp[7:0] == 0);
                    tempFlagsOut[2] = (temp[0] == 1);
                end
            end
            5'b01110: begin
                temp[7:0] = (A << 1) | (A >> 7); //circular rotate left
                if (WF == 1) begin
                    tempFlagsOut[3] = (temp[7:0] == 0);
                    tempFlagsOut[2] = (temp[0] == 1);
                    tempFlagsOut[1] = (temp[7] == 1);
                end 
            end
            5'b01111: begin
                temp[7:0] = (A >> 1) | (A << 7); //circular rotate right
                if (WF == 1) begin
                    tempFlagsOut[3] = (temp[7:0] == 0);
                    tempFlagsOut[2] = (temp[7] == 1);
                    tempFlagsOut[1] = (temp[7] == 1);
                end 
            end


            5'b10000: begin
            temp[15:0] = A;
            if (WF == 1) begin
                tempFlagsOut[3] = (temp[15:0] == 0);
                tempFlagsOut[1] = (temp[15] == 1);
            end
            end
            5'b10001: begin
            temp[15:0] = B;
            if (WF == 1) begin
                tempFlagsOut[3] = (temp[15:0] == 0);
                tempFlagsOut[1] = (temp[15] == 1);
            end
            end
            5'b10010: begin
            temp[15:0] = ~A;
            if (WF == 1) begin
                tempFlagsOut[3] = (temp[15:0] == 0);
                tempFlagsOut[1] = (temp[15] == 1);
            end
            end
            5'b10011: begin
            temp[15:0] = ~B;
            if (WF == 1) begin
                tempFlagsOut[3] = (temp[15:0] == 0);
                tempFlagsOut[1] = (temp[15] == 1);
            end
            end        
            5'b10100: begin
            temp[16:0] = A[15:0] + B[15:0]; //ADD
            if (WF == 1) begin
                tempFlagsOut[3] = (temp[15:0] == 0);
                tempFlagsOut[2] = (temp[16] == 1);
                tempFlagsOut[1] = (temp[15] == 1);
                tempFlagsOut[0] = ((A[15] == B[15]) && (A[15] != temp[15]));
            end
            end    
            5'b10101: begin
            temp[16:0] = A[15:0] + B[15:0] + tempFlagsOut[2]; //add with carry
            if (WF == 1) begin
                tempFlagsOut[3] = (temp[15:0] == 0);
                tempFlagsOut[2] = (temp[16] == 1);
                tempFlagsOut[1] = (temp[15] == 1);
                tempFlagsOut[0] = ((A[15] == B[15]) && (A[15] != temp[15]));
            end
            end  
            5'b10110: begin
            temp[15:0] = A - B; //SUB
            if (WF == 1) begin
                tempFlagsOut[3] = (temp[15:0] == 0);
                tempFlagsOut[2] = (temp[15] == 1);
                tempFlagsOut[1] = (temp[15] == 1);
                tempFlagsOut[0] = (A[15] == B[15] && A[15] != temp[15]);
            end
            end  
            5'b10111: begin
            temp[15:0] = A & B; //AND
            if (WF == 1) begin
                tempFlagsOut[3] = (temp[15:0] == 0);
                tempFlagsOut[1] = (temp[15] == 1);
            end
            end  
            5'b11000: begin
            temp[15:0] = A | B; //OR
            if (WF == 1) begin
                tempFlagsOut[3] = (temp[15:0] == 0);
                tempFlagsOut[1] = (temp[15] == 1);
            end
            end
            5'b11001: begin
            temp[15:0] = A ^ B; //XOR
            if (WF == 1) begin
                tempFlagsOut[3] = (temp[15:0] == 0);
                tempFlagsOut[1] = (temp[15] == 1);
            end
            end
            5'b11010: begin
            temp[15:0] = ~(A & B); //NAND
            if (WF == 1) begin
                tempFlagsOut[3] = (temp[15:0] == 0);
                tempFlagsOut[1] = (temp[15] == 1);
            end
            end
            5'b11011: begin
                temp[15:0] = A << 1; //logical shift left
                if (WF == 1) begin
                    tempFlagsOut[3] = (temp[15:0] == 0);
                    tempFlagsOut[2] = (temp[0] == 1);
                    tempFlagsOut[1] = (temp[15] == 1);
                end
            end
            5'b11100: begin
                temp[15:0] = A >> 1; //logical shift right
                if (WF == 1) begin
                    tempFlagsOut[3] = (temp[15:0] == 0);
                    tempFlagsOut[2] = (temp[15] == 1);
                    tempFlagsOut[1] = (temp[15] == 1);
                end
            end
            5'b11101: begin
                temp[15:0] = A >>> 1; //arithmetical shift right
                if (WF == 1) begin
                    tempFlagsOut[3] = (temp[15:0] == 0);
                    tempFlagsOut[2] = (temp[0] == 1);
                end
            end
            5'b11110: begin
                temp[15:0] = (A << 1) | (A >> 15); //circular rotate left
                if (WF == 1) begin
                    tempFlagsOut[3] = (temp[15:0] == 0);
                    tempFlagsOut[2] = (temp[0] == 1);
                    tempFlagsOut[1] = (temp[15] == 1);
                end 
            end
            5'b11111: begin
                temp[15:0] = (A >> 1) | (A << 15); //circular rotate right
                if (WF == 1) begin
                    tempFlagsOut[3] = (temp[15:0] == 0);
                    tempFlagsOut[2] = (temp[15] == 1);
                    tempFlagsOut[1] = (temp[15] == 1);
                end 
            end
            default : begin
                temp[15:0] = 16'b0;
                tempFlagsOut[3:0] = 4'b0;
            end
        endcase
    end 
    assign ALUOut = temp;
    always@(posedge Clock) begin 
    FlagsOut=tempFlagsOut;
    end

        //tempFlagsOut[0] = (temp == 0);

   
endmodule
