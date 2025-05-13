//////////////////////////////////////////////////////////////////////////////////
// Author: Mingjun Cheng, Jiayu Zhang
// Create Date: 2023/04/21 14:18:48
// Module Name: QDiv_QSqrt
// Description: 
// 
// Dependencies: 
// 
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module QDiv_QSqrt(
    input div_en,
    input sqrt_en,
    input [31:0] a_operand,
    input [31:0] b_operand,     // QSqrt's input is 'b_operand'
    output Exception,
    output [31:0] result,
    output QDiv_QSqrt_done,
    
    input clk,
    input rst_n
    );
    
    wire QDiv_QSqrt_en = div_en | sqrt_en;
//    reg sign;
    wire [31:0] operand_1;
    wire [31:0] operand_2;
//    reg [31:0] operand_3;
    wire [31:0] operand_3;
    wire [7:0] operandhalf_exp;
    wire [31:0] operandhalf;
    wire [31:0] Iteration_X0;
//    reg [31:0] Iteration_X2;
    wire [31:0] Iteration_X3;
    wire [31:0] fin_mul_operand;
    wire [31:0] solution;
    // sqrt's exception
    wire QSqrt_Exception = sqrt_en & (b_operand[31] == 1'b1); 
    //Exception flag sets 1 if either one of the exponent is 255.
    //阶码为255时，异常置1
    wire num_Exception = (&operand_3[30:23]) | (&b_operand[30:23]);
    wire wire_Exception = QSqrt_Exception | num_Exception;  
//    reg [1:0] status = 2'b0;
//    reg [31:0] Iteration_D;
    wire [31:0] Iteration_Q;
    
    assign operand_1 = {1'b0,b_operand[30:0]};
    //阶码减1相当于0.5倍
    assign operandhalf_exp = operand_1[30:23] - 8'd1;
    assign operandhalf = {1'b0,operandhalf_exp,operand_1[22:0]};
    //右移
    assign operand_2 = operand_1>>1;
    //相减，magic number
    assign Iteration_X0 = 32'h5f3759df - operand_2;

////////////////////////////////////////////////////////////
// Version: sirv_gnrl_dfflr
    wire [1:0] status;
    wire status_00 = (status == 2'b00);
    wire status_01 = (status == 2'b01);
    wire status_11 = (status == 2'b11);
    wire status_10 = (status == 2'b10);
   
    // Add FF to Iteration
    wire Iter_en = ~wire_Exception & (status_01 | status_11);
    wire status_4_Iteration;
    wire status_4_Iteration_nxt = Iter_en & ~status_4_Iteration;
   
    wire [1:0] status_nxt = status_00 ? 2'b01
                         : status_01 ? (wire_Exception ? 2'b0 : (status_4_Iteration ? 2'b11 : 2'b01))
                         : status_11 ? (status_4_Iteration ? 2'b10 : 2'b11)
                         : 2'b00;
    wire sign;
    wire sign_nxt = status_01 & (a_operand[31] ^ b_operand[31]);
    wire Exception_nxt = status_01 & wire_Exception;
    
    wire [31:0] operand_3_nxt =  {32{status_01}} & 
                                 (div_en  ? a_operand
                                : sqrt_en ? b_operand
                                : 32'b0);
    wire [31:0] Iteration_X2;
    wire [31:0] Iteration_X2_nxt = {32{status_10}} & Iteration_Q;
    wire [31:0] Iteration_D;
    wire [31:0] Iteration_D_nxt = status_01 ? Iteration_X0
                                  : status_11 ? Iteration_Q
                                  : 32'b0;
    wire QDiv_QSqrt_done_nxt = status_10;

    sirv_gnrl_dfflr #(2) status_dfflr (QDiv_QSqrt_en,status_nxt,status,clk,rst_n);
    sirv_gnrl_dfflr #(1) sign_dfflr (
                                     (QDiv_QSqrt_en & (status_01 | status_00)),
                                     sign_nxt,
                                     sign,
                                     clk,
                                     rst_n
                                    );
    sirv_gnrl_dfflr #(1) Exception_dfflr (
                                          (QDiv_QSqrt_en & (status_01 | status_00)),
                                          Exception_nxt,
                                          Exception,
                                          clk,
                                          rst_n
                                         );
    sirv_gnrl_dfflr #(32) operand_3_dfflr (
                                           (QDiv_QSqrt_en & (status_01 | status_00)),
                                           operand_3_nxt,
                                           operand_3,
                                           clk,
                                           rst_n
                                          );
    sirv_gnrl_dfflr #(32) Iteration_X2_dfflr (QDiv_QSqrt_en,Iteration_X2_nxt,Iteration_X2,clk,rst_n);
    sirv_gnrl_dfflr #(32) Iteration_D_dfflr (QDiv_QSqrt_en,Iteration_D_nxt,Iteration_D,clk,rst_n);
    sirv_gnrl_dfflr #(1) done_dfflr (QDiv_QSqrt_en,QDiv_QSqrt_done_nxt,QDiv_QSqrt_done,clk,rst_n);

    // Add FF to Iteration
    sirv_gnrl_dfflr #(1) status4Iteration_dfflr ((QDiv_QSqrt_en & Iter_en),status_4_Iteration_nxt,status_4_Iteration,clk,rst_n);

///////////////////////////////////////////////////////////

/* //////////////////////////////////////////////////   
// Version: Posedge clk
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            status      <= 2'b0 ;
            sign        <= 1'b0;
            QDiv_QSqrt_done <= 1'b0;
            Exception   <= 1'b0;
            Iteration_D <= 32'b0;
            Iteration_X2 <= 32'b0;
        end
        else begin
            status      <= (status ==2'b00) ? (QDiv_QSqrt_en ? 2'b01 : 2'b00)
                         : (status ==2'b01) ? (wire_Exception ? 2'b0 : 2'b11)
                         : (status ==2'b11) ? 2'b10
                         : 2'b00;
        end
    end
    
    always @(*) begin
        case(status)
            2'b00: begin
                sign = 1'b0;
                operand_3 = 32'b0;
                Iteration_D <= 32'b0;
                Iteration_X2 <= 32'b0;
                QDiv_QSqrt_done <= 1'b0;
            end
            2'b01: begin
                //符号位相同为零不同为一
                sign = a_operand[31] ^ b_operand[31];
                // Choose 'operand_3'
                operand_3 =   div_en  ? a_operand
                            : sqrt_en ? b_operand
                            : 32'b0;
                Iteration_D <= QDiv_QSqrt_en ? Iteration_X0 : 32'b0;
                Iteration_X2 <= 32'b0;
                QDiv_QSqrt_done <= 1'b0;
                Exception <=  wire_Exception;
            end
            2'b11: begin
                Iteration_D <= Iteration_Q;
                Iteration_X2 <= 32'b0;
                QDiv_QSqrt_done <= 1'b0;
            end
            2'b10: begin
                Iteration_D  <= 32'b0;
                Iteration_X2 <= Iteration_Q;
                QDiv_QSqrt_done <= 1'b1;
            end
        endcase
    end
////////////////////////////////////////////////////
*/
    
    IterationQRSqrt I0(Iter_en,Iteration_D,operandhalf,Iteration_Q,clk,rst_n);
    
    //平方根倒数乘以平方根倒数等于除数分之一
    Multiplication x3(Iteration_X2,Iteration_X2,,,,Iteration_X3);
    assign fin_mul_operand =  div_en  ? Iteration_X3
                            : sqrt_en ? Iteration_X2
                            : 32'b0;
    Multiplication x4(operand_3,fin_mul_operand,,,,solution);
    
    // Choose result
    // If Exception set, result = 0
    assign result = Exception ? 32'b0 
                    : div_en  ? {sign,solution[30:0]}
                    : sqrt_en ? solution
                    : 32'b0;
    
endmodule
