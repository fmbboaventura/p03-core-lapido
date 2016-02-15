module mux3x1 (
	input [31:0] in_a,    
	input [31:0] in_b, 
	input [31:0] in_c,
	input [1:0] sel,  

	output [31:0] out
	
);

assign out = in_a & (~sel[1] & ~sel[0]) |
			 in_b & (~sel[1] & sel[0]) |
			 in_c & ( sel[1] & ~sel[0]);

endmodule