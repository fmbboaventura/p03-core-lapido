module program_counter (
	input clk,    // Clock
	input [31:0] pc_in,

	output [31:0] pc_out
	
);

always @ (clk, pc_in, pc_out) begin 
	case (clk)
		1'b0 : pc_in = pc_out;
		1'b1 : pc_out = pc_in;

	endcase
end

endmodule