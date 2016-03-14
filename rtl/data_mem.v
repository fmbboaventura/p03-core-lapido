/***************************************************
 * Module: data_mem
 * Project: core_lapido
 * Author: Afonso Machado
 * Description: Implentação de uma memória RAM para
 * palavras de 32 bits
 ***************************************************/

`include "lapido_defs.v"

module data_mem (
	input clk,    // Clock
	input [31:0] addr,
	input [31:0] write_data,
	input write_en,

	output [31:0] read_data
	
);

reg [31:0] ram [1024:0];

always @(posedge clk) begin
	if(write_en) begin
		ram[addr] <= write_data;
	end
end

assign write_data = ram[addr];

endmodule