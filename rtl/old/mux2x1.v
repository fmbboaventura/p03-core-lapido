/***************************************************
 * Module: mux2x1
 * Project: core_lapido
 * Author: Afonso Machado
 * Description: Multiplexador de duas entradas e uma
 * saida, com seletores 0 e 1.
 ***************************************************/

module mux2x1 (
	input [31:0] in_a, //Primeira entrada de dados
	input [31:0] in_b, //Segunda entrada de dados
	input sel,  //Entrada do seletor

	output [31:0] out //Saida do multiplexador
	
);

assign out = sel ? in_a : in_b; //Selecao

endmodule