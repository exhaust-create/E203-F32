////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//File Name: Converter.v
//Created By: Sheetal Swaroop Burada
//Date: 30-04-2019
//Project Name: Design of 32 Bit Floating Point ALU Based on Standard IEEE-754 in Verilog and its implementation on FPGA.
//University: Dayalbagh Educational Institute
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


module Floating_Point_to_Integer(
		input [31:0] a_operand,
		input fp2usint,           // Float to unsigned-int
		output [31:0] Integer
		);

reg [30:0] Integer_Value;
wire [30:0] Int_Val_Com;

always @(*)
begin
    // Int equal to +0
	if (a_operand[30:23] == 8'd127)
			begin
				Integer_Value = {31'd0};
			end

	else if (a_operand[30:23] == 8'd128)
			begin
				Integer_Value = {29'd0,1'b1,a_operand[22]};
			end

	else if (a_operand[30:23] == 8'd129)
			begin
				Integer_Value = {28'd0,1'b1,a_operand[22:21]};
				 
			end

	else if (a_operand[30:23] == 8'd130)
			begin
				Integer_Value = {27'd0,1'b1,a_operand[22:20]};
				 
			end

	else if (a_operand[30:23] == 8'd131)
			begin
				Integer_Value = {26'd0,1'b1,a_operand[22:19]};
				 
			end

	else if (a_operand[30:23] == 8'd132)
			begin
				Integer_Value = {25'd0,1'b1,a_operand[22:18]};
				 
			end

	else if (a_operand[30:23] == 8'd133)
			begin
				Integer_Value = {24'd0,1'b1,a_operand[22:17]};
				 
			end

	else if (a_operand[30:23] == 8'd134)
			begin
				Integer_Value = {23'd0,1'b1,a_operand[22:16]};
				 
			end

	else if (a_operand[30:23] == 8'd135)
			begin
				Integer_Value = {22'd0,1'b1,a_operand[22:15]};
				 
			end

	else if (a_operand[30:23] == 8'd136)
			begin
				Integer_Value = {21'd0,1'b1,a_operand[22:14]};
				 
			end

	else if (a_operand[30:23] == 8'd137)
			begin
				Integer_Value = {20'd0,1'b1,a_operand[22:13]};
				 
			end

	else if (a_operand[30:23] == 8'd138)
			begin
				Integer_Value = {19'd0,1'b1,a_operand[22:12]};
				 
			end

	else if (a_operand[30:23] == 8'd139)
			begin
				Integer_Value = {18'd0,1'b1,a_operand[22:11]};
				 
			end

	else if (a_operand[30:23] == 8'd140)
			begin
				Integer_Value = {17'd0,1'b1,a_operand[22:10]};
				 
			end

	else if (a_operand[30:23] == 8'd141)
			begin
				Integer_Value = {16'd0,1'b1,a_operand[22:9]};
				 
			end

	else if (a_operand[30:23] == 8'd142)
			begin
				Integer_Value = {15'd0,1'b1,a_operand[22:8]};
				 
			end

	else if (a_operand[30:23] == 8'd143)
			begin
				Integer_Value = {14'd0,1'b1,a_operand[22:7]};
				 
			end

	else if (a_operand[30:23] == 8'd144)
			begin
				Integer_Value = {13'd0,1'b1,a_operand[22:6]};
				 
			end

	else if (a_operand[30:23] == 8'd145)
			begin
				Integer_Value = {12'd0,1'b1,a_operand[22:5]};
				 
			end

	else if (a_operand[30:23] == 8'd146)
			begin
				Integer_Value = {11'd0,1'b1,a_operand[22:4]};
				 
			end

	else if (a_operand[30:23] == 8'd147)
			begin
				Integer_Value = {10'd0,1'b1,a_operand[22:3]};
				 
			end

	else if (a_operand[30:23] == 8'd148)
			begin
				Integer_Value = {9'd0,1'b1,a_operand[22:2]};
				 
			end

	else if (a_operand[30:23] == 8'd149)
			begin
				Integer_Value = {8'd0,1'b1,a_operand[22:1]};
				 
			end

	else if (a_operand[30:23] == 8'd150)
			begin
				Integer_Value = {7'd0,1'b1,a_operand[22:0]};
				 
			end
			
    else if (a_operand[30:23] == 8'd151)
        Integer_Value = {6'd0,1'b1,a_operand[22:0],1'd0};
        
    else if (a_operand[30:23] == 8'd152)
        Integer_Value = {5'd0,1'b1,a_operand[22:0],2'd0};
        
    else if (a_operand[30:23] == 8'd153)
        Integer_Value = {4'd0,1'b1,a_operand[22:0],3'd0};
        
    else if (a_operand[30:23] == 8'd154)
        Integer_Value = {3'd0,1'b1,a_operand[22:0],4'd0};
        
    else if (a_operand[30:23] == 8'd155)
        Integer_Value = {2'd0,1'b1,a_operand[22:0],5'd0};
        
    else if (a_operand[30:23] == 8'd156)
        Integer_Value = {1'd0,1'b1,a_operand[22:0],6'd0};
        
    else if (a_operand[30:23] == 8'd157)
        Integer_Value = {1'b1,a_operand[22:0],7'd0};
        
    // In RISC-V, if positive input is out-of-range, then set all bits of signed-int output.
    else if (a_operand[30:23] == 8'd158)
        Integer_Value = fp2usint ? {a_operand[22:0],8'd0} : {31{1'b1}};
        
    else if (a_operand[30:23] >= 8'd159)
        Integer_Value = {31{1'b1}};

    // Int less than or equal to -0
	else if (a_operand[30:23] <= 8'd126)
			begin
				Integer_Value = {31'd0};
				 
			end
    else
        Integer_Value = {31'd0};
end

assign Int_Val_Com = (~fp2usint & a_operand[31]) ? (~Integer_Value + 1'b1) : Integer_Value;
assign Integer = fp2usint ? {1'b1,Int_Val_Com} : {a_operand[31],Int_Val_Com};

endmodule