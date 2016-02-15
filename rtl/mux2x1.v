module mux2x1 (
	input [31:0] in_a,    // Clock
	input [31:0] in_b, // Clock Enable
	input sel,  // Asynchronous reset active low

	output [31:0] out
	
);

assign out = sel ? in_b : in_b;

endmodule