`timescale 1ns / 1ps

module registers_bank_tb;

	reg clk,
	reg rst,
	reg en,
	reg [4:0] rd,
	reg [31:0] data,
	reg [4:0] rs,
	reg [4:0] rt,

	wire [31:0] data_rs,
	wire [31:0] data_rt,

	registers_bank uut (
		.clk(clk),
		.rst(rst),
		.en(en),
		.rd(rd),
		.data(data),
		.rs(rs),
		.rt(rt),
		.data_rs(data_rs),
		.data_rt(data_rt)

	);

	parameter PCLK = 10;
	always #(PCLK / 2)
		clk =~ clk;
	integer i;
	reg [31:0] rand;

	initial begin 

		clk = 0;
		rst = 0;
		en = 0;
		rd = 0;
		data = 0;
		rs = 0;
		rt = 0;

		#100;

		#(PCLK/2)
		#1
		#(PCLK*1) rst = 1;
		#(PCLK*1) rst = 0;

	end

endmodule