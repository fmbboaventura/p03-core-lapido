module mux3x1;

	reg [31:0] in_a;
	reg [31:0] in_b;
	reg [31:0] in_c;
	reg sel;

	wire [31:0] out;

	integer i;
	integer j;
	integer k;

	mux2x1 uut (
		.in_a(in_a),
		.in_b(in_b),
		.in_c(in_c),
		.sel(sel),
		.out(out)
		);

	initial begin 
		k = $random % 400;
		j=15;
		#1 $monitor("a = %b", in_a, "  |  b = %b", in_b, "  |  c = %b", in_c,"  |  select = ", sel, "  |  out = ", out );
		for (i = 0; i <= 15; i = i + 1) begin
			in_a = i;
			in_b = j;

			sel = 0; #1
			sel = 1; #1
			sel = 3; #1

			j = j - 1;

			$display("-----------------------------------------");
		end

	end

endmodule