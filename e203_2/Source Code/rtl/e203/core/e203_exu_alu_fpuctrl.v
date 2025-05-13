//=====================================================================
// Designer   : Mingjun Cheng
//
// Description:
//  The FPU Control module in ALU to transmit Source Operands to FPU and
//  control the FPU to implement which operation.
//
// ====================================================================

`include "e203_defines.v"

`ifdef E203_HAS_FPU//{
module e203_exu_alu_fpuctrl (

    // Indicates if FPU is off
    input status_i_fs_off,
    
    // The Issue Handshake Interface between ALU and FPUCTRL 
    input  fpuctrl_i_valid, // Handshake valid
    output fpuctrl_o_ready, // Handshake ready
    
    // Get fpu_info from ALU, only FPU-corresponding part.
    input [`E203_DECINFO_WIDTH-1:0] fpu_i_info,

    // Get operands from ALU.
    input [`E203_FLEN-1:0] fpu_i_rs1,
    input [`E203_FLEN-1:0] fpu_i_rs2,
    input [`E203_FLEN-1:0] fpu_i_rs3,

    // FLSU, FMIS and FMAC share the same itag, because they use the same FPU.
    input [`E203_ITAG_WIDTH-1:0] fpu_i_itag,
    
    // FPU is turned on.
    output fpu_o_longpipe,
    
    // The fpu Commit Interface. Need to connect to alu first.
    output                        fpu_cmt_o_valid, // Handshake valid
    input                         fpu_cmt_i_ready, // Handshake ready
    
    // The fpu write-back Interface between module longpwbck. Need to connect to alu first. 
    output                        fpu_o_longpwbck_valid, // Handshake valid
    input                         fpu_i_longpwbck_ready, // Handshake ready
    output [`E203_ITAG_WIDTH-1:0] fpu_o_itag, 
    
    // Req Channel to FPU.
    output fpu_req_valid, // Handshake valid
    input  fpu_req_ready, // Handshake ready
    output [`E203_FLEN-1:0] fpu_req_rs1,
    output [`E203_FLEN-1:0] fpu_req_rs2,
    output [`E203_FLEN-1:0] fpu_req_rs3,
    output [`E203_DECINFO_WIDTH-1:0] fpu_req_info,
    
    // Rsp Channel from FPU
    input  fpu_rsp_valid,
    output fpu_rsp_ready,
    
    input  clk,
    input  rst_n
);
    assign fpu_o_longpipe = ~status_i_fs_off;
                    
    // when there is a valid info and the cmt is ready, then Req Channel is valid.
    wire   fpu_req_valid_pos = fpuctrl_i_valid & fpu_cmt_i_ready;
    assign fpu_req_valid = fpu_o_longpipe &  fpu_req_valid_pos;
    // when fpu is disable, its req_ready is assumed to 1.
    wire   fpu_req_ready_pos = status_i_fs_off ? 1'b1 : fpu_req_ready;
    // fpu reports ready to operat when its cmt is ready and the fpu is ready.
    assign fpuctrl_o_ready   = fpu_req_ready_pos & fpu_cmt_i_ready  ;
    // the fpu isns is about to cmt when the info is truly a valid fpu info and the fpu has accepted.
    assign fpu_cmt_o_valid   = fpuctrl_i_valid   & fpu_req_ready_pos;
    
    wire   fifo_o_vld;
    assign fpu_rsp_ready = fpu_i_longpwbck_ready & fifo_o_vld;
    assign fpu_o_longpwbck_valid = fifo_o_vld & fpu_rsp_valid;

    assign fpu_req_info = fpu_i_info;
    assign fpu_req_rs1 = fpu_i_rs1;
    assign fpu_req_rs2 = fpu_i_rs2;
    assign fpu_req_rs3 = fpu_i_rs3;

    wire itag_fifo_wen = fpu_o_longpipe & (fpu_req_valid & fpu_req_ready); 
    wire itag_fifo_ren = fpu_rsp_valid & fpu_rsp_ready; 

    wire          fifo_i_vld  = itag_fifo_wen;
    wire          fifo_i_rdy;
    wire [`E203_ITAG_WIDTH-1:0] fifo_i_dat = fpu_i_itag;

    wire          fifo_o_rdy = itag_fifo_ren;
    wire [`E203_ITAG_WIDTH-1:0] fifo_o_dat; 
    //ctrl path must be independent with data path to avoid timing-loop.
    assign fpu_o_itag = fifo_o_dat;

     sirv_gnrl_fifo # (
           .DP(1),
           .DW(`E203_ITAG_WIDTH),
           .CUT_READY(0),
           .MSKO (0)
      ) u_fpu_itag_fifo(
        .i_vld   (fifo_i_vld),
        .i_rdy   (fifo_i_rdy),
        .i_dat   (fifo_i_dat),
        .o_vld   (fifo_o_vld),
        .o_rdy   (fifo_o_rdy),
        .o_dat   (fifo_o_dat),
        .clk     (clk  ),
        .rst_n   (rst_n)
      );

endmodule
`endif//}