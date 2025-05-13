 /*                                                                      
 Copyright 2018-2020 Nuclei System Technology, Inc.                
                                                                         
 Licensed under the Apache License, Version 2.0 (the "License");         
 you may not use this file except in compliance with the License.        
 You may obtain a copy of the License at                                 
                                                                         
     http://www.apache.org/licenses/LICENSE-2.0                          
                                                                         
  Unless required by applicable law or agreed to in writing, software    
 distributed under the License is distributed on an "AS IS" BASIS,       
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and     
 limitations under the License.                                          
 */                                                                      
                                                                         
                                                                         
                                                                         
//=====================================================================
// Designer   : Bob Hu
//
// Description:
//  The mini-decode module to decode the instruction in IFU 
//
// ====================================================================
`include "e203_defines.v"

module e203_ifu_minidec(

  //////////////////////////////////////////////////////////////
  // The IR stage to Decoder
  input  [`E203_INSTR_SIZE-1:0] instr,
  
  //////////////////////////////////////////////////////////////
  // The Decoded Info-Bus


  output dec_rs1en,
  output dec_rs2en,
  output [`E203_RFIDX_WIDTH-1:0] dec_rs1idx,
  output [`E203_RFIDX_WIDTH-1:0] dec_rs2idx,
  
  `ifdef E203_HAS_FPU
  output dec_fpu,
  output dec_fpu_rs1en,
  output dec_fpu_rs2en,
  output dec_fpu_rs3en,
  output dec_fpu_rs1fpu,
  output dec_fpu_rs2fpu,
  output [`E203_RFIDX_WIDTH-1:0] dec_fpu_rs1idx,
  output [`E203_RFIDX_WIDTH-1:0] dec_fpu_rs2idx,
  output [`E203_RFIDX_WIDTH-1:0] dec_fpu_rs3idx,
  `endif

  output dec_mulhsu,
  output dec_mul   ,
  output dec_div   ,
  output dec_rem   ,
  output dec_divu  ,
  output dec_remu  ,

  output dec_rv32,
  output dec_bjp,
  output dec_jal,
  output dec_jalr,
  output dec_bxx,
  output [`E203_RFIDX_WIDTH-1:0] dec_jalr_rs1idx,
  output [`E203_XLEN-1:0] dec_bjp_imm 

  );

  e203_exu_decode u_e203_exu_decode(

  .i_instr(instr),
  .i_pc(`E203_PC_SIZE'b0),
  .i_prdt_taken(1'b0), 
  .i_muldiv_b2b(1'b0), 

  .i_misalgn (1'b0),
  .i_buserr  (1'b0),

  .dbg_mode  (1'b0),

  .dec_misalgn(),
  .dec_buserr(),
  .dec_ilegl(),

  .dec_rs1x0(),
  .dec_rs2x0(),
  .dec_rs1en(dec_rs1en),
  .dec_rs2en(dec_rs2en),
  .dec_rdwen(),
  .dec_rs1idx(dec_rs1idx),
  .dec_rs2idx(dec_rs2idx),
  .dec_rdidx(),
  .dec_info(),  
  .dec_imm(),
  .dec_pc(),

`ifdef E203_HAS_NICE//{
  .dec_nice   (),
  .nice_xs_off(1'b0),  
  .nice_cmt_off_ilgl_o(),
`endif//}

 `ifdef E203_HAS_FPU//{
 .dec_fpu          (dec_fpu),
 .status_i_fs_off  (1'b0),      // Temporarily = 0
 .fpu_o_cmt_off_ilgl(),
 .dec_fpu_rs1en    (dec_fpu_rs1en),
 .dec_fpu_rs2en    (dec_fpu_rs2en),
 .dec_fpu_rs3en    (dec_fpu_rs3en),
 .dec_fpu_rdwen    (),
 .dec_fpu_rs1fpu   (dec_fpu_rs1fpu),
 .dec_fpu_rs2fpu   (dec_fpu_rs2fpu),
 .dec_fpu_rdfpu    (),
 .dec_fpu_rs1idx   (dec_fpu_rs1idx),
 .dec_fpu_rs2idx   (dec_fpu_rs2idx),
 .dec_fpu_rs3idx   (dec_fpu_rs3idx),
 .dec_fpu_rdidx    (),
 `endif//}

  .dec_mulhsu(dec_mulhsu),
  .dec_mul   (dec_mul   ),
  .dec_div   (dec_div   ),
  .dec_rem   (dec_rem   ),
  .dec_divu  (dec_divu  ),
  .dec_remu  (dec_remu  ),

  .dec_rv32(dec_rv32),
  .dec_bjp (dec_bjp ),
  .dec_jal (dec_jal ),
  .dec_jalr(dec_jalr),
  .dec_bxx (dec_bxx ),

  .dec_jalr_rs1idx(dec_jalr_rs1idx),
  .dec_bjp_imm    (dec_bjp_imm    )  
  );


endmodule
