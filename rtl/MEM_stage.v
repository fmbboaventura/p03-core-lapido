 `include "lapido_defs.v"

module MEM_stage 
(
	input clk,    // Clock
	input rst,  
	
	//Sinal para o estágio wb
	input wb_res_mux,

	//Entradas de sinais do registrador EX/MEM para o MEM
	input is_branch,
	input sel_jflag_branch,
	input sel_beq_bne,
	input sel_jt_jf,
	input mem_write,

	//Entrada de dados
	input [4:0]flag_code,
	input [`PC_WIDTH - 1:0] in_next_pc,
	input [`PC_WIDTH - 1:0] branch_addr,
	input [5:0]flags,
	input [31:0]alu_res,
	input [31:0] in_mem_addr,//saida rs_data do banco de registradores
	input [31:0] in_mem_data,//saida rt_data do banco de registradores
	input [4:0] in_reg_dst,//registrador onde vai ser escrito os dados da operação do tio R
	input [31:0] in_immediate,//

	//saídas do estágio MEM
	output reg [1:0] out_wb_res_mux,
	output reg [1:0] out_branch_taken, 
	output reg [`PC_WIDTH - 1:0] out_next_pc,
	output reg [31:0] out_mem_data,//
	output reg [31:0] out_alu_res,//
    output reg [4:0]  out_reg_dst,//
    output reg [31:0] out_imm//  

);

	wire [31:0] wire_out_mem_data;
	wire wire_out_bru;

	 bru branch_resolution_unit
	 (
	 	.flag_code(flag_code),
	 	.flags_in(flags),
	 	.sel_jt_jf(sel_jt_jf),
	 	.sel_beq_bne(sel_beq_bne),
	 	.sel_jflag_branch(sel_jflag_branch),
	 	.is_branch(is_branch),
	 	.branch_taken(wire_out_bru)
	 );

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
		out_branch_taken <= wire_out_bru;
		out_next_pc <= in_next_pc;
		out_mem_data <= wire_out_mem_data;
		out_alu_res <= alu_res;
		out_reg_dst <= in_reg_dst;
		out_imm <= in_immediate; 
	end	

endmodule