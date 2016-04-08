/***************************************************
 * Module: mux3x1
 * Project: core_lapido
 * Author: Afonso Machado
 * Description: Multiplexador de três entradas e uma
 * saida, com seletor em 00, 01 e 10.
 ***************************************************/

module mux3x1 (
	input [31:0] in_a, //Primeira entrada de dados
	input [31:0] in_b, //Segunda entrada de dados
	input [31:0] in_c, //Terceira entrada de dados
	input [1:0] sel,  //Entrada do seletor

	output [31:0] out //Saida do multiplexador
	
);

assign out = in_a & (~sel[1] & ~sel[0]) |
			 in_b & (~sel[1] & sel[0]) |
			 in_c & ( sel[1] & ~sel[0]);

			 //Selecao de dados na ordem 00, 01, 10

endmodule