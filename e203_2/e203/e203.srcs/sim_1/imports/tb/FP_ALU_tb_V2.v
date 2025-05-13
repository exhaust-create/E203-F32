///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//File Name: FP_ALU_tb.v
//Created By: Mingjun Cheng
//Date: 22-04-2023
//Project Name: Design of 32 Bit Floating Point ALU Based on Standard IEEE-754 in Verilog and its implementation on FPGA.
//University: Guangdong University of Technology
//Description: When test 'QDiv_Qsqrt', do not check the TestResult File created by this testbench, JUST check the WAVE FORM.
//             When test 'QDiv_Qsqrt', the next test number will be entered at posedge falu_done, 
//             i.e. a clk period after creating result.
//             When test 'Adder' or 'Mul', enter the test number and produce result in the same clk period.
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps

//`include "Division.v"
//`include "Multiplication.v"
//`include "Addition-Subtraction.v"
//`include "Iteration.v"

`define N_TESTS 100000

module FP_ALU_tb;

	reg clk = 0;
	reg [31:0] a_operand;
	reg [31:0] b_operand;
	wire [3:0] option = 4'd3;      // Choose operation
	wire add_en = (option == 4'd1);
	wire sub_en = (option == 4'd2);
	wire mul_en = (option == 4'd3);
	wire div_en = (option == 4'd4);
	wire sqrt_en = (option == 4'd5);
	wire fp2int_en = (option == 4'd6);
	wire int2fp_en = (option == 4'd7);
	wire fp2usint_en = (option == 4'd8);
	wire usint2fp_en = (option == 4'd9);
	
	wire [31:0] result;
	wire Exception,Overflow,Underflow;

	reg [31:0] Expected_result;

	reg [95:0] testVector [`N_TESTS-1:0];

	reg test_stop_enable;

	integer mcd;
	integer test_n = 0;
	integer pass   = 0;
	integer error  = 0;
	wire falu_done;
	reg rst_n;

	FALU falu(option,a_operand,b_operand,result,Exception,Overflow,Underflow,falu_done,clk,rst_n);

	always #5 clk = ~clk;
	
	initial  
	begin 
	   rst_n = 1'b0;
	   #10
	   rst_n = 1'b1;
	   a_operand = 32'h3ffffff9;
	   b_operand = 32'h3f000004;
	   #10
	   $stop(0);
	end

	initial  
	begin 
	   rst_n = 1'b0;
	   #10
	   rst_n = 1'b1;
	   if (div_en) begin    // Div Test File
            $readmemh("E:/Vivado_Workspace/e203_2/Source Code/TestFile/TestVectorDivision", testVector);
            mcd = $fopen("E:/Vivado_Workspace/e203_2/Source Code/TestFile/ResultsDivision_Ver2.txt");
	   end
	   else if (sqrt_en) begin   // Sqrt Test File
	       $readmemh("E:/Vivado_Workspace/e203_2/Source Code/TestFile/TestVectorSqrt", testVector);
            mcd = $fopen("E:/Vivado_Workspace/e203_2/Source Code/TestFile/ResultsSqrt_Ver2.txt");
	   end
	   else if (mul_en) begin
	       $readmemh("E:/Vivado_Workspace/e203_2/Source Code/TestFile/TestVectorMultiply", testVector); 
	       mcd = $fopen("E:/Vivado_Workspace/e203_2/Source Code/TestFile/ResultsMul_Ver2.txt");
	   end     
	   else if (add_en) begin
	       $readmemh("E:/Vivado_Workspace/e203_2/Source Code/TestFile/TestVectorAddition", testVector); 
	       mcd = $fopen("E:/Vivado_Workspace/e203_2/Source Code/TestFile/ResultsAdd_Ver2.txt");
	   end
	   else if (sub_en) begin
	       $readmemh("E:/Vivado_Workspace/e203_2/Source Code/TestFile/TestVectorSubtraction", testVector); 
	       mcd = $fopen("E:/Vivado_Workspace/e203_2/Source Code/TestFile/ResultsSub_Ver2.txt");
	   end
	   else if (fp2int_en) begin
	       $readmemh("E:/Vivado_Workspace/e203_2/Source Code/TestFile/TestVectorFp2Int", testVector); 
	       mcd = $fopen("E:/Vivado_Workspace/e203_2/Source Code/TestFile/ResultsFp2Int_Ver2.txt");
	   end
	   else if (int2fp_en) begin
	       $readmemh("E:/Vivado_Workspace/e203_2/Source Code/TestFile/TestVectorInt2Fp", testVector); 
	       mcd = $fopen("E:/Vivado_Workspace/e203_2/Source Code/TestFile/ResultsInt2Fp_Ver2.txt");
	   end
	   
	   if (div_en | mul_en | add_en | sub_en) begin    // Div Test File
			{a_operand,b_operand,Expected_result} = testVector[test_n];
	   end 
	   else if (sqrt_en | fp2int_en | int2fp_en) begin   // Sqrt Test File
            {a_operand,Expected_result} = testVector[test_n];
       end
			test_n = test_n + 1'b1;
	end 
	
	always @(posedge clk) begin
        if (add_en | mul_en | sub_en | fp2int_en | int2fp_en) begin    // Div Test File
            if (fp2int_en | int2fp_en) begin
                {a_operand,Expected_result} = testVector[test_n];
            end
            else if (add_en | mul_en | sub_en) begin
//                  {a_operand,b_operand,Expected_result} = {32'h3ffffff9,32'h3f000004,32'h3f800000};
                {a_operand,b_operand,Expected_result} = testVector[test_n];
            end
            test_n = test_n + 1'b1;
				
            if (test_n >= `N_TESTS) begin
                $fdisplay(mcd,"Completed %d tests, %d passes and %d fails.", test_n, pass, error);
                test_stop_enable = 1'b1;
            end
	   end
	end
	
	always @(posedge clk) begin
	   if (Exception) begin
	       if (div_en | mul_en | add_en | sub_en) begin    // Div Test File
			{a_operand,b_operand,Expected_result} = testVector[test_n];
           end 
           else if (sqrt_en) begin   // Sqrt Test File
                {a_operand,Expected_result} = testVector[test_n];
           end
	       test_n = test_n + 1'b1;
	   end
	end

	always @(posedge clk) 
	begin
	if (falu_done) begin
	   if (div_en | sqrt_en) begin
           if (div_en) begin    // Div Test File
                {a_operand,b_operand,Expected_result} = testVector[test_n];
           end 
           else if (sqrt_en) begin   // Sqrt Test File
                {a_operand,Expected_result} = testVector[test_n];
           end
                test_n = test_n + 1'b1;
                    
           if (test_n >= `N_TESTS) 
                begin
                    $fdisplay(mcd,"Completed %d tests, %d passes and %d fails.", test_n, pass, error);
                    test_stop_enable = 1'b1;
                end
        end
    end
	end

	always @(negedge clk) begin
//	   #2;
	   if (falu_done|Exception) begin
           if (result[31:11] == Expected_result[31:11]) begin
                    $fdisplay (mcd,"TestPassed Test Number -> %d",test_n);
                    pass = pass + 1'b1;
           end
        
           if (result[31:11] != Expected_result[31:11]) begin
               $fdisplay (mcd,"Test Failed Expected Result = %h, Obtained result = %h, Test Number -> %d",Expected_result,result,test_n);
               error = error + 1'b1;
           end
       end
	end

always @(posedge test_stop_enable)
begin
$fclose(mcd);
$finish;
end

endmodule
