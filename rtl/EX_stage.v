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

	//Entradas de sinais do registrador ID/EX para o EX
	input alu_src,
	input [5:0]alu_funct,// op code da instrucao
	input sel_fl_write_enable,
	input sel_reg_dest,

	//Entrada de dados
	input [`GRP_ADDR_WIDTH-1:0] address_rt,//saida address_rt do banco de registradores
	input [`GRP_ADDR_WIDTH-1:0] address_rd,//saida address_rd do banco de registradores
	input [`GRP_ADDR_WIDTH-1:0] address_rs,//saida address_rs do banco de registradores
	input [`GPR_WIDTH-1:0] data_rs,//saida data_rs do banco de registradores
    	input [`GPR_WIDTH-1:0] data_rt,//saida data_rt do banco de registradores
	input [`GPR_WIDTH-1:0] imm,//saida do signal extend.
	input [`PC_WIDTH-1:0] next_pc,

	//saidas do estagio EX
	output reg [1:0] out_alu_flags,
	output reg [`GPR_WIDTH-1:0 ] out_alu_data,
	output reg [`GRP_ADDR_WIDTH-1:0] out_address_rs,
	output reg [`GPR_WIDTH-1:0] out_add,
	output reg [`GPR_WIDTH-1:0] out_data_rs,
	output reg [`GPR_WIDTH-1:0] out_data_rt,
	output reg [`GRP_ADDR_WIDTH-1:0] out_mux, 
	output reg [`PC_WIDTH - 1:0] out_next_pc,
	output reg [`GPR_WIDTH-1:0] out_imm

);

	alu alu(
		.op1(data_rs),
		.op2(data_rt),
		.alu_funct(alu_funct),
		.alu_res(out_alu_data),
		.flags(out_alu_flags)
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
		.soma(out_add),
	);
	
endmodule
	
