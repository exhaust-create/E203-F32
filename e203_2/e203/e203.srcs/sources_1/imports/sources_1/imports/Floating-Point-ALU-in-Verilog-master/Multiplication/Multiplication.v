///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//File Name: Multiplication.v
//Created By: Sheetal Swaroop Burada
//Corrected By: Jiayu Zhang
//Date: 30-04-2019
//Project Name: Design of 32 Bit Floating Point ALU Based on Standard IEEE-754 in Verilog and its implementation on FPGA.
//University: Dayalbagh Educational Institute
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


module Multiplication(
		input [31:0] a_operand,
		input [31:0] b_operand,
		output Exception,Overflow,Underflow,
		output [31:0] result
		);

wire sign,product_round,normalised,zero;
wire [8:0] exponent,sum_exponent;
//wire [22:0] product_mantissa;//尾数
wire [23:0] product_mantissa;
wire [23:0] operand_a,operand_b;
wire [47:0] product,product_normalised; //48 Bits

//符号位相同为零不同为一
assign sign = a_operand[31] ^ b_operand[31];

//Exception flag sets 1 if either one of the exponent is 255.
//阶码为255时，异常置1
assign Exception = (&a_operand[30:23]) | (&b_operand[30:23]);

//Assigining significand values according to Hidden Bit.
//If exponent is equal to zero then hidden bit will be 0 for that respective significand else it will be 1
//如果指数等于零，则相应有效位的隐藏位将为0，否则为1_____ieee754标准-非规约形式的浮点数
assign operand_a = (|a_operand[30:23]) ? {1'b1,a_operand[22:0]} : {1'b0,a_operand[22:0]};

assign operand_b = (|b_operand[30:23]) ? {1'b1,b_operand[22:0]} : {1'b0,b_operand[22:0]};

assign product = operand_a * operand_b;			//Calculating Product
//最后的23位进行或运算以进行舍入运算
assign product_round = |product_normalised[22:0];  //Ending 22 bits are OR'ed for rounding operation.
//第48位为1时则为正规化
assign normalised = product[47] ? 1'b1 : 1'b0;	
//左移直到第48位为1
assign product_normalised = normalised ? product : product << 1;	//Assigning Normalised value based on 48th bit

//Final Manitssa.
//最后的24位四舍五入
assign product_mantissa = product_normalised[46:24] + (product_normalised[23] & product_round); 
//异常为1时zero为0，异常为0时，尾数不为0，zero为0，否则为1
//assign zero = Exception ? 1'b0 : (product_mantissa == 23'd0) ? 1'b1 : 1'b0;
assign zero = Exception ? 1'b0 : (a_operand==32'h00000000||b_operand==32'h00000000) ? 1'b1 : 1'b0;
//两数的阶码相加
assign sum_exponent = a_operand[30:23] + b_operand[30:23];
//两数相乘后的指数
assign exponent = sum_exponent - 8'd127 + normalised + product_mantissa[23];
//尾数不为0且双符号位不同时为上溢出
assign Overflow = ((exponent[8] & !exponent[7]) & !zero) ; //If overall exponent is greater than 255 then Overflow condition.
//Exception Case when exponent reaches its maximu value that is 384.
//254+254-127+1或0=最大值为384
//If sum of both exponents is less than 127 then Underflow condition.

//以384为界，超过384则下溢，小于384大于255为上溢
assign Underflow = ((exponent[8] & exponent[7]) & !zero) ? 1'b1 : 1'b0; 

//assign result = Exception ? 32'd0 : zero ? {sign,31'd0} : Overflow ? {sign,8'hFF,23'd0} : Underflow ? {sign,31'd0} : {sign,exponent[7:0],product_mantissa};
assign result = Exception ? 32'd0 : zero ? {sign,31'd0} : Overflow ? {sign,8'hFF,23'd0} : Underflow ? {sign,31'd0} : {sign,exponent[7:0],product_mantissa[22:0]};
//assign result = Exception ? 32'd0 : zero ? {sign,exponent[7:0],23'd0} : Overflow ? {sign,8'hFF,23'd0} : Underflow ? {sign,31'd0} : {sign,exponent[7:0],product_mantissa};


endmodule