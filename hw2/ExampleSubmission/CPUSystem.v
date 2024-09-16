`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Istanbul Technical University
// Engineer: Emil Huseynov, Nahid Aliyev
// 
// Create Date: 10/04/2024 
// Design Name: 
// Module Name: CPUSystem
// Project Name: Project 2
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

module CPUSystem(Clock, Reset, T);
    input wire Clock;
    input wire Reset;
    

    ////////////deyisdi
    reg [2:0] RF_OutASel; 
    reg [2:0] RF_OutBSel; 
    reg [2:0] RF_FunSel;
    reg [3:0] RF_RegSel;
    reg[3:0] RF_ScrSel;

    reg [4:0] ALU_FunSel;
    reg ALU_WF;
    
    reg [1:0] ARF_OutCSel; 
    reg [1:0] ARF_OutDSel; 
    reg [2:0] ARF_FunSel;
    reg [2:0] ARF_RegSel;

    reg IR_LH;
    reg IR_Write;

    reg Mem_WR;
    reg Mem_CS;

    reg [1:0] MuxASel;
    reg [1:0] MuxBSel;
    reg MuxCSel;
    ////////////

    
    output reg [7:0] T;

    ////////////////deyisdi
    wire [7:0] MemOut; //memory_out

    reg [15:0] MuxBOut; 
    reg [15:0] MuxAOut;
    reg [7:0] MuxCOut;

    wire [15:0] OutC, Address; //ARF_OutC, ARF_OutD
    wire [15:0] OutA, OutB; //rf_outA, rf_outB

    wire [15:0] IROut; //ir_out

    wire [15:0] ALUOut;  //alu_out
    wire [3:0] ALUOutFlag; //alu_out_flag
    
    
    ArithmeticLogicUnitSystem _ALUSystem(RF_OutASel, ALU_WF ,RF_OutBSel, RF_FunSel, RF_RegSel, RF_ScrSel, ALU_FunSel, ARF_OutCSel, ARF_OutDSel, ARF_FunSel, ARF_RegSel, IR_LH, IR_Write, Mem_WR, Mem_CS, MuxASel, MuxBSel, MuxCSel, Clock);
    //////////////////////////////

 always @ (negedge Reset)
    begin
        //reset everything
            RF_FunSel <= 3'b011;
            RF_RegSel <= 4'b0000;
            RF_ScrSel <= 4'b0000;
  
            ARF_FunSel <= 3'b011; //clear
            ARF_RegSel <= 3'b000; //all enable
            ARF_OutDSel <= 2'b00; //send PC to MEM

            ALU_WF <= 0;

            T <= 8'b00000000;// time=0 
        end
    
    
    always @ (posedge Clock)
    begin

        if(T == 8'b00000000)
        begin //load LSB of IR
            Mem_CS <= 0;  //chip is enable
            Mem_WR <= 0;  //read
            
            IR_Write <= 1'b1; //write enable
            IR_LH <= 0;  //IR(7-0)
            
            ARF_RegSel <= 3'b011; //PC enable
            ARF_FunSel <= 3'b001; //increment
            ARF_OutDSel <= 2'b00; //PC send

            



            MuxASel <= 2'b11; //select IR
            RF_ScrSel <=4'b0111; //select s1
            RF_RegSel <= 4'b1111; //disable all
            RF_FunSel <= 3'b100; //Write low
            ALU_FunSel <= 5'b00000; //A
            RF_OutASel <=3'b100;//s1 send
            
            T <= T + 1;  //increment time      
        end


        else if(T == 8'b00000001)
        begin           
            Mem_CS <= 0;  //chip is enable
            Mem_WR <= 0;  //read
             
            IR_Write <= 1'b1;
            IR_LH <= 1; //load MSB 
         
            ARF_RegSel <= 3'b011; //PC enable
            ARF_FunSel <= 3'b001; //increment
            ARF_OutDSel <= 2'b00; //PC send         
            
            T <= T + 1; //increment time 
        end

        else if(T == 8'b00000010)
        begin           
               IR_Write <= 1'b0;  
            ARF_RegSel <= 3'b111; //PC disable
            T <= T + 1; //increment time 
        end
////////////////////////////////////////////////////////////////////////////
/////////////////////////////operation//////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
        
        else if(T == 8'b00000011)
        begin
            

            case(_ALUSystem.IROut[15:10]) 

////////////////////////////////////////////////
                6'b000000: //BRA
                begin 
                    IR_Write <= 0; 
                    Mem_CS <= 0;  //chip is enable
                    Mem_WR <= 0;  //read
                               
                    MuxASel <= 2'b01;     // Select OutC as input B  
                    
                    RF_ScrSel <= 4'b1011; //Enable S2
                    RF_FunSel <=3'b010;   //Write low S2
                    ARF_OutCSel <=2'b00;  //Send PC to OutC 
                    
                    T <= T + 1;  //increment time
                end

///////////////////////////////////////////////
                6'b000001: //BNE
                begin 
                    case(_ALUSystem.ALU.FlagsOut[3])
                    1'b1:
                    begin
                     IR_Write <= 0;
                        T <= 8'b00000101;  //increment time
                    end

                    1'b0:
                    begin
                        IR_Write <= 0; 
                        Mem_CS <= 0;  //chip is enable
                        Mem_WR <= 0;  //read
                                
                        MuxASel <= 2'b01;     // Select OutC as input B  
                        
                        RF_ScrSel <= 4'b1011; //Enable S2
                        RF_FunSel <=3'b010;   //Write low S2
                        ARF_OutCSel <=2'b00;  //Send PC to OutC 
                        
                        T <= T + 1;  //increment time
                    end
                    endcase
                end

///////////////////////////////////////////////
                6'b000010: //BEQ
                begin 
                    case(_ALUSystem.ALU.FlagsOut[3])
                    1'b0:
                    begin
                     IR_Write <= 0;
                        T <= 8'b00000101;  //increment time
                    end

                    1'b1:
                    begin
                        IR_Write <= 0; 
                        Mem_CS <= 0;  //chip is enable
                        Mem_WR <= 0;  //read
                                
                        MuxASel <= 2'b01;     // Select OutC as input B  
                        
                        RF_ScrSel <= 4'b1011; //Enable S2
                        RF_FunSel <=3'b010;   //Write low S2
                        ARF_OutCSel <=2'b00;  //Send PC to OutC 
                        
                        T <= T + 1;  //increment time
                    end
                    endcase  
                end                

///////////////////////////////////////////////
                6'b000011: //POP
                begin 
                    ARF_RegSel <= 3'b110; //SP enable
                    ARF_FunSel <= 3'b001; //Increment
                    Mem_CS <= 0; //Memory chip enable
                    Mem_WR <= 0; //Memory 
                    ARF_OutDSel <= 2'b11; //SP sent to memory as adress
                    T <= T + 1;  //increment time
                end 

///////////////////////////////////////////////
                6'b000100: //PUSH
                begin 
                    case(_ALUSystem.IROut[9:8])
                        2'b00: RF_OutASel <= 3'b000; //R1
                        2'b01: RF_OutASel <= 3'b001; //R2
                        2'b10: RF_OutASel <= 3'b010; //R3
                        2'b11: RF_OutASel <= 3'b011; //R4
                    endcase //OutA-ni teyin ele

                    RF_ScrSel <= 4'b1111; //all is disabled

                    ALU_FunSel <= 5'b00000; //send A   
                    MuxCSel <= 0; //output to RF
                    
                    Mem_WR <= 1; //Memory write
                    Mem_CS <= 0; //Memory chip enable
                    
                    ARF_OutDSel <= 2'b11; //SP send


                    T <= T + 1;  //increment time
                end 

/////////////////////////////////////////////////

                6'b000101: //INC
                begin 
                    case(_ALUSystem.IROut[5:3])//SReg1
                        3'b000:  //PC is source
                        begin
                            case(_ALUSystem.IROut[8:6])
                            3'b000: //Dreg //pc
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b001; //increment
                                ARF_OutCSel <= 2'b00; //PC send
                            end
                            3'b001: //Dreg //pc
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b001; //increment
                                ARF_OutCSel <= 2'b00; //PC send
                            end
                            3'b010: //Dreg //SP
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b001; //increment
                                ARF_OutCSel <= 2'b00; //PC send
                            end
                            3'b011: //Dreg //Ar
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b001; //increment
                                ARF_OutCSel <= 2'b00; //PC send
                            end
                            3'b100: //Dreg //R1
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b001; //increment
                                ARF_OutCSel <= 2'b00; //PC send
                            end
                            3'b101: //Dreg //R2
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b001; //increment
                                ARF_OutCSel <= 2'b00; //PC send
                            end
                            3'b110: //Dreg //R3
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b001; //increment
                                ARF_OutCSel <= 2'b00; //PC send
                            end
                            3'b111: //Dreg //R4
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b001; //increment
                                ARF_OutCSel <= 2'b00; //PC send
                            end
                        endcase
                        end

                        3'b001:  //PC is source
                        begin
                            case(_ALUSystem.IROut[8:6])
                            3'b000: //Dreg //pc
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b001; //increment
                                ARF_OutCSel <= 2'b00; //PC send
                            end
                            3'b001: //Dreg //pc
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b001; //increment
                                ARF_OutCSel <= 2'b00; //PC send
                            end
                            3'b010: //Dreg //SP
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b001; //increment
                                ARF_OutCSel <= 2'b00; //PC send
                            end
                            3'b011: //Dreg //Ar
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b001; //increment
                                ARF_OutCSel <= 2'b00; //PC send
                            end
                            3'b100: //Dreg //R1
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b001; //increment
                                ARF_OutCSel <= 2'b00; //PC send
                            end
                            3'b101: //Dreg //R2
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b001; //increment
                                ARF_OutCSel <= 2'b00; //PC send0;
                            end
                            3'b110: //Dreg //R3
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b001; //increment
                                ARF_OutCSel <= 2'b00; //PC send
                            end
                            3'b111: //Dreg //R4
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b001; //increment
                                ARF_OutCSel <= 2'b00; //PC send
                            end
                        endcase
                        end


                        3'b010:  //SP is source
                        begin
                            case(_ALUSystem.IROut[8:6])
                            3'b000: //Dreg //pc
                            begin
                                ARF_RegSel <= 3'b110; //SP enable
                                ARF_FunSel <= 3'b001; //increment
                                ARF_OutCSel <= 2'b11; //SP send
                            end
                            3'b001: //Dreg //pc
                            begin
                                ARF_RegSel <= 3'b110; //SP enable
                                ARF_FunSel <= 3'b001; //increment
                                ARF_OutCSel <= 2'b11; //SP send
                            end
                            3'b010: //Dreg //SP
                            begin
                                ARF_RegSel <= 3'b110; //SP enable
                                ARF_FunSel <= 3'b001; //increment
                                ARF_OutCSel <= 2'b11; //SP send
                            end
                            3'b011: //Dreg //Ar
                            begin
                                ARF_RegSel <= 3'b110; //SP enable
                                ARF_FunSel <= 3'b001; //increment
                                ARF_OutCSel <= 2'b11; //SP send
                            end
                            3'b100: //Dreg //R1
                            begin
                                ARF_RegSel <= 3'b110; //SP enable
                                ARF_FunSel <= 3'b001; //increment
                                ARF_OutCSel <= 2'b11; //SP send
                            end
                            3'b101: //Dreg //R2
                            begin
                                ARF_RegSel <= 3'b110; //SP enable
                                ARF_FunSel <= 3'b001; //increment
                                ARF_OutCSel <= 2'b11; //SP send
                            end
                            3'b110: //Dreg //R3
                            begin
                                ARF_RegSel <= 3'b110; //SP enable
                                ARF_FunSel <= 3'b001; //increment
                                ARF_OutCSel <= 2'b11; //SP send
                            end
                            3'b111: //Dreg //R4
                            begin
                                ARF_RegSel <= 3'b110; //SP enable
                                ARF_FunSel <= 3'b001; //increment
                                ARF_OutCSel <= 2'b11; //SP send
                            end
                        endcase
                        end

                    

                        3'b011:  //AR is source
                        begin
                            case(_ALUSystem.IROut[8:6])
                            3'b000: //Dreg //pc
                            begin
                                ARF_RegSel <= 3'b101; //AR enable
                                ARF_FunSel <= 3'b001; //increment
                                ARF_OutCSel <= 2'b10; //AR send
                            end
                            3'b001: //Dreg //pc
                            begin
                                ARF_RegSel <= 3'b101; //AR enable
                                ARF_FunSel <= 3'b001; //increment
                                ARF_OutCSel <= 2'b10; //AR send
                            end
                            3'b010: //Dreg //SP
                            begin
                                ARF_RegSel <= 3'b101; //AR enable
                                ARF_FunSel <= 3'b001; //increment
                                ARF_OutCSel <= 2'b10; //AR send
                            end
                            3'b011: //Dreg //Ar
                            begin
                                ARF_RegSel <= 3'b101; //AR enable
                                ARF_FunSel <= 3'b001; //increment
                                ARF_OutCSel <= 2'b10; //AR send
                            end
                            3'b100: //Dreg //R1
                            begin
                                ARF_RegSel <= 3'b101; //AR enable
                                ARF_FunSel <= 3'b001; //increment
                                ARF_OutCSel <= 2'b10; //AR send
                            end
                            3'b101: //Dreg //R2
                            begin
                                ARF_RegSel <= 3'b101; //AR enable
                                ARF_FunSel <= 3'b001; //increment
                                ARF_OutCSel <= 2'b10; //AR send
                            end
                            3'b110: //Dreg //R3
                            begin
                                ARF_RegSel <= 3'b101; //AR enable
                                ARF_FunSel <= 3'b001; //increment
                                ARF_OutCSel <= 2'b10; //AR send
                            end
                            3'b111: //Dreg //R4
                            begin
                                ARF_RegSel <= 3'b101; //AR enable
                                ARF_FunSel <= 3'b001; //increment
                                ARF_OutCSel <= 2'b10; //AR send
                            end
                        endcase
                        end


                        3'b100:  //R! is source
                        begin
                            case(_ALUSystem.IROut[8:6])
                            3'b000: //Dreg //pc
                            begin
                                RF_RegSel <= 4'b0111; //Only R1
                                RF_FunSel <= 3'b001; //increment
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b000; //R1 to ALU
                            end
                            3'b001: //Dreg //pc
                            begin
                                RF_RegSel <= 4'b0111; //Only R1
                                RF_FunSel <= 3'b001; //increment
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b000; //R1 to ALU
                            end
                            3'b010: //Dreg //SP
                            begin
                                RF_RegSel <= 4'b0111; //Only R1
                                RF_FunSel <= 3'b001; //increment
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b000; //R1 to ALU
                            end
                            3'b011: //Dreg //Ar
                            begin
                                RF_RegSel <= 4'b0111; //Only R1
                                RF_FunSel <= 3'b001; //increment
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b000; //R1 to ALU
                            end
                            3'b100: //Dreg //R1
                            begin
                                RF_RegSel <= 4'b0111; //Only R1
                                RF_FunSel <= 3'b001; //increment
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b000; //R1 to ALU
                            end
                            3'b101: //Dreg //R2
                            begin
                                RF_RegSel <= 4'b0111; //Only R1
                                RF_FunSel <= 3'b001; //increment
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel<= 3'b000; //R1 to ALU
                            end
                            3'b110: //Dreg //R3
                            begin
                                RF_RegSel <= 4'b0111; //Only R1
                                RF_FunSel <= 3'b001; //increment
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b000; //R1 to ALU
                            end
                            3'b111: //Dreg //R4
                            begin
                                RF_RegSel <= 4'b0111; //Only R1
                                RF_FunSel <= 3'b001; //increment
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b000; //R1 to ALU
                            end
                        endcase
                        end


                        3'b101:  //R2 is source
                        begin
                            case(_ALUSystem.IROut[8:6])
                            3'b000: //Dreg //pc
                            begin
                                RF_RegSel <= 4'b1011; //Only R2
                                RF_FunSel <= 3'b001; //increment
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b001; //R2 to ALU
                            end
                            3'b001: //Dreg //pc
                            begin
                                RF_RegSel <= 4'b1011; //Only R2
                                RF_FunSel <= 3'b001; //increment
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b001; //R2 to ALU
                            end
                            3'b010: //Dreg //SP
                            begin
                                RF_RegSel <= 4'b1011; //Only R2
                                RF_FunSel <= 3'b001; //increment
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b001; //R2 to ALU
                            end
                            3'b011: //Dreg //Ar
                            begin
                                RF_RegSel <= 4'b1011; //Only R2
                                RF_FunSel <= 3'b001; //increment
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b001; //R2 to ALU
                            end
                            3'b100: //Dreg //R1
                            begin
                                RF_RegSel <= 4'b1011; //Only R2
                                RF_FunSel <= 3'b001; //increment
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b001; //R2 to ALU
                            end
                            3'b101: //Dreg //R2
                            begin
                                RF_RegSel <= 4'b1011; //Only R2
                                RF_FunSel <= 3'b001; //increment
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b001; //R2 to ALU
                            end
                            3'b110: //Dreg //R3
                            begin
                                RF_RegSel <= 4'b1011; //Only R2
                                RF_FunSel <= 3'b001; //increment
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b001; //R2 to ALU
                            end
                            3'b111: //Dreg //R4
                            begin
                                RF_RegSel <= 4'b1011; //Only R2
                                RF_FunSel <= 3'b001; //increment
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b001; //R2 to ALU
                            end
                        endcase
                        end

                        3'b110:  //R3 is source
                        begin
                            case(_ALUSystem.IROut[8:6])
                            3'b000: //Dreg //pc
                            begin
                                RF_RegSel <= 4'b1101; //Only R3
                                RF_FunSel <= 3'b001; //increment
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b010; //R3 to ALU
                            end
                            3'b001: //Dreg //pc
                            begin
                                RF_RegSel <= 4'b1101; //Only R3
                                RF_FunSel <= 3'b001; //increment
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b010; //R3 to ALU
                            end
                            3'b010: //Dreg //SP
                            begin
                                RF_RegSel <= 4'b1101; //Only R3
                                RF_FunSel <= 3'b001; //increment
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b010; //R3 to ALU
                            end
                            3'b011: //Dreg //Ar
                            begin
                                RF_RegSel <= 4'b1101; //Only R3
                                RF_FunSel <= 3'b001; //increment
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b010; //R3 to ALU
                            end
                            3'b100: //Dreg //R1
                            begin
                                RF_RegSel <= 4'b1101; //Only R3
                                RF_FunSel <= 3'b001; //increment
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b010; //R3 to ALU
                            end
                            3'b101: //Dreg //R2
                            begin
                                RF_RegSel <= 4'b1101; //Only R3
                                RF_FunSel <= 3'b001; //increment
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b010; //R3 to ALU
                            end
                            3'b110: //Dreg //R3
                            begin
                                RF_RegSel <= 4'b1101; //Only R3
                                RF_FunSel <= 3'b001; //increment
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b010; //R3 to ALU
                            end
                            3'b111: //Dreg //R4
                            begin
                                RF_RegSel <= 4'b1101; //Only R3
                                RF_FunSel <= 3'b001; //increment
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b010; //R3 to ALU
                            end
                        endcase
                        end

                        3'b111:  //R4 is source
                        begin
                            case(_ALUSystem.IROut[8:6])
                            3'b000: //Dreg //pc
                            begin
                                RF_RegSel <= 4'b1110; //Only R4
                                RF_FunSel <= 3'b001; //increment
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b011; //R4 to ALU
                            end
                            3'b001: //Dreg //pc
                            begin
                                RF_RegSel <= 4'b1110; //Only R4
                                RF_FunSel <= 3'b001; //increment
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b011; //R4 to ALU
                            end
                            3'b010: //Dreg //SP
                            begin
                                RF_RegSel <= 4'b1110; //Only R4
                                RF_FunSel <= 3'b001; //increment
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b011; //R4 to ALU
                            end
                            3'b011: //Dreg //Ar
                            begin
                                RF_RegSel <= 4'b1110; //Only R4
                                RF_FunSel <= 3'b001; //increment
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b011; //R4 to ALU
                            end
                            3'b100: //Dreg //R1
                            begin
                                RF_RegSel <= 4'b1110; //Only R4
                                RF_FunSel <= 3'b001; //increment
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b011; //R4 to ALU
                            end
                            3'b101: //Dreg //R2
                            begin
                                RF_RegSel <= 4'b1110; //Only R4
                                RF_FunSel <= 3'b001; //increment
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b011; //R4 to ALU
                            end
                            3'b110: //Dreg //R3
                            begin
                                RF_RegSel <= 4'b1110; //Only R4
                                RF_FunSel <= 3'b001; //increment
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b011; //R4 to ALU
                            end
                            3'b111: //Dreg //R4
                            begin
                                RF_RegSel <= 4'b1110; //Only R4
                                RF_FunSel <= 3'b001; //increment
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b011; //R4 to ALU
                            end
                        endcase
                        end
                    endcase
                    T <= T + 1;  //increment time
                    ////////////////////////esas hisse//////////////////////////////////////
                end

////////////////////////////////////////////////////////
                6'b000110: //DEC
                begin 
                    case(_ALUSystem.IROut[5:3])//SReg1
                        3'b000:  //PC is source
                        begin
                            case(_ALUSystem.IROut[8:6])
                            3'b000: //Dreg //pc
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b000; //Decrement
                                ARF_OutCSel <= 2'b00; //PC send
                            end
                            3'b001: //Dreg //pc
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b000; //Decrement
                                ARF_OutCSel <= 2'b00; //PC send
                            end
                            3'b010: //Dreg //SP
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b000; //Decrement
                                ARF_OutCSel <= 2'b00; //PC send
                            end
                            3'b011: //Dreg //Ar
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b000; //Decrement
                                ARF_OutCSel <= 2'b00; //PC send
                            end
                            3'b100: //Dreg //R1
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b000; //Decrement
                                ARF_OutCSel <= 2'b00; //PC send
                            end
                            3'b101: //Dreg //R2
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b000; //Decrement
                                ARF_OutCSel <= 2'b00; //PC send
                            end
                            3'b110: //Dreg //R3
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b000; //Decrement
                                ARF_OutCSel <= 2'b00; //PC send
                            end
                            3'b111: //Dreg //R4
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b000; //Decrement
                                ARF_OutCSel <= 2'b00; //PC send
                            end
                        endcase
                        end

                        3'b001:  //PC is source
                        begin
                            case(_ALUSystem.IROut[8:6])
                            3'b000: //Dreg //pc
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b000; //Decrement
                                ARF_OutCSel <= 2'b00; //PC send
                            end
                            3'b001: //Dreg //pc
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b000; //Decrement
                                ARF_OutCSel <= 2'b00; //PC send
                            end
                            3'b010: //Dreg //SP
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b000; //Decrement
                                ARF_OutCSel <= 2'b00; //PC send
                            end
                            3'b011: //Dreg //Ar
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b000; //Decrement
                                ARF_OutCSel <= 2'b00; //PC send
                            end
                            3'b100: //Dreg //R1
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b000; //Decrement
                                ARF_OutCSel <= 2'b00; //PC send
                            end
                            3'b101: //Dreg //R2
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b000; //Decrement
                                ARF_OutCSel <= 2'b00; //PC send0;
                            end
                            3'b110: //Dreg //R3
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b000; //Decrement
                                ARF_OutCSel <= 2'b00; //PC send
                            end
                            3'b111: //Dreg //R4
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b000; //Decrement
                                ARF_OutCSel <= 2'b00; //PC send
                            end
                        endcase
                        end


                        3'b010:  //SP is source
                        begin
                            case(_ALUSystem.IROut[8:6])
                            3'b000: //Dreg //pc
                            begin
                                ARF_RegSel <= 3'b110; //SP enable
                                ARF_FunSel <= 3'b000; //Decrement
                                ARF_OutCSel <= 2'b11; //SP send
                            end
                            3'b001: //Dreg //pc
                            begin
                                ARF_RegSel <= 3'b110; //SP enable
                                ARF_FunSel <= 3'b000; //Decrement
                                ARF_OutCSel <= 2'b11; //SP send
                            end
                            3'b010: //Dreg //SP
                            begin
                                ARF_RegSel <= 3'b110; //SP enable
                                ARF_FunSel <= 3'b000; //Decrement
                                ARF_OutCSel <= 2'b11; //SP send
                            end
                            3'b011: //Dreg //Ar
                            begin
                                ARF_RegSel <= 3'b110; //SP enable
                                ARF_FunSel <= 3'b000; //Decrement
                                ARF_OutCSel <= 2'b11; //SP send
                            end
                            3'b100: //Dreg //R1
                            begin
                                ARF_RegSel <= 3'b110; //SP enable
                                ARF_FunSel <= 3'b000; //Decrement
                                ARF_OutCSel <= 2'b11; //SP send
                            end
                            3'b101: //Dreg //R2
                            begin
                                ARF_RegSel <= 3'b110; //SP enable
                                ARF_FunSel <= 3'b000; //Decrement
                                ARF_OutCSel <= 2'b11; //SP send
                            end
                            3'b110: //Dreg //R3
                            begin
                                ARF_RegSel <= 3'b110; //SP enable
                                ARF_FunSel <= 3'b000; //Decrement
                                ARF_OutCSel <= 2'b11; //SP send
                            end
                            3'b111: //Dreg //R4
                            begin
                                ARF_RegSel <= 3'b110; //SP enable
                                ARF_FunSel <= 3'b000; //Decrement
                                ARF_OutCSel <= 2'b11; //SP send
                            end
                        endcase
                        end

                    

                        3'b011:  //AR is source
                        begin
                            case(_ALUSystem.IROut[8:6])
                            3'b000: //Dreg //pc
                            begin
                                ARF_RegSel <= 3'b101; //AR enable
                                ARF_FunSel <= 3'b000; //Decrement
                                ARF_OutCSel <= 2'b10; //AR send
                            end
                            3'b001: //Dreg //pc
                            begin
                                ARF_RegSel <= 3'b101; //AR enable
                                ARF_FunSel <= 3'b000; //Decrement
                                ARF_OutCSel <= 2'b10; //AR send
                            end
                            3'b010: //Dreg //SP
                            begin
                                ARF_RegSel <= 3'b101; //AR enable
                                ARF_FunSel <= 3'b000; //Decrement
                                ARF_OutCSel <= 2'b10; //AR send
                            end
                            3'b011: //Dreg //Ar
                            begin
                                ARF_RegSel <= 3'b101; //AR enable
                                ARF_FunSel <= 3'b000; //Decrement
                                ARF_OutCSel <= 2'b10; //AR send
                            end
                            3'b100: //Dreg //R1
                            begin
                                ARF_RegSel <= 3'b101; //AR enable
                                ARF_FunSel <= 3'b000; //Decrement
                                ARF_OutCSel <= 2'b10; //AR send
                            end
                            3'b101: //Dreg //R2
                            begin
                                ARF_RegSel <= 3'b101; //AR enable
                                ARF_FunSel <= 3'b000; //Decrement
                                ARF_OutCSel <= 2'b10; //AR send
                            end
                            3'b110: //Dreg //R3
                            begin
                                ARF_RegSel <= 3'b101; //AR enable
                                ARF_FunSel <= 3'b000; //Decrement
                                ARF_OutCSel <= 2'b10; //AR send
                            end
                            3'b111: //Dreg //R4
                            begin
                                ARF_RegSel <= 3'b101; //AR enable
                                ARF_FunSel <= 3'b000; //Decrement
                                ARF_OutCSel <= 2'b10; //AR send
                            end
                        endcase
                        end


                        3'b100:  //R! is source
                        begin
                            case(_ALUSystem.IROut[8:6])
                            3'b000: //Dreg //pc
                            begin
                                RF_RegSel <= 4'b0111; //Only R1
                                RF_FunSel <= 3'b000; //Decrement
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b000; //R1 to ALU
                            end
                            3'b001: //Dreg //pc
                            begin
                                RF_RegSel <= 4'b0111; //Only R1
                                RF_FunSel <= 3'b000; //Decrement
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b000; //R1 to ALU
                            end
                            3'b010: //Dreg //SP
                            begin
                                RF_RegSel <= 4'b0111; //Only R1
                                RF_FunSel <= 3'b000; //Decrement
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b000; //R1 to ALU
                            end
                            3'b011: //Dreg //Ar
                            begin
                                RF_RegSel <= 4'b0111; //Only R1
                                RF_FunSel <= 3'b000; //Decrement
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b000; //R1 to ALU
                            end
                            3'b100: //Dreg //R1
                            begin
                                RF_RegSel <= 4'b0111; //Only R1
                                RF_FunSel <= 3'b000; //Decrement
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b000; //R1 to ALU
                            end
                            3'b101: //Dreg //R2
                            begin
                                RF_RegSel <= 4'b0111; //Only R1
                                RF_FunSel <= 3'b000; //Decrement
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b000; //R1 to ALU
                            end
                            3'b110: //Dreg //R3
                            begin
                                RF_RegSel <= 4'b0111; //Only R1
                                RF_FunSel <= 3'b000; //Decrement
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b000; //R1 to ALU
                            end
                            3'b111: //Dreg //R4
                            begin
                                RF_RegSel <= 4'b0111; //Only R1
                                RF_FunSel <= 3'b000; //Decrement
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b000; //R1 to ALU
                            end
                        endcase
                        end


                        3'b101:  //R2 is source
                        begin
                            case(_ALUSystem.IROut[8:6])
                            3'b000: //Dreg //pc
                            begin
                                RF_RegSel <= 4'b1011; //Only R2
                                RF_FunSel <= 3'b000; //Decrement
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b001; //R2 to ALU
                            end
                            3'b001: //Dreg //pc
                            begin
                                RF_RegSel <= 4'b1011; //Only R2
                                RF_FunSel <= 3'b000; //Decrement
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b001; //R2 to ALU
                            end
                            3'b010: //Dreg //SP
                            begin
                                RF_RegSel <= 4'b1011; //Only R2
                                RF_FunSel <= 3'b000; //Decrement
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b001; //R2 to ALU
                            end
                            3'b011: //Dreg //Ar
                            begin
                                RF_RegSel <= 4'b1011; //Only R2
                                RF_FunSel <= 3'b000; //Decrement
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b001; //R2 to ALU
                            end
                            3'b100: //Dreg //R1
                            begin
                                RF_RegSel <= 4'b1011; //Only R2
                                RF_FunSel <= 3'b000; //Decrement
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b001; //R2 to ALU
                            end
                            3'b101: //Dreg //R2
                            begin
                                RF_RegSel <= 4'b1011; //Only R2
                                RF_FunSel <= 3'b000; //Decrement
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b001; //R2 to ALU
                            end
                            3'b110: //Dreg //R3
                            begin
                                RF_RegSel <= 4'b1011; //Only R2
                                RF_FunSel <= 3'b000; //Decrement
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b001; //R2 to ALU
                            end
                            3'b111: //Dreg //R4
                            begin
                                RF_RegSel <= 4'b1011; //Only R2
                                RF_FunSel <= 3'b000; //Decrement
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b001; //R2 to ALU
                            end
                        endcase
                        end

                        3'b110:  //R3 is source
                        begin
                            case(_ALUSystem.IROut[8:6])
                            3'b000: //Dreg //pc
                            begin
                                RF_RegSel <= 4'b1101; //Only R3
                                RF_FunSel <= 3'b000; //Decrement
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b010; //R3 to ALU
                            end
                            3'b001: //Dreg //pc
                            begin
                                RF_RegSel <= 4'b1101; //Only R3
                                RF_FunSel <= 3'b000; //Decrement
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b010; //R3 to ALU
                            end
                            3'b010: //Dreg //SP
                            begin
                                RF_RegSel <= 4'b1101; //Only R3
                                RF_FunSel <= 3'b000; //Decrement
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b010; //R3 to ALU
                            end
                            3'b011: //Dreg //Ar
                            begin
                                RF_RegSel <= 4'b1101; //Only R3
                                RF_FunSel <= 3'b000; //Decrement
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b010; //R3 to ALU
                            end
                            3'b100: //Dreg //R1
                            begin
                                RF_RegSel <= 4'b1101; //Only R3
                                RF_FunSel <= 3'b000; //Decrement
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b010; //R3 to ALU
                            end
                            3'b101: //Dreg //R2
                            begin
                                RF_RegSel <= 4'b1101; //Only R3
                                RF_FunSel <= 3'b000; //Decrement
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b010; //R3 to ALU
                            end
                            3'b110: //Dreg //R3
                            begin
                                RF_RegSel <= 4'b1101; //Only R3
                                RF_FunSel <= 3'b000; //Decrement
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b010; //R3 to ALU
                            end
                            3'b111: //Dreg //R4
                            begin
                                RF_RegSel <= 4'b1101; //Only R3
                                RF_FunSel <= 3'b000; //Decrement
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b010; //R3 to ALU
                            end
                        endcase
                        end

                        3'b111:  //R4 is source
                        begin
                            case(_ALUSystem.IROut[8:6])
                            3'b000: //Dreg //pc
                            begin
                                RF_RegSel <= 4'b1110; //Only R4
                                RF_FunSel <= 3'b000; //Decrement
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b011; //R4 to ALU
                            end
                            3'b001: //Dreg //pc
                            begin
                                RF_RegSel <= 4'b1110; //Only R4
                                RF_FunSel <= 3'b000; //Decrement
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b011; //R4 to ALU
                            end
                            3'b010: //Dreg //SP
                            begin
                                RF_RegSel <= 4'b1110; //Only R4
                                RF_FunSel <= 3'b000; //Decrement
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b011; //R4 to ALU
                            end
                            3'b011: //Dreg //Ar
                            begin
                                RF_RegSel <= 4'b1110; //Only R4
                                RF_FunSel <= 3'b000; //Decrement
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b011; //R4 to ALU
                            end
                            3'b100: //Dreg //R1
                            begin
                                RF_RegSel <= 4'b1110; //Only R4
                                RF_FunSel <= 3'b000; //Decrement
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b011; //R4 to ALU
                            end
                            3'b101: //Dreg //R2
                            begin
                                RF_RegSel <= 4'b1110; //Only R4
                                RF_FunSel <= 3'b000; //Decrement
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b011; //R4 to ALU
                            end
                            3'b110: //Dreg //R3
                            begin
                                RF_RegSel <= 4'b1110; //Only R4
                                RF_FunSel <= 3'b000; //Decrement
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b011; //R4 to ALU
                            end
                            3'b111: //Dreg //R4
                            begin
                                RF_RegSel <= 4'b1110; //Only R4
                                RF_FunSel <= 3'b000; //Decrement
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_OutASel <= 3'b011; //R4 to ALU
                            end
                        endcase
                        end
                    endcase
                    T <= T + 1;  //increment Decrem
                    ////////////////////////esas hisse//////////////////////////////////////
                end
                

////////////////////////////////////////////////////////////////
                6'b000111: //LSL
                begin
                    case(_ALUSystem.IROut[5])
                    1'b0:
                    begin
                        case(_ALUSystem.IROut[4:3])
                        2'b00: ARF_OutCSel <= 2'b00; //Send PC
                        2'b01: ARF_OutCSel <= 2'b01; //Send PC
                        2'b10: ARF_OutCSel <= 2'b11; //Send SP
                        2'b11: ARF_OutCSel <= 2'b10; //Send AR
                        endcase

                        MuxASel <= 2'b01;     // Select OutC as input B  
                    
                        RF_ScrSel <= 4'b1011; //Enable S2
                        RF_RegSel <= 4'b1111;   //Disable RX
                        RF_FunSel <=3'b010;   //Write low S2

                        RF_OutASel <=3'b101; //Send S2 to ALU
                    end

                    1'b1:
                    begin
                        case(_ALUSystem.IROut[4:3])
                        2'b00: RF_OutASel <=3'b000; //Send R1
                        2'b01: RF_OutASel <=3'b001; //Send R2
                        2'b10: RF_OutASel <=3'b010; //Send R3
                        2'b11: RF_OutASel <=3'b011; //Send R4
                        endcase
                    end
                    endcase
                     T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b001000: //LSR    
                begin
                    case(_ALUSystem.IROut[5])
                    1'b0:
                    begin
                        case(_ALUSystem.IROut[4:3])
                        2'b00: ARF_OutCSel <= 2'b00; //Send PC
                        2'b01: ARF_OutCSel <= 2'b01; //Send PC
                        2'b10: ARF_OutCSel <= 2'b11; //Send SP
                        2'b11: ARF_OutCSel <= 2'b10; //Send AR
                        endcase

                        MuxASel <= 2'b01;     // Select OutC as input B  
                    
                        RF_ScrSel <= 4'b1011; //Enable S2
                        RF_RegSel <= 4'b1111;   //Disable RX
                        RF_FunSel <=3'b010;   //Write low S2

                        RF_OutASel <=3'b101; //Send S2 to ALU
                    end

                    1'b1:
                    begin
                        case(_ALUSystem.IROut[4:3])
                        2'b00: RF_OutASel <=3'b000; //Send R1
                        2'b01: RF_OutASel <=3'b001; //Send R2
                        2'b10: RF_OutASel <=3'b010; //Send R3
                        2'b11: RF_OutASel <=3'b011; //Send R4
                        endcase
                    end
                    endcase
                     T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b001001: //ASR
                begin
                    case(_ALUSystem.IROut[5])
                    1'b0:
                    begin
                        case(_ALUSystem.IROut[4:3])
                        2'b00: ARF_OutCSel <= 2'b00; //Send PC
                        2'b01: ARF_OutCSel <= 2'b01; //Send PC
                        2'b10: ARF_OutCSel <= 2'b11; //Send SP
                        2'b11: ARF_OutCSel <= 2'b10; //Send AR
                        endcase

                        MuxASel <= 2'b01;     // Select OutC as input B  
                    
                        RF_ScrSel <= 4'b1011; //Enable S2
                        RF_RegSel <= 4'b1111;   //Disable RX
                        RF_FunSel <=3'b010;   //Write low S2

                        RF_OutASel <=3'b101; //Send S2 to ALU
                    end

                    1'b1:
                    begin
                        case(_ALUSystem.IROut[4:3])
                        2'b00: RF_OutASel <=3'b000; //Send R1
                        2'b01: RF_OutASel <=3'b001; //Send R2
                        2'b10: RF_OutASel <=3'b010; //Send R3
                        2'b11: RF_OutASel <=3'b011; //Send R4
                        endcase
                    end
                    endcase
                     T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b001010: //CSL
                begin
                    case(_ALUSystem.IROut[5])
                    1'b0:
                    begin
                        case(_ALUSystem.IROut[4:3])
                        2'b00: ARF_OutCSel <= 2'b00; //Send PC
                        2'b01: ARF_OutCSel <= 2'b01; //Send PC
                        2'b10: ARF_OutCSel <= 2'b11; //Send SP
                        2'b11: ARF_OutCSel <= 2'b10; //Send AR
                        endcase

                        MuxASel <= 2'b01;     // Select OutC as input B  
                    
                        RF_ScrSel <= 4'b1011; //Enable S2
                        RF_RegSel <= 4'b1111;   //Disable RX
                        RF_FunSel <=3'b010;   //Write low S2

                        RF_OutASel <=3'b101; //Send S2 to ALU
                    end

                    1'b1:
                    begin
                        case(_ALUSystem.IROut[4:3])
                        2'b00: RF_OutASel <=3'b000; //Send R1
                        2'b01: RF_OutASel <=3'b001; //Send R2
                        2'b10: RF_OutASel <=3'b010; //Send R3
                        2'b11: RF_OutASel <=3'b011; //Send R4
                        endcase
                    end
                    endcase
                     T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b001011: //CSR
                begin
                    case(_ALUSystem.IROut[5])
                    1'b0:
                    begin
                        case(_ALUSystem.IROut[4:3])
                        2'b00: ARF_OutCSel <= 2'b00; //Send PC
                        2'b01: ARF_OutCSel <= 2'b01; //Send PC
                        2'b10: ARF_OutCSel <= 2'b11; //Send SP
                        2'b11: ARF_OutCSel <= 2'b10; //Send AR
                        endcase

                        MuxASel <= 2'b01;     // Select OutC as input B  
                    
                        RF_ScrSel <= 4'b1011; //Enable S2
                        RF_RegSel <= 4'b1111;   //Disable RX
                        RF_FunSel <=3'b010;   //Write low S2

                        RF_OutASel <=3'b101; //Send S2 to ALU
                    end

                    1'b1:
                    begin
                        case(_ALUSystem.IROut[4:3])
                        2'b00: RF_OutASel <=3'b000; //Send R1
                        2'b01: RF_OutASel <=3'b001; //Send R2
                        2'b10: RF_OutASel <=3'b010; //Send R3
                        2'b11: RF_OutASel <=3'b011; //Send R4
                        endcase
                    end
                    endcase
                     T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b001100: //AND
                begin
                    ALU_FunSel <= 5'b10111; //AND 16bit

                    case(_ALUSystem.IROut[5])
                    1'b0:
                    begin
                        ARF_RegSel <= 3'b111; //All disable
                        case(_ALUSystem.IROut[4:3])
                        2'b00: ARF_OutCSel <= 2'b00; //PC
                        2'b01: ARF_OutCSel <= 2'b01; //PC
                        2'b10: ARF_OutCSel <= 2'b11; //SP
                        2'b11: ARF_OutCSel <= 2'b10; //AR
                        endcase
                        MuxASel <= 2'b01; //ARF to RF
                        RF_FunSel <= 3'b010; //Load
                        RF_ScrSel <= 4'b1101; //Enable S3 and Upload ARF value to it
                        RF_RegSel <= 4'b1111; //Disable all
                        RF_OutASel <= 3'b110; //Send S3 to ALU
                    end
                    1'b1:
                    begin
                        case(_ALUSystem.IROut[4:3])
                        2'b00: RF_OutBSel <= 3'b000; //R1
                        2'b01: RF_OutBSel <= 3'b001; //R2
                        2'b10: RF_OutBSel <= 3'b010; //R3
                        2'b11: RF_OutBSel <= 3'b011; //R4
                        endcase
                    end
                    endcase

                     T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b001101: //ORR
                begin
                    ALU_FunSel <= 5'b11000; //OR 16bit

                    case(_ALUSystem.IROut[5])
                    1'b0:
                    begin
                        ARF_RegSel <= 3'b111; //All disable
                        case(_ALUSystem.IROut[4:3])
                        2'b00: ARF_OutCSel <= 2'b00; //PC
                        2'b01: ARF_OutCSel <= 2'b01; //PC
                        2'b10: ARF_OutCSel <= 2'b11; //SP
                        2'b11: ARF_OutCSel <= 2'b10; //AR
                        endcase
                        MuxASel <= 2'b01; //ARF to RF
                        RF_FunSel <= 3'b010; //Load
                        RF_ScrSel <= 4'b1101; //Enable S3 and Upload ARF value to it
                        RF_RegSel <= 4'b1111; //Disable all
                        RF_OutASel <= 3'b110; //Send S3 to ALU
                    end
                    1'b1:
                    begin
                        case(_ALUSystem.IROut[4:3])
                        2'b00: RF_OutBSel <= 3'b000; //R1
                        2'b01: RF_OutBSel <= 3'b001; //R2
                        2'b10: RF_OutBSel <= 3'b010; //R3
                        2'b11: RF_OutBSel <= 3'b011; //R4
                        endcase
                    end
                    endcase

                     T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b001110: //NOT
                begin 
                    case(_ALUSystem.IROut[5])
                    1'b0:
                    begin
                        case(_ALUSystem.IROut[4:3])
                        2'b00: ARF_OutCSel <= 2'b00; //Send PC
                        2'b01: ARF_OutCSel <= 2'b01; //Send PC
                        2'b10: ARF_OutCSel <= 2'b11; //Send SP
                        2'b11: ARF_OutCSel <= 2'b10; //Send AR
                        endcase

                        MuxASel <= 2'b01;     // Select OutC as input B  
                    
                        RF_ScrSel <= 4'b1011; //Enable S2
                        RF_RegSel <= 4'b1111;   //Disable RX
                        RF_FunSel <=3'b010;   //Write low S2

                        RF_OutASel <=3'b101; //Send S2 to ALU
                    end

                    1'b1:
                    begin
                        case(_ALUSystem.IROut[4:3])
                        2'b00: RF_OutASel <=3'b000; //Send R1
                        2'b01: RF_OutASel <=3'b001; //Send R2
                        2'b10: RF_OutASel <=3'b010; //Send R3
                        2'b11: RF_OutASel <=3'b011; //Send R4
                        endcase
                    end
                    endcase
                     T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b001111: //XOR
                begin
                    ALU_FunSel <= 5'b11001; //XOR 16bit

                    case(_ALUSystem.IROut[5])
                    1'b0:
                    begin
                        ARF_RegSel <= 3'b111; //All disable
                        case(_ALUSystem.IROut[4:3])
                        2'b00: ARF_OutCSel <= 2'b00; //PC
                        2'b01: ARF_OutCSel <= 2'b01; //PC
                        2'b10: ARF_OutCSel <= 2'b11; //SP
                        2'b11: ARF_OutCSel <= 2'b10; //AR
                        endcase
                        MuxASel <= 2'b01; //ARF to RF
                        RF_FunSel <= 3'b010; //Load
                        RF_ScrSel <= 4'b1101; //Enable S3 and Upload ARF value to it
                        RF_RegSel <= 4'b1111; //Disable all
                        RF_OutASel <= 3'b110; //Send S3 to ALU
                    end
                    1'b1:
                    begin
                        case(_ALUSystem.IROut[4:3])
                        2'b00: RF_OutBSel <= 3'b000; //R1
                        2'b01: RF_OutBSel <= 3'b001; //R2
                        2'b10: RF_OutBSel <= 3'b010; //R3
                        2'b11: RF_OutBSel <= 3'b011; //R4
                        endcase
                    end
                    endcase

                     T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b010000: //NAND
                begin
                    ALU_FunSel <= 5'b11010; //NAND 16bit

                    case(_ALUSystem.IROut[5])
                    1'b0:
                    begin
                        ARF_RegSel <= 3'b111; //All disable
                        case(_ALUSystem.IROut[4:3])
                        2'b00: ARF_OutCSel <= 2'b00; //PC
                        2'b01: ARF_OutCSel <= 2'b01; //PC
                        2'b10: ARF_OutCSel <= 2'b11; //SP
                        2'b11: ARF_OutCSel <= 2'b10; //AR
                        endcase
                        MuxASel <= 2'b01; //ARF to RF
                        RF_FunSel <= 3'b010; //Load
                        RF_ScrSel <= 4'b1101; //Enable S3 and Upload ARF value to it
                        RF_RegSel <= 4'b1111; //Disable all
                        RF_OutASel <= 3'b110; //Send S3 to ALU
                    end
                    1'b1:
                    begin
                        case(_ALUSystem.IROut[4:3])
                        2'b00: RF_OutBSel <= 3'b000; //R1
                        2'b01: RF_OutBSel <= 3'b001; //R2
                        2'b10: RF_OutBSel <= 3'b010; //R3
                        2'b11: RF_OutBSel <= 3'b011; //R4
                        endcase
                    end
                    endcase

                     T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b010001: //MOVH
                begin
                    MuxASel <= 2'b11; //Send IR to RF
                    MuxBSel <= 2'b11; //Send IR to ARF
                    case(_ALUSystem.IROut[8])
                    1'b0:
                    begin
                        ARF_FunSel <= 3'b110; //Write high
                        case(_ALUSystem.IROut[7:6])
                        2'b00: ARF_RegSel <= 3'b011; //PC
                        2'b01: ARF_RegSel <= 3'b011; //PC
                        2'b10: ARF_RegSel <= 3'b110; //SP
                        2'b11: ARF_RegSel <= 3'b101; //AR
                        endcase
                    end
                    1'b1:
                    begin
                        
                        RF_FunSel <= 3'b110; //Write high
                        RF_ScrSel <= 4'b1111; //Disable all
                        case(_ALUSystem.IROut[7:6])
                        2'b00: RF_RegSel <= 4'b0111; //Only R1
                        2'b01: RF_RegSel <= 4'b1011; //Only R2
                        2'b10: RF_RegSel <= 4'b1101; //Only R3
                        2'b11: RF_RegSel <= 4'b1110; //Only R4
                        endcase
                    end
                    endcase

                    T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b010010: //LDR (16bit)
                begin
                    ARF_OutDSel <= 2'b10; //Send AR
                    Mem_CS <= 1'b1; //Disable Mem
                    Mem_WR <= 1'b0; //Read from memory

                    T <= T + 1;
                end
            
////////////////////////////////////////////////////////////////
                6'b010011: //STR (16bit)
                begin
                    Mem_CS <= 1'b0; //Enable memory
                    Mem_WR <= 1'b1; //Write to memory
                    case(_ALUSystem.IROut[9:8])
                    2'b00: RF_OutASel <= 3'b000; //Send R1
                    2'b01: RF_OutASel <= 3'b001; //Send R2
                    2'b10: RF_OutASel <= 3'b010; //Send R3
                    2'b11: RF_OutASel <= 3'b011; //Send R4
                    endcase
                    
                    T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b010100: //MOVL
                begin
                    MuxASel <= 2'b11; //Send IR to RF
                    MuxBSel <= 2'b11; //Send IR to ARF
                    case(_ALUSystem.IROut[8])
                    1'b0:
                    begin
                        ARF_FunSel <= 3'b101; //Write high
                        case(_ALUSystem.IROut[7:6])
                        2'b00: ARF_RegSel <= 3'b011; //PC
                        2'b01: ARF_RegSel <= 3'b011; //PC
                        2'b10: ARF_RegSel <= 3'b110; //SP
                        2'b11: ARF_RegSel <= 3'b101; //AR
                        endcase
                    end
                    1'b1:
                    begin
                        
                        RF_FunSel <= 3'b101; //Write high
                        RF_ScrSel <= 4'b1111; //Disable all
                        case(_ALUSystem.IROut[7:6])
                        2'b00: RF_RegSel <= 4'b0111; //Only R1
                        2'b01: RF_RegSel <= 4'b1011; //Only R2
                        2'b10: RF_RegSel <= 4'b1101; //Only R3
                        2'b11: RF_RegSel <= 4'b1110; //Only R4
                        endcase
                    end
                    endcase

                    T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b010101: //ADD (16bit)
                begin
                    ALU_FunSel <= 5'b10100; //ADD 16bit

                    case(_ALUSystem.IROut[5])
                    1'b0:
                    begin
                        ARF_RegSel <= 3'b111; //All disable
                        case(_ALUSystem.IROut[4:3])
                        2'b00: ARF_OutCSel <= 2'b00; //PC
                        2'b01: ARF_OutCSel <= 2'b01; //PC
                        2'b10: ARF_OutCSel <= 2'b11; //SP
                        2'b11: ARF_OutCSel <= 2'b10; //AR
                        endcase
                        MuxASel <= 2'b01; //ARF to RF
                        RF_FunSel <= 3'b010; //Load
                        RF_ScrSel <= 4'b1101; //Enable S3 and Upload ARF value to it
                        RF_RegSel <= 4'b1111; //Disable all
                        RF_OutASel <= 3'b110; //Send S3 to ALU
                    end
                    1'b1:
                    begin
                        case(_ALUSystem.IROut[4:3])
                        2'b00: RF_OutBSel <= 3'b000; //R1
                        2'b01: RF_OutBSel <= 3'b001; //R2
                        2'b10: RF_OutBSel <= 3'b010; //R3
                        2'b11: RF_OutBSel <= 3'b011; //R4
                        endcase
                    end
                    endcase

                     T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b010110: //ADC (16bit)
                begin
                    ALU_FunSel <= 5'b10101; //ADD 16bit with carry

                    case(_ALUSystem.IROut[5])
                    1'b0:
                    begin
                        ARF_RegSel <= 3'b111; //All disable
                        case(_ALUSystem.IROut[4:3])
                        2'b00: ARF_OutCSel <= 2'b00; //PC
                        2'b01: ARF_OutCSel <= 2'b01; //PC
                        2'b10: ARF_OutCSel <= 2'b11; //SP
                        2'b11: ARF_OutCSel <= 2'b10; //AR
                        endcase
                        MuxASel <= 2'b01; //ARF to RF
                        RF_FunSel <= 3'b010; //Load
                        RF_ScrSel <= 4'b1101; //Enable S3 and Upload ARF value to it
                        RF_RegSel <= 4'b1111; //Disable all
                        RF_OutASel <= 3'b110; //Send S3 to ALU
                    end
                    1'b1:
                    begin
                        case(_ALUSystem.IROut[4:3])
                        2'b00: RF_OutBSel <= 3'b000; //R1
                        2'b01: RF_OutBSel <= 3'b001; //R2
                        2'b10: RF_OutBSel <= 3'b010; //R3
                        2'b11: RF_OutBSel <= 3'b011; //R4
                        endcase
                    end
                    endcase

                     T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b010111: //SUB (16bit)
                begin
                    ALU_FunSel <= 5'b10110; //ADD 16bit

                    case(_ALUSystem.IROut[5])
                    1'b0:
                    begin
                        ARF_RegSel <= 3'b111; //All disable
                        case(_ALUSystem.IROut[4:3])
                        2'b00: ARF_OutCSel <= 2'b00; //PC
                        2'b01: ARF_OutCSel <= 2'b01; //PC
                        2'b10: ARF_OutCSel <= 2'b11; //SP
                        2'b11: ARF_OutCSel <= 2'b10; //AR
                        endcase
                        MuxASel <= 2'b01; //ARF to RF
                        RF_FunSel <= 3'b010; //Load
                        RF_ScrSel <= 4'b1101; //Enable S3 and Upload ARF value to it
                        RF_RegSel <= 4'b1111; //Disable all
                        RF_OutASel <= 3'b110; //Send S3 to ALU
                    end
                    1'b1:
                    begin
                        case(_ALUSystem.IROut[4:3])
                        2'b00: RF_OutBSel <= 3'b000; //R1
                        2'b01: RF_OutBSel <= 3'b001; //R2
                        2'b10: RF_OutBSel <= 3'b010; //R3
                        2'b11: RF_OutBSel <= 3'b011; //R4
                        endcase
                    end
                    endcase

                     T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b011000: //MOVS
                begin
                    case(_ALUSystem.IROut[5])
                    1'b0:
                    begin
                        case(_ALUSystem.IROut[4:3])
                        2'b00: ARF_OutCSel <= 2'b00; //Send PC
                        2'b01: ARF_OutCSel <= 2'b01; //Send PC
                        2'b10: ARF_OutCSel <= 2'b11; //Send SP
                        2'b11: ARF_OutCSel <= 2'b10; //Send AR
                        endcase

                        MuxASel <= 2'b01;     // Select OutC as input B  
                    
                        RF_ScrSel <= 4'b1011; //Enable S2
                        RF_RegSel <= 4'b1111;   //Disable RX
                        RF_FunSel <=3'b010;   //Write low S2

                        RF_OutASel <=3'b101; //Send S2 to ALU
                    end

                    1'b1:
                    begin
                        case(_ALUSystem.IROut[4:3])
                        2'b00: RF_OutASel <=3'b000; //Send R1
                        2'b01: RF_OutASel <=3'b001; //Send R2
                        2'b10: RF_OutASel <=3'b010; //Send R3
                        2'b11: RF_OutASel <=3'b011; //Send R4
                        endcase
                    end
                    endcase
                     T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b011001: //ADDS (16bit)
                begin
                    ALU_WF <= 1'b1; //Allow write to ALU flags
                    ALU_FunSel <= 5'b10100; //ADD 16bit

                    case(_ALUSystem.IROut[5])
                    1'b0:
                    begin
                        ARF_RegSel <= 3'b111; //All disable
                        case(_ALUSystem.IROut[4:3])
                        2'b00: ARF_OutCSel <= 2'b00; //PC
                        2'b01: ARF_OutCSel <= 2'b01; //PC
                        2'b10: ARF_OutCSel <= 2'b11; //SP
                        2'b11: ARF_OutCSel <= 2'b10; //AR
                        endcase
                        MuxASel <= 2'b01; //ARF to RF
                        RF_FunSel <= 3'b010; //Load
                        RF_ScrSel <= 4'b1101; //Enable S3 and Upload ARF value to it
                        RF_RegSel <= 4'b1111; //Disable all
                        RF_OutASel <= 3'b110; //Send S3 to ALU
                    end
                    1'b1:
                    begin
                        case(_ALUSystem.IROut[4:3])
                        2'b00: RF_OutBSel <= 3'b000; //R1
                        2'b01: RF_OutBSel <= 3'b001; //R2
                        2'b10: RF_OutBSel <= 3'b010; //R3
                        2'b11: RF_OutBSel <= 3'b011; //R4
                        endcase
                    end
                    endcase

                     T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b011010: //SUBS (16bit)
                begin
                    ALU_FunSel <= 5'b10110; //ADD 16bit
                    ALU_WF <= 1'b1; //Allow write to ALU flags

                    case(_ALUSystem.IROut[5])
                    1'b0:
                    begin
                        ARF_RegSel <= 3'b111; //All disable
                        case(_ALUSystem.IROut[4:3])
                        2'b00: ARF_OutCSel <= 2'b00; //PC
                        2'b01: ARF_OutCSel <= 2'b01; //PC
                        2'b10: ARF_OutCSel <= 2'b11; //SP
                        2'b11: ARF_OutCSel <= 2'b10; //AR
                        endcase
                        MuxASel <= 2'b01; //ARF to RF
                        RF_FunSel <= 3'b010; //Load
                        RF_ScrSel <= 4'b1101; //Enable S3 and Upload ARF value to it
                        RF_RegSel <= 4'b1111; //Disable all
                        RF_OutASel <= 3'b110; //Send S3 to ALU
                    end
                    1'b1:
                    begin
                        case(_ALUSystem.IROut[4:3])
                        2'b00: RF_OutBSel <= 3'b000; //R1
                        2'b01: RF_OutBSel <= 3'b001; //R2
                        2'b10: RF_OutBSel <= 3'b010; //R3
                        2'b11: RF_OutBSel <= 3'b011; //R4
                        endcase
                    end
                    endcase

                     T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b011011: //ANDS (16bit)
                begin
                    ALU_FunSel <= 5'b10111; //AND 16bit
                    ALU_WF <= 1'b1; //Allow write to ALU flags

                    case(_ALUSystem.IROut[5])
                    1'b0:
                    begin
                        ARF_RegSel <= 3'b111; //All disable
                        case(_ALUSystem.IROut[4:3])
                        2'b00: ARF_OutCSel <= 2'b00; //PC
                        2'b01: ARF_OutCSel <= 2'b01; //PC
                        2'b10: ARF_OutCSel <= 2'b11; //SP
                        2'b11: ARF_OutCSel <= 2'b10; //AR
                        endcase
                        MuxASel <= 2'b01; //ARF to RF
                        RF_FunSel <= 3'b010; //Load
                        RF_ScrSel <= 4'b1101; //Enable S3 and Upload ARF value to it
                        RF_RegSel <= 4'b1111; //Disable all
                        RF_OutASel <= 3'b110; //Send S3 to ALU
                    end
                    1'b1:
                    begin
                        case(_ALUSystem.IROut[4:3])
                        2'b00: RF_OutBSel <= 3'b000; //R1
                        2'b01: RF_OutBSel <= 3'b001; //R2
                        2'b10: RF_OutBSel <= 3'b010; //R3
                        2'b11: RF_OutBSel <= 3'b011; //R4
                        endcase
                    end
                    endcase

                     T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b011100: //ORRS
                begin
                    ALU_FunSel <= 5'b11000; //OR 16bit
                    ALU_WF <= 1'b1; //Allow write to ALU flags

                    case(_ALUSystem.IROut[5])
                    1'b0:
                    begin
                        ARF_RegSel <= 3'b111; //All disable
                        case(_ALUSystem.IROut[4:3])
                        2'b00: ARF_OutCSel <= 2'b00; //PC
                        2'b01: ARF_OutCSel <= 2'b01; //PC
                        2'b10: ARF_OutCSel <= 2'b11; //SP
                        2'b11: ARF_OutCSel <= 2'b10; //AR
                        endcase
                        MuxASel <= 2'b01; //ARF to RF
                        RF_FunSel <= 3'b010; //Load
                        RF_ScrSel <= 4'b1101; //Enable S3 and Upload ARF value to it
                        RF_RegSel <= 4'b1111; //Disable all
                        RF_OutASel <= 3'b110; //Send S3 to ALU
                    end
                    1'b1:
                    begin
                        case(_ALUSystem.IROut[4:3])
                        2'b00: RF_OutBSel <= 3'b000; //R1
                        2'b01: RF_OutBSel <= 3'b001; //R2
                        2'b10: RF_OutBSel <= 3'b010; //R3
                        2'b11: RF_OutBSel <= 3'b011; //R4
                        endcase
                    end
                    endcase

                     T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b011101: //XORS
                begin
                    ALU_FunSel <= 5'b11001; //XOR 16bit
                    ALU_WF <= 1'b1; //Allow write to ALU flags

                    case(_ALUSystem.IROut[5])
                    1'b0:
                    begin
                        ARF_RegSel <= 3'b111; //All disable
                        case(_ALUSystem.IROut[4:3])
                        2'b00: ARF_OutCSel <= 2'b00; //PC
                        2'b01: ARF_OutCSel <= 2'b01; //PC
                        2'b10: ARF_OutCSel <= 2'b11; //SP
                        2'b11: ARF_OutCSel <= 2'b10; //AR
                        endcase
                        MuxASel <= 2'b01; //ARF to RF
                        RF_FunSel <= 3'b010; //Load
                        RF_ScrSel <= 4'b1101; //Enable S3 and Upload ARF value to it
                        RF_RegSel <= 4'b1111; //Disable all
                        RF_OutASel <= 3'b110; //Send S3 to ALU
                    end
                    1'b1:
                    begin
                        case(_ALUSystem.IROut[4:3])
                        2'b00: RF_OutBSel <= 3'b000; //R1
                        2'b01: RF_OutBSel <= 3'b001; //R2
                        2'b10: RF_OutBSel <= 3'b010; //R3
                        2'b11: RF_OutBSel <= 3'b011; //R4
                        endcase
                    end
                    endcase

                     T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b011110: //BX
                begin
                    ARF_OutCSel <= 2'b00; //Send PC
                    MuxASel <= 2'b01; //ARF to RF
                    RF_FunSel <= 3'b010; //Load
                    RF_ScrSel <= 4'b0111; //Enable S1 and Upload ARF value to it
                    RF_RegSel <= 4'b1111; //Disable all
                    RF_OutASel <= 3'b100; //Send S1 to ALU

                    T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b011111: //BL
                begin
                    Mem_CS <= 1'b1; //Enable memory
                    Mem_WR <= 1'b0; //Read from memory
                    ARF_OutDSel <= 2'b11; //Send SP
                    MuxBSel <= 2'b10; //Memory to ARF

                    T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b100000: //LDRIM
                begin
                    Mem_CS <= 1'b1; //Enable memory
                    Mem_WR <= 1'b0; //Read from memory
                    MuxBSel <= 2'b11; //IR to ARF
                    ARF_FunSel <= 3'b010; //LOAD
                    ARF_RegSel <= 3'b101; //AR is enable 

                    T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b100001: //STRIM
                begin
                    /////////////////esas hisse/////////////////////
                end




            endcase
        end
                       
        else if(T == 8'b00000100)
        begin
            ARF_RegSel <= 3'b111; //PC disable
            IR_Write <= 0;
            case(_ALUSystem.IROut[15:10]) 

///////////////////////////////////////////////////////////////
                6'b000000: //BRA
                begin    
                    RF_OutASel <=3'b100; //Send S1 to ALU
                    RF_OutBSel <=3'b101; //Send S2 to ALU
                    
                    ALU_FunSel <=5'b00100; //Add
                    
                    
                    
                    ARF_RegSel <= 3'b011; //PC enable
                    ARF_FunSel <= 3'b010; //Load to PC
                    MuxBSel <= 2'b00; //output to ARF
                    RF_FunSel <= 3'b011;//clear
                    RF_RegSel <= 4'b0000;//enable all
                    RF_ScrSel <= 4'b0000;//enable all
            
                    T <= T + 1;  //increment time
                end

////////////////////////////////////////////////////////////////
                6'b000001: //BNE
                begin 
                    case(_ALUSystem.ALU.FlagsOut[3])
                    1'b1:
                    begin
                        T <= 8'b00000101;  //increment time
                        
                    end

                    1'b0:
                    begin
                        RF_OutASel <=3'b100; //Send S1 to ALU
                        RF_OutBSel <=3'b101; //Send S2 to ALU
                        
                        ALU_FunSel <=5'b00100; //Add
                        
                        
                        
                        ARF_RegSel <= 3'b011; //PC enable
                        ARF_FunSel <= 3'b010; //Load to PC
                        MuxBSel <= 2'b00; //output to ARF
                        RF_FunSel <= 3'b011;//clear
                        RF_RegSel <= 4'b0000;//enable all
                        RF_ScrSel <= 4'b0000;//enable all
                
                        T <= T + 1;  //increment time
                    end
                    endcase
                end
                

////////////////////////////////////////////////////////////////
                6'b000010: //BEQ
                begin 
                    case(_ALUSystem.ALU.FlagsOut[3])
                    1'b0:
                    begin
                        T <= 8'b00000101;  //increment time
                    end

                    1'b1:
                    begin
                        RF_OutASel <=3'b100; //Send S1 to ALU
                        RF_OutBSel <=3'b101; //Send S2 to ALU
                        
                        ALU_FunSel <=5'b00100; //Add
                        
                        
                        
                        ARF_RegSel <= 3'b011; //PC enable
                        ARF_FunSel <= 3'b010; //Load to PC
                        MuxBSel <= 2'b00; //output to ARF
                        RF_FunSel <= 3'b011;//clear
                        RF_RegSel <= 4'b0000;//enable all
                        RF_ScrSel <= 4'b0000;//enable all
                
                        T <= T + 1;  //increment time
                    end
                    endcase
                end

////////////////////////////////////////////////////////////////
                6'b000011: //POP
                begin 
                    ARF_RegSel <= 3'b111; //SP disable
                    MuxASel <= 2'b10; //memory output to RF
                    case(_ALUSystem.IROut[9:8])
                
                        2'b00: RF_RegSel <= 4'b0111; //R1
                        2'b01: RF_RegSel <= 4'b1011; //R2
                        2'b10: RF_RegSel <= 4'b1101; //R3
                        2'b11: RF_RegSel <= 4'b1110; //R4
                    endcase
                    RF_ScrSel <= 4'b1111; //all is disabled
                    RF_FunSel <= 3'b010; //Load to register file
                   T <= T + 1;  //increment time
                end

////////////////////////////////////////////////////////////////
                6'b000100: //PUSH
                begin 
                    ARF_RegSel <= 3'b110; //SP enable
                    ARF_FunSel <= 3'b000; //decrement
                    T <= T + 1;  //increment time
                end

////////////////////////////////////////////////////////////////
                6'b000101: //INC
                begin
                    /////////////////esas hisse/////////////////////
                    case(_ALUSystem.IROut[5:3])//SReg1
                        3'b000:  //PC is source
                        begin
                            case(_ALUSystem.IROut[8:6])
                            3'b000: //Dreg //pc
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                MuxBSel <= 2'b01; //ARF to ARF
                                ARF_FunSel <= 3'b010;
                            end
                            3'b001: //Dreg //pc
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                MuxBSel <= 2'b01; //ARF to ARF
                                ARF_FunSel <= 3'b010;
                            end
                            3'b010: //Dreg //SP
                            begin
                                ARF_RegSel <= 3'b110; //SP enable
                                MuxBSel <= 2'b01; //ARF to ARF
                                ARF_FunSel <= 3'b010;
                            end
                            3'b011: //Dreg //Ar
                            begin
                                ARF_RegSel <= 3'b101; //AR enable
                                MuxBSel <= 2'b01; //ARF to ARF
                                ARF_FunSel <= 3'b010;
                            end
                            3'b100: //Dreg //R1
                            begin
                                MuxASel <= 2'b01;  // Select OutC as input B
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_RegSel <= 4'b0111; //Only R1
                                RF_FunSel <= 3'b010;
                            end
                            3'b101: //Dreg //R2
                            begin
                                MuxASel <= 2'b01;  // Select OutC as input B
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_RegSel <= 4'b1011; //Only R1
                                RF_FunSel <= 3'b010;
                            end
                            3'b110: //Dreg //R3
                            begin
                                MuxASel <= 2'b01;  // Select OutC as input B
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_RegSel <= 4'b1101; //Only R1
                                RF_FunSel <= 3'b010;
                            end
                            3'b111: //Dreg //R4
                            begin
                                MuxASel <= 2'b01;  // Select OutC as input B
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_RegSel <= 4'b1110; //Only R1
                                RF_FunSel <= 3'b010;
                            end
                        endcase
                        end

                        3'b001:  //PC is source
                        begin
                            case(_ALUSystem.IROut[8:6])
                            3'b000: //Dreg //pc
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                MuxBSel <= 2'b01; //ARF to ARF
                                ARF_FunSel <= 3'b010;
                            end
                            3'b001: //Dreg //pc
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                MuxBSel <= 2'b01; //ARF to ARF
                                ARF_FunSel <= 3'b010;
                            end
                            3'b010: //Dreg //SP
                            begin
                                ARF_RegSel <= 3'b110; //SP enable
                                MuxBSel <= 2'b01; //ARF to ARF
                                ARF_FunSel <= 3'b010;
                            end
                            3'b011: //Dreg //Ar
                            begin
                                ARF_RegSel <= 3'b101; //AR enable
                                MuxBSel <= 2'b01; //ARF to ARF
                                ARF_FunSel <= 3'b010;
                            end
                            3'b100: //Dreg //R1
                            begin
                                MuxASel <= 2'b01;  // Select OutC as input B
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_RegSel <= 4'b0111; //Only R1
                                RF_FunSel <= 3'b010;
                            end
                            3'b101: //Dreg //R2
                            begin
                                MuxASel <= 2'b01;  // Select OutC as input B
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_RegSel <= 4'b1011; //Only R1
                                RF_FunSel <= 3'b010;
                            end
                            3'b110: //Dreg //R3
                            begin
                                MuxASel <= 2'b01;  // Select OutC as input B
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_RegSel <= 4'b1101; //Only R1
                                RF_FunSel <= 3'b010;
                            end
                            3'b111: //Dreg //R4
                            begin
                                MuxASel <= 2'b01;  // Select OutC as input B
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_RegSel <= 4'b1110; //Only R1
                                RF_FunSel <= 3'b010;
                            end
                        endcase
                        end


                        3'b010:  //SP is source
                        begin
                            case(_ALUSystem.IROut[8:6])
                            3'b000: //Dreg //pc
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                MuxBSel <= 2'b01; //ARF to ARF
                                ARF_FunSel <= 3'b010;
                            end
                            3'b001: //Dreg //pc
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                MuxBSel <= 2'b01; //ARF to ARF
                                ARF_FunSel <= 3'b010;
                            end
                            3'b010: //Dreg //SP
                            begin
                                ARF_RegSel <= 3'b110; //SP enable
                                MuxBSel <= 2'b01; //ARF to ARF
                                ARF_FunSel <= 3'b010;
                            end
                            3'b011: //Dreg //Ar
                            begin
                                ARF_RegSel <= 3'b101; //AR enable
                                MuxBSel <= 2'b01; //ARF to ARF
                                ARF_FunSel <= 3'b010;
                            end
                            3'b100: //Dreg //R1
                            begin
                                MuxASel <= 2'b01;  // Select OutC as input B
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_RegSel <= 4'b0111; //Only R1
                                RF_FunSel <= 3'b010;
                            end
                            3'b101: //Dreg //R2
                            begin
                                MuxASel <= 2'b01;  // Select OutC as input B
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_RegSel <= 4'b1011; //Only R1
                                RF_FunSel <= 3'b010;
                            end
                            3'b110: //Dreg //R3
                            begin
                                MuxASel <= 2'b01;  // Select OutC as input B
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_RegSel <= 4'b1101; //Only R1
                                RF_FunSel <= 3'b010;
                            end
                            3'b111: //Dreg //R4
                            begin
                                MuxASel <= 2'b01;  // Select OutC as input B
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_RegSel <= 4'b1110; //Only R1
                                RF_FunSel <= 3'b010;
                            end
                        endcase
                        end

                        3'b011:  //AR is source
                        begin
                            case(_ALUSystem.IROut[8:6])
                            3'b000: //Dreg //pc
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                MuxBSel <= 2'b01; //ARF to ARF
                                ARF_FunSel <= 3'b010;
                            end
                            3'b001: //Dreg //pc
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                MuxBSel <= 2'b01; //ARF to ARF
                                ARF_FunSel <= 3'b010;
                            end
                            3'b010: //Dreg //SP
                            begin
                                ARF_RegSel <= 3'b110; //SP enable
                                MuxBSel <= 2'b01; //ARF to ARF
                                ARF_FunSel <= 3'b010;
                            end
                            3'b011: //Dreg //Ar
                            begin
                                ARF_RegSel <= 3'b101; //AR enable
                                MuxBSel <= 2'b01; //ARF to ARF
                                ARF_FunSel <= 3'b010;
                            end
                            3'b100: //Dreg //R1
                            begin
                                MuxASel <= 2'b01;  // Select OutC as input B
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_RegSel <= 4'b0111; //Only R1
                                RF_FunSel <= 3'b010;
                            end
                            3'b101: //Dreg //R2
                            begin
                                MuxASel <= 2'b01;  // Select OutC as input B
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_RegSel <= 4'b1011; //Only R1
                                RF_FunSel <= 3'b010;
                            end
                            3'b110: //Dreg //R3
                            begin
                                MuxASel <= 2'b01;  // Select OutC as input B
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_RegSel <= 4'b1101; //Only R1
                                RF_FunSel <= 3'b010;
                            end
                            3'b111: //Dreg //R4
                            begin
                                MuxASel <= 2'b01;  // Select OutC as input B
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_RegSel <= 4'b1110; //Only R1
                                RF_FunSel <= 3'b010;
                            end
                        endcase
                        end


                        3'b100:  //R! is source
                        begin
                            case(_ALUSystem.IROut[8:6])
                            3'b000: //Dreg //pc
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxBSel <= 2'b00; //ALu to arf
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b010; //Load
                            end
                            3'b001: //Dreg //pc
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxBSel <= 2'b00; //ALu to arf
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b010; //Load
                            end
                            3'b010: //Dreg //SP
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxBSel <= 2'b00; //ALu to arf
                                ARF_RegSel <= 3'b110; //SP enable
                                ARF_FunSel <= 3'b010; //Load
                            end
                            3'b011: //Dreg //Ar
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxBSel <= 2'b00; //ALu to arf
                                ARF_RegSel <= 3'b101; //AR enable
                                ARF_FunSel <= 3'b010; //Load
                            end
                            3'b100: //Dreg //R1
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxASel <= 2'b00;  //ALU to rf
                                RF_RegSel <= 4'b0111; //Only R1
                                RF_FunSel <= 3'b010; //Load
                            end
                            3'b101: //Dreg //R2
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxASel <= 2'b00;  //ALU to rf
                                RF_RegSel <= 4'b1011; //Only R2
                                RF_FunSel <= 3'b010; //Load
                            end
                            3'b110: //Dreg //R3
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxASel <= 2'b00;  //ALU to rf
                                RF_RegSel <= 4'b1101; //Only R3
                                RF_FunSel <= 3'b010; //Load
                            end
                            3'b111: //Dreg //R4
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxASel <= 2'b00;  //ALU to rf
                                RF_RegSel <= 4'b1110; //Only R3
                                RF_FunSel <= 3'b010; //Load
                            end
                        endcase
                        end


                        3'b101:  //R2 is source
                        begin
                            case(_ALUSystem.IROut[8:6])
                            3'b000: //Dreg //pc
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxBSel <= 2'b00; //ALu to arf
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b010; //Load
                            end
                            3'b001: //Dreg //pc
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxBSel <= 2'b00; //ALu to arf
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b010; //Load
                            end
                            3'b010: //Dreg //SP
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxBSel <= 2'b00; //ALu to arf
                                ARF_RegSel <= 3'b110; //SP enable
                                ARF_FunSel <= 3'b010; //Load
                            end
                            3'b011: //Dreg //Ar
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxBSel <= 2'b00; //ALu to arf
                                ARF_RegSel <= 3'b101; //AR enable
                                ARF_FunSel <= 3'b010; //Load
                            end
                            3'b100: //Dreg //R1
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxASel <= 2'b00;  //ALU to rf
                                RF_RegSel <= 4'b0111; //Only R1
                                RF_FunSel <= 3'b010; //Load
                            end
                            3'b101: //Dreg //R2
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxASel <= 2'b00;  //ALU to rf
                                RF_RegSel <= 4'b1011; //Only R2
                                RF_FunSel <= 3'b010; //Load
                            end
                            3'b110: //Dreg //R3
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxASel <= 2'b00;  //ALU to rf
                                RF_RegSel <= 4'b1101; //Only R3
                                RF_FunSel <= 3'b010; //Load
                            end
                            3'b111: //Dreg //R4
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxASel <= 2'b00;  //ALU to rf
                                RF_RegSel <= 4'b1110; //Only R3
                                RF_FunSel <= 3'b010; //Load
                            end
                        endcase
                        end

                        3'b110:  //R3 is source
                        begin
                            case(_ALUSystem.IROut[8:6])
                            3'b000: //Dreg //pc
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxBSel <= 2'b00; //ALu to arf
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b010; //Load
                            end
                            3'b001: //Dreg //pc
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxBSel <= 2'b00; //ALu to arf
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b010; //Load
                            end
                            3'b010: //Dreg //SP
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxBSel <= 2'b00; //ALu to arf
                                ARF_RegSel <= 3'b110; //SP enable
                                ARF_FunSel <= 3'b010; //Load
                            end
                            3'b011: //Dreg //Ar
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxBSel <= 2'b00; //ALu to arf
                                ARF_RegSel <= 3'b101; //AR enable
                                ARF_FunSel <= 3'b010; //Load
                            end
                            3'b100: //Dreg //R1
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxASel <= 2'b00;  //ALU to rf
                                RF_RegSel <= 4'b0111; //Only R1
                                RF_FunSel <= 3'b010; //Load
                            end
                            3'b101: //Dreg //R2
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxASel <= 2'b00;  //ALU to rf
                                RF_RegSel <= 4'b1011; //Only R2
                                RF_FunSel <= 3'b010; //Load
                            end
                            3'b110: //Dreg //R3
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxASel <= 2'b00;  //ALU to rf
                                RF_RegSel <= 4'b1101; //Only R3
                                RF_FunSel <= 3'b010; //Load
                            end
                            3'b111: //Dreg //R4
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxASel <= 2'b00;  //ALU to rf
                                RF_RegSel <= 4'b1110; //Only R3
                                RF_FunSel <= 3'b010; //Load
                            end
                        endcase
                        end

                        3'b111:  //R4 is source
                        begin
                            case(_ALUSystem.IROut[8:6])
                            3'b000: //Dreg //pc
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxBSel <= 2'b00; //ALu to arf
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b010; //Load
                            end
                            3'b001: //Dreg //pc
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxBSel <= 2'b00; //ALu to arf
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b010; //Load
                            end
                            3'b010: //Dreg //SP
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxBSel <= 2'b00; //ALu to arf
                                ARF_RegSel <= 3'b110; //SP enable
                                ARF_FunSel <= 3'b010; //Load
                            end
                            3'b011: //Dreg //Ar
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxBSel <= 2'b00; //ALu to arf
                                ARF_RegSel <= 3'b101; //AR enable
                                ARF_FunSel <= 3'b010; //Load
                            end
                            3'b100: //Dreg //R1
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxASel <= 2'b00;  //ALU to rf
                                RF_RegSel <= 4'b0111; //Only R1
                                RF_FunSel <= 3'b010; //Load
                            end
                            3'b101: //Dreg //R2
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxASel <= 2'b00;  //ALU to rf
                                RF_RegSel <= 4'b1011; //Only R2
                                RF_FunSel <= 3'b010; //Load
                            end
                            3'b110: //Dreg //R3
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxASel <= 2'b00;  //ALU to rf
                                RF_RegSel <= 4'b1101; //Only R3
                                RF_FunSel <= 3'b010; //Load
                            end
                            3'b111: //Dreg //R4
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxASel <= 2'b00;  //ALU to rf
                                RF_RegSel <= 4'b1110; //Only R3
                                RF_FunSel <= 3'b010; //Load
                            end
                        endcase
                        
                        end
                    endcase
                    T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b000110: //DEC
                begin
                    /////////////////esas hisse/////////////////////
                    case(_ALUSystem.IROut[5:3])//SReg1
                        3'b000:  //PC is source
                        begin
                            case(_ALUSystem.IROut[8:6])
                            3'b000: //Dreg //pc
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                MuxBSel <= 2'b01; //ARF to ARF
                                ARF_FunSel <= 3'b010;
                            end
                            3'b001: //Dreg //pc
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                MuxBSel <= 2'b01; //ARF to ARF
                                ARF_FunSel <= 3'b010;
                            end
                            3'b010: //Dreg //SP
                            begin
                                ARF_RegSel <= 3'b110; //SP enable
                                MuxBSel <= 2'b01; //ARF to ARF
                                ARF_FunSel <= 3'b010;
                            end
                            3'b011: //Dreg //Ar
                            begin
                                ARF_RegSel <= 3'b101; //AR enable
                                MuxBSel <= 2'b01; //ARF to ARF
                                ARF_FunSel <= 3'b010;
                            end
                            3'b100: //Dreg //R1
                            begin
                                MuxASel <= 2'b01;  // Select OutC as input B
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_RegSel <= 4'b0111; //Only R1
                                RF_FunSel <= 3'b010;
                            end
                            3'b101: //Dreg //R2
                            begin
                                MuxASel <= 2'b01;  // Select OutC as input B
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_RegSel <= 4'b1011; //Only R1
                                RF_FunSel <= 3'b010;
                            end
                            3'b110: //Dreg //R3
                            begin
                                MuxASel <= 2'b01;  // Select OutC as input B
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_RegSel <= 4'b1101; //Only R1
                                RF_FunSel <= 3'b010;
                            end
                            3'b111: //Dreg //R4
                            begin
                                MuxASel <= 2'b01;  // Select OutC as input B
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_RegSel <= 4'b1110; //Only R1
                                RF_FunSel <= 3'b010;
                            end
                        endcase
                        end

                        3'b001:  //PC is source
                        begin
                            case(_ALUSystem.IROut[8:6])
                            3'b000: //Dreg //pc
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                MuxBSel <= 2'b01; //ARF to ARF
                                ARF_FunSel <= 3'b010;
                            end
                            3'b001: //Dreg //pc
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                MuxBSel <= 2'b01; //ARF to ARF
                                ARF_FunSel <= 3'b010;
                            end
                            3'b010: //Dreg //SP
                            begin
                                ARF_RegSel <= 3'b110; //SP enable
                                MuxBSel <= 2'b01; //ARF to ARF
                                ARF_FunSel <= 3'b010;
                            end
                            3'b011: //Dreg //Ar
                            begin
                                ARF_RegSel <= 3'b101; //AR enable
                                MuxBSel <= 2'b01; //ARF to ARF
                                ARF_FunSel <= 3'b010;
                            end
                            3'b100: //Dreg //R1
                            begin
                                MuxASel <= 2'b01;  // Select OutC as input B
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_RegSel <= 4'b0111; //Only R1
                                RF_FunSel <= 3'b010;
                            end
                            3'b101: //Dreg //R2
                            begin
                                MuxASel <= 2'b01;  // Select OutC as input B
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_RegSel <= 4'b1011; //Only R1
                                RF_FunSel <= 3'b010;
                            end
                            3'b110: //Dreg //R3
                            begin
                                MuxASel <= 2'b01;  // Select OutC as input B
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_RegSel <= 4'b1101; //Only R1
                                RF_FunSel <= 3'b010;
                            end
                            3'b111: //Dreg //R4
                            begin
                                MuxASel <= 2'b01;  // Select OutC as input B
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_RegSel <= 4'b1110; //Only R1
                                RF_FunSel <= 3'b010;
                            end
                        endcase
                        end


                        3'b010:  //SP is source
                        begin
                            case(_ALUSystem.IROut[8:6])
                            3'b000: //Dreg //pc
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                MuxBSel <= 2'b01; //ARF to ARF
                                ARF_FunSel <= 3'b010;
                            end
                            3'b001: //Dreg //pc
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                MuxBSel <= 2'b01; //ARF to ARF
                                ARF_FunSel <= 3'b010;
                            end
                            3'b010: //Dreg //SP
                            begin
                                ARF_RegSel <= 3'b110; //SP enable
                                MuxBSel <= 2'b01; //ARF to ARF
                                ARF_FunSel <= 3'b010;
                            end
                            3'b011: //Dreg //Ar
                            begin
                                ARF_RegSel <= 3'b101; //AR enable
                                MuxBSel <= 2'b01; //ARF to ARF
                                ARF_FunSel <= 3'b010;
                            end
                            3'b100: //Dreg //R1
                            begin
                                MuxASel <= 2'b01;  // Select OutC as input B
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_RegSel <= 4'b0111; //Only R1
                                RF_FunSel <= 3'b010;
                            end
                            3'b101: //Dreg //R2
                            begin
                                MuxASel <= 2'b01;  // Select OutC as input B
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_RegSel <= 4'b1011; //Only R1
                                RF_FunSel <= 3'b010;
                            end
                            3'b110: //Dreg //R3
                            begin
                                MuxASel <= 2'b01;  // Select OutC as input B
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_RegSel <= 4'b1101; //Only R1
                                RF_FunSel <= 3'b010;
                            end
                            3'b111: //Dreg //R4
                            begin
                                MuxASel <= 2'b01;  // Select OutC as input B
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_RegSel <= 4'b1110; //Only R1
                                RF_FunSel <= 3'b010;
                            end
                        endcase
                        end

                        3'b011:  //AR is source
                        begin
                            case(_ALUSystem.IROut[8:6])
                            3'b000: //Dreg //pc
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                MuxBSel <= 2'b01; //ARF to ARF
                                ARF_FunSel <= 3'b010;
                            end
                            3'b001: //Dreg //pc
                            begin
                                ARF_RegSel <= 3'b011; //PC enable
                                MuxBSel <= 2'b01; //ARF to ARF
                                ARF_FunSel <= 3'b010;
                            end
                            3'b010: //Dreg //SP
                            begin
                                ARF_RegSel <= 3'b110; //SP enable
                                MuxBSel <= 2'b01; //ARF to ARF
                                ARF_FunSel <= 3'b010;
                            end
                            3'b011: //Dreg //Ar
                            begin
                                ARF_RegSel <= 3'b101; //AR enable
                                MuxBSel <= 2'b01; //ARF to ARF
                                ARF_FunSel <= 3'b010;
                            end
                            3'b100: //Dreg //R1
                            begin
                                MuxASel <= 2'b01;  // Select OutC as input B
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_RegSel <= 4'b0111; //Only R1
                                RF_FunSel <= 3'b010;
                            end
                            3'b101: //Dreg //R2
                            begin
                                MuxASel <= 2'b01;  // Select OutC as input B
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_RegSel <= 4'b1011; //Only R1
                                RF_FunSel <= 3'b010;
                            end
                            3'b110: //Dreg //R3
                            begin
                                MuxASel <= 2'b01;  // Select OutC as input B
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_RegSel <= 4'b1101; //Only R1
                                RF_FunSel <= 3'b010;
                            end
                            3'b111: //Dreg //R4
                            begin
                                MuxASel <= 2'b01;  // Select OutC as input B
                                RF_ScrSel <= 4'b1111; //Disable all
                                RF_RegSel <= 4'b1110; //Only R1
                                RF_FunSel <= 3'b010;
                            end
                        endcase
                        end


                        3'b100:  //R! is source
                        begin
                            case(_ALUSystem.IROut[8:6])
                            3'b000: //Dreg //pc
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxBSel <= 2'b00; //ALu to arf
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b010; //Load
                            end
                            3'b001: //Dreg //pc
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxBSel <= 2'b00; //ALu to arf
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b010; //Load
                            end
                            3'b010: //Dreg //SP
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxBSel <= 2'b00; //ALu to arf
                                ARF_RegSel <= 3'b110; //SP enable
                                ARF_FunSel <= 3'b010; //Load
                            end
                            3'b011: //Dreg //Ar
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxBSel <= 2'b00; //ALu to arf
                                ARF_RegSel <= 3'b101; //AR enable
                                ARF_FunSel <= 3'b010; //Load
                            end
                            3'b100: //Dreg //R1
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxASel <= 2'b00;  //ALU to rf
                                RF_RegSel <= 4'b0111; //Only R1
                                RF_FunSel <= 3'b010; //Load
                            end
                            3'b101: //Dreg //R2
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxASel <= 2'b00;  //ALU to rf
                                RF_RegSel <= 4'b1011; //Only R2
                                RF_FunSel <= 3'b010; //Load
                            end
                            3'b110: //Dreg //R3
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxASel <= 2'b00;  //ALU to rf
                                RF_RegSel <= 4'b1101; //Only R3
                                RF_FunSel <= 3'b010; //Load
                            end
                            3'b111: //Dreg //R4
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxASel <= 2'b00;  //ALU to rf
                                RF_RegSel <= 4'b1110; //Only R3
                                RF_FunSel <= 3'b010; //Load
                            end
                        endcase
                        end


                        3'b101:  //R2 is source
                        begin
                            case(_ALUSystem.IROut[8:6])
                            3'b000: //Dreg //pc
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxBSel <= 2'b00; //ALu to arf
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b010; //Load
                            end
                            3'b001: //Dreg //pc
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxBSel <= 2'b00; //ALu to arf
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b010; //Load
                            end
                            3'b010: //Dreg //SP
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxBSel <= 2'b00; //ALu to arf
                                ARF_RegSel <= 3'b110; //SP enable
                                ARF_FunSel <= 3'b010; //Load
                            end
                            3'b011: //Dreg //Ar
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxBSel <= 2'b00; //ALu to arf
                                ARF_RegSel <= 3'b101; //AR enable
                                ARF_FunSel <= 3'b010; //Load
                            end
                            3'b100: //Dreg //R1
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxASel <= 2'b00;  //ALU to rf
                                RF_RegSel <= 4'b0111; //Only R1
                                RF_FunSel <= 3'b010; //Load
                            end
                            3'b101: //Dreg //R2
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxASel <= 2'b00;  //ALU to rf
                                RF_RegSel <= 4'b1011; //Only R2
                                RF_FunSel <= 3'b010; //Load
                            end
                            3'b110: //Dreg //R3
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxASel <= 2'b00;  //ALU to rf
                                RF_RegSel <= 4'b1101; //Only R3
                                RF_FunSel <= 3'b010; //Load
                            end
                            3'b111: //Dreg //R4
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxASel <= 2'b00;  //ALU to rf
                                RF_RegSel <= 4'b1110; //Only R3
                                RF_FunSel <= 3'b010; //Load
                            end
                        endcase
                        end

                        3'b110:  //R3 is source
                        begin
                            case(_ALUSystem.IROut[8:6])
                            3'b000: //Dreg //pc
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxBSel <= 2'b00; //ALu to arf
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b010; //Load
                            end
                            3'b001: //Dreg //pc
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxBSel <= 2'b00; //ALu to arf
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b010; //Load
                            end
                            3'b010: //Dreg //SP
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxBSel <= 2'b00; //ALu to arf
                                ARF_RegSel <= 3'b110; //SP enable
                                ARF_FunSel <= 3'b010; //Load
                            end
                            3'b011: //Dreg //Ar
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxBSel <= 2'b00; //ALu to arf
                                ARF_RegSel <= 3'b101; //AR enable
                                ARF_FunSel <= 3'b010; //Load
                            end
                            3'b100: //Dreg //R1
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxASel <= 2'b00;  //ALU to rf
                                RF_RegSel <= 4'b0111; //Only R1
                                RF_FunSel <= 3'b010; //Load
                            end
                            3'b101: //Dreg //R2
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxASel <= 2'b00;  //ALU to rf
                                RF_RegSel <= 4'b1011; //Only R2
                                RF_FunSel <= 3'b010; //Load
                            end
                            3'b110: //Dreg //R3
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxASel <= 2'b00;  //ALU to rf
                                RF_RegSel <= 4'b1101; //Only R3
                                RF_FunSel <= 3'b010; //Load
                            end
                            3'b111: //Dreg //R4
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxASel <= 2'b00;  //ALU to rf
                                RF_RegSel <= 4'b1110; //Only R3
                                RF_FunSel <= 3'b010; //Load
                            end
                        endcase
                        end

                        3'b111:  //R4 is source
                        begin
                            case(_ALUSystem.IROut[8:6])
                            3'b000: //Dreg //pc
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxBSel <= 2'b00; //ALu to arf
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b010; //Load
                            end
                            3'b001: //Dreg //pc
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxBSel <= 2'b00; //ALu to arf
                                ARF_RegSel <= 3'b011; //PC enable
                                ARF_FunSel <= 3'b010; //Load
                            end
                            3'b010: //Dreg //SP
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxBSel <= 2'b00; //ALu to arf
                                ARF_RegSel <= 3'b110; //SP enable
                                ARF_FunSel <= 3'b010; //Load
                            end
                            3'b011: //Dreg //Ar
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxBSel <= 2'b00; //ALu to arf
                                ARF_RegSel <= 3'b101; //AR enable
                                ARF_FunSel <= 3'b010; //Load
                            end
                            3'b100: //Dreg //R1
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxASel <= 2'b00;  //ALU to rf
                                RF_RegSel <= 4'b0111; //Only R1
                                RF_FunSel <= 3'b010; //Load
                            end
                            3'b101: //Dreg //R2
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxASel <= 2'b00;  //ALU to rf
                                RF_RegSel <= 4'b1011; //Only R2
                                RF_FunSel <= 3'b010; //Load
                            end
                            3'b110: //Dreg //R3
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxASel <= 2'b00;  //ALU to rf
                                RF_RegSel <= 4'b1101; //Only R3
                                RF_FunSel <= 3'b010; //Load
                            end
                            3'b111: //Dreg //R4
                            begin
                                ALU_FunSel <= 5'b00000; //A

                                //cycle happens

                                MuxASel <= 2'b00;  //ALU to rf
                                RF_RegSel <= 4'b1110; //Only R3
                                RF_FunSel <= 3'b010; //Load
                            end
                        endcase
                       
                        end
                    endcase
                     T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b000111: //LSL
                begin
                    ALU_FunSel <= 5'b11011; //LSL 16bit ///ancaq bu

                    //cycle happens here

                    case(_ALUSystem.IROut[8])
                    1'b0:
                    begin
                        MuxBSel <= 2'b00; //ALU out
                        ARF_FunSel <= 3'b010; //Load 

                        case(_ALUSystem.IROut[7:6])
                        2'b00: ARF_RegSel <= 3'b011; //PC
                        2'b01: ARF_RegSel <= 3'b011; //PC
                        2'b10: ARF_RegSel <= 3'b110; //sp
                        2'b11: ARF_RegSel <= 3'b101; //ar
                        endcase
                    end

                    1'b1:
                    begin
                        MuxASel <= 2'b00; //ALU out
                        RF_FunSel <= 3'b010; //Load
                        RF_ScrSel <= 4'b1111; //Disable all
                        case(_ALUSystem.IROut[7:6])
                        2'b00: RF_RegSel <= 4'b0111; //R1
                        2'b01: RF_RegSel <= 4'b1011; //R2
                        2'b10: RF_RegSel <= 4'b1101; //R3
                        2'b11: RF_RegSel <= 4'b1110; //R4
                        endcase
                    end
                    endcase
                     T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b001000: //LSR    
                begin
                   ALU_FunSel <= 5'b11100; //LSR 16bit ///ancaq bu

                    //cycle happens here

                    case(_ALUSystem.IROut[8])
                    1'b0:
                    begin
                        MuxBSel <= 2'b00; //ALU out
                        ARF_FunSel <= 3'b010; //Load 

                        case(_ALUSystem.IROut[7:6])
                        2'b00: ARF_RegSel <= 3'b011; //PC
                        2'b01: ARF_RegSel <= 3'b011; //PC
                        2'b10: ARF_RegSel <= 3'b110; //sp
                        2'b11: ARF_RegSel <= 3'b101; //ar
                        endcase
                    end

                    1'b1:
                    begin
                        MuxASel <= 2'b00; //ALU out
                        RF_FunSel <= 3'b010; //Load
                        RF_ScrSel <= 4'b1111; //Disable all
                        case(_ALUSystem.IROut[7:6])
                        2'b00: RF_RegSel <= 4'b0111; //R1
                        2'b01: RF_RegSel <= 4'b1011; //R2
                        2'b10: RF_RegSel <= 4'b1101; //R3
                        2'b11: RF_RegSel <= 4'b1110; //R4
                        endcase
                    end
                    endcase
                     T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b001001: //ASR
                begin
                    ALU_FunSel <= 5'b11101; //ASR 16bit ///ancaq bu

                    //cycle happens here

                    case(_ALUSystem.IROut[8])
                    1'b0:
                    begin
                        MuxBSel <= 2'b00; //ALU out
                        ARF_FunSel <= 3'b010; //Load 

                        case(_ALUSystem.IROut[7:6])
                        2'b00: ARF_RegSel <= 3'b011; //PC
                        2'b01: ARF_RegSel <= 3'b011; //PC
                        2'b10: ARF_RegSel <= 3'b110; //sp
                        2'b11: ARF_RegSel <= 3'b101; //ar
                        endcase
                    end

                    1'b1:
                    begin
                        MuxASel <= 2'b00; //ALU out
                        RF_FunSel <= 3'b010; //Load
                        RF_ScrSel <= 4'b1111; //Disable all
                        case(_ALUSystem.IROut[7:6])
                        2'b00: RF_RegSel <= 4'b0111; //R1
                        2'b01: RF_RegSel <= 4'b1011; //R2
                        2'b10: RF_RegSel <= 4'b1101; //R3
                        2'b11: RF_RegSel <= 4'b1110; //R4
                        endcase
                    end
                    endcase
                     T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b001010: //CSL
                begin
                    ALU_FunSel <= 5'b11110; //CSL 16bit ///ancaq bu

                 

                    case(_ALUSystem.IROut[8])
                    1'b0:
                    begin
                        MuxBSel <= 2'b00; //ALU out
                        ARF_FunSel <= 3'b010; //Load 

                        case(_ALUSystem.IROut[7:6])
                        2'b00: ARF_RegSel <= 3'b011; //PC
                        2'b01: ARF_RegSel <= 3'b011; //PC
                        2'b10: ARF_RegSel <= 3'b110; //sp
                        2'b11: ARF_RegSel <= 3'b101; //ar
                        endcase
                    end

                    1'b1:
                    begin
                        MuxASel <= 2'b00; //ALU out
                        RF_FunSel <= 3'b010; //Load
                        RF_ScrSel <= 4'b1111; //Disable all
                        case(_ALUSystem.IROut[7:6])
                        2'b00: RF_RegSel <= 4'b0111; //R1
                        2'b01: RF_RegSel <= 4'b1011; //R2
                        2'b10: RF_RegSel <= 4'b1101; //R3
                        2'b11: RF_RegSel <= 4'b1110; //R4
                        endcase
                    end
                    endcase
                     T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b001011: //CSR
                begin
                   ALU_FunSel  <= 5'b11111; //CSR 16bit ///ancaq bu

                    //cycle happens here

                    case(_ALUSystem.IROut[8])
                    1'b0:
                    begin
                        MuxBSel <= 2'b00; //ALU out
                        ARF_FunSel <= 3'b010; //Load 

                        case(_ALUSystem.IROut[7:6])
                        2'b00: ARF_RegSel <= 3'b011; //PC
                        2'b01: ARF_RegSel <= 3'b011; //PC
                        2'b10: ARF_RegSel <= 3'b110; //sp
                        2'b11: ARF_RegSel <= 3'b101; //ar
                        endcase
                    end

                    1'b1:
                    begin
                        MuxASel <= 2'b00; //ALU out
                        RF_FunSel <= 3'b010; //Load
                        RF_ScrSel <= 4'b1111; //Disable all
                        case(_ALUSystem.IROut[7:6])
                        2'b00: RF_RegSel <= 4'b0111; //R1
                        2'b01: RF_RegSel <= 4'b1011; //R2
                        2'b10: RF_RegSel <= 4'b1101; //R3
                        2'b11: RF_RegSel <= 4'b1110; //R4
                        endcase
                    end
                    endcase
                     T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b001100: //AND
                begin
                    case(_ALUSystem.IROut[2])
                    1'b0:
                    begin
                        ARF_RegSel <= 3'b111; //All disable
                        case(_ALUSystem.IROut[1:0])
                        2'b00: ARF_OutCSel <= 2'b00; //PC
                        2'b01: ARF_OutCSel <= 2'b01; //PC
                        2'b10: ARF_OutCSel <= 2'b11; //SP
                        2'b11: ARF_OutCSel <= 2'b10; //AR
                        endcase
                        MuxASel <= 2'b01; //ARF to RF
                        RF_FunSel <= 3'b010; //Load
                        RF_ScrSel <= 4'b1110; //Enable S4 and Upload ARF value to it
                        RF_RegSel <= 4'b1111; //Disable all
                        RF_OutASel <= 3'b111; //Send S4 to ALU
                    end
                    1'b1:
                    begin
                        case(_ALUSystem.IROut[1:0])
                        2'b00: RF_OutBSel <= 3'b000; //R1
                        2'b01: RF_OutBSel <= 3'b001; //R2
                        2'b10: RF_OutBSel <= 3'b010; //R3
                        2'b11: RF_OutBSel <= 3'b011; //R4
                        endcase
                    end
                    endcase

                     T <= T + 1;
                end
            
////////////////////////////////////////////////////////////////
                6'b001101: //ORR
                begin
                    case(_ALUSystem.IROut[2])
                    1'b0:
                    begin
                        ARF_RegSel <= 3'b111; //All disable
                        case(_ALUSystem.IROut[1:0])
                        2'b00: ARF_OutCSel <= 2'b00; //PC
                        2'b01: ARF_OutCSel <= 2'b01; //PC
                        2'b10: ARF_OutCSel <= 2'b11; //SP
                        2'b11: ARF_OutCSel <= 2'b10; //AR
                        endcase
                        MuxASel <= 2'b01; //ARF to RF
                        RF_FunSel <= 3'b010; //Load
                        RF_ScrSel <= 4'b1110; //Enable S4 and Upload ARF value to it
                        RF_RegSel <= 4'b1111; //Disable all
                        RF_OutASel <= 3'b111; //Send S4 to ALU
                    end
                    1'b1:
                    begin
                        case(_ALUSystem.IROut[1:0])
                        2'b00: RF_OutBSel <= 3'b000; //R1
                        2'b01: RF_OutBSel <= 3'b001; //R2
                        2'b10: RF_OutBSel <= 3'b010; //R3
                        2'b11: RF_OutBSel <= 3'b011; //R4
                        endcase
                    end
                    endcase

                     T <= T + 1;
                end
   
////////////////////////////////////////////////////////////////
                6'b001110: //NOT
                begin
                    ALU_FunSel <= 5'b10010; //NOT 16bit

                    //cycle happens here

                    case(_ALUSystem.IROut[8])
                    1'b0:
                    begin
                        MuxBSel <= 2'b00; //ALU out
                        ARF_FunSel <= 3'b010; //Load 

                        case(_ALUSystem.IROut[7:6])
                        2'b00: ARF_RegSel <= 3'b011; //PC
                        2'b01: ARF_RegSel <= 3'b011; //PC
                        2'b10: ARF_RegSel <= 3'b110; //sp
                        2'b11: ARF_RegSel <= 3'b101; //ar
                        endcase
                    end

                    1'b1:
                    begin
                        MuxASel <= 2'b00; //ALU out
                        RF_FunSel <= 3'b010; //Load
                        RF_ScrSel <= 4'b1111; //Disable all
                        case(_ALUSystem.IROut[7:6])
                        2'b00: RF_RegSel <= 4'b0111; //R1
                        2'b01: RF_RegSel <= 4'b1011; //R2
                        2'b10: RF_RegSel <= 4'b1101; //R3
                        2'b11: RF_RegSel <= 4'b1110; //R4
                        endcase
                    end
                    endcase
                     T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b001111: //XOR
                begin
                    case(_ALUSystem.IROut[2])
                    1'b0:
                    begin
                        ARF_RegSel <= 3'b111; //All disable
                        case(_ALUSystem.IROut[1:0])
                        2'b00: ARF_OutCSel <= 2'b00; //PC
                        2'b01: ARF_OutCSel <= 2'b01; //PC
                        2'b10: ARF_OutCSel <= 2'b11; //SP
                        2'b11: ARF_OutCSel <= 2'b10; //AR
                        endcase
                        MuxASel <= 2'b01; //ARF to RF
                        RF_FunSel <= 3'b010; //Load
                        RF_ScrSel <= 4'b1110; //Enable S4 and Upload ARF value to it
                        RF_RegSel <= 4'b1111; //Disable all
                        RF_OutASel <= 3'b111; //Send S4 to ALU
                    end
                    1'b1:
                    begin
                        case(_ALUSystem.IROut[1:0])
                        2'b00: RF_OutBSel <= 3'b000; //R1
                        2'b01: RF_OutBSel <= 3'b001; //R2
                        2'b10: RF_OutBSel <= 3'b010; //R3
                        2'b11: RF_OutBSel <= 3'b011; //R4
                        endcase
                    end
                    endcase

                     T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b010000: //NAND
                begin
                    case(_ALUSystem.IROut[2])
                    1'b0:
                    begin
                        ARF_RegSel <= 3'b111; //All disable
                        case(_ALUSystem.IROut[1:0])
                        2'b00: ARF_OutCSel <= 2'b00; //PC
                        2'b01: ARF_OutCSel <= 2'b01; //PC
                        2'b10: ARF_OutCSel <= 2'b11; //SP
                        2'b11: ARF_OutCSel <= 2'b10; //AR
                        endcase
                        MuxASel <= 2'b01; //ARF to RF
                        RF_FunSel <= 3'b010; //Load
                        RF_ScrSel <= 4'b1110; //Enable S4 and Upload ARF value to it
                        RF_RegSel <= 4'b1111; //Disable all
                        RF_OutASel <= 3'b111; //Send S4 to ALU
                    end
                    1'b1:
                    begin
                        case(_ALUSystem.IROut[1:0])
                        2'b00: RF_OutBSel <= 3'b000; //R1
                        2'b01: RF_OutBSel <= 3'b001; //R2
                        2'b10: RF_OutBSel <= 3'b010; //R3
                        2'b11: RF_OutBSel <= 3'b011; //R4
                        endcase
                    end
                    endcase

                     T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b010001: //MOVH
                begin                                        
                    ARF_RegSel <= 3'b111; //pc disable
                    RF_RegSel <= 4'b1111;//disable all
                    RF_ScrSel <= 4'b1111;//disable all

                    T=8'b00000000;  //Time to 0
                end

////////////////////////////////////////////////////////////////
                6'b010010: //LDR (16bit)
                begin
                    MuxASel <= 2'b10; //Memory to RF
                    RF_FunSel <= 3'b010; //Load
                    RF_ScrSel <= 4'b1111; //Disable all
                    case(_ALUSystem.IROut[9:8])
                    2'b00: RF_RegSel <= 4'b1000; //Enable R1
                    2'b01: RF_RegSel <= 4'b1001; //Enable R2
                    2'b10: RF_RegSel <= 4'b1010; //Enable R3
                    2'b11: RF_RegSel <= 4'b1011; //Enable R4
                    endcase

                    T <= T + 1;
                end
            
////////////////////////////////////////////////////////////////
                6'b010011: //STR (16bit)
                begin
                    ARF_FunSel <= 3'b001; //Increment
                    ARF_RegSel <= 3'b101; //AR                    
                    ALU_FunSel <= 5'b10000; //Send A
                    MuxCSel <= 1'b0; //Send A to ALU
                    ARF_OutDSel <= 2'b10; //Send AR

                    T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b010100: //MOVL
                begin                                        
                    ARF_RegSel <= 3'b111; //pc disable
                    RF_RegSel <= 4'b1111;//disable all
                    RF_ScrSel <= 4'b1111;//disable all

                    T=8'b00000000;  //Time to 0
                end

////////////////////////////////////////////////////////////////
                6'b010101: //ADD 16bit
                begin
                    case(_ALUSystem.IROut[2])
                    1'b0:
                    begin
                        ARF_RegSel <= 3'b111; //All disable
                        case(_ALUSystem.IROut[1:0])
                        2'b00: ARF_OutCSel <= 2'b00; //PC
                        2'b01: ARF_OutCSel <= 2'b01; //PC
                        2'b10: ARF_OutCSel <= 2'b11; //SP
                        2'b11: ARF_OutCSel <= 2'b10; //AR
                        endcase
                        MuxASel <= 2'b01; //ARF to RF
                        RF_FunSel <= 3'b010; //Load
                        RF_ScrSel <= 4'b1110; //Enable S4 and Upload ARF value to it
                        RF_RegSel <= 4'b1111; //Disable all
                        RF_OutASel <= 3'b111; //Send S4 to ALU
                    end
                    1'b1:
                    begin
                        case(_ALUSystem.IROut[1:0])
                        2'b00: RF_OutBSel <= 3'b000; //R1
                        2'b01: RF_OutBSel <= 3'b001; //R2
                        2'b10: RF_OutBSel <= 3'b010; //R3
                        2'b11: RF_OutBSel <= 3'b011; //R4
                        endcase
                    end
                    endcase

                     T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b010110: //ADC 16bit
                begin
                    case(_ALUSystem.IROut[2])
                    1'b0:
                    begin
                        ARF_RegSel <= 3'b111; //All disable
                        case(_ALUSystem.IROut[1:0])
                        2'b00: ARF_OutCSel <= 2'b00; //PC
                        2'b01: ARF_OutCSel <= 2'b01; //PC
                        2'b10: ARF_OutCSel <= 2'b11; //SP
                        2'b11: ARF_OutCSel <= 2'b10; //AR
                        endcase
                        MuxASel <= 2'b01; //ARF to RF
                        RF_FunSel <= 3'b010; //Load
                        RF_ScrSel <= 4'b1110; //Enable S4 and Upload ARF value to it
                        RF_RegSel <= 4'b1111; //Disable all
                        RF_OutASel <= 3'b111; //Send S4 to ALU
                    end
                    1'b1:
                    begin
                        case(_ALUSystem.IROut[1:0])
                        2'b00: RF_OutBSel <= 3'b000; //R1
                        2'b01: RF_OutBSel <= 3'b001; //R2
                        2'b10: RF_OutBSel <= 3'b010; //R3
                        2'b11: RF_OutBSel <= 3'b011; //R4
                        endcase
                    end
                    endcase

                     T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b010111: //SUB 16bit
                begin
                    case(_ALUSystem.IROut[2])
                    1'b0:
                    begin
                        ARF_RegSel <= 3'b111; //All disable
                        case(_ALUSystem.IROut[1:0])
                        2'b00: ARF_OutCSel <= 2'b00; //PC
                        2'b01: ARF_OutCSel <= 2'b01; //PC
                        2'b10: ARF_OutCSel <= 2'b11; //SP
                        2'b11: ARF_OutCSel <= 2'b10; //AR
                        endcase
                        MuxASel <= 2'b01; //ARF to RF
                        RF_FunSel <= 3'b010; //Load
                        RF_ScrSel <= 4'b1110; //Enable S4 and Upload ARF value to it
                        RF_RegSel <= 4'b1111; //Disable all
                        RF_OutASel <= 3'b111; //Send S4 to ALU
                    end
                    1'b1:
                    begin
                        case(_ALUSystem.IROut[1:0])
                        2'b00: RF_OutBSel <= 3'b000; //R1
                        2'b01: RF_OutBSel <= 3'b001; //R2
                        2'b10: RF_OutBSel <= 3'b010; //R3
                        2'b11: RF_OutBSel <= 3'b011; //R4
                        endcase
                    end
                    endcase

                     T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b011000: //MOVS
                begin
                    ALU_WF <= 1'b1; //Allow write to ALU flags
                    ALU_FunSel <= 5'b10000; //MOVL 16bit //send only A to RF
                    

                    case(_ALUSystem.IROut[8])
                    1'b0:
                    begin
                        MuxBSel <= 2'b00; //ALU out
                        ARF_FunSel <= 3'b010; //Load 

                        case(_ALUSystem.IROut[7:6])
                        2'b00: ARF_RegSel <= 3'b011; //PC
                        2'b01: ARF_RegSel <= 3'b011; //PC
                        2'b10: ARF_RegSel <= 3'b110; //sp
                        2'b11: ARF_RegSel <= 3'b101; //ar
                        endcase
                    end

                    1'b1:
                    begin
                        MuxASel <= 2'b00; //ALU out
                        RF_FunSel <= 3'b010; //Load
                        RF_ScrSel <= 4'b1111; //Disable all
                        case(_ALUSystem.IROut[7:6])
                        2'b00: RF_RegSel <= 4'b0111; //R1
                        2'b01: RF_RegSel <= 4'b1011; //R2
                        2'b10: RF_RegSel <= 4'b1101; //R3
                        2'b11: RF_RegSel <= 4'b1110; //R4
                        endcase
                    end
                    endcase
                     T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b011001: //ADDS 16bit
                begin
                    case(_ALUSystem.IROut[2])
                    1'b0:
                    begin
                        ARF_RegSel <= 3'b111; //All disable
                        case(_ALUSystem.IROut[1:0])
                        2'b00: ARF_OutCSel <= 2'b00; //PC
                        2'b01: ARF_OutCSel <= 2'b01; //PC
                        2'b10: ARF_OutCSel <= 2'b11; //SP
                        2'b11: ARF_OutCSel <= 2'b10; //AR
                        endcase
                        MuxASel <= 2'b01; //ARF to RF
                        RF_FunSel <= 3'b010; //Load
                        RF_ScrSel <= 4'b1110; //Enable S4 and Upload ARF value to it
                        RF_RegSel <= 4'b1111; //Disable all
                        RF_OutASel <= 3'b111; //Send S4 to ALU
                    end
                    1'b1:
                    begin
                        case(_ALUSystem.IROut[1:0])
                        2'b00: RF_OutBSel <= 3'b000; //R1
                        2'b01: RF_OutBSel <= 3'b001; //R2
                        2'b10: RF_OutBSel <= 3'b010; //R3
                        2'b11: RF_OutBSel <= 3'b011; //R4
                        endcase
                    end
                    endcase
                     T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b011010: //SUBS 16bit
                begin
                    case(_ALUSystem.IROut[2])
                    1'b0:
                    begin
                        ARF_RegSel <= 3'b111; //All disable
                        case(_ALUSystem.IROut[1:0])
                        2'b00: ARF_OutCSel <= 2'b00; //PC
                        2'b01: ARF_OutCSel <= 2'b01; //PC
                        2'b10: ARF_OutCSel <= 2'b11; //SP
                        2'b11: ARF_OutCSel <= 2'b10; //AR
                        endcase
                        MuxASel <= 2'b01; //ARF to RF
                        RF_FunSel <= 3'b010; //Load
                        RF_ScrSel <= 4'b1110; //Enable S4 and Upload ARF value to it
                        RF_RegSel <= 4'b1111; //Disable all
                        RF_OutASel <= 3'b111; //Send S4 to ALU
                    end
                    1'b1:
                    begin
                        case(_ALUSystem.IROut[1:0])
                        2'b00: RF_OutBSel <= 3'b000; //R1
                        2'b01: RF_OutBSel <= 3'b001; //R2
                        2'b10: RF_OutBSel <= 3'b010; //R3
                        2'b11: RF_OutBSel <= 3'b011; //R4
                        endcase
                    end
                    endcase

                     T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b011011: //ANDS 16bit
                begin
                    case(_ALUSystem.IROut[2])
                    1'b0:
                    begin
                        ARF_RegSel <= 3'b111; //All disable
                        case(_ALUSystem.IROut[1:0])
                        2'b00: ARF_OutCSel <= 2'b00; //PC
                        2'b01: ARF_OutCSel <= 2'b01; //PC
                        2'b10: ARF_OutCSel <= 2'b11; //SP
                        2'b11: ARF_OutCSel <= 2'b10; //AR
                        endcase
                        MuxASel <= 2'b01; //ARF to RF
                        RF_FunSel <= 3'b010; //Load
                        RF_ScrSel <= 4'b1110; //Enable S4 and Upload ARF value to it
                        RF_RegSel <= 4'b1111; //Disable all
                        RF_OutASel <= 3'b111; //Send S4 to ALU
                    end
                    1'b1:
                    begin
                        case(_ALUSystem.IROut[1:0])
                        2'b00: RF_OutBSel <= 3'b000; //R1
                        2'b01: RF_OutBSel <= 3'b001; //R2
                        2'b10: RF_OutBSel <= 3'b010; //R3
                        2'b11: RF_OutBSel <= 3'b011; //R4
                        endcase
                    end
                    endcase

                     T <= T + 1;
                end
            
////////////////////////////////////////////////////////////////
                6'b011100: //ORRS
                begin
                    case(_ALUSystem.IROut[2])
                    1'b0:
                    begin
                        ARF_RegSel <= 3'b111; //All disable
                        case(_ALUSystem.IROut[1:0])
                        2'b00: ARF_OutCSel <= 2'b00; //PC
                        2'b01: ARF_OutCSel <= 2'b01; //PC
                        2'b10: ARF_OutCSel <= 2'b11; //SP
                        2'b11: ARF_OutCSel <= 2'b10; //AR
                        endcase
                        MuxASel <= 2'b01; //ARF to RF
                        RF_FunSel <= 3'b010; //Load
                        RF_ScrSel <= 4'b1110; //Enable S4 and Upload ARF value to it
                        RF_RegSel <= 4'b1111; //Disable all
                        RF_OutASel <= 3'b111; //Send S4 to ALU
                    end
                    1'b1:
                    begin
                        case(_ALUSystem.IROut[1:0])
                        2'b00: RF_OutBSel <= 3'b000; //R1
                        2'b01: RF_OutBSel <= 3'b001; //R2
                        2'b10: RF_OutBSel <= 3'b010; //R3
                        2'b11: RF_OutBSel <= 3'b011; //R4
                        endcase
                    end
                    endcase

                     T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b011101: //XORS
                begin
                    case(_ALUSystem.IROut[2])
                    1'b0:
                    begin
                        ARF_RegSel <= 3'b111; //All disable
                        case(_ALUSystem.IROut[1:0])
                        2'b00: ARF_OutCSel <= 2'b00; //PC
                        2'b01: ARF_OutCSel <= 2'b01; //PC
                        2'b10: ARF_OutCSel <= 2'b11; //SP
                        2'b11: ARF_OutCSel <= 2'b10; //AR
                        endcase
                        MuxASel <= 2'b01; //ARF to RF
                        RF_FunSel <= 3'b010; //Load
                        RF_ScrSel <= 4'b1110; //Enable S4 and Upload ARF value to it
                        RF_RegSel <= 4'b1111; //Disable all
                        RF_OutASel <= 3'b111; //Send S4 to ALU
                    end
                    1'b1:
                    begin
                        case(_ALUSystem.IROut[1:0])
                        2'b00: RF_OutBSel <= 3'b000; //R1
                        2'b01: RF_OutBSel <= 3'b001; //R2
                        2'b10: RF_OutBSel <= 3'b010; //R3
                        2'b11: RF_OutBSel <= 3'b011; //R4
                        endcase
                    end
                    endcase

                     T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b011110: //BX
                begin
                    ALU_FunSel <= 5'b10000; //send A
                    MuxCSel <= 1'b0; //send lower bits to memory
                    Mem_CS <= 1'b1; //enable memory
                    Mem_WR <= 1'b1; //write to memory
                    ARF_OutDSel <= 2'b11; //send SP

                    T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b011111: //BL
                begin
                    ARF_FunSel <= 3'b010; //LOAD
                    ARF_RegSel <= 3'b011; //PC enable

                    T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b100000: //LDRIM
                begin
                    ARF_OutDSel <= 2'b10; //Send AR to memory
                    T <= T + 1;
                end

            endcase
        end
         
         
         
         
        else if(T == 8'b00000101)
        begin
            IR_Write <= 0;
            case(_ALUSystem.IROut[15:10])
 ////////////////////////////////////////////////
                6'b000000: //BRA
                begin                                        
                    ARF_RegSel <= 3'b111; //pc disable
                    RF_RegSel <= 4'b1111;//disable all
                    RF_ScrSel <= 4'b1111;//disable all

                    T=8'b00000000;  //Time to 0
                end

////////////////////////////////////////////////
                6'b000001: //BNE
                begin                                        
                    ARF_RegSel <= 3'b111; //pc disable
                    RF_RegSel <= 4'b1111;//disable all
                    RF_ScrSel <= 4'b1111;//disable all

                    T=8'b00000000;  //Time to 0
                end

////////////////////////////////////////////////
                6'b000010: //BEQ
                begin                                        
                    ARF_RegSel <= 3'b111; //pc disable
                    RF_RegSel <= 4'b1111;//disable all
                    RF_ScrSel <= 4'b1111;//disable all

                    T=8'b00000000;  //Time to 0
                end

////////////////////////////////////////////////
                6'b000011: //POP
                begin     
                    Mem_CS <= 0; //Memory chip enable                                   
                    ARF_RegSel <= 3'b111; //pc disable
                    RF_RegSel <= 4'b1111;//disable all
                    RF_ScrSel <= 4'b1111;//disable all

                    T=8'b00000000;  //Time to 0
                end

////////////////////////////////////////////////
                6'b000100: //PUSH
                begin                                        
                    ARF_RegSel <= 3'b111; //pc disable
                    RF_RegSel <= 4'b1111;//disable all
                    RF_ScrSel <= 4'b1111;//disable all

                    T=8'b00000000;  //Time to 0
                end

////////////////////////////////////////////////
                6'b000101: //INC
                begin                                        
                    ARF_RegSel <= 3'b111; //pc disable
                    RF_RegSel <= 4'b1111;//disable all
                    RF_ScrSel <= 4'b1111;//disable all

                    T=8'b00000000;  //Time to 0
                end

////////////////////////////////////////////////
                6'b000110: //DEC
                begin                                        
                    ARF_RegSel <= 3'b111; //pc disable
                    RF_RegSel <= 4'b1111;//disable all
                    RF_ScrSel <= 4'b1111;//disable all

                    T=8'b00000000;  //Time to 0
                end

////////////////////////////////////////////////
                6'b000111: //LSL
                begin                                        
                    ARF_RegSel <= 3'b111; //pc disable
                    RF_RegSel <= 4'b1111;//disable all
                    RF_ScrSel <= 4'b1111;//disable all

                    T=8'b00000000;  //Time to 0
                end

////////////////////////////////////////////////
                6'b001000: //LSR
                begin                                        
                    ARF_RegSel <= 3'b111; //pc disable
                    RF_RegSel <= 4'b1111;//disable all
                    RF_ScrSel <= 4'b1111;//disable all

                    T=8'b00000000;  //Time to 0
                end

////////////////////////////////////////////////
                6'b001001: //ASR
                begin                                        
                    ARF_RegSel <= 3'b111; //pc disable
                    RF_RegSel <= 4'b1111;//disable all
                    RF_ScrSel <= 4'b1111;//disable all

                    T=8'b00000000;  //Time to 0
                end

////////////////////////////////////////////////
                6'b001010: //CSL
                begin                                        
                    ARF_RegSel <= 3'b111; //pc disable
                    RF_RegSel <= 4'b1111;//disable all
                    RF_ScrSel <= 4'b1111;//disable all

                    T=8'b00000000;  //Time to 0
                end

////////////////////////////////////////////////
                6'b001011: //CSR
                begin                                        
                    ARF_RegSel <= 3'b111; //pc disable
                    RF_RegSel <= 4'b1111;//disable all
                    RF_ScrSel <= 4'b1111;//disable all

                    T=8'b00000000;  //Time to 0
                end

////////////////////////////////////////////////
                6'b001100: //AND
                begin
                    //cycle to send result to DSTReg
                    case(_ALUSystem.IROut[8]) 
                    1'b0://First bit says ARF
                    begin
                        MuxBSel <= 2'b00; //ALU out to ARF
                        ARF_FunSel <= 3'b010; //Load
                        case(_ALUSystem.IROut[7:6])
                        2'b00: ARF_RegSel <= 3'b011; //PC
                        2'b01: ARF_RegSel <= 3'b011; //PC
                        2'b10: ARF_RegSel <= 3'b110; //SP
                        2'b11: ARF_RegSel <= 3'b101; //AR
                        endcase
                    end
                    1'b1: //First bit says RF
                    begin
                        MuxASel <= 2'b00; //ALU out to RF
                        RF_FunSel <= 3'b010; //Load
                        RF_ScrSel <= 4'b1111; //Disable all
                        case(_ALUSystem.IROut[7:6])
                        2'b00: RF_RegSel <= 4'b0111; //R1
                        2'b01: RF_RegSel <= 4'b1011; //R2
                        2'b10: RF_RegSel <= 4'b1101; //R3
                        2'b11: RF_RegSel <= 4'b1110; //R4
                        endcase
                    end
                    endcase
                     T <= T + 1;
                end

////////////////////////////////////////////////
                6'b001101: //ORR
                begin
                    //cycle to send result to DSTReg
                    case(_ALUSystem.IROut[8]) 
                    1'b0://First bit says ARF
                    begin
                        MuxBSel <= 2'b00; //ALU out to ARF
                        ARF_FunSel <= 3'b010; //Load
                        case(_ALUSystem.IROut[7:6])
                        2'b00: ARF_RegSel <= 3'b011; //PC
                        2'b01: ARF_RegSel <= 3'b011; //PC
                        2'b10: ARF_RegSel <= 3'b110; //SP
                        2'b11: ARF_RegSel <= 3'b101; //AR
                        endcase
                    end
                    1'b1: //First bit says RF
                    begin
                        MuxASel <= 2'b00; //ALU out to RF
                        RF_FunSel <= 3'b010; //Load
                        RF_ScrSel <= 4'b1111; //Disable all
                        case(_ALUSystem.IROut[7:6])
                        2'b00: RF_RegSel <= 4'b0111; //R1
                        2'b01: RF_RegSel <= 4'b1011; //R2
                        2'b10: RF_RegSel <= 4'b1101; //R3
                        2'b11: RF_RegSel <= 4'b1110; //R4
                        endcase
                    end
                    endcase
                     T <= T + 1;
                end

////////////////////////////////////////////////
                6'b001110: //NOT
                begin                                        
                    ARF_RegSel <= 3'b111; //pc disable
                    RF_RegSel <= 4'b1111;//disable all
                    RF_ScrSel <= 4'b1111;//disable all

                    T=8'b00000000;  //Time to 0
                end

////////////////////////////////////////////////
                6'b001111: //XOR
                begin
                    //cycle to send result to DSTReg
                    case(_ALUSystem.IROut[8]) 
                    1'b0://First bit says ARF
                    begin
                        MuxBSel <= 2'b00; //ALU out to ARF
                        ARF_FunSel <= 3'b010; //Load
                        case(_ALUSystem.IROut[7:6])
                        2'b00: ARF_RegSel <= 3'b011; //PC
                        2'b01: ARF_RegSel <= 3'b011; //PC
                        2'b10: ARF_RegSel <= 3'b110; //SP
                        2'b11: ARF_RegSel <= 3'b101; //AR
                        endcase
                    end
                    1'b1: //First bit says RF
                    begin
                        MuxASel <= 2'b00; //ALU out to RF
                        RF_FunSel <= 3'b010; //Load
                        RF_ScrSel <= 4'b1111; //Disable all
                        case(_ALUSystem.IROut[7:6])
                        2'b00: RF_RegSel <= 4'b0111; //R1
                        2'b01: RF_RegSel <= 4'b1011; //R2
                        2'b10: RF_RegSel <= 4'b1101; //R3
                        2'b11: RF_RegSel <= 4'b1110; //R4
                        endcase
                    end
                    endcase
                     T <= T + 1;
                end

////////////////////////////////////////////////
                6'b010000: //NAND
                begin
                    //cycle to send result to DSTReg
                    case(_ALUSystem.IROut[8]) 
                    1'b0://First bit says ARF
                    begin
                        MuxBSel <= 2'b00; //ALU out to ARF
                        ARF_FunSel <= 3'b010; //Load
                        case(_ALUSystem.IROut[7:6])
                        2'b00: ARF_RegSel <= 3'b011; //PC
                        2'b01: ARF_RegSel <= 3'b011; //PC
                        2'b10: ARF_RegSel <= 3'b110; //SP
                        2'b11: ARF_RegSel <= 3'b101; //AR
                        endcase
                    end
                    1'b1: //First bit says RF
                    begin
                        MuxASel <= 2'b00; //ALU out to RF
                        RF_FunSel <= 3'b010; //Load
                        RF_ScrSel <= 4'b1111; //Disable all
                        case(_ALUSystem.IROut[7:6])
                        2'b00: RF_RegSel <= 4'b0111; //R1
                        2'b01: RF_RegSel <= 4'b1011; //R2
                        2'b10: RF_RegSel <= 4'b1101; //R3
                        2'b11: RF_RegSel <= 4'b1110; //R4
                        endcase
                    end
                    endcase
                     T <= T + 1;
                end


////////////////////////////////////////////////////////////////
                6'b010010: //LDR (16bit)
                begin                    
                    ARF_RegSel <= 3'b111; //all disable
                    RF_RegSel <= 4'b1111;//disable all
                    RF_ScrSel <= 4'b1111;//disable all

                    T=8'b00000000;  //Time to 0
                end
            
            
////////////////////////////////////////////////////////////////
                6'b010011: //STR (16bit)
                begin
                    ARF_RegSel <= 3'b111; //Disable all
                    ALU_FunSel <= 5'b10000; //Send A
                    MuxCSel <= 1'b1; //Send higher bits

                    T <= T + 1;
                end


////////////////////////////////////////////////
                6'b010101: //ADD 16bit
                begin
                    //cycle to send result to DSTReg
                    case(_ALUSystem.IROut[8]) 
                    1'b0://First bit says ARF
                    begin
                        MuxBSel <= 2'b00; //ALU out to ARF
                        ARF_FunSel <= 3'b010; //Load
                        case(_ALUSystem.IROut[7:6])
                        2'b00: ARF_RegSel <= 3'b011; //PC
                        2'b01: ARF_RegSel <= 3'b011; //PC
                        2'b10: ARF_RegSel <= 3'b110; //SP
                        2'b11: ARF_RegSel <= 3'b101; //AR
                        endcase
                    end
                    1'b1: //First bit says RF
                    begin
                        MuxASel <= 2'b00; //ALU out to RF
                        RF_FunSel <= 3'b010; //Load
                        RF_ScrSel <= 4'b1111; //Disable all
                        case(_ALUSystem.IROut[7:6])
                        2'b00: RF_RegSel <= 4'b0111; //R1
                        2'b01: RF_RegSel <= 4'b1011; //R2
                        2'b10: RF_RegSel <= 4'b1101; //R3
                        2'b11: RF_RegSel <= 4'b1110; //R4
                        endcase
                    end
                    endcase
                     T <= T + 1;
                end

////////////////////////////////////////////////
                6'b010110: //ADC 16bit
                begin
                    //cycle to send result to DSTReg
                    case(_ALUSystem.IROut[8]) 
                    1'b0://First bit says ARF
                    begin
                        MuxBSel <= 2'b00; //ALU out to ARF
                        ARF_FunSel <= 3'b010; //Load
                        case(_ALUSystem.IROut[7:6])
                        2'b00: ARF_RegSel <= 3'b011; //PC
                        2'b01: ARF_RegSel <= 3'b011; //PC
                        2'b10: ARF_RegSel <= 3'b110; //SP
                        2'b11: ARF_RegSel <= 3'b101; //AR
                        endcase
                    end
                    1'b1: //First bit says RF
                    begin
                        MuxASel <= 2'b00; //ALU out to RF
                        RF_FunSel <= 3'b010; //Load
                        RF_ScrSel <= 4'b1111; //Disable all
                        case(_ALUSystem.IROut[7:6])
                        2'b00: RF_RegSel <= 4'b0111; //R1
                        2'b01: RF_RegSel <= 4'b1011; //R2
                        2'b10: RF_RegSel <= 4'b1101; //R3
                        2'b11: RF_RegSel <= 4'b1110; //R4
                        endcase
                    end
                    endcase
                     T <= T + 1;
                end

////////////////////////////////////////////////
                6'b010111: //SUB 16bit
                begin
                    //cycle to send result to DSTReg
                    case(_ALUSystem.IROut[8]) 
                    1'b0://First bit says ARF
                    begin
                        MuxBSel <= 2'b00; //ALU out to ARF
                        ARF_FunSel <= 3'b010; //Load
                        case(_ALUSystem.IROut[7:6])
                        2'b00: ARF_RegSel <= 3'b011; //PC
                        2'b01: ARF_RegSel <= 3'b011; //PC
                        2'b10: ARF_RegSel <= 3'b110; //SP
                        2'b11: ARF_RegSel <= 3'b101; //AR
                        endcase
                    end
                    1'b1: //First bit says RF
                    begin
                        MuxASel <= 2'b00; //ALU out to RF
                        RF_FunSel <= 3'b010; //Load
                        RF_ScrSel <= 4'b1111; //Disable all
                        case(_ALUSystem.IROut[7:6])
                        2'b00: RF_RegSel <= 4'b0111; //R1
                        2'b01: RF_RegSel <= 4'b1011; //R2
                        2'b10: RF_RegSel <= 4'b1101; //R3
                        2'b11: RF_RegSel <= 4'b1110; //R4
                        endcase
                    end
                    endcase
                     T <= T + 1;
                end

////////////////////////////////////////////////
                6'b011000: //MOVS
                begin                                        
                    ARF_RegSel <= 3'b111; //pc disable
                    RF_RegSel <= 4'b1111;//disable all
                    RF_ScrSel <= 4'b1111;//disable all

                    T=8'b00000000;  //Time to 0
                end

////////////////////////////////////////////////
                6'b011001: //ADDS 16bit
                begin
                    //cycle to send result to DSTReg
                    case(_ALUSystem.IROut[8]) 
                    1'b0://First bit says ARF
                    begin
                        MuxBSel <= 2'b00; //ALU out to ARF
                        ARF_FunSel <= 3'b010; //Load
                        case(_ALUSystem.IROut[7:6])
                        2'b00: ARF_RegSel <= 3'b011; //PC
                        2'b01: ARF_RegSel <= 3'b011; //PC
                        2'b10: ARF_RegSel <= 3'b110; //SP
                        2'b11: ARF_RegSel <= 3'b101; //AR
                        endcase
                    end
                    1'b1: //First bit says RF
                    begin
                        MuxASel <= 2'b00; //ALU out to RF
                        RF_FunSel <= 3'b010; //Load
                        RF_ScrSel <= 4'b1111; //Disable all
                        case(_ALUSystem.IROut[7:6])
                        2'b00: RF_RegSel <= 4'b0111; //R1
                        2'b01: RF_RegSel <= 4'b1011; //R2
                        2'b10: RF_RegSel <= 4'b1101; //R3
                        2'b11: RF_RegSel <= 4'b1110; //R4
                        endcase
                    end
                    endcase
                     T <= T + 1;
                end

////////////////////////////////////////////////
                6'b011010: //SUBS 16bit
                begin
                    //cycle to send result to DSTReg
                    case(_ALUSystem.IROut[8]) 
                    1'b0://First bit says ARF
                    begin
                        MuxBSel <= 2'b00; //ALU out to ARF
                        ARF_FunSel <= 3'b010; //Load
                        case(_ALUSystem.IROut[7:6])
                        2'b00: ARF_RegSel <= 3'b011; //PC
                        2'b01: ARF_RegSel <= 3'b011; //PC
                        2'b10: ARF_RegSel <= 3'b110; //SP
                        2'b11: ARF_RegSel <= 3'b101; //AR
                        endcase
                    end
                    1'b1: //First bit says RF
                    begin
                        MuxASel <= 2'b00; //ALU out to RF
                        RF_FunSel <= 3'b010; //Load
                        RF_ScrSel <= 4'b1111; //Disable all
                        case(_ALUSystem.IROut[7:6])
                        2'b00: RF_RegSel <= 4'b0111; //R1
                        2'b01: RF_RegSel <= 4'b1011; //R2
                        2'b10: RF_RegSel <= 4'b1101; //R3
                        2'b11: RF_RegSel <= 4'b1110; //R4
                        endcase
                    end
                    endcase
                     T <= T + 1;
                end

////////////////////////////////////////////////
                6'b011011: //ANDS 16bit
                begin
                    //cycle to send result to DSTReg
                    case(_ALUSystem.IROut[8]) 
                    1'b0://First bit says ARF
                    begin
                        MuxBSel <= 2'b00; //ALU out to ARF
                        ARF_FunSel <= 3'b010; //Load
                        case(_ALUSystem.IROut[7:6])
                        2'b00: ARF_RegSel <= 3'b011; //PC
                        2'b01: ARF_RegSel <= 3'b011; //PC
                        2'b10: ARF_RegSel <= 3'b110; //SP
                        2'b11: ARF_RegSel <= 3'b101; //AR
                        endcase
                    end
                    1'b1: //First bit says RF
                    begin
                        MuxASel <= 2'b00; //ALU out to RF
                        RF_FunSel <= 3'b010; //Load
                        RF_ScrSel <= 4'b1111; //Disable all
                        case(_ALUSystem.IROut[7:6])
                        2'b00: RF_RegSel <= 4'b0111; //R1
                        2'b01: RF_RegSel <= 4'b1011; //R2
                        2'b10: RF_RegSel <= 4'b1101; //R3
                        2'b11: RF_RegSel <= 4'b1110; //R4
                        endcase
                    end
                    endcase
                     T <= T + 1;
                end

////////////////////////////////////////////////
                6'b011100: //ORRS
                begin
                    //cycle to send result to DSTReg
                    case(_ALUSystem.IROut[8]) 
                    1'b0://First bit says ARF
                    begin
                        MuxBSel <= 2'b00; //ALU out to ARF
                        ARF_FunSel <= 3'b010; //Load
                        case(_ALUSystem.IROut[7:6])
                        2'b00: ARF_RegSel <= 3'b011; //PC
                        2'b01: ARF_RegSel <= 3'b011; //PC
                        2'b10: ARF_RegSel <= 3'b110; //SP
                        2'b11: ARF_RegSel <= 3'b101; //AR
                        endcase
                    end
                    1'b1: //First bit says RF
                    begin
                        MuxASel <= 2'b00; //ALU out to RF
                        RF_FunSel <= 3'b010; //Load
                        RF_ScrSel <= 4'b1111; //Disable all
                        case(_ALUSystem.IROut[7:6])
                        2'b00: RF_RegSel <= 4'b0111; //R1
                        2'b01: RF_RegSel <= 4'b1011; //R2
                        2'b10: RF_RegSel <= 4'b1101; //R3
                        2'b11: RF_RegSel <= 4'b1110; //R4
                        endcase
                    end
                    endcase
                     T <= T + 1;
                end

////////////////////////////////////////////////
                6'b011101: //XORS
                begin
                    //cycle to send result to DSTReg
                    case(_ALUSystem.IROut[8]) 
                    1'b0://First bit says ARF
                    begin
                        MuxBSel <= 2'b00; //ALU out to ARF
                        ARF_FunSel <= 3'b010; //Load
                        case(_ALUSystem.IROut[7:6])
                        2'b00: ARF_RegSel <= 3'b011; //PC
                        2'b01: ARF_RegSel <= 3'b011; //PC
                        2'b10: ARF_RegSel <= 3'b110; //SP
                        2'b11: ARF_RegSel <= 3'b101; //AR
                        endcase
                    end
                    1'b1: //First bit says RF
                    begin
                        MuxASel <= 2'b00; //ALU out to RF
                        RF_FunSel <= 3'b010; //Load
                        RF_ScrSel <= 4'b1111; //Disable all
                        case(_ALUSystem.IROut[7:6])
                        2'b00: RF_RegSel <= 4'b0111; //R1
                        2'b01: RF_RegSel <= 4'b1011; //R2
                        2'b10: RF_RegSel <= 4'b1101; //R3
                        2'b11: RF_RegSel <= 4'b1110; //R4
                        endcase
                    end
                    endcase
                     T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b011110: //BX
                begin
                    ALU_FunSel <= 5'b10000; //send A
                    MuxCSel <= 1'b1; //send higher bits to memory
                    Mem_CS <= 1'b1; //enable memory
                    Mem_WR <= 1'b1; //write to memory
                    ARF_OutDSel <= 2'b11; //send SP

                    T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b011111: //BL
                begin                                        
                    ARF_RegSel <= 3'b111; //pc disable
                    RF_RegSel <= 4'b1111;//disable all
                    RF_ScrSel <= 4'b1111;//disable all

                    T=8'b00000000;  //Time to 0
                end

////////////////////////////////////////////////////////////////
                6'b100000: //LDRIM
                begin
                    MuxASel <= 2'b10; //Memory to RF
                    RF_FunSel <= 3'b010; //Load
                    RF_ScrSel <= 4'b1111; //Disable all
                    case(_ALUSystem.IROut[9:8])
                        2'b00: RF_RegSel <= 4'b0111; //R1
                        2'b01: RF_RegSel <= 4'b1011; //R2
                        2'b10: RF_RegSel <= 4'b1101; //R3
                        2'b11: RF_RegSel <= 4'b1110; //R4
                    endcase

                    T <= T + 1;
                end

            endcase
            end


    else if(T == 8'b00000110)
        begin
            IR_Write <= 0;
            case(_ALUSystem.IROut[15:10])
    ////////////////////////////////////////////////
                6'b001100: //AND
                begin                                        
                    ARF_RegSel <= 3'b111; //pc disable
                    RF_RegSel <= 4'b1111;//disable all
                    RF_ScrSel <= 4'b1111;//disable all

                    T=8'b00000000;  //Time to 0
                end

    ////////////////////////////////////////////////
                6'b001101: //ORR
                begin                                        
                    ARF_RegSel <= 3'b111; //pc disable
                    RF_RegSel <= 4'b1111;//disable all
                    RF_ScrSel <= 4'b1111;//disable all

                    T=8'b00000000;  //Time to 0
                end
    
    ////////////////////////////////////////////////
                6'b001111: //XOR
                begin                                        
                    ARF_RegSel <= 3'b111; //pc disable
                    RF_RegSel <= 4'b1111;//disable all
                    RF_ScrSel <= 4'b1111;//disable all

                    T=8'b00000000;  //Time to 0
                end

    ////////////////////////////////////////////////
                6'b010000: //NAND
                begin                                        
                    ARF_RegSel <= 3'b111; //pc disable
                    RF_RegSel <= 4'b1111;//disable all
                    RF_ScrSel <= 4'b1111;//disable all

                    T=8'b00000000;  //Time to 0
                end

////////////////////////////////////////////////////////////////
                6'b010010: //LDR (16bit)
                begin                                        
                    //No need to do anything
                    T=8'b00000000;  //Time to 0
                end
            
////////////////////////////////////////////////////////////////
                6'b010011: //STR (16bit)
                begin
                    ARF_RegSel <= 3'b111; //all disable
                    RF_RegSel <= 4'b1111;//disable all
                    RF_ScrSel <= 4'b1111;//disable all

                    T=8'b00000000;  //Time to 0
                end

///////////////////////////////////////////////////////////////
                6'b010101: //ADD 16bit
                begin                                        
                    ARF_RegSel <= 3'b111; //pc disable
                    RF_RegSel <= 4'b1111;//disable all
                    RF_ScrSel <= 4'b1111;//disable all

                    T=8'b00000000;  //Time to 0
                end

///////////////////////////////////////////////////////////////
                6'b010110: //ADC 16bit
                begin                                        
                    ARF_RegSel <= 3'b111; //pc disable
                    RF_RegSel <= 4'b1111;//disable all
                    RF_ScrSel <= 4'b1111;//disable all

                    T=8'b00000000;  //Time to 0
                end

///////////////////////////////////////////////////////////////
                6'b010111: //SUB 16bit
                begin                                        
                    ARF_RegSel <= 3'b111; //pc disable
                    RF_RegSel <= 4'b1111;//disable all
                    RF_ScrSel <= 4'b1111;//disable all

                    T=8'b00000000;  //Time to 0
                end

///////////////////////////////////////////////////////////////
                6'b011001: //ADDS 16bit
                begin                                        
                    ARF_RegSel <= 3'b111; //pc disable
                    RF_RegSel <= 4'b1111;//disable all
                    RF_ScrSel <= 4'b1111;//disable all

                    T=8'b00000000;  //Time to 0
                end

///////////////////////////////////////////////////////////////
                6'b011010: //SUBS 16bit
                begin                                        
                    ARF_RegSel <= 3'b111; //pc disable
                    RF_RegSel <= 4'b1111;//disable all
                    RF_ScrSel <= 4'b1111;//disable all

                    T=8'b00000000;  //Time to 0
                end
            
    ////////////////////////////////////////////////
                6'b011011: //ANDS
                begin                                        
                    ARF_RegSel <= 3'b111; //pc disable
                    RF_RegSel <= 4'b1111;//disable all
                    RF_ScrSel <= 4'b1111;//disable all

                    T=8'b00000000;  //Time to 0
                end

    ////////////////////////////////////////////////
                6'b011100: //ORRS
                begin                                        
                    ARF_RegSel <= 3'b111; //pc disable
                    RF_RegSel <= 4'b1111;//disable all
                    RF_ScrSel <= 4'b1111;//disable all

                    T=8'b00000000;  //Time to 0
                end

    ////////////////////////////////////////////////
                6'b011101: //XORS
                begin                                        
                    ARF_RegSel <= 3'b111; //pc disable
                    RF_RegSel <= 4'b1111;//disable all
                    RF_ScrSel <= 4'b1111;//disable all

                    T=8'b00000000;  //Time to 0
                end

////////////////////////////////////////////////////////////////
                6'b011110: //BX
                begin
                    Mem_CS <= 1'b0; //disable memory
                    Mem_WR <= 1'b0; //disable write
                    case(_ALUSystem.IROut[9:8])
                    2'b00: RF_OutBSel <= 3'b000; //R1
                    2'b01: RF_OutBSel <= 3'b001; //R2
                    2'b10: RF_OutBSel <= 3'b010; //R3
                    2'b11: RF_OutBSel <= 3'b011; //R4
                    endcase
                    RF_ScrSel <= 4'b1111; //all is disabled
                    ALu_FunSel <= 5'b10001; //send B
                    ARF_RegSel <= 3'b011; //PC enable
                    ARF_FunSel <= 3'b010; //Load to PC
                    MuxBSel <= 2'b00; //output to ARF

                    T <= T + 1;
                end

////////////////////////////////////////////////////////////////
                6'b100000: //LDRIM
                begin                                        
                    ARF_RegSel <= 3'b111; //pc disable
                    RF_RegSel <= 4'b1111;//disable all
                    RF_ScrSel <= 4'b1111;//disable all

                    T=8'b00000000;  //Time to 0
                end





            endcase
        end

    else if(T == 8'b00000111)
        begin
            IR_Write <= 0;
            case(_ALUSystem.IROut[15:10])
    ////////////////////////////////////////////////
                6'b011110: //BX
                begin                                        
                    ARF_RegSel <= 3'b111; //pc disable
                    RF_RegSel <= 4'b1111;//disable all
                    RF_ScrSel <= 4'b1111;//disable all

                    T=8'b00000000;  //Time to 0
                end
            endcase
        end


   
         end
     endmodule