module comparator (
	input [31:0] a,
	input [31:0] b,

	output c
);
 
assign c = (a==b);

endmodule