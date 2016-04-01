/***************************************************
 * Module: EX_stage
 * Project: core_lapido
 * Author: Gadiel Xavier
 * Description: Modulo responsavel pelo calculo das
instrucoes aritimeticas e de endereco.
 ***************************************************/
`include "lapido_defs.v"

module EX_stage
(
	input clk,// Clock
	input rst,// Reset
	input branch_taken, // Do estagio MEM. Insere bolha se o branch foi tomado

	// Sinais para o estagio EX
	input [5:0] alu_funct,  // Seleciona a operacao da alu
	input alu_src_mux,      // Seleciona o segundo operando da alu
	input [1:0] reg_dst_mux,// Seleciona o endereco do registrador de escrita
	input fl_write_enable,  // Habilita a escrita no registrador de flags

	// Sinais para o estagio MEM
	input mem_write_enable, // Habilita a escrita na memoria
	input sel_beq_bne,      // Seleciona entre beq e bne
	input sel_jt_jf,        // Seleciona entre jt e jf na fmu
	input is_branch,        // A instrucao eh um desvio pc-relative

	input sel_jflag_branch, // seletor do tipo do branch

	// Sinais para o estagio WB
	input [1:0] wb_res_mux, // Seleciona o dado que sera escrito no registrador
	input reg_write_enable, // Habilita a escrita no banco de registradores

	//Campos das intrucoes
	input [`GRP_ADDR_WIDTH-1:0] rs,
	input [`GRP_ADDR_WIDTH-1:0] rt,
	input [`GRP_ADDR_WIDTH-1:0] rd,

	// Possiveis operando da alu
	input [`GPR_WIDTH-1:0] data_rs,
	input [`GPR_WIDTH-1:0] data_rt,
	input [`GPR_WIDTH-1:0] imm,
	input [`GPR_WIDTH-1:0] EX_MEM_data,
	input [`GPR_WIDTH-1:0] MEM_WB_data,

	// Do fowarding_unit
	input [1:0] fowardA,
	input [1:0] fowardB,

	// pc+1 para propagar
	input [`PC_WIDTH-1:0] next_pc,

    // Sinais para o estagio MEM
    output reg out_mem_write_enable, // Habilita a escrita na memoria
    output reg out_sel_beq_bne,      // Seleciona entre beq e bne
    output reg out_sel_jt_jf,        // Seleciona entre jt e jf na fmu
    output reg out_is_branch,        // A instrucao eh um desvio pc-relative
    output reg out_sel_jflag_branch, // seletor do tipo do branch

    // Sinais para o estagio WB
    output reg [1:0] out_wb_res_mux, // Seleciona o dado que sera escrito no registrador
    output reg out_reg_write_enable, // Habilita a escrita no banco de registradores

	//Saidas
	output reg [`GPR_WIDTH-1:0] out_imm,
	output reg [`PC_WIDTH-1:0] out_next_pc,
	output reg [`PC_WIDTH-1:0] out_branch_addr,
	output reg [`GPR_WIDTH-1:0] out_alu_res,
	output reg [`GPR_WIDTH-1:0] out_mem_addr,
	output reg [`GPR_WIDTH-1:0] out_mem_data,
	output reg [5:0] out_flags,
	output reg [`GRP_ADDR_WIDTH-1:0] out_reg_dest,
	output reg [`GRP_ADDR_WIDTH-1:0] out_rs
);

wire [`GPR_WIDTH-1:0] op1;
wire [`GPR_WIDTH-1:0] op2;
wire [32:0] alu_res;
wire [4:0] flag_out;

//Entradas da alu
assign op1 = (fowardA == `FOWARD_EX) ? EX_MEM_data :
			 (fowardA == `FOWARD_MEM) ? MEM_WB_data : data_rs;
assign op2 = (alu_src_mux == `ALU_SRC_IMM) ? imm :
			 (fowardB == `FOWARD_EX) ? EX_MEM_data :
			 (fowardB == `FOWARD_MEM) ? MEM_WB_data : data_rt;

alu alu(
	.op1(op1),
	.op2(op2),
	.alu_funct(alu_funct),
	.alu_res(alu_res),
	.flags(flag_out)
);

// Selecionando o endereco do registrador de destino
always @ (posedge clk or posedge rst) begin
	if (rst || branch_taken) begin
		out_reg_dest <= `GRP_ADDR_WIDTH'b0;
	end else begin
		case (reg_dst_mux)
			`REG_DST_RD: out_reg_dest <= rd;
			`REG_DST_RT: out_reg_dest <= rt;
			`REG_DST_15: out_reg_dest <= `GRP_ADDR_WIDTH'hF;
		endcase
	end
end

// Propagando sinais para o campo MEM do registrador de estagios
// Propagando dados relativos ao estagio MEM
always @(posedge clk or posedge rst) begin
	if (rst || branch_taken) begin
		out_mem_write_enable <= 1'b0;
		out_sel_beq_bne <= 1'b0;
		out_sel_jt_jf <= 1'b0;
		out_is_branch <= 1'b0;
		out_sel_jflag_branch <= 1'b0;
		out_branch_addr <= `PC_WIDTH'b0;
	end else begin
		out_rs <= rs;
		out_mem_write_enable <= mem_write_enable;
		out_sel_beq_bne <= sel_beq_bne;
		out_sel_jt_jf <= sel_jt_jf;
		out_is_branch <= is_branch;
		out_sel_jflag_branch <= sel_jflag_branch;
		out_branch_addr <= next_pc + imm; // Substitui o somador
	end
end

// Escrevendo no registrador de flags
always @ (posedge clk or posedge rst) begin
	if (rst || branch_taken) begin
		out_flags <= 6'b0;
	end else begin
		if (fl_write_enable) begin
			out_flags[5] <= alu_res[32];
			out_flags[4:0] <= flag_out[4:0];
		end
	end
end

// Propagando sinais para o campo WB do registrador de estagios
// Propagando dados relativos ao WB
always @(posedge clk or posedge rst) begin
	if (rst || branch_taken) begin
		out_wb_res_mux <= 2'b0;
		out_reg_write_enable <= 1'b0;
		out_next_pc <= `PC_WIDTH'b0; // pc+1 para salvar no banco de registradores
		out_imm <= `GPR_WIDTH'b0; // imediato para salvar no banco de registradores
		out_alu_res <= `GPR_WIDTH'b0; // Resultado da alu para salvar no banco de registradores
	end else begin
		out_wb_res_mux <= wb_res_mux; // seleciona o que vai gravar no banco de registradores
		out_reg_write_enable <= out_reg_write_enable; // Enable de escrita do register file
		out_next_pc <= next_pc; // pc+1 para salvar no banco de registradores
		out_imm <= imm; // imediato para salvar no banco de registradores
		out_alu_res[31:0] <= alu_res[31:0]; // Resultado da alu para salvar no banco de registradores
	end
end

endmodule
