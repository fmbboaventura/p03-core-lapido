module flags (
	input clk,
	input rst,  // Asynchronous reset active low
	input branch_taken,
	input [5:0] in_flags,
	input fl_write_enable,
	output reg [5:0] out_flags
);

// Escrevendo no registrador de flags
always @ (posedge clk or posedge rst) begin
	if (rst || branch_taken) begin
		out_flags <= 6'b0;
	end else begin
		if (fl_write_enable) begin
			out_flags <= in_flags;
		end
	end
end

endmodule
