module add (
	input [31:0] a,
	input [31:0] b,
	
	output [32:0] soma
	
);

assign soma = a + b;

endmodule