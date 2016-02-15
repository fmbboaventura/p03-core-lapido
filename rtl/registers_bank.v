/***************************************************
 * Module: registers_bank
 * Project: core_lapido
 * Author: Afonso Machado
 * Description: Banco de registradores contendo os
 * 16 registradores de proposito geral.
 ***************************************************/
`timescale 1ns/1ps

module registers_bank (
	input clk,
	input rst,
	input en,
	input [4:0] rd,
	input [4:0] rs,
	input [4:0] rt,
	input [31:0] data,

	output reg [31:0] data_rs,
	output reg [31:0] data_rt
	
);

//integer i;
reg [31:0] registers [15:0];

/*initial begin

  for (i = 0; i < 32; i = i + 1) begin
    registers[i] = 0;
  end
  
  data_rs = 0;
  data_rt = 0;
end*/

always @ (posedge clk or posedge rst) begin 
	if(rst) begin
		registers[0]=32'd0;
			registers[1]=32'd0;
			registers[2]=32'd0;
			registers[3]=32'd0;
			registers[4]=32'd0;
			registers[5]=32'd0;
			registers[6]=32'd0;
			registers[7]=32'd0;
			registers[8]=32'd0;
			registers[9]=32'd0;
			registers[10]=32'd0;
			registers[11]=32'd0;
			registers[12]=32'd0;
			registers[13]=32'd0;
			registers[14]=32'd0;
			registers[15]=32'd0;
			registers[16]=32'd0;
			registers[17]=32'd0;
			registers[18]=32'd0;
			registers[19]=32'd0;
			registers[20]=32'd0;
			registers[21]=32'd0;
			registers[22]=32'd0;
			registers[23]=32'd0;
			registers[24]=32'd0;
			registers[25]=32'd0;
			registers[26]=32'd0;
			registers[27]=32'd0;
			registers[28]=32'd0;
			registers[29]=32'd0;
			registers[30]=32'd0;
			registers[31]=32'd0;
	end
	else begin
		if(en) begin
			registers[rd] <= data;
		end
	end
end

assign rs = (data_rs == 0) ? 32'd0 : registers[data_rs];

assign rt = (data_rt == 0) ? 32'd0 : registers[data_rt];

endmodule