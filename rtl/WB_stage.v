/***************************************************
 * Module: WB_stage
 * Project: core_lapido
 * Author: Filipe Boaventura
 * Description: Seleciona o dado a ser escrito no
 * banco de registradores e propaga os sinais e
 * enderecos para os saltos
 ***************************************************/
 `include "lapido_defs.v"

module WB_stage
(
    input reg in_is_jump,
    input reg in_branch_taken,
    input reg in_branch_addr,
    input reg in_reg_write_enable,
    input reg [1:0] wb_res_mux,
    input reg [`PC_WIDTH-1: 0] next_pc, // o pc + 1 do jal
    input reg [31:0] mem_data,
    input reg [31:0] alu_res,
    input reg [4:0]  in_reg_dst,
    input reg [31:0] imm,
    input reg [31:0] in_jump_addr,

    output out_is_jump,
    output out_branch_taken,
    output out_branch_addr,
    output out_reg_write_enable,
    output [`PC_WIDTH-1: 0] wb_res,
    output [4:0]  out_reg_dst,
    output [31:0] out_jump_addr
);

assign out_is_jump = in_is_jump;
assign out_branch_taken = in_branch_taken;
assign out_branch_addr = in_branch_addr;
assign out_reg_write_enable = in_reg_write_enable;
assign out_jump_addr = in_jump_addr;
assign out_reg_dst = in_reg_dst;

mux4x1 mux
(
    .in_a(alu_res),
    .in_b(mem_data),
    .in_c(next_pc),
    .in_d(imm),
    .sel(wb_res_mux),
    .out(wb_res)
);

endmodule // WB_stage
