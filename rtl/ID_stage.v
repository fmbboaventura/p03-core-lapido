/***************************************************
 * Module: ID_stage
 * Project: core_lapido
 * Author: Filipe Boaventura
 * Description: Modulo responsavel pela busca de
 * operandos e decodificacao da instrucao.
 ***************************************************/
`include "lapido_defs.v"

module ID_stage
(
    input clk,
    input rst,

    // Do estagio IF
    input [`INSTRUCTION_WIDTH-1:0] instruction,
    input [`PC_WIDTH-1:0] pc,

    // Do banco de registradores
    input [`GPR_WIDTH-1:0] data_rs,
    input [`GPR_WIDTH-1:0] data_rt,

    // Do hazard detection unit
    input stall_pipeline,

    // Para o banco de registradores
    output [`GRP_ADDR_WIDTH-1:0] rs,
    output [`GRP_ADDR_WIDTH-1:0] rt,

    // Para o estagio IF
    output [`PC_WIDTH-1:0] jump_addr,
    output is_jump,

    // Sinais para o estagio EX
    output reg [5:0] out_alu_funct,  // Seleciona a operacao da alu
    output reg out_alu_src_mux,      // Seleciona o segundo operando da alu
    output reg [1:0] out_reg_dst_mux,// Seleciona o endereco do registrador de escrita
    output reg out_is_load,          // A instrucao eh um load
    output reg out_fl_write_enable,  // Habilita a escrita no registrador de flags

    // Sinais para o estagio MEM
    output reg out_mem_write_enable, // Habilita a escrita na memoria
    output reg out_sel_beq_bne,      // Seleciona entre beq e bne
    output reg out_sel_jt_jf,        // Seleciona entre jt e jf na fmu
    output reg out_is_branch,        // A instrucao eh um desvio pc-relative
    output reg out_sel_jflag_branch, // seletor do tipo do branch

    // Sinais para o estagio WB
    output reg [1:0] out_wb_res_mux, // Seleciona o dado que sera escrito no registrador
    output reg out_reg_write_enable, // Habilita a escrita no banco de registradores

    // Campos das instrucoes
    output reg [4:0] out_rd,
    output reg [4:0] out_rs,
    output reg [4:0] out_rt,
    output reg [`GPR_WIDTH-1:0] out_imm,

    // pc + 1 para o proximo estagio
    output reg [`PC_WIDTH-1:0] out_next_pc,

    // Saida do banco de registradores
    output reg [`GPR_WIDTH-1:0] out_data_rs,
    output reg [`GPR_WIDTH-1:0] out_data_rt
);

/**** Registrador de instrucao e campos da instrucao ****/
reg [`INSTRUCTION_WIDTH-1:0] instruction_reg;
wire	[5:0]		ir_opcode;
wire	[5:0]		ir_funct;

/***************** Sinais de Controle *******************/
// Sinais para o estagio ID (este estagio)
wire sel_j_jr;         // Seleciona a fonte do endereco do salto incondicional

// Sinais para o estagio EX
wire [5:0] alu_funct;  // Seleciona a operacao da alu
wire alu_src_mux;      // Seleciona o segundo operando da alu
wire [1:0] reg_dst_mux;// Seleciona o endereco do registrador de escrita
wire is_load;          // A instrucao eh um load
wire fl_write_enable;  // Habilita a escrita no registrador de flags

// Sinais para o estagio MEM
wire mem_write_enable; // Habilita a escrita na memoria
wire sel_beq_bne;      // Seleciona entre beq e bne
wire sel_jt_jf;        // Seleciona entre jt e jf na fmu
wire is_branch;        // A instrucao eh um desvio pc-relative
wire sel_jflag_branch; // seletor do tipo do branch

// Sinais para o estagio WB
wire [1:0] wb_res_mux; // Seleciona o dado que sera escrito no registrador
wire reg_write_enable; // Habilita a escrita no banco de registradores

always @ (posedge clk) begin
    instruction_reg <= instruction;
    out_next_pc <= pc+`PC_WIDTH'b1;
end

assign ir_opcode = instruction_reg[31:26];
assign ir_funct  = instruction_reg[5:0];

control_unit ctrl
(
    .opcode(ir_opcode),
    .funct(ir_funct),
    .stall_pipeline(stall_pipeline),
    .is_jump(is_jump), // Para o estagio if
    .sel_j_jr(sel_j_jr),
    .alu_funct(alu_funct),
    .alu_src_mux(alu_src_mux),
    .reg_dst_mux(reg_dst_mux),
    .is_load(is_load),
    .fl_write_enable(fl_write_enable),
    .mem_write_enable(mem_write_enable),
    .sel_beq_bne(sel_beq_bne),
    .sel_jt_jf(sel_jt_jf),
    .is_branch(is_branch),
    .sel_jflag_branch(sel_jflag_branch),
    .wb_res_mux(wb_res_mux),
    .reg_write_enable(reg_write_enable)
);

// Para o banco de registradores
assign rs = (instruction_reg[25:21] < `REGISTER_FILE_SIZE)?
        instruction_reg[25:21] : `GRP_ADDR_WIDTH'hF;
assign rt = (instruction_reg[20:16] < `REGISTER_FILE_SIZE)?
        instruction_reg[20:16] : `GRP_ADDR_WIDTH'hF;

// Para o estagio IF
assign jump_addr = (sel_j_jr)? {6'b000000, instruction_reg[25:0]} : data_rs;// Para o estagio IF

always @ (posedge clk) begin
    out_data_rs <= data_rs;
    out_data_rt <= data_rt;
end

always @ (posedge clk or posedge rst) begin
    if (rst) begin
        //pipeline_reg_out <= 0;
    end else begin
        out_is_load <= is_load;
        out_wb_res_mux <= wb_res_mux;
        out_reg_write_enable <= reg_write_enable;
        out_mem_write_enable <= mem_write_enable;
        out_sel_beq_bne <= sel_beq_bne;
        out_fl_write_enable <= fl_write_enable;
        out_sel_jt_jf <= sel_jt_jf;
        out_is_branch <= is_branch;
        out_sel_jflag_branch <= sel_jflag_branch;
        out_alu_funct <= alu_funct;
        out_alu_src_mux <= alu_src_mux;
        out_reg_dst_mux <= reg_dst_mux;
        out_rd <= instruction_reg[15:11];
        out_rs <= instruction_reg[25:21];
        out_rt <= instruction_reg[20:16];
        out_imm <= {{16{instruction_reg[15]}}, instruction_reg[15:0]};
    end
end

endmodule // ID_stage
