module mux2x1_tb;

	reg [31:0] in_a;
	reg [31:0] in_b;
	reg sel;

	wire [31:0] out;

	integer i;
	integer j;

	mux2x1 uut (
		.in_a(in_a),
		.in_b(in_b),
		.sel(sel),
		.out(out)
		);

	initial begin 
		j=15;
		#1 $monitor("a = %b", in_a, "  |  b = %b", in_b, "  |  select = ", sel, "  |  out = ", out );
		for (i = 0; i <= 15; i = i + 1) begin
			in_a = i;
			in_b = j;

			sel = 0; #1
			sel = 1; #1

			j = j - 1;

			$display("-----------------------------------------");
		end

	end

endmodule