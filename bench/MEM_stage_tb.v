/***************************************************
 * Module: MEM_stage_tb
 * Project: core_lapido
 * Author: Afonso Machado
 * Description: Test bench 
 ***************************************************/
 `include "lapido_defs.v"

module MEM_stage_tb ();

	reg clk;    // Clock
	reg rst;  
	
	//Sinal para o estágio wb
	reg wb_res_mux;

	//Entradas de sinais do registrador EX/MEM para o MEM
	reg is_branch;
	reg sel_jflag_branch;
	reg sel_beq_bne;
	reg sel_jt_jf;
	reg mem_write;

	//Entrada de dados
	reg [4:0] flag_code;
	reg [`PC_WIDTH - 1:0] in_next_pc;
	reg [`PC_WIDTH - 1:0] branch_addr;
	reg [5:0] flags;
	reg [31:0] alu_res;
	reg [31:0] in_mem_addr;//saida rs_data do banco de registradores
	reg [31:0] in_mem_data;//saida rt_data do banco de registradores
	reg [4:0] in_reg_dst;//registrador onde vai ser escrito os dados da operação do tio R
	reg [31:0] in_immediate;//

	//saídas do estágio MEM
	wire [1:0] out_wb_res_mux;
	wire [1:0] out_branch_taken; 
	wire [`PC_WIDTH - 1:0] out_next_pc;
	wire [31:0] out_mem_data;//
	wire [31:0] out_alu_res;//
    wire [4:0]  out_reg_dst;//
    wire [31:0] out_im;// 

    reg [4:0] flags_array [5:0];

    bru dut_bru
    (
    	.is_branch(is_branch),
    	.sel_jflag_branch(sel_jflag_branch),
    	.sel_beq_bne(sel_beq_bne),
    	.sel_jt_jf(sel_jt_jf),
    	.flags_in(flags),
    	.flag_code(flag_code),

    	.branch_taken(branch_taken)
    ); 

    data_mem dut_data_memory
	(
		.clk(clk),
		.rst(rst),
		.addr(in_mem_addr),
		.write_data(in_mem_data),
		.write_en(mem_write),

		.read_data(wire_out_mem_data)
	);

	initial begin

		$monitor("Time: %t clk: %b rst: %b ",
        $time, clk, rst);

        clk = 0;
        rst = 0;


	end

	integer i;

	task branch_resolution_unit;
		begin
			for (i=0; i < 6; i=i+1) begin
				flag_code = flags_array[i];
				is_branch = 0;
				#1

				$display("Testando is_branch 0");
				if(branch_taken == 0)
					$display("OK!");
				else $display("ERRO! @ %t, Esperado %d, Obtido %d",
					$time, 0, branch_taken);
			end

			for (i=0; i < 6; i=i+1) begin
				flag_code = flags_array[i];
				is_branch = 1;
				#1

				$display("Testando JT");
			end

			for (i=0; i < 6; i=i+1) begin
				flag_code = flags_array[i];
				is_branch = 1;
				#1

				$display("Testando JF");
			end

			for (i=0; i < 6; i=i+1) begin
				flag_code = flags_array[i];
				is_branch = 1;
				#1

				$display("Testando beq");
			end

			for (i=0; i < 6; i=i+1) begin
				flag_code = flags_array[i];
				is_branch = 1;
				#1

				$display("Testando bne");
			end


		end

	
	endtask

	task load_flags_array;
		begin
			flags_array[0] = `FL_ZERO;
			flags_array[1] = `FL_TRUE;
			flags_array[2] = `FL_NEG;
			flags_array[3] = `FL_OVERFLOW;
			flags_array[4] = `FL_NEGZERO;
			flags_array[5] = `FL_CARRY;
		end

	
	endtask



endmodule