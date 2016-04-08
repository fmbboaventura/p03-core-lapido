/***************************************************
 * Module: mux4x1
 * Project: core_lapido
 * Author: Filipe Boaventura
 * Description: Multiplexador de quatro entradas e uma
 * saida, com seletor em 00, 01, 10, 11.
 ***************************************************/

module mux4x1 (
	input [31:0] in_a, //Primeira entrada de dados
	input [31:0] in_b, //Segunda entrada de dados
	input [31:0] in_c, //Terceira entrada de dados
    input [31:0] in_d, //Quarta entrada de dados
	input [1:0] sel,  //Entrada do seletor

	output [31:0] out //Saida do multiplexador

);

assign out = in_a & (~sel[1] & ~sel[0]) |
			 in_b & (~sel[1] & sel[0]) |
			 in_c & ( sel[1] & ~sel[0]) |
             in_d & ( sel[1] & sel[0]);

			 //Selecao de dados na ordem 00, 01, 10, 11

endmodule
