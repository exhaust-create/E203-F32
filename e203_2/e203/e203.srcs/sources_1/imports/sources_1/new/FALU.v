/////////////////////////////////////////////////////////////////////////////////
// Author: Mingjun Cheng
// Create Date: 2023/04/21 20:01:46
// Module Name: FALU
// Description: The Adder and Multiplier are single-period, but QDiv_QSqrt is 3-period module.
// 
// Dependencies: 
// 
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module FALU(
    input [3:0] option,
    input [31:0] a_operand,     // from rs1
    input [31:0] b_operand,     // from rs2
    output [31:0] result,
    output Exception,
    output Overflow,
    output Underflow,
    output falu_done,
    
    input clk,
    input rst_n
    );
    
    wire add_en = (option == 4'd1);
	wire sub_en = (option == 4'd2);
	wire mul_en = (option == 4'd3);
	wire div_en = (option == 4'd4);
	wire sqrt_en = (option == 4'd5);
	wire fp2sint_en = (option == 4'd6);
	wire sint2fp_en = (option == 4'd7);
	wire fp2usint_en = (option == 4'd8);
	wire usint2fp_en = (option == 4'd9);
	wire Adder_en = add_en | sub_en;
	wire DS_en = div_en | sqrt_en;
	
	// If sqrt_en set, then switch 'a_operand' and 'b_operand'
	wire [31:0] DS_operand_1 = sqrt_en ? b_operand : a_operand;
	wire [31:0] DS_operand_2 = sqrt_en ? a_operand : b_operand;
	// 'DS_Output' is Div_Sqrt_Output
	wire [31:0] Adder_Output,DS_Output,Mul_Output,Fp2Int_Output,Int2Fp_Output;    
	wire Adder_Exception,Mul_Exception,DS_Exception,Mul_Overflow,Mul_Underflow;
	wire DS_done;
	
	assign Exception = (DS_en & DS_Exception) | (Adder_en & Adder_Exception) |  (mul_en & Mul_Exception);
	assign Overflow  = mul_en ? Mul_Overflow : 1'b0;
	assign Underflow = mul_en ? Mul_Underflow : 1'b0;
	// If add, mul or fp2sint operation, then set 'falu_done' straightly
	assign falu_done = DS_en ?  DS_done 
	                   : (Adder_en | mul_en | fp2sint_en | fp2usint_en | sint2fp_en | usint2fp_en);
	assign result = Exception  ? 32'b0
		           : (DS_en & DS_done)   ? DS_Output
	               : Adder_en  ? Adder_Output
	               : mul_en    ? Mul_Output
	               : (fp2sint_en | fp2usint_en) ? Fp2Int_Output
	               : (sint2fp_en | usint2fp_en) ? Int2Fp_Output
	               : 32'b0;
    
    Addition_Subtraction u_add_sub(a_operand,b_operand,sub_en,Adder_Exception,Adder_Output);
    Multiplication u_mul(a_operand,b_operand,Mul_Exception,Mul_Overflow,Mul_Underflow,Mul_Output);
    QDiv_QSqrt u_qdiv_qsqrt(div_en,sqrt_en,DS_operand_1,DS_operand_2,
                                    DS_Exception,DS_Output,DS_done,clk,rst_n);
    Floating_Point_to_Integer u_fp2sint(a_operand,fp2usint_en,Fp2Int_Output);
    Int_to_Fp u_int2fp(a_operand,usint2fp_en,Int2Fp_Output);
endmodule
