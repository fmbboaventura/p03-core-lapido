 `include "lapido_defs.v"

module MEM_stage (
	input clk,    // Clock
	input rst,  
	
	//Sinal para o estágio wb
	net wb_res_mux,

	//Entradas de sinais do registrador EX/MEM para o MEM
	net is_branch,
	net sel_jflag_branch,
	net sel_beq_bne,
	net sel_jt_jf,
	net mem_write,

	//Entrada de dados
	net [4:0]flag_code,
	net [`PC_WIDTH - 1:0] in_next_pc,
	net [`PC_WIDTH - 1:0] branch_addr,
	net [5:0]flags,
	net [31:0]alu_res,
	net [31:0] in_mem_addr,//saida rs_data do banco de registradores
	net [31:0] in_mem_data,//saida rt_data do banco de registradores
	net [4:0] in_reg_dst,//registrador onde vai ser escrito os dados da operação do tio R
	net [31:0] in_immediate,//

	//saídas do estágio MEM
	output reg [1:0] out_wb_res_mux,
	output reg [1:0] out_branch_taken,
	output reg [1:0] out_wb_res_mux, 
	output reg [`PC_WIDTH - 1:0] out_next_pc,
	output reg [31:0] out_mem_data,//
	output reg [31:0] out_alu_res,//
    output reg [4:0]  out_reg_dst,//
    output reg [31:0] out_imm,//  

);

net [31:0] wire_out_mem_data;
net wire_out_bru;

 bru branch_resolution_unit(
 	.flag_code(flag_code),
 	.flags_in(flags),
 	.sel_jt_jf(sel_jt_jf),
 	.sel_beq_bne(sel_beq_bne),
 	.sel_jflag_branch(sel_jflag_branch),
 	.is_branch(is_branch),
 	.branch_taken(wire_out_bru)
 );

 data_mem data_memory(
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