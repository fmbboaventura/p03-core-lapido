/***************************************************
 * Module: EX_stage
 * Project: core_lapido
 * Author: Filipe Boaventura
 * Description:
 ***************************************************/
 `include "lapido_defs.v"

module EX_stage
(
    input clk,
    input rst,

    // Controle para o EX
    input reg alu_src_mux,
    input reg [5:0] alu_funct,
    input reg [1:0] reg_dst_mux,
    input reg sel_j_jr,

    // Dados para o EX
    input reg [`PC_WIDTH - 1:0] in_next_pc,
    input reg [31:0] in_immediate,
    input reg [31:0] in_data_rs,
    input reg [31:0] in_data_rt,
    input reg [4:0] in_rs,
    input reg [4:0] in_rt,
    input reg [4:0] in_rd,

    // Sinais para propagar
    input reg in_sel_jflag_branch,

    input reg in_mem_write_enable,
    input reg in_sel_beq_bne,
    input reg in_fl_write_enable,
    input reg in_sel_jt_jf,
    input reg in_is_branch,
    input reg in_is_jump,
    input reg [1:0] in_wb_res_mux,
    input reg in_reg_write_enable,

    output reg out_sel_jflag_branch,

    output reg out_mem_write_enable,
    output reg out_sel_beq_bne,
    output reg out_fl_write_enable,
    output reg out_sel_jt_jf,
    output reg out_is_branch,
    output reg out_is_jump,
    output reg [1:0] out_wb_res_mux,
    output reg out_reg_write_enable,

    // Dados para propagar
    output reg [`PC_WIDTH - 1:0] out_next_pc,
    output reg [31:0] out_immediate,
    output reg [31:0] abs_addr,
    output reg [31:0] mem_addr,
    output reg [31:0] mem_data,
    output reg [31:0] alu_out,
    output reg [5:0] alu_flags_out,
    output reg [4:0] flag_addr,
    output reg [4:0] reg_dst
);

wire [32:0] full_alu_out;
wire [4:0]  flags;
wire [31:0] alu_src;
wire [4:0] wire_reg_dst;
wire [31:0] wire_abs_addr;


always @ (posedge clk) begin
    out_mem_write_enable <= in_mem_write_enable;
    out_sel_beq_bne <= in_sel_beq_bne;
    out_fl_write_enable <= in_fl_write_enable;
    out_sel_jt_jf <= in_sel_jt_jf;
    out_is_branch <= in_is_branch;
    out_is_jump <= in_is_jump;
    out_wb_res_mux <= in_wb_res_mux;
    out_reg_write_enable <= in_reg_write_enable;

    out_next_pc <= in_next_pc;
    out_immediate <= in_immediate;
    mem_addr <= in_data_rs;
    mem_data <= in_data_rt;
    flag_addr <= in_rs;

    alu_out <= full_alu_out [31:0];
    alu_flags_out <= flags;
    alu_flags_out[5] <= full_alu_out [32];

    abs_addr <= wire_abs_addr;
    reg_dst <= wire_reg_dst;
end

mux3x1_5bit rd_mux
(
    .in_a(in_rt),
    .in_b(in_rd),
    .in_c(5'd15),
    .sel(reg_dst_mux),
    .out(wire_reg_dst)
);

mux2x1 abs_addr_mux
(
    .in_a(in_data_rs),
    .in_b(in_immediate),
    .sel(sel_j_jr),
    .out(wire_abs_addr)
);


mux2x1 alu_mux
(
    .in_a(in_data_rt),
    .in_b(in_immediate),
    .sel(alu_src_mux),
    .out(alu_src)
);


alu alu
(
    .op1(in_data_rs),
    .op2(alu_src),
    .alu_funct(alu_funct),
    .alu_res(full_alu_out),
    .flags(flags)
);

endmodule // EX_stage
