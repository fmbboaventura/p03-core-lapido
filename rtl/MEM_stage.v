 /***************************************************
 * Module: MEM_stage
 * Project: core_lapido
 * Author: Afonso Machado e Felipe Cordeiro
 * Description: Modulo que representa o estágio de
 * memória do processador LAPIDO
 ***************************************************/

 `include "lapido_defs.v"

module MEM_stage
(
	input clk,
	input rst,

	//Sinal para o estágio wb
	input [1:0] wb_res_mux,
    input reg_write_enable,
	input mem_write,

	input [`PC_WIDTH - 1:0] in_next_pc,
	input [31:0] alu_res,
	input [31:0] in_mem_addr,//saida rs_data do banco de registradores
	input [31:0] in_mem_data,//saida rt_data do banco de registradores
	input [31:0] in_immediate,//
	input [4:0] in_reg_dst,//registrador onde vai ser escrito os dados

	//saídas do estágio MEM
	output reg [1:0] out_wb_res_mux,
    output reg out_reg_write_enable,
	output reg [`PC_WIDTH - 1:0] out_next_pc,
	output reg [31:0] out_mem_data,//
	output reg [31:0] out_alu_res,//
    output reg [31:0] out_imm,//
    output reg [4:0]  out_reg_dst//
);

	wire [31:0] wire_out_mem_data;
	wire wire_out_bru;

	 data_mem data_memory
	 (
		.clk(clk),
		.rst(rst),
		.addr(in_mem_addr),
		.write_data(in_mem_data),
		.write_en(mem_write),
		.read_data(wire_out_mem_data)
	  );

	always @ (posedge clk) begin
		out_wb_res_mux <= wb_res_mux;
        out_reg_write_enable <= reg_write_enable;
		out_next_pc <= in_next_pc;
		out_mem_data <= wire_out_mem_data;
		out_alu_res <= alu_res;
		out_reg_dst <= in_reg_dst;
		out_imm <= in_immediate;
	end

endmodule
