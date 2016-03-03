/***************************************************
 * Module: MEM_stage
 * Project: core_lapido
 * Author: Afonso Machado
 * Description:
 ***************************************************/
 `include "lapido_defs.v"

module MEM_stage (
	input clk,    // Clock
	input rst,

	input reg in_mem_write_enable,//
    input reg in_sel_beq_bne,//
    input reg in_fl_write_enable,//
    input reg in_sel_jt_jf,//
    input reg in_is_branch,//
    input reg in_is_jump,//
    input reg [1:0] in_wb_res_mux,//
    input reg in_reg_write_enable,//

    // Dados para propagar
    input reg [`PC_WIDTH - 1:0] in_next_pc,//
    input reg [31:0] in_immediate,//
    input reg [31:0] abs_addr,//
    input reg [31:0] in_mem_addr,//
    input reg [31:0] in_mem_data,//
    input reg [31:0] in_alu_res,//
    input reg [5:0] alu_flags,//
    input reg [4:0] flag_addr,//
    input reg [4:0] in_reg_dst,//

    input reg sel_jflag_branch,//

    output reg out_is_jump,//
    output reg out_branch_taken,//
    output reg out_branch_addr,
    output reg out_reg_write_enable,//
    output reg [1:0] out_wb_res_mux, //
    output reg [`PC_WIDTH-1: 0] out_next_pc, // o pc + 1 do jal
    output reg [31:0] out_mem_data,//
    output reg [31:0] out_alu_res,//
    output reg [4:0]  out_reg_dst,//
    output reg [31:0] imm,//
    output reg [31:0] out_jump_addr//

);

wire jt_jf_ok;
wire beq_bne_ok;//
wire pra_and;
wire [31:0] wire_out_mem_data;

always @ (posedge clk) begin
	out_is_jump <= in_is_jump;
	out_reg_write_enable <= in_reg_write_enable;
	imm <= in_immediate;
	out_alu_res <= in_alu_res;
	out_reg_dst <= in_reg_dst;
	out_wb_res_mux <= in_wb_res_mux;
	out_next_pc <= in_next_pc;

	out_jump_addr <= abs_addr;
	out_branch_addr <= in_next_pc;
	out_branch_taken <= in_is_branch & pra_and;
    out_mem_data <= wire_out_mem_data;
end

ram2 data_memory(
	.read_file(rst),
	.write_file(rst),
	.DATA(in_mem_data),
	.ADRESS(in_mem_addr),
	.WE(in_mem_write_enable),
	.clk(clk),
	.Q(wire_out_mem_data)
);

fmu flags(
	.clk(clk),
	.flags_in(alu_flags),
	.flag_code(flag_addr),
	.write_enable(in_fl_write_enable),
	.sel_jt_jf(in_sel_jt_jf),
	.jt_jf_ok(jt_jf_ok)
);

// mux2x1 mux_flags(
// 	.in_a(alu_flags[`FL_ZERO]),
// 	.in_b(alu_flags[`FL_TRUE]),
// 	.sel(in_sel_beq_bne),
// 	.out(beq_bne_ok)
// );

assign beq_bne_ok = (in_sel_beq_bne) ? alu_flags[`FL_TRUE] : alu_flags[`FL_ZERO];
assign para_and = (sel_jflag_branch) ? beq_bne_ok : jt_jf_ok;


// mux2x1 jflags_branch_mux(
// 	.in_a(jt_jf_ok),
// 	.in_b(beq_bne_ok),
// 	.sel(sel_jflag_branch),
// 	.out(pra_and)
// );

endmodule
