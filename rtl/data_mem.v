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
	input rst,
	input [`DATA_MEM_ADDR_WIDTH-1:0] addr,
	input [31:0] write_data,
	input write_en,

	output [31:0] read_data

);

reg [31:0] ram [1023:0];

integer ram_in; // Arquivo de entrada
integer ram_out; // Arquivo de saida
integer i;
reg [31:0] data;

always @ (posedge clk or posedge rst) begin
	if (rst) begin
		ram_out = $fopen("data/data_out.txt", "w");
		for (i = 0; i < 1024; i = i + 1) begin
			$fwrite(ram_out,"%08H\n", ram[i]);
		end
		$fclose(ram_out);

		ram_in = $fopen("data/data_in.txt", "r");
		for (i = 0; i < 1024; i = i + 1) begin
			$fscanf(ram_in,"%08H", data);
			if($feof(ram_in)) i = 1024;
			else ram[i] = data;
		end
		$fclose(ram_in);
	end else if(write_en) begin
		ram[addr] <= write_data;
	end
end

assign read_data = ram[addr];

endmodule
