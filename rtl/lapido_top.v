`include "lapido_defs.v"

module lapido_top (
	input clk,    // Clock
	input rst  // Asynchronous reset active low
);

	wire [`PC_WIDTH - 1:0] ID_IF_jump_addr;
    wire ID_IF_is_jump;

    // Do estagio IF para o ID
    wire [`INSTRUCTION_WIDTH-1:0] IF_ID_instruction;
    wire [`PC_WIDTH - 1:0] IF_ID_pc;

    // Do banco de registradores para o estagio ID
    wire [`GPR_WIDTH-1:0] REG_ID_data_rs;
    wire [`GPR_WIDTH-1:0] REG_ID_data_rt;

    // Do estagio ID para o banco de registradores
    wire [`GRP_ADDR_WIDTH-1:0] ID_REG_rs;
    wire [`GRP_ADDR_WIDTH-1:0] ID_REG_rt;

    // Saidas para os demais estagios
    wire [5:0] out_alu_funct;
    wire out_alu_src_mux;
    wire [1:0] out_reg_dst_mux;
    wire out_fl_write_enable;
    wire out_mem_write_enable;
    wire out_sel_beq_bne;
    wire out_sel_jt_jf;
    wire out_is_branch;
    wire out_sel_jflag_branch;
    wire [1:0] out_wb_res_mux;
    wire out_reg_write_enable;
    wire [4:0] out_rd;
    wire [4:0] out_rs;
    wire [`GPR_WIDTH-1:0] out_imm;
    wire [`PC_WIDTH-1:0] out_next_pc;

    // Entradas para o hazard_detection_unit
    wire [4:0] ID_HDU_out_rt;
    wire ID_HDU_out_is_load;

    // Saida do hazard_detection_unit
    wire HDU_stall_pipeline;

    wire [`PC_WIDTH - 1:0] MEM_branch_addr;
    wire MEM_branch_taken;

    wire [`GPR_WIDTH-1:0] EX_MEM_data;
    wire [`GPR_WIDTH-1:0] MEM_WB_data;

    // Do fowarding_unit
    wire [1:0] fowardA;
    wire [1:0] fowardB;

    // pc+1 para propagar
    wire [`PC_WIDTH-1:0] next_pc_EX_MEM;

    // Sinais para o estagio MEM
    wire EX_MEM_out_mem_write_enable; // Habilita a escrita na memoria
    wire EX_MEM_out_sel_beq_bne;      // Seleciona entre beq e bne
    wire EX_MEM_out_sel_jt_jf;        // Seleciona entre jt e jf na fmu
    wire EX_MEM_out_is_branch;        // A instrucao eh um desvio pc-relative
    wire EX_MEM_out_sel_jflag_branch; // seletor do tipo do branch

    // Sinais para o estagio WB
    wire [1:0] EX_MEM_out_wb_res_mux; // Seleciona o dado que sera escrito no registrador
    wire EX_MEM_out_reg_write_enable; // Habilita a escrita no banco de registradores

    //Saidas
    wire [`GPR_WIDTH-1:0] EX_MEM_out_imm;
    wire [`PC_WIDTH-1:0] EX_MEM_out_next_pc;
    wire [`PC_WIDTH-1:0] EX_MEM_out_branch_addr;
    wire [`GPR_WIDTH-1:0] EX_MEM_out_alu_res;
    wire [`GPR_WIDTH-1:0] EX_MEM_out_mem_addr;
    wire [`GPR_WIDTH-1:0] EX_MEM_out_mem_data;
    wire [5:0] EX_MEM_out_flags;
    wire [`GRP_ADDR_WIDTH-1:0] EX_MEM_out_reg_dest;

    //--------------------------------------------------------------------------------------
    //---------------ESTÁGIO ID----------------






    IF_stage if_stage(

    	.rst           (rst),
    	.clk           (clk),
    	.jump_addr   	(ID_IF_jump_addr),
    	.is_jump       (ID_IF_is_jump),
    	.branch_taken  (MEM_branch_taken),
    	.branch_addr	(MEM_branch_addr),
    	.stall_pipeline  (HDU_stall_pipeline),

    	.instruction   (IF_ID_instruction),
    	.pc            (IF_ID_pc)

    	);

    ID_stage id_stage(

        .rst                 (rst),
        .clk                 (clk),

        .branch_taken        (MEM_branch_taken),
        .instruction         (IF_ID_instruction),
        .pc                  (IF_ID_instruction),
        .data_rs             (REG_ID_data_rs),
        .data_rt             (REG_ID_data_rt),
        .stall_pipeline      (HDU_stall_pipeline),

        .rs                  (ID_REG_rs),
        .rt                  (ID_REG_rt),
        .jump_addr           (ID_IF_jump_addr),
        .is_jump             (ID_IF_is_jump),
        .out_alu_funct(out_alu_funct),
        .out_alu_src_mux(out_alu_src_mux),
        .out_reg_dst_mux(out_reg_dst_mux),
        .out_is_load(ID_HDU_out_is_load),
        .out_fl_write_enable(out_fl_write_enable),
        .out_mem_write_enable(out_mem_write_enable),
        .out_sel_beq_bne(out_sel_beq_bne),
        .out_sel_jt_jf(out_sel_jt_jf),
        .out_is_branch(out_is_branch),
        .out_sel_jflag_branch(out_sel_jflag_branch),
        .out_wb_res_mux(out_wb_res_mux),
        .out_reg_write_enable(out_reg_write_enable),
        .out_rd(out_rd),
        .out_rs(out_rs),
        .out_rt              (ID_HDU_out_rt),
        .out_imm(out_imm),
        .out_next_pc(out_next_pc)

        );

        EX_stage ex_stage (
            .clk                 (clk),
            .rst                 (rst),
            .branch_taken        (MEM_branch_taken),
            .alu_funct           (out_alu_funct),
            .alu_src_mux         (out_alu_src_mux),
            .reg_dst_mux         (out_reg_dst_mux),
            .fl_write_enable     (out_fl_write_enable),
            .mem_write_enable    (out_mem_write_enable),
            .sel_beq_bne         (out_sel_beq_bne),
            .sel_jt_jf           (out_sel_jt_jf),
            .is_branch           (out_is_branch),
            .sel_jflag_branch    (out_sel_jflag_branch),
            .wb_res_mux          (out_wb_res_mux),
            .reg_write_enable    (out_reg_write_enable),
            .rs                  (out_rs),
            .rt                  (out_rt),
            .rd                  (out_rd),
            .data_rs             (REG_ID_data_rs),
            .data_rt             (REG_ID_data_rt),
            .imm                 (out_imm),
            .EX_MEM_data         (EX_MEM_data),
            .MEM_WB_data         (MEM_WB_data),
            .fowardA             (fowardA),
            .fowardB             (fowardB),
            .next_pc             (next_pc_EX_MEM),

            .out_imm             (EX_MEM_out_imm),
            .out_next_pc         (EX_MEM_out_next_pc),
            .out_branch_addr     (EX_MEM_out_branch_addr),
            .out_alu_res         (EX_MEM_out_alu_res),
            .out_mem_addr        (EX_MEM_out_mem_addr),
            .out_mem_data        (EX_MEM_out_mem_data),
            .out_flags           (EX_MEM_out_flags),
            .out_reg_dest        (EX_MEM_out_reg_dest)


            );
endmodule