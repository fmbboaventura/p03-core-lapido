/***************************************************
 * Module: WB_stage
 * Project: core_lapido
 * Author: Afonso Machado
 * Description: Seleciona o dado a ser escrito no
 * banco de registradores e propaga os sinais e
 * enderecos para os saltos
 ***************************************************/
 `include "lapido_defs.v"

 module WB_stage (

 	input [1:0] wb_res_mux,//
    input reg_write_enable,//
	input [`PC_WIDTH - 1:0] next_pc,//
	input [31:0] mem_data,//
	input [31:0] alu_res,//
    input [31:0] imm,//
    input [4:0]  reg_dst,//

    output out_reg_write_enable,
    output [`PC_WIDTH-1: 0] out_wb_res,
    output [4:0] out_reg_dst
 	
 );

 	assign out_wb_res = (wb_res_mux == `WB_ALU) ? alu_res : 
 						(wb_res_mux == `WB_MEM) ? mem_data :
						(wb_res_mux == `WB_PC) ? next_pc : imm;
 

	assign out_reg_write_enable = reg_write_enable;
	assign out_reg_dst = reg_dst;

 endmodule