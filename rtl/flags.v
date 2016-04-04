module flags (
	input clk,
	input rst,  // Asynchronous reset active low
	input branch_taken,
	input [32:0] alu_res,
	input [4:0] alu_flags,
	input fl_write_enable,

	output reg [5:0] out_flags 
	
);

// Escrevendo no registrador de flags
always @ (posedge clk or posedge rst) begin
	if (rst || branch_taken) begin
		out_flags <= 6'b0;
	end else begin
		if (fl_write_enable) begin
			out_flags[5] <= alu_res[32];
			out_flags[4:0] <= alu_flags[4:0];
		end
	end
end

endmodule