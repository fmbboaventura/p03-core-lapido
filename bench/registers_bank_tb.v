

`timescale 1ns / 1ps

module registers_bank_tb;

	reg clk;
	reg rst;
	reg en;
	reg [4:0] rd;
	reg [31:0] data;
	reg [4:0] rs;
	reg [4:0] rt;

	wire [31:0] data_rs;
	wire [31:0] data_rt;

	register_file uut (
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

		#(PCLK*10);
		display_all_regs;
		write_all_regs;
		read_all_regs_from_rs;
		read_all_regs_from_rt;
		write_and_read_all_regs;
		$stop;
		$finish;
		


	end

	task display_all_regs;
		begin
			$display("display_all_regs");
			$display("----------------------");
			for (i = 0; i < 16; i = i + 1) begin
				$write("%d\t", uut.registers[i]);
			$display("----------------------");
			end
		end
	endtask

	task read_all_regs_from_rs;
		begin
			$display("read_all_regs_from_rs:");
			$display("------------------------------");
			i=0;
			while(i<16) begin
				rs = i;
				#(PCLK*1)
				$write("%d\t",rs);
				i=i+1;
			end
			$display("\n------------------------------");
		end
	endtask

	task read_all_regs_from_rt;
		begin
			$display("read_all_regs_from_read_port_2:");
			$display("------------------------------");
			i=0;
			while(i<16) begin
				rt = i;
				#(PCLK*1)
				$write("%d\t",rt);
				i=i+1;
			end
			$display("\n------------------------------");
		end
	endtask

	task write_all_regs;
		begin
			$display("write_all_regs(random):");
			$display("------------------------------");
			i=0;
			while(i<16) begin
				en=1;
				rd = i;
				data = $random % 2147483647;
				#(PCLK*1)
				$write("%d\t",uut.registers[i]);
				en=0;
				i=i+1;
			end
			$display("\n------------------------------");
		end
	endtask

	reg [15:0] read_tmp_1[7:0];
	reg [15:0] read_tmp_2[7:0];

	task write_and_read_all_regs;
		begin
			$display("write_and_read_all_regs(random):");
			$display("------------------------------");
			while(i<16) begin
				en=1;
				rd = i;
				data = $random % 2147483647;
				rs = i;
				rt = i-1;
				#(PCLK*0.5)
				read_tmp_1[i]=data_rs;
				if(data_rs > 0)
					read_tmp_2[i-1]=data_rt;
				#(PCLK*0.5)
				$write("%d\t",uut.registers[i]);
				en=0;
				i=i+1;
			end
			rt = i-1;
			#(PCLK*0.5)
			read_tmp_2[i-1]=data_rt;
			#(PCLK*0.5)
			$display("\n------------------------------");
			
			$display("read from rs (read regs being wrote will hold its value):");
			$display("------------------------------");
			i=0;
			while(i<16) begin
				$write("%d\t",read_tmp_1[i]);
				i=i+1;
			end
			$display("\n------------------------------");
			
			$display("read from rt (read wrote regs will get its new value):");
			$display("------------------------------");
			i=0;
			while(i<16) begin
				$write("%d\t",read_tmp_2[i]);
				i=i+1;
			end
			$display("\n------------------------------");
		end
	
	endtask

endmodule