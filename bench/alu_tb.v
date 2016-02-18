/***************************************************
 * Module: alu_tb
 * Project: core_lapido
 * Author: Felipe Cordeiro
 * Description: Test Bench criado para o modulo da alu.
 ***************************************************/

`include "lapido_defs.v"

`timescale 1ns/1ps
module alu_tb();
	
	reg [31:0] data_rs;		// Primeiro operando
	reg [31:0] data_rt; 	// Segundo operando
    reg [5:0] alu_funct; // Operacao da alu

    wire [32:0] alu_res; // O 33th bit eh o carry da alu
    wire [4:0] flags;     // Demais flags

    alu uut(
    	.data_rs(data_rs),
     	.data_rt(data_rt),
      	.alu_funct(alu_funct),
      	.alu_res(alu_res),
      	.flags(flags));
	


	initial
		begin
			data_rs = 32'b00000000000000000000000000000010;
			data_rt = 32'b00000000000000000000000000000001;
			alu_funct = `FN_ADD;
			#100;
			$Display("%b + %b = %b", data_rs, data_rt, alu_res);
			//00000000000000000000000000000010 + 00000000000000000000000000000001= 00000000000000000000000000000011


			data_rs = 32'b00000000000000000000000000000010;
			data_rt = 32'b00000000000000000000000000000001;
			alu_funct = `FN_SUB;
			#100;
			$Display("%b - %b = %b", data_rs, data_rt, alu_res);
			//00000000000000000000000000000010 - 00000000000000000000000000000001= 0000000000000000000000000000001
		end

endmodule