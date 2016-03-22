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

	//
	input [`GPR_WIDTH-1:0] data_rs,
	input [`GPR_WIDTH-1:0] data_rt,
	input [`GPR_WIDTH-1:0] imm,
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
	output reg [`GRP_ADDR_WIDTH-1:0] out_reg_dest
);

wire [31:0] op1;
wire [31:0] op2;
wire [32:0] alu_res;
wire [4:0] flag_out;

	alu alu(
		.op1(op1),
		.op2(op2),
		.alu_funct(alu_funct),
		.alu_res(alu_res),
		.flags(flag_out)
	);

	mux3x1 mux3x1(
		.in_a(address_rt),
		.in_b(address_rd),
		.in_c(15),
		.sel(sel_reg_dest),
		.out(out_mux)
	);
	
	add add(
		.a(next_pc),
		.b(imm),
		.soma(out_add)
	);

// Propagando sinais para o campo MEM do registrador de estagios
always @(posedge clk) begin
	out_mem_write_enable <= mem_write_enable;
	out_sel_beq_bne <= sel_beq_bne;
	out_sel_jt_jf <= sel_jt_jf;
	out_is_branch <= is_branch;
	out_sel_jflag_branch <= sel_jflag_branch;
end

// Propagando sinais para o campo WB do registrador de estagios
always @(posedge clk) begin
	out_wb_res_mux <= wb_res_mux;
	out_reg_write_enable <= out_reg_write_enable;
end
	
endmodule
	
