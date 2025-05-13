`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/23 15:29:46
// Design Name: 
// Module Name: Int_to_Fp
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Default: Signed Int to Floating-Point
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Int_to_Fp(
    input [31:0] a_operand,
    input usint2fp,             // unsigned int to fp
    output [31:0] Floating_Point
    );
    
    reg [30:0] Fp_Value;
    wire [30:0] Int_Com = (~usint2fp & a_operand[31]) ? (~a_operand[30:0] + 1'b1) : a_operand[30:0];   // ²¹Âë
    reg [30:0] Usint2Fp_Value;
    always @(Int_Com) begin
            if(Int_Com[30] == 1'b1) 
                Fp_Value = {8'd157,Int_Com[29:7]};
            else if(Int_Com[30:29] == 2'b01)
                Fp_Value = {8'd156,Int_Com[28:6]};
            else if(Int_Com[30:28] == 3'b001)
                Fp_Value = {8'd155,Int_Com[27:5]};
            else if(Int_Com[30:27] == 4'b0001)
                Fp_Value = {8'd154,Int_Com[26:4]};
            else if(Int_Com[30:26] == 5'b0000_1)
                Fp_Value = {8'd153,Int_Com[25:3]};
            else if(Int_Com[30:25] == 6'b0000_01)
                Fp_Value = {8'd152,Int_Com[24:2]};
            else if(Int_Com[30:24] == 7'b0000_001)
                Fp_Value = {8'd151,Int_Com[23:1]};
            else if(Int_Com[30:23] == 8'b0000_0001)
                Fp_Value = {8'd150,Int_Com[22:0]};
            else if(Int_Com[30:22] == 9'b0000_0000_1)
                Fp_Value = {8'd149,Int_Com[21:0],1'd0};
            else if(Int_Com[30:21] == 10'b0000_0000_01)
                Fp_Value = {8'd148,Int_Com[20:0],2'd0};
            else if(Int_Com[30:20] == 11'b0000_0000_001)
                Fp_Value = {8'd147,Int_Com[19:0],3'd0};
            else if(Int_Com[30:19] == 12'b0000_0000_0001)
                Fp_Value = {8'd146,Int_Com[18:0],4'd0};
            else if(Int_Com[30:18] == 13'b0000_0000_0000_1)
                Fp_Value = {8'd145,Int_Com[17:0],5'd0};
            else if(Int_Com[30:17] == 14'b0000_0000_0000_01)
                Fp_Value = {8'd144,Int_Com[16:0],6'd0};
            else if(Int_Com[30:16] == 15'b0000_0000_0000_001)
                Fp_Value = {8'd143,Int_Com[15:0],7'd0};
            else if(Int_Com[30:15] == 16'b0000_0000_0000_0001)
                Fp_Value = {8'd142,Int_Com[14:0],8'd0};
            else if(Int_Com[30:14] == 17'b0000_0000_0000_0000_1)
                Fp_Value = {8'd141,Int_Com[13:0],9'd0};
            else if(Int_Com[30:13] == 18'b0000_0000_0000_0000_01)
                Fp_Value = {8'd140,Int_Com[12:0],10'd0};
            else if(Int_Com[30:12] == 19'b0000_0000_0000_0000_001)
                Fp_Value = {8'd139,Int_Com[11:0],11'd0};
            else if(Int_Com[30:11] == 20'b0000_0000_0000_0000_0001)
                Fp_Value = {8'd138,Int_Com[10:0],12'd0};
            else if(Int_Com[30:10] == 21'b0000_0000_0000_0000_0000_1)
                Fp_Value = {8'd137,Int_Com[9:0],13'd0};
            else if(Int_Com[30:9] == 22'b0000_0000_0000_0000_0000_01)
                Fp_Value = {8'd136,Int_Com[8:0],14'd0};
            else if(Int_Com[30:8] == 23'b0000_0000_0000_0000_0000_001)
                Fp_Value = {8'd135,Int_Com[7:0],15'd0};
            else if(Int_Com[30:7] == 24'b0000_0000_0000_0000_0000_0001)
                Fp_Value = {8'd134,Int_Com[6:0],16'd0};
            else if(Int_Com[30:6] == 25'b0000_0000_0000_0000_0000_0000_1)
                Fp_Value = {8'd133,Int_Com[5:0],17'd0};
            else if(Int_Com[30:5] == 26'b0000_0000_0000_0000_0000_0000_01)
                Fp_Value = {8'd132,Int_Com[4:0],18'd0};
            else if(Int_Com[30:4] == 27'b0000_0000_0000_0000_0000_0000_001)
                Fp_Value = {8'd131,Int_Com[3:0],19'd0};
            else if(Int_Com[30:3] == 28'b0000_0000_0000_0000_0000_0000_0001)
                Fp_Value = {8'd130,Int_Com[2:0],20'd0};
            else if(Int_Com[30:2] == 29'b0000_0000_0000_0000_0000_0000_0000_1)
                Fp_Value = {8'd129,Int_Com[1:0],21'd0};
            else if(Int_Com[30:1] == 30'b0000_0000_0000_0000_0000_0000_0000_01)
                Fp_Value = {8'd128,Int_Com[0],22'd0};
            else if(Int_Com[30:0] == 31'b0000_0000_0000_0000_0000_0000_0000_001)
                Fp_Value = {8'd127,23'd0};
            else if(Int_Com[30:0] == 31'b0000_0000_0000_0000_0000_0000_0000_000)
                Fp_Value = {31'd0};
            else
                Fp_Value = {31'd0};
            
            // If not unsigned-int to float, then don't excute this operation and don't choose 'Usint2Fp_Value'.
            // If unsigned-int to float but a_operand[31] isn't set, then the operation is the same with signed-int to float.
            if (usint2fp & a_operand[31]) begin
                Usint2Fp_Value = {8'd158,Int_Com[30:8]};
            end
            else begin
                Usint2Fp_Value = Fp_Value;
            end
    end
    assign Floating_Point = usint2fp ? {1'b0,Usint2Fp_Value} : {a_operand[31],Fp_Value};
endmodule
