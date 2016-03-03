/***************************************************
 * Module: lapido_top
 * Project: core_lapido
 * Author: Filipe Boaventura
 * Description: Top level do processador LAPI DOpaCA
 * LAMBA
 ***************************************************/
 `include "lapido_defs.v"

module lapido_top (input clk, input rst);

    // Do IF para o ID
    wire [31:0] IF_ID_instruction;
    wire [`PC_WIDTH - 1:0] IF_ID_next_pc;

    // Do ID para o EX
    wire [31:0] ID_EX_rs_data;
    wire [31:0] ID_EX_rt_data;
    wire [4:0] ID_EX_flag_addr; // campo rs da instrucao
    wire [4:0] ID_EX_rt;
    wire [4:0] ID_EX_rd;
    wire [31:0] ID_EX_imm;
    wire [5:0] ID_EX_alu_funct;  // Seleciona a operacao da alu
    wire ID_EX_alu_src_mux;      // Seleciona o segundo operando da alu
    wire ID_EX_sel_j_jr;         // Seleciona a fonte do endereco do salto incondicional
    wire [1:0] ID_EX_reg_dst_mux;// Seleciona o endereco do registrador de escrita
    wire ID_EX_is_jump;          // A instrucao eh um salto incondicional
    wire ID_EX_mem_write_enable; // Habilita a escrita na memoria
    wire ID_EX_sel_beq_bne;      // Seleciona entre beq e bne
    wire ID_EX_fl_write_enable;  // Habilita a escrita no registrador de flags
    wire ID_EX_sel_jt_jf;        // Seleciona entre jt e jf na fmu
    wire ID_EX_is_branch;        // A instrucao eh um desvio pc-relative
    wire ID_EX_sel_jflag_branch; // seletor do tipo do branch
    wire [1:0] ID_EX_wb_res_mux; // Seleciona o dado que sera escrito no registrador
    wire ID_EX_reg_write_enable; // Habilita a escrita no banco de registradores

    // Do EX para o MEM
    wire [`PC_WIDTH - 1:0] EX_MEM_out_branch_addr;
    wire EX_MEM_out_sel_jflag_branch;
    wire EX_MEM_out_mem_write_enable;
    wire EX_MEM_out_sel_beq_bne;
    wire EX_MEM_out_fl_write_enable;
    wire EX_MEM_out_sel_jt_jf;
    wire EX_MEM_out_is_branch;
    wire EX_MEM_out_is_jump;
    wire [1:0] EX_MEM_out_wb_res_mux;
    wire EX_MEM_out_reg_write_enable;
    wire [`PC_WIDTH - 1:0] EX_MEM_out_next_pc;
    wire [31:0] EX_MEM_out_immediate;
    wire [31:0] EX_MEM_abs_addr;
    wire [31:0] EX_MEM_mem_addr;
    wire [31:0] EX_MEM_mem_data;
    wire [31:0] EX_MEM_alu_out;
    wire [5:0] EX_MEM_alu_flags_out;
    wire [4:0] EX_MEM_flag_addr;
    wire [4:0] EX_MEM_reg_dst;

    // Do MEM para o WB
    wire MEM_WB_out_is_jump;//
    wire MEM_WB_out_branch_taken;//
    wire [`PC_WIDTH - 1:0] MEM_WB_out_branch_addr;
    wire MEM_WB_out_reg_write_enable;//
    wire [1:0] MEM_WB_out_wb_res_mux; //
    wire [`PC_WIDTH-1: 0] MEM_WB_out_next_pc; // o pc + 1 do jal
    wire [31:0] MEM_WB_out_mem_data;//
    wire [31:0] MEM_WB_out_alu_res;//
    wire [4:0]  MEM_WB_out_reg_dst;//
    wire [31:0] MEM_WB_imm;//
    wire [31:0] MEM_WB_out_jump_addr;//

    // Do WB para o ID (banco de registradores)
    wire WB_ID_out_reg_write_enable;
    wire [`PC_WIDTH-1: 0] WB_ID_wb_res;
    wire [4:0]  WB_ID_out_reg_dst;

    // Do WB para o IF (enderecos de saltos)
    wire WB_IF_out_is_jump;
    wire WB_IF_out_branch_taken;
    wire [`PC_WIDTH - 1:0] WB_IF_out_branch_addr;
    wire [`PC_WIDTH - 1:0] WB_IF_out_jump_addr;
endmodule // lapido_top
