/******************************************************
 * Module: lapido_top
 * Project: core_lapido
 * Author: Afonso Machado, Gadiel Xavier, Felipe Cordeiro
 * e Filipe Boaventura
 * Description: Top level module do processador LAPI
 * DOpaCA LAMBA. Alguns detalhes tecnicos:
 *	-- Arquitetura Harvard, 32 bit
 *  -- Pipeline capaz de detectar e tratar RAW hazards
 *  -- 5 estagios, baseados no MIPS
 *  -- ISA contem +30 instrucoes
 ******************************************************/

`include "lapido_defs.v"

module lapido_top (
	input clk,    // Clock
	input rst  // Asynchronous reset active low
);
    // ----------------- Saidas do estagio IF ----------------
    wire [`INSTRUCTION_WIDTH-1:0] IF_instruction;
    wire [`PC_WIDTH - 1:0] IF_pc;
	wire [`PC_WIDTH - 1:0] ID_jump_addr;
    wire ID_is_jump;

	//// ----------------- Saidas do estagio ID ----------------
    wire [`GRP_ADDR_WIDTH-1:0] ID_rs;
    wire [`GRP_ADDR_WIDTH-1:0] ID_rt;
    wire [5:0] ID_alu_funct;
    wire ID_alu_src_mux;
    wire [1:0] ID_reg_dst_mux;
    wire ID_fl_write_enable;
    wire ID_mem_write_enable;
    wire ID_sel_beq_bne;
    wire ID_sel_jt_jf;
    wire ID_is_branch;
    wire ID_sel_jflag_branch;
    wire [1:0] ID_wb_res_mux;
    wire ID_reg_write_enable;
    wire [4:0] ID_out_rd;
    wire [4:0] ID_out_rs;
    wire [`GPR_WIDTH-1:0] ID_imm;
    wire [`PC_WIDTH-1:0] ID_next_pc;
    wire [4:0] ID_out_rt;
    wire ID_out_is_load;

    // ---------- Saidas do Banco de Registradores ---------
    wire [`GPR_WIDTH-1:0] REG_data_rs;
    wire [`GPR_WIDTH-1:0] REG_data_rt;

    // ---------- Saida do hazard_detection_unit -----------
    wire HDU_stall_pipeline;

	// ----------------- Saidas do estagio EX ----------------
    wire EX_mem_write_enable; // Habilita a escrita na memoria
    wire EX_sel_beq_bne;      // Seleciona entre beq e bne
    wire EX_sel_jt_jf;        // Seleciona entre jt e jf na fmu
    wire EX_is_branch;        // A instrucao eh um desvio pc-relative
    wire EX_sel_jflag_branch; // seletor do tipo do branch
    wire [1:0] EX_wb_res_mux; // Seleciona o dado que sera escrito no registrador
    wire EX_reg_write_enable; // Habilita a escrita no banco de registradores
    wire [`GPR_WIDTH-1:0] EX_out_imm;
    wire [`PC_WIDTH-1:0] EX_next_pc;
    wire [`PC_WIDTH-1:0] EX_branch_addr;
    wire [`GPR_WIDTH-1:0] EX_alu_res;
    wire [`GPR_WIDTH-1:0] EX_mem_addr;
    wire [`GPR_WIDTH-1:0] EX_mem_data;
    wire [5:0] EX_flags;
    wire [`GRP_ADDR_WIDTH-1:0] EX_reg_dest;
	wire [`GRP_ADDR_WIDTH-1:0] EX_flag_code;

    // ----------------- Saidas do estagio MEM ----------------
    wire [1:0] MEM_wb_res_mux;
    wire MEM_reg_write_enable;
    wire [`PC_WIDTH - 1:0] MEM_next_pc;
    wire [31:0] MEM_mem_data;
    wire [31:0] MEM_alu_res;
    wire [31:0] MEM_imm;
    wire [4:0]  MEM_reg_dst;
    wire [`PC_WIDTH - 1:0] MEM_branch_addr;
    wire MEM_branch_taken;

    // ----------------- Saidas do fowarding unit ----------------
    wire [1:0] FU_fowardA;
    wire [1:0] FU_fowardB;

	// ----------------- Saidas do estagio WB ----------------
	wire WB_reg_write_enable;
	wire [`GRP_ADDR_WIDTH-1:0] WB_reg_dest;
	wire [`GPR_WIDTH-1:0] WB_res;

    IF_stage if_stage(
    	.rst            (rst),
    	.clk            (clk),
    	.jump_addr      (ID_jump_addr),
    	.is_jump        (ID_is_jump),
    	.branch_taken   (MEM_branch_taken),
    	.branch_addr	(MEM_branch_addr),
    	.stall_pipeline (HDU_stall_pipeline),
    	.instruction    (IF_instruction),
    	.pc             (IF_pc)
    	);

    ID_stage id_stage(

        .rst                 (rst),
        .clk                 (clk),

        .branch_taken        (MEM_branch_taken),
        .instruction         (IF_instruction),
        .pc                  (IF_pc),
        .data_rs             (REG_data_rs),
        .data_rt             (REG_data_rt),
        .stall_pipeline      (HDU_stall_pipeline),

        .rs                  	(ID_rs),
        .rt                  	(ID_rt),
        .jump_addr           	(ID_jump_addr),
        .is_jump             	(ID_is_jump),
        .out_alu_funct		 	(ID_alu_funct),
        .out_alu_src_mux		(ID_alu_src_mux),
        .out_reg_dst_mux		(ID_reg_dst_mux),
        .out_is_load			(ID_out_is_load),
        .out_fl_write_enable	(ID_fl_write_enable),
        .out_mem_write_enable	(ID_mem_write_enable),
        .out_sel_beq_bne		(ID_sel_beq_bne),
        .out_sel_jt_jf			(ID_sel_jt_jf),
        .out_is_branch			(ID_is_branch),
        .out_sel_jflag_branch	(ID_sel_jflag_branch),
        .out_wb_res_mux			(ID_wb_res_mux),
        .out_reg_write_enable	(ID_reg_write_enable),
        .out_rd					(ID_out_rd),
        .out_rs					(ID_out_rs),
        .out_rt					(ID_out_rt),
        .out_imm				(ID_imm),
        .out_next_pc			(ID_next_pc)

    );

    EX_stage ex_stage (
        .clk                  (clk),
        .rst                  (rst),
        .alu_funct            (ID_alu_funct),
        .alu_src_mux          (ID_alu_src_mux),
        .reg_dst_mux          (ID_reg_dst_mux),
        .fl_write_enable      (ID_fl_write_enable),
        .mem_write_enable     (ID_mem_write_enable),
        .sel_beq_bne          (ID_sel_beq_bne),
        .sel_jt_jf            (ID_sel_jt_jf),
        .is_branch            (ID_is_branch),
        .sel_jflag_branch     (ID_sel_jflag_branch),
        .wb_res_mux           (ID_wb_res_mux),
        .reg_write_enable     (ID_reg_write_enable),
        .rs                   (ID_out_rs),
        .rt                   (ID_out_rt),
        .rd                   (ID_out_rd),
        .next_pc              (ID_next_pc),
        .imm                  (ID_imm),
        .data_rs              (REG_data_rs),
        .data_rt              (REG_data_rt),
        .branch_taken         (MEM_branch_taken),
        .EX_MEM_data          (EX_alu_res),
        .MEM_WB_data          (WB_res),
        .fowardA              (FU_fowardA),
        .fowardB              (FU_fowardB),

        .out_imm              (EX_out_imm),
        .out_next_pc          (EX_next_pc),
        .out_branch_addr      (EX_branch_addr),
        .out_alu_res          (EX_alu_res),
        .out_mem_addr         (EX_mem_addr),
        .out_mem_data         (EX_mem_data),
        .out_flags            (EX_flags),
        .out_reg_dest         (EX_reg_dest),
    	.out_mem_write_enable (EX_mem_write_enable), // Habilita a escrita na memoria
		.out_sel_beq_bne	  (EX_sel_beq_bne),      // Seleciona entre beq e bne
		.out_sel_jt_jf        (EX_sel_jt_jf),         // Seleciona entre jt e jf na fmu
    	.out_is_branch        (EX_is_branch),        // A instrucao eh um desvio pc-relative
    	.out_sel_jflag_branch (EX_sel_jflag_branch),
    	.out_wb_res_mux       (EX_wb_res_mux), // Seleciona o dado que sera escrito no registrador
    	.out_reg_write_enable (EX_reg_write_enable), // Habilita a escrita no banco de registradores

    	.flag_code              (EX_flag_code)
    );

	register_file reg_file (
		.clk(clk),
		.rst(rst),
		.en(WB_reg_write_enable),
		.rd(WB_reg_dest),
		.rs(ID_rs),
		.rt(ID_rt),
		.data(WB_res),
		.data_rs(REG_data_rs),
		.data_rt(REG_data_rt)
	);

	hazard_detection_unit hdu
    (
        .ID_EX_is_load(ID_out_is_load),
        .ID_EX_rt(ID_out_rt),
        .IF_ID_rs(IF_instruction[25:21]),
        .IF_ID_rt(IF_instruction[20:16]),
        .stall_pipeline(HDU_stall_pipeline)
    );

	fowarding_unit fu (
		.ID_EX_rs(ID_rs),
    	.ID_EX_rt(ID_rt),
    	.EX_MEM_reg_write_enable(EX_reg_write_enable),
    	.EX_MEM_rd(EX_reg_dest),
    	.MEM_WB_reg_write_enable(WB_reg_write_enable),
    	.MEM_WB_rd(WB_reg_dest),
    	.fowardA(FU_fowardA),
    	.fowardB(FU_fowardB)
	);

    MEM_stage mem_stage (
        .clk                 (clk),
        .rst                 (rst),
        .wb_res_mux          (EX_wb_res_mux),
        .reg_write_enable    (EX_reg_write_enable),

        .is_branch           (EX_is_branch),
        .sel_jflag_branch    (EX_sel_jflag_branch),
        .sel_beq_bne         (EX_sel_beq_bne),
        .sel_jt_jf           (EX_sel_jt_jf),
        .mem_write           (EX_mem_write_enable),

        .flag_code           (EX_flag_code),
        .flags               (EX_flags),
        .in_next_pc          (EX_next_pc),
        .branch_addr         (EX_branch_addr),
        .alu_res             (EX_alu_res),
        .in_mem_addr         (EX_mem_addr),
        .in_mem_data         (EX_mem_data),
        .in_immediate        (EX_out_imm),
        .in_reg_dst          (EX_reg_dest),

        .out_branch_taken    (MEM_branch_taken),
        .out_wb_res_mux      (MEM_wb_res_mux),
        .out_reg_write_enable(MEM_reg_write_enable),
        .out_next_pc         (MEM_next_pc),
        .out_mem_data        (MEM_mem_data),
        .out_alu_res         (MEM_alu_res),
        .out_imm             (MEM_imm),
        .out_reg_dst         (MEM_reg_dst)

        );

    WB_stage wb_stage (
        .wb_res_mux          (MEM_wb_res_mux),
        .reg_write_enable    (MEM_reg_write_enable),
        .next_pc             (MEM_next_pc),
        .mem_data            (MEM_mem_data),
        .alu_res             (MEM_alu_res),
        .imm                 (MEM_imm),
        .reg_dst             (MEM_reg_dst),

        .out_reg_write_enable(WB_reg_write_enable),
        .out_wb_res          (WB_res),
        .out_reg_dst         (WB_reg_dest)

        );
endmodule
