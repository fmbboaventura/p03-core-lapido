/***************************************************
 * Module: comparator
 * Project: core_lapido
 * Author: Gadiel Xavier
 * Description: Compara dois numeros de 32 bits e a 
saida eh um numero de 1 bit, sendo que 1 representa verdadeiro 
e 0 falso.
 ***************************************************/

module comparator (
	input [31:0] a,
	input [31:0] b,

	output c
);
 
assign c = (a==b);

endmodule