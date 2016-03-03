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
    wire [`PC_WIDTH - 1:0] ID_EX_out_next_pc;
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

    // Instanciando os estágios
    IF_stage IF_stage_inst
    (
        // Entradas
        .clk(clk),
        .rst(rst),
        .branch_addr(WB_IF_out_branch_addr),
        .branch_taken(WB_IF_out_branch_taken),
        .jump_addr(WB_IF_out_jump_addr),
        .is_jump(WB_IF_out_is_jump),
        // Saidas
        .instruction(IF_ID_instruction),
        .next_pc(IF_ID_next_pc)
    );

    ID_stage ID_stage_inst
    (
        // Entradas
        .clk(clk),
        .rst(rst),
        .instruction(IF_ID_instruction),
        .in_next_pc(IF_ID_next_pc),
        .reg_dst(WB_ID_out_reg_dst), // endereco do registrador destino
        .wb_res(WB_ID_wb_res), // dado a ser escrito no registrador
        .in_reg_write_enable(WB_ID_out_reg_write_enable), // Habilita a escrita no registrador
        .rs_data(ID_EX_rs_data),
        .rt_data(ID_EX_rt_data),
        .out_next_pc(ID_EX_out_next_pc),
        .flag_addr(ID_EX_flag_addr), // campo rs da instrucao
        .rt(ID_EX_rt),
        .rd(ID_EX_rd),
        .imm(ID_EX_imm),
        .alu_funct(ID_EX_alu_funct),  // Seleciona a operacao da alu
        .alu_src_mux(ID_EX_alu_src_mux),      // Seleciona o segundo operando da alu
        .sel_j_jr(ID_EX_sel_j_jr),         // Seleciona a fonte do endereco do salto incondicional
        .reg_dst_mux(ID_EX_reg_dst_mux),// Seleciona o endereco do registrador de escrita
        .is_jump(ID_EX_is_jump),          // A instrucao eh um salto incondicional
        .mem_write_enable(ID_EX_mem_write_enable), // Habilita a escrita na memoria
        .sel_beq_bne(ID_EX_sel_beq_bne),      // Seleciona entre beq e bne
        .fl_write_enable(ID_EX_fl_write_enable),  // Habilita a escrita no registrador de flags
        .sel_jt_jf(ID_EX_sel_jt_jf),        // Seleciona entre jt e jf na fmu
        .is_branch(ID_EX_is_branch),        // A instrucao eh um desvio pc-relative
        .sel_jflag_branch(ID_EX_sel_jflag_branch), // seletor do tipo do branch
        .wb_res_mux(ID_EX_wb_res_mux), // Seleciona o dado que sera escrito no registrador
        .reg_write_enable(ID_EX_reg_write_enable) // Habilita a escrita no banco de registradores
    );

    EX_stage EX_stage_inst
    (
        // Entradas
        .clk(clk),
        .rst(rst),
        .alu_src_mux(ID_EX_alu_src_mux),
        .alu_funct(ID_EX_alu_funct),
        .reg_dst_mux(ID_EX_reg_dst_mux),
        .sel_j_jr(ID_EX_sel_j_jr),
        .in_next_pc(ID_EX_out_next_pc),
        .in_immediate(ID_EX_imm),
        .in_data_rs(ID_EX_rs_data),
        .in_data_rt(ID_EX_rt_data),
        .in_rs(ID_EX_flag_addr),
        .in_rt(ID_EX_rt),
        .in_rd(ID_EX_rd),
        .in_sel_jflag_branch(ID_EX_sel_jflag_branch),
        .in_mem_write_enable(ID_EX_mem_write_enable),
        .in_sel_beq_bne(ID_EX_sel_beq_bne),
        .in_fl_write_enable(ID_EX_fl_write_enable),
        .in_sel_jt_jf(ID_EX_sel_jt_jf),
        .in_is_branch(ID_EX_is_branch),
        .in_is_jump(ID_EX_is_jump),
        .in_wb_res_mux(ID_EX_wb_res_mux),
        .in_reg_write_enable(ID_EX_reg_write_enable),

        // Saidas
        .out_sel_jflag_branch(EX_MEM_out_sel_jflag_branch),
        .out_mem_write_enable(EX_MEM_out_mem_write_enable),
        .out_sel_beq_bne(EX_MEM_out_sel_beq_bne),
        .out_fl_write_enable(EX_MEM_out_fl_write_enable),
        .out_sel_jt_jf(EX_MEM_out_sel_jt_jf),
        .out_is_branch(EX_MEM_out_is_branch),
        .out_is_jump(EX_MEM_out_is_jump),
        .out_wb_res_mux(EX_MEM_out_wb_res_mux),
        .out_reg_write_enable(EX_MEM_out_reg_write_enable),
        .out_next_pc(EX_MEM_out_next_pc),
        .out_branch_addr(EX_MEM_out_branch_addr),
        .out_immediate(EX_MEM_out_immediate),
        .abs_addr(EX_MEM_abs_addr),
        .mem_addr(EX_MEM_mem_addr),
        .mem_data(EX_MEM_mem_data),
        .alu_out(EX_MEM_alu_out),
        .alu_flags_out(EX_MEM_alu_flags_out),
        .flag_addr(EX_MEM_flag_addr),
        .reg_dst(EX_MEM_reg_dst)
    );

    MEM_stage MEM_stage_inst
    (
        // Entradas
        .clk(clk),
        .rst(rst),
        .sel_jflag_branch(EX_MEM_out_sel_jflag_branch),
        .in_mem_write_enable(EX_MEM_out_mem_write_enable),
        .in_sel_beq_bne(EX_MEM_out_sel_beq_bne),
        .in_fl_write_enable(EX_MEM_out_fl_write_enable),
        .in_sel_jt_jf(EX_MEM_out_sel_jt_jf),
        .in_is_branch(EX_MEM_out_is_branch),
        .in_is_jump(EX_MEM_out_is_jump),
        .in_wb_res_mux(EX_MEM_out_wb_res_mux),
        .in_reg_write_enable(EX_MEM_out_reg_write_enable),
        .in_next_pc(EX_MEM_out_next_pc),
        .in_branch_addr(EX_MEM_out_branch_addr),
        .in_immediate(EX_MEM_out_immediate),
        .abs_addr(EX_MEM_abs_addr),
        .in_mem_addr(EX_MEM_mem_addr),
        .in_mem_data(EX_MEM_mem_data),
        .in_alu_res(EX_MEM_alu_out),
        .alu_flags(EX_MEM_alu_flags_out),
        .flag_addr(EX_MEM_flag_addr),
        .in_reg_dst(EX_MEM_reg_dst),

        //saidas
        .out_is_jump(MEM_WB_out_is_jump),//
        .out_branch_taken(MEM_WB_out_branch_taken),//
        .out_branch_addr(MEM_WB_out_branch_addr),
        .out_reg_write_enable(MEM_WB_out_reg_write_enable),//
        .out_wb_res_mux(MEM_WB_out_wb_res_mux), //
        .out_next_pc(MEM_WB_out_next_pc), // o pc + 1 do jal
        .out_mem_data(MEM_WB_out_mem_data),//
        .out_alu_res(MEM_WB_out_alu_res),//
        .out_reg_dst(MEM_WB_out_reg_dst),//
        .imm(MEM_WB_imm),//
        .out_jump_addr(MEM_WB_out_jump_addr)//
    );

    WB_stage WB_stage_inst
    (
        // Entradas
        .in_is_jump(MEM_WB_out_is_jump),//
        .in_branch_taken(MEM_WB_out_branch_taken),//
        .in_branch_addr(MEM_WB_out_branch_addr),
        .in_reg_write_enable(MEM_WB_out_reg_write_enable),//
        .wb_res_mux(MEM_WB_out_wb_res_mux), //
        .next_pc(MEM_WB_out_next_pc), // o pc + 1 do jal
        .mem_data(MEM_WB_out_mem_data),//
        .alu_res(MEM_WB_out_alu_res),//
        .in_reg_dst(MEM_WB_out_reg_dst),//
        .imm(MEM_WB_imm),//
        .in_jump_addr(MEM_WB_out_jump_addr),//

        // Saidas
        .out_is_jump(WB_IF_out_is_jump),
        .out_branch_taken(WB_IF_out_branch_taken),
        .out_branch_addr(WB_IF_out_jump_addr),
        .out_reg_write_enable(WB_ID_out_reg_write_enable),
        .wb_res(WB_ID_wb_res),
        .out_reg_dst(WB_ID_out_reg_dst),
        .out_jump_addr(WB_IF_out_jump_addr)
    );
endmodule // lapido_top
