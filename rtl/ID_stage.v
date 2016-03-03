/***************************************************
 * Module: ID_stage
 * Project: core_lapido
 * Author: Filipe Boaventura
 * Description:
 ***************************************************/
 `include "lapido_defs.v"

module ID_stage
(
    input clk,
    input rst,
    input reg [31:0] instruction,
    input reg [`PC_WIDTH-1:0] in_next_pc,

    output [`PC_WIDTH-1:0] out_next_pc,

    // Do estágio wb
    input [4:0] reg_dst, // endereco do registrador destino
    input [31:0] wb_res, // dado a ser escrito no registrador
    input in_reg_write_enable, // Habilita a escrita no registrador


    // saidas do banco de registradores
    output [31:0] rs_data,
    output [31:0] rt_data,

    // campos das instrucoes
    output [4:0] flag_addr, // campo rs da instrucao
    output [4:0] rt,
    output [4:0] rd,
    output [31:0] imm,

    // Sinais para o estagio EX
    output [5:0] alu_funct,  // Seleciona a operacao da alu
    output alu_src_mux,      // Seleciona o segundo operando da alu
    output sel_j_jr,         // Seleciona a fonte do endereco do salto incondicional
    output [1:0] reg_dst_mux,// Seleciona o endereco do registrador de escrita
    output is_jump,          // A instrucao eh um salto incondicional

    // Sinais para o estagio MEM
    output mem_write_enable, // Habilita a escrita na memoria
    output sel_beq_bne,      // Seleciona entre beq e bne
    output fl_write_enable,  // Habilita a escrita no registrador de flags
    output sel_jt_jf,        // Seleciona entre jt e jf na fmu
    output is_branch,        // A instrucao eh um desvio pc-relative

    // Sinais para o estagio WB
    output [1:0] wb_res_mux, // Seleciona o dado que sera escrito no registrador
    output reg_write_enable // Habilita a escrita no banco de registradores
);

register_file reg_file
(
    .clk(clk),
    .rst(rst),
    .en(in_reg_write_enable),
    .rd(reg_dst),
    .rs(instruction[25:21]),
    .rt(instruction[20:16]),
    .data(wb_res),
    .data_rs(rs_data),
    .data_rt(rt_data)
);

assign flag_addr = instruction[25:21];
assign rt = instruction[20:16];
assign rd = instruction[15:11];

ext_de_sinal sx (.unex(instruction[15:0]), .ext(imm));

control_unit ctrl
(
    .opcode(instruction[31:26]),
    .funct(instruction[5:0]),
    .alu_funct(alu_funct),  // Seleciona a operacao da alu
    .alu_src_mux(alu_src_mux),      // Seleciona o segundo operando da alu
    .sel_j_jr(sel_j_jr),         // Seleciona a fonte do endereco do salto incondicional
    .reg_dst_mux(reg_dst_mux),// Seleciona o endereco do registrador de escrita
    .is_jump(is_jump),          // A instrucao eh um salto incondicional

    // Sinais para o estagio MEM
    .mem_write_enable(mem_write_enable), // Habilita a escrita na memoria
    .sel_beq_bne(sel_beq_bne),      // Seleciona entre beq e bne
    .fl_write_enable(fl_write_enable),  // Habilita a escrita no registrador de flags
    .sel_jt_jf(sel_jt_jf),        // Seleciona entre jt e jf na fmu
    .is_branch(is_branch),        // A instrucao eh um desvio pc-relative

    // Sinais para o estagio WB
    .wb_res_mux(wb_res_mux), // Seleciona o dado que sera escrito no registrador
    .reg_write_enable(reg_write_enable) // Habilita a escrita no banco de registradores
);

endmodule // ID_stage
