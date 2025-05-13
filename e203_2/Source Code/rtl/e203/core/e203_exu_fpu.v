/*******************************
* Author: Mingjun Cheng, Jiayu Zhang
* Describtion: To comply with the rule of OITF ---- as least 2-period Instr. can be allocated a 
*              OITF, 1-period Instr. will be turn into 2-period Instr..
*******************************/

`include "e203_defines.v"

`ifdef E203_HAS_FPU
module e203_exu_fpu(
    input status_i_fs_off,

    // Req Channel from FPUCTRL 
    input  fpu_req_valid,
    output fpu_req_ready,
    input [`E203_FLEN-1:0] fpu_req_rs1,
    input [`E203_FLEN-1:0] fpu_req_rs2,
    input [`E203_FLEN-1:0] fpu_req_rs3,
    input [`E203_DECINFO_WIDTH-1:0] fpu_req_info,
    
    // Rsp Channel to FPUCTRL
    output fpu_rsp_valid,
    input  fpu_rsp_ready,
    
    // Write back data
    output [`E203_FLEN-1:0] fpu_rsp_wdat,
    
    // Write fflags to csr
    /**************************
    * fflags:
    * 10000: Invalid Operation
    * 01000: Divide by Zero
    * 00100: Overflow
    * 00010: Underflow
    * 00001: Inexact
    ****************************/
    output [4:0] fpu2csr_o_fflags,
    output fpu2csr_wen,         // fpu2csr write enable
    
    input clk,
    input rst_n
);

    wire wire_fpu_en;
    wire [`E203_DECINFO_WIDTH-1:0] fpu_i_info;
    wire [`E203_FLEN-1:0] fpu_rs1;
    wire [`E203_FLEN-1:0] fpu_rs2;
    wire [`E203_FLEN-1:0] fpu_rs3;
/////////////////////////////////////////////////////
// signal for FALU
    wire [`E203_FLEN-1:0] falu_res;
    wire falu_Overflow,falu_Underflow;
// END
////////////////////////////////////////////////////

///////////////////////////////////////////////////
// Turn 1-period Instr. into 2-period, and 5-period Instr. into 6-period, 2 into 3.
// Version: sirv_gnrl_dfflr

    wire [`E203_DECINFO_WIDTH-1:0] fpu_info_nxt =  fpu_req_valid ? fpu_req_info : 0;
    wire [`E203_FLEN-1:0] fpu_rs1_nxt = fpu_req_valid ? fpu_req_rs1 : 0;
    wire [`E203_FLEN-1:0] fpu_rs2_nxt = fpu_req_valid ? fpu_req_rs2 : 0;
    wire [`E203_FLEN-1:0] fpu_rs3_nxt = fpu_req_valid ? fpu_req_rs3 : 0;
    sirv_gnrl_dfflr #(1) fpu_en_dfflr (fpu_req_ready, fpu_req_valid, wire_fpu_en, clk, rst_n);
    sirv_gnrl_dfflr #(`E203_DECINFO_WIDTH) fpu_info_dfflr (fpu_req_ready, fpu_info_nxt, fpu_i_info, clk, rst_n);
    sirv_gnrl_dfflr #(`E203_FLEN) fpu_rs1_dfflr (fpu_req_ready, fpu_rs1_nxt, fpu_rs1, clk, rst_n);
    sirv_gnrl_dfflr #(`E203_FLEN) fpu_rs2_dfflr (fpu_req_ready, fpu_rs2_nxt, fpu_rs2, clk, rst_n);
    sirv_gnrl_dfflr #(`E203_FLEN) fpu_rs3_dfflr (fpu_req_ready, fpu_rs3_nxt, fpu_rs3, clk, rst_n);
// END
///////////////////////////////////////////////////
    
/*
///////////////////////////////////////////////////
// Turn 1-period Instr. into 2-period, and 4-period Instr. into 5-period. 
// Version: Posedge clk

    reg reg_fpu_en = 1'b0;
    reg [`E203_FLEN-1:0] reg_fpu_rs1;
    reg [`E203_FLEN-1:0] reg_fpu_rs2;
    reg [`E203_FLEN-1:0] reg_fpu_rs3;
    reg [`E203_DECINFO_WIDTH-1:0] reg_fpu_info;
    
    always @(posedge clk) begin
        if (!rst_n) begin
            reg_fpu_info <= 0;
            reg_fpu_rs1 <= 0;
            reg_fpu_rs2 <= 0;
            reg_fpu_rs3 <= 0;
            reg_fpu_en <= 1'd0;
        end
        else begin
            if (fpu_req_ready) begin
                case(fpu_req_valid)
                    1'b0: begin
                        reg_fpu_en <= 1'b0;
                        reg_fpu_info <= 0;
                        reg_fpu_rs1 <= 0;
                        reg_fpu_rs2 <= 0;
                        reg_fpu_rs3 <= 0;
                    end
                    1'b1: begin
                        reg_fpu_en <= 1'b1;
                        reg_fpu_info <= fpu_req_info;
                        reg_fpu_rs1 <= fpu_req_rs1;
                        reg_fpu_rs2 <= fpu_req_rs2;
                        reg_fpu_rs3 <= fpu_req_rs3;
                    end
                endcase
            end
            else begin
                reg_fpu_en <= reg_fpu_en;
                reg_fpu_info <= fpu_req_info;
                reg_fpu_rs1 <= reg_fpu_rs1;
                reg_fpu_rs2 <= reg_fpu_rs2;
                reg_fpu_rs3 <= reg_fpu_rs3;
            end
        end
    end
// END
//////////////////////////////////////////////////////////////////
*/
/////////////////////////////////////////////////////////////////////
// Decode info
/*
    assign wire_fpu_en = reg_fpu_en;
    assign [`E203_DECINFO_WIDTH-1:0] fpu_i_info = reg_fpu_info;
    assign [`E203_FLEN-1:0] fpu_rs1 = reg_fpu_rs1;
    assign [`E203_FLEN-1:0] fpu_rs2 = reg_fpu_rs2;
    assign [`E203_FLEN-1:0] fpu_rs3 = reg_fpu_rs3;
*/
    wire fmis_op = (~status_i_fs_off) & wire_fpu_en
                    & (fpu_i_info[`E203_DECINFO_FPU_GRP] == `E203_DECINFO_GRP_FPU_FMIS);
    wire fmac_op = (~status_i_fs_off) & wire_fpu_en
                    & (fpu_i_info[`E203_DECINFO_FPU_GRP] == `E203_DECINFO_GRP_FPU_FMAC);
    
    assign fpu2csr_wen = fmac_op & fpu_rsp_valid;       // Need to write fflags and when to write
    
    wire [2:0] rm   = fpu_i_info[`E203_DECINFO_FPU_RM];
    wire use_rm     = fpu_i_info[`E203_DECINFO_FPU_USERM];
    
    // fmis
    wire fsgnj      = fmis_op & fpu_i_info[`E203_DECINFO_FMIS_FSGNJ];
    wire fsgnjn     = fmis_op & fpu_i_info[`E203_DECINFO_FMIS_FSGNJN];
    wire fsgnjx     = fmis_op & fpu_i_info[`E203_DECINFO_FMIS_FSGNJX];
    wire fmvxw      = fmis_op & fpu_i_info[`E203_DECINFO_FMIS_FMVXW];
    wire fclass     = fmis_op & fpu_i_info[`E203_DECINFO_FMIS_FCLASS];
    wire fmvwx      = fmis_op & fpu_i_info[`E203_DECINFO_FMIS_FMVWX];
    wire fcvtws     = fmis_op & fpu_i_info[`E203_DECINFO_FMIS_CVTWS];  // fp to signed-int
    wire fcvtwus    = fmis_op & fpu_i_info[`E203_DECINFO_FMIS_CVTWUS]; // fp to unsigned-int
    wire fcvtsw     = fmis_op & fpu_i_info[`E203_DECINFO_FMIS_CVTSW];  // signed-int to fp
    wire fcvtswu    = fmis_op & fpu_i_info[`E203_DECINFO_FMIS_CVTSWU]; // unsigned-int to fp
    
    //fmac
    wire fmadd     = fmac_op & fpu_i_info[`E203_DECINFO_FMAC_FMADD];
    wire fmsub     = fmac_op & fpu_i_info[`E203_DECINFO_FMAC_FMSUB];
    wire fnmsub    = fmac_op & fpu_i_info[`E203_DECINFO_FMAC_FNMSUB];
    wire fnmadd    = fmac_op & fpu_i_info[`E203_DECINFO_FMAC_FNMADD];
    wire fadd      = fmac_op & fpu_i_info[`E203_DECINFO_FMAC_FADD];
    wire fsub      = fmac_op & fpu_i_info[`E203_DECINFO_FMAC_FSUB];
    wire fmul      = fmac_op & fpu_i_info[`E203_DECINFO_FMAC_FMUL];
    wire fmin      = fmac_op & fpu_i_info[`E203_DECINFO_FMAC_FMIN];
    wire fmax      = fmac_op & fpu_i_info[`E203_DECINFO_FMAC_FMAX];
    wire feq       = fmac_op & fpu_i_info[`E203_DECINFO_FMAC_FEQ];
    wire flt       = fmac_op & fpu_i_info[`E203_DECINFO_FMAC_FLT];
    wire fle       = fmac_op & fpu_i_info[`E203_DECINFO_FMAC_FLE];
    wire fdiv      = fmac_op & fpu_i_info[`E203_DECINFO_FMAC_DIV];
    wire fsqrt     = fmac_op & fpu_i_info[`E203_DECINFO_FMAC_SQRT];
// END
////////////////////////////////////////////////////////////////////
    
///////////////////////////////////////////////////////////////////////////
// Split rs1, rs2 and rs3
    wire sign_rs1 = fpu_rs1[`E203_FLEN-1];      // 0 + 1 -
    wire [7:0] exp_rs1 = fpu_rs1[`E203_FLEN-2:23]; //exponent field of rs1
    wire [22:0] frac_rs1 = fpu_rs1[22:0];  // fraction field of rs1
    wire [22:0] frac_rs2 = fpu_rs2[22:0];  // fraction field of rs2
    wire exp_rs1_all_0 = (exp_rs1 == 8'h0);
    wire exp_rs1_all_1 = (exp_rs1 == 8'hff);
    wire exp_rs2_all_1 = (fpu_rs2[`E203_FLEN-2:23] == 8'hff);
    wire exp_rs2_all_0 = (fpu_rs2[`E203_FLEN-2:23] == 8'h0);
    wire exp_rs3_all_1 = (fpu_rs3[`E203_FLEN-2:23] == 8'hff);
    wire frac_rs1_all_0 = (frac_rs1 == 22'b0);
    wire frac_rs2_all_0 = (frac_rs2 == 22'b0);
    wire rs1_all_0 = exp_rs1_all_0 & frac_rs1_all_0;
    wire rs2_all_0 = exp_rs2_all_0 & frac_rs2_all_0;
// END
///////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////
// fflags
    wire divide_by_zero = fdiv & rs2_all_0;
    wire invalid_operation;
    wire fminmax_Exception, fltle_Exception, feq_Exception;
// END
/////////////////////////////////////////

    wire fcom      = fmin | fmax | feq | flt | fle;     // Compare rs1 with rs2
    wire ffused    = fmadd | fmsub | fnmsub | fnmadd;
//    wire fdiv_en    = ~rs2_all_0 & fdiv;
    wire single_period_Ins = fmis_op | fmac_op & ~(ffused | fdiv | fsqrt); 
    
    // To reduce power, toggle the result only when fmis_op = 1
    wire [`E203_FLEN-1:0] fsgnj_res  = fmis_op ? {fpu_rs2[`E203_FLEN-1],fpu_rs1[`E203_FLEN-2:0]} : `E203_FLEN'b0;
    wire [`E203_FLEN-1:0] fsgnjn_res = fmis_op ? {~fpu_rs2[`E203_FLEN-1],fpu_rs1[`E203_FLEN-2:0]} : `E203_FLEN'b0;
    wire [`E203_FLEN-1:0] fsgnjx_res = fmis_op ? {fpu_rs2[`E203_FLEN-1] ^ fpu_rs1[`E203_FLEN-1]
                                        ,fpu_rs1[`E203_FLEN-2:0]} : `E203_FLEN'b0;
    
    wire [`E203_FLEN-1:0] fmvxw_res = fmis_op ? fpu_rs1 : `E203_FLEN'b0;
    wire [`E203_FLEN-1:0] fmvwx_res = fmis_op ? fpu_rs1 : `E203_FLEN'b0;
    
    wire [`E203_FLEN-1:0] fclass_res;
    assign fclass_res[`E203_FLEN-1:10] = {(`E203_FLEN-10){1'b0}};
    assign fclass_res[9] = fmis_op & exp_rs1_all_1 & fpu_rs1[22]; // A quiet NaN
    assign fclass_res[8] = fmis_op & exp_rs1_all_1 & ~fpu_rs1[22]; // A signaling NaN
    assign fclass_res[7] = fmis_op & ~sign_rs1 & exp_rs1_all_1 & frac_rs1_all_0; // A positive inf
    assign fclass_res[6] = fmis_op & ~sign_rs1 & ~exp_rs1_all_0 & ~exp_rs1_all_1; // A positive normal number
    assign fclass_res[5] = fmis_op & ~sign_rs1 & exp_rs1_all_0 & ~frac_rs1_all_0; // A positive subnormal number
    assign fclass_res[4] = fmis_op & ~sign_rs1 & exp_rs1_all_0 & frac_rs1_all_0; // A positive zero
    assign fclass_res[3] = fmis_op & sign_rs1 & exp_rs1_all_0 & frac_rs1_all_0; // A negatives zero
    assign fclass_res[2] = fmis_op & sign_rs1 & exp_rs1_all_0 & ~frac_rs1_all_0; // A negative subnormal number
    assign fclass_res[1] = fmis_op & sign_rs1 & ~exp_rs1_all_0 & ~exp_rs1_all_1; // A negative normal number
    assign fclass_res[0] = fmis_op & sign_rs1 & exp_rs1_all_1 & frac_rs1_all_0; // A negative inf
    wire [`E203_FLEN-1:0] fcvtws_res = {`E203_FLEN{fmac_op}} & falu_res;
    wire [`E203_FLEN-1:0] fcvtwus_res = {`E203_FLEN{fmac_op}} & falu_res;
    wire [`E203_FLEN-1:0] fcvtsw_res = {`E203_FLEN{fmac_op}} & falu_res;
    wire [`E203_FLEN-1:0] fcvtswu_res = {`E203_FLEN{fmac_op}} & falu_res;
    
///////////////////////////////////////////////////////////////////////////////////
// Compare rs1 with rs2
    // Exist NaN as there is '1' in 'fcom_mark'
    wire [1:0] fcom_mark = (exp_rs1_all_1 & exp_rs2_all_1) ? 2'b11       // booth NaNs
                           :(exp_rs1_all_1 & ~exp_rs2_all_1) ? 2'b10   // rs1 is a NaN
                           :(~exp_rs1_all_1 & exp_rs2_all_1) ? 2'b01  // rs2 is a NaN
                           :2'b00;
    wire [`E203_FLEN-1:0] fmin_res = {`E203_FLEN{fmac_op}} &
                                    ((fcom_mark == 2'b11) ? `E203_FLEN'h7fc00000
                                    :(fcom_mark == 2'b10) ? fpu_rs2
                                    :(fcom_mark == 2'b01) ? fpu_rs1
                                    : falu_res[31] ? fpu_rs1 
                                    : fpu_rs2);
    wire [`E203_FLEN-1:0] fmax_res = {`E203_FLEN{fmac_op}} &
                                    ((fcom_mark == 2'b11) ? `E203_FLEN'h7fc00000
                                    :(fcom_mark == 2'b10) ? fpu_rs2
                                    :(fcom_mark == 2'b01) ? fpu_rs1
                                    : falu_res[31] ? fpu_rs2 
                                    : fpu_rs1);
    assign fminmax_Exception = (exp_rs1_all_1 & ~fpu_rs1[22]) | (exp_rs2_all_1 & ~fpu_rs2[22]);
    wire eq_mark = (fpu_rs1 == fpu_rs2);
    wire [`E203_XLEN-1:0] feq_res = {`E203_XLEN{fmac_op}} & 
                                    (&fcom_mark  ? `E203_XLEN'h0 : eq_mark);
    wire [`E203_XLEN-1:0] flt_res = {`E203_XLEN{fmac_op}} & 
                                    (&fcom_mark  ? `E203_XLEN'h0 
                                   : falu_res[31] ? `E203_XLEN'd1
                                   : `E203_XLEN'd0);
    wire [`E203_XLEN-1:0] fle_res = {`E203_XLEN{fmac_op}} &
                                    (&fcom_mark  ? `E203_XLEN'h0 : (eq_mark | falu_res[31])); 
    assign fltle_Exception = exp_rs1_all_1 | exp_rs2_all_1;       // FLT ot FLE Exception
    assign feq_Exception = fminmax_Exception;
 // END
//////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////// 
// Floating-point fused multiply-add Instr. controlling FALU.
// Version: sirv_gnrl_dfflr 
    wire ffused_Exception_in = ffused & (                                                                         
                                      (exp_rs1_all_1 | exp_rs2_all_1)            // Booth are infinite        
                                     |(rs1_all_0 & exp_rs2_all_1)    // rs1 is zero and rs2 is infinite       
                                     |(exp_rs1_all_1 & rs2_all_0) ); // rs2 is zero and rs1 is infinite 
    wire [1:0] ffused_status;
    wire ffused_status_00 = (ffused_status == 2'b00);
    wire ffused_status_01 = (ffused_status == 2'b01);
    wire ffused_status_11 = (ffused_status == 2'b11);
    wire ffused_status_10 = (ffused_status == 2'b10);
    wire [1:0] ffused_status_nxt =  ffused_status_00 ? 2'b01
                                  : ffused_status_01 ? (ffused_Exception_in ? 2'b0 : 2'b11)
                                  : 2'b00;
    wire ffused_Exception;                              
    wire ffused_Exception_nxt = ffused_status_01 & ffused_Exception_in;
    wire [`E203_FLEN-1:0] ffused_operand_1;
    wire [`E203_FLEN-1:0] ffused_operand_2;
    wire [`E203_FLEN-1:0] ffused_operand_1_nxt =   ffused_status_01 ? fpu_rs1
                                                 : ffused_status_11 ? falu_res
                                                 : `E203_FLEN'd0;
    wire [`E203_FLEN-1:0] ffused_operand_2_nxt =   ffused_status_01 ? fpu_rs2
                                                 : ffused_status_11 ? fpu_rs3
                                                 : `E203_FLEN'd0;
    wire ffused_sub,ffused_mul_en,ffused_adder_en;
    wire ffused_sub_nxt = ffused_status_11 & (fmsub | fnmsub);
    wire ffused_mul_en_nxt = ffused_status_01;
    wire ffused_adder_en_nxt = ffused_status_11;
    wire ffused_mul_Overflow,ffused_mul_Underflow;
    wire ffused_Overflow_nxt = ffused_status_11 & falu_Overflow;
    wire ffused_Underflow_nxt = ffused_status_11 & falu_Underflow;
    wire ffused_done;
    wire ffused_done_nxt = ffused_status_11;
    
    sirv_gnrl_dfflr #(1) ffused_Exception_dfflr (ffused,ffused_Exception_nxt,ffused_Exception,clk,rst_n);
    sirv_gnrl_dfflr #(2) ffused_status_dfflr (ffused,ffused_status_nxt,ffused_status,clk,rst_n);
    sirv_gnrl_dfflr #(`E203_FLEN) ffused_rs1_dfflr (ffused,ffused_operand_1_nxt,ffused_operand_1,clk,rst_n);
    sirv_gnrl_dfflr #(`E203_FLEN) ffused_rs2_dfflr (ffused,ffused_operand_2_nxt,ffused_operand_2,clk,rst_n);
    sirv_gnrl_dfflr #(1) ffused_sub_dfflr (ffused,ffused_sub_nxt,ffused_sub,clk,rst_n);
    sirv_gnrl_dfflr #(1) ffused_mul_en_dfflr (ffused,ffused_mul_en_nxt,ffused_mul_en,clk,rst_n);
    sirv_gnrl_dfflr #(1) ffused_adder_en_dfflr (ffused,ffused_adder_en_nxt,ffused_adder_en,clk,rst_n);
    sirv_gnrl_dfflr #(1) ffused_Overflow_dfflr (ffused,ffused_Overflow_nxt,ffused_mul_Overflow,clk,rst_n);
    sirv_gnrl_dfflr #(1) ffused_Underflow_dfflr (ffused,ffused_Underflow_nxt,ffused_mul_Underflow,clk,rst_n);
    sirv_gnrl_dfflr #(1) ffused_done_dfflr (ffused,ffused_done_nxt,ffused_done,clk,rst_n);
// END
//////////////////////////////////////////////////
  
/*  
/////////////////////////////////////////////////////////////////////
// Floating-point fused multiply-add Instr. controlling FALU.
// Version: Posedge clk
    reg [`E203_FLEN-1:0] ffused_operand_1;
    reg [`E203_FLEN-1:0] ffused_operand_2;
    reg ffused_sub = 1'b0;
    reg ffused_mul_en = 1'b0;
    reg ffused_adder_en = 1'b0;
    wire ffused_Exception_in = ffused & (
                                          (exp_rs1_all_1 | exp_rs2_all_1)            // Booth are infinite
                                         |(rs1_all_0 & exp_rs2_all_1)    // rs1 is zero and rs2 is infinite
                                         |(exp_rs1_all_1 & rs2_all_0) ); // rs2 is zero and rs1 is infinite
    reg ffused_Exception;
    reg ffused_mul_Overflow;
    reg ffused_mul_Underflow;
    reg ffused_done = 1'b0;     // Floating-point fused multiply-add Instr.s don't use 'falu_done'
    reg ffused_status = 2'b0;   // Floating-point fused multiply-add status
      
    // Floating-point fused multiply-add result choose sign bit at final falu_res choosing.
    always @(posedge clk) begin
        if (!rst_n) begin
            ffused_operand_1 = 32'b0;
            ffused_operand_2 = 32'b0;
            ffused_status      <= 2'b0;
            ffused_done        <= 1'b0;
            ffused_Exception   <= 1'b0;
            ffused_mul_Overflow <= 1'b0;
            ffused_mul_Underflow <= 1'b0;
        end
        else begin
            ffused_status      <=  (ffused_status ==2'b00) ? (ffused ? 2'b01 : 2'b00)
                                 : (ffused_status ==2'b01) ? (ffused_Exception_in ? 2'b0 : 2'b11)
                                 : 2'b00;
        end
    end
    always @(*) begin
        case(ffused_status)
            2'b00: begin
                ffused_operand_1 = 32'b0;
                ffused_operand_2 = 32'b0;
                ffused_mul_en    = 1'b0;
                ffused_adder_en  = 1'b0;
                ffused_sub       = 1'b0;
                ffused_Exception = 1'b0;
                ffused_mul_Overflow = 1'b0;
                ffused_mul_Underflow = 1'b0;
                ffused_done      = 1'b0;
            end
            2'b01: begin
                ffused_operand_1 = fpu_rs1;
                ffused_operand_2 = fpu_rs2;
                ffused_mul_en    = ffused;
                ffused_adder_en  = 1'b0;
                ffused_sub       = 1'b0;
                ffused_Exception  <= ffused_Exception_in;
                ffused_done = 1'b0;
            end
            2'b11: begin
                ffused_operand_1 = falu_res;
                ffused_operand_2 = fpu_rs3;
                ffused_mul_en    = 1'b0;
                ffused_adder_en  = ffused;
                ffused_sub = fmsub | fnmsub;
                ffused_mul_Overflow = falu_Overflow;
                ffused_mul_Underflow = falu_Underflow;
                ffused_done = 1'b1;
            end
            default: begin
                ffused_operand_1 = 32'b0;
                ffused_operand_2 = 32'b0;
                ffused_mul_en    = 1'b0;
                ffused_adder_en  = 1'b0;
                ffused_sub       = 1'b0;
                ffused_Exception = 1'b0;
                ffused_done      = 1'b0;
            end
        endcase
    end
*/
    wire [31:0] ffused_res =  ffused_Exception ? 32'h7fc00000
                            : ffused_done ? falu_res
                            : 32'h0;
// END
/////////////////////////////////////////////////////////////////////
    
    
////////////////////////////////////////////////////////////////////
// FALU instantiation
    wire [3:0] option = (fadd | (ffused_adder_en & ~ffused_sub)) ?  4'd1
                        : (fcom | fsub | (ffused_adder_en & ffused_sub))   ?  4'd2
                        : (fmul | ffused_mul_en) ?  4'd3
                        : fdiv  ?  4'd4         // Not use 'fdiv_en', but use fdiv?
                        : fsqrt  ?  4'd5
                        : fcvtws ?  4'd6
                        : fcvtsw ?  4'd7
                        : fcvtwus?  4'd8
                        : fcvtswu?  4'd9
                        : 4'd0;
    wire [`E203_FLEN-1:0] a_operand = (fcvtws |fcvtwus |fcvtsw |fcvtswu |fadd |fsub |fmul |fdiv |fsqrt |fcom) ? fpu_rs1
                                     : ffused ? ffused_operand_1
                                     : `E203_FLEN'd0;
    wire [`E203_FLEN-1:0] b_operand = (fcvtws |fcvtwus |fcvtsw |fcvtswu |fadd |fsub |fmul |fdiv |fsqrt |fcom) ? fpu_rs2
                                     : ffused ? ffused_operand_2
                                     : `E203_FLEN'd0;
    wire falu_Exception;
    wire falu_done;
    /*************************
    * FALU Describtion:
    * 1-period adder and multiplier.
    * 1-period int2float and float2int.
    * 2-period divider and SQRT.
    *************************/
    FALU falu(option,a_operand,b_operand,falu_res,falu_Exception,falu_Overflow,falu_Underflow,falu_done,clk,rst_n);
// END
////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////
// 1-period Instr.
//    reg single_period_fpu_req_ready;
//    reg 
// END
//////////////////////////////////////////////////////////////////

    assign invalid_operation = ((fadd |fsub |fmul |fdiv |fsqrt) & falu_Exception)
                              |(ffused & ffused_Exception)
                              |((fmin |fmax |feq) & fminmax_Exception) 
                              |((flt |fle) & fltle_Exception);
                              
    // Set "Inexact" bit when takes fdiv or fsqrt operation, and don't set this bit when takes int <-> float operation.
    assign fpu2csr_o_fflags = {invalid_operation,
                               divide_by_zero,
                               (fmul & falu_Overflow) |(ffused & ffused_mul_Overflow),
                               (fmul & falu_Underflow) |(ffused & ffused_mul_Underflow),
                               (fdiv |fsqrt)
                               };
    assign fpu_rsp_wdat = ((fdiv |fadd |fsub |fsqrt |fmul |fcvtws |fcvtwus |fcvtsw |fcvtswu) & falu_done) ? falu_res
                         :(fmadd |fmsub) ? ffused_res
                         :(fnmsub |fnmadd) ? {~ffused_res[31],ffused_res[30:0]}
                         : fmin ? fmin_res
                         : fmax ? fmax_res
                         : feq  ? feq_res
                         : flt  ? flt_res
                         : fle  ? fle_res
                         : fsgnj ? fsgnj_res
                         : fsgnjn ? fsgnjn_res
                         : fsgnjx ? fsgnjx_res
                         : fmvxw ? fmvxw_res
                         : fclass ? fclass_res
                         : fmvwx ? fmvwx_res
                         : `E203_FLEN'd0;
                         
//////////////////////////////////////////////////////////////
// System
    wire fpu_rsp_hsked = fpu_rsp_valid & fpu_rsp_ready;     

    // FPU is free, or it has produce result, do not wait for finishing Writeback
    assign fpu_req_ready = (fmis_op |fmac_op) ? fpu_rsp_hsked : 1'b1;
    assign fpu_rsp_valid = ffused ? (ffused_Exception |ffused_done)
                          :(fdiv |fsqrt) ? (falu_Exception |falu_done)
                          :(fmis_op |fmac_op) ? 1'b1        // 1-period Instr. will enter next input in the next clk period
                          : 1'b0;
// END
/////////////////////////////////////////////////////////////

endmodule
`endif