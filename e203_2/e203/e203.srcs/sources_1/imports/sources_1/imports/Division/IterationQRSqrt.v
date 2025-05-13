
module IterationQRSqrt(
      input Iter_D_en,  // For dfflr
	  input [31:0] Iteration_X0_0,
	  input [31:0] operandhalf,	
	  output [31:0] Iteration_output,
	  // For dfflr
	  input clk,
	  input rst_n
);

  localparam threehalfs = 32'h3fc00000;  //32'h3fc00000 = 1.5

  wire [31:0] Iteration_X0_1;
  wire [31:0] Iteration_X0_2;
  wire [31:0] Iteration_X0_3;

  Multiplication x0(Iteration_X0_0,Iteration_X0_0,,,,Iteration_X0_1);
  Multiplication x1(Iteration_X0_1,operandhalf,,,,Iteration_X0_2);
  
  // Add buffer to Iteration
  wire [31:0] Iteration_X0_2_r;
  sirv_gnrl_dfflr #(32) Iteration_X0_2_dfflr (Iter_D_en,Iteration_X0_2,Iteration_X0_2_r,clk,rst_n);
  wire [31:0] Iteration_X0_0_r;
  sirv_gnrl_dfflr #(32) Iteration_X0_0_dfflr (Iter_D_en,Iteration_X0_0,Iteration_X0_0_r,clk,rst_n);
  
  Addition_Subtraction X0(threehalfs,Iteration_X0_2_r,1'b1,,Iteration_X0_3);
  Multiplication x2(Iteration_X0_3,Iteration_X0_0_r,,,,Iteration_output);

endmodule