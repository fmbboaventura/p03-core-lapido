/***************************************************
 * Module: register_file
 * Project: core_lapido
 * Author: Afonso Machado
 * Description: Banco de registradores contendo os
 * 16 registradores de proposito geral.
 ***************************************************/
`include "lapido_defs.v"

module register_file (
	input clk,
	input rst,
	input en,
	input [4:0] rd,
	input [4:0] rs,
	input [4:0] rt,
	input [`GPR_WIDTH-1:0] data,

	output [`GPR_WIDTH-1:0] data_rs,
	output [`GPR_WIDTH-1:0] 

	//ADICIONAR JAL NO BANCO DE REGITRADORES
	//ADICIONAR A INSERÇÃO LCL, LCH BLABLA

);

reg [`GPR_WIDTH-1:0] registers [`REGISTER_FILE_SIZE-1:0];

always @ (posedge clk or posedge rst) begin
	if(rst) begin
		registers[0]=32'b0;
		registers[1]=32'b0;
		registers[2]=32'b0;
		registers[3]=32'b0;
		registers[4]=32'b0;
		registers[5]=32'b0;
		registers[6]=32'b0;
		registers[7]=32'b0;
		registers[8]=32'b0;
		registers[9]=32'b0;
		registers[10]=32'b0;
		registers[11]=32'b0;
		registers[12]=32'b0;
		registers[13]=32'b0;
		registers[14]=32'b0;
		registers[15]=32'b0;
	end else begin
		if(en) begin
			registers[rd] <= data;
		end
	end
end

assign data_rs = registers[rs];

assign data_rt = registers[rt];

endmodule
