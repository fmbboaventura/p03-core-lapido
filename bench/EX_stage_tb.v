/***************************************************
 * Module: IF_stage_tb
 * Project: core_lapido
 * Author: Afonso Machado
 * Description: Test bench para o modulo de execução de
 * instrucao.
 ***************************************************/
 `include "lapido_defs.v"

module EX_stage_tb ();
	reg clk;
    reg rst;

    // Controle para o EX
    reg alu_src_mux;
    reg [5:0] alu_funct;
    reg [1:0] reg_dst_mux;
    reg sel_j_jr;

    // Dados para o EX
    reg [`PC_WIDTH - 1:0] in_next_pc;
    reg [31:0] in_immediate;
    reg [31:0] in_data_rs;
    reg [31:0] in_data_rt;
    reg [4:0] in_rs;
    reg [4:0] in_rt;
    reg [4:0] in_rd;

    // Sinais para propagar
    reg in_mem_write_enable;
    reg in_sel_beq_bne;
    reg in_fl_write_enable;
    reg in_sel_jt_jf;
    reg in_is_branch;
    reg in_is_jump;
    reg [1:0] in_wb_res_mux;
    reg in_reg_write_enable;

    wire out_mem_write_enable;
    wire out_sel_beq_bne;
    wire out_fl_write_enable;
    wire out_sel_jt_jf;
    wire out_is_branch;
    wire out_is_jump;
    wire [1:0] out_wb_res_mux;
    wire out_reg_write_enable;

    // Dados para propagar
    wire [`PC_WIDTH - 1:0] out_next_pc;
    wire [31:0] out_immediate;
    wire [31:0] abs_addr;
    wire [31:0] mem_addr;
    wire [31:0] mem_data;
    wire [31:0] alu_out;
    wire [5:0] alu_flags_out;
    wire [4:0] flag_addr;
    wire [4:0] reg_dst;

    EX_stage dut(
    	.clk(clk),
	    .rst(rst),

	    // Controle para o EX
	    .alu_src_mux(alu_src_mux),
	    .alu_funct(alu_funct),
	    .reg_dst_mux(reg_dst_mux),
	    .sel_j_jr(sel_j_jr),

	    // Dados para o EX
	    .in_next_pc(in_next_pc),
	    .in_immediate(in_immediate),
	    .in_data_rs(in_data_rs),
	    .in_data_rt(in_data_rt),
	    .in_rs(in_rs),
	    .in_rt(in_rt),
	    .in_rd(in_rd),

	    // Sinais para propagar
	    .in_mem_write_enable(in_mem_write_enable),
	    .in_sel_beq_bne(in_sel_beq_bne),
	    .in_fl_write_enable(in_fl_write_enable),
	    .in_sel_jt_jf(in_sel_jt_jf),
	    .in_is_branch(in_is_branch),
	    .in_is_jump(in_is_jump),
	    .in_wb_res_mux(in_wb_res_mux),
	    .in_reg_write_enable(in_wb_res_mux),

	    .out_mem_write_enable(out_mem_write_enable),
	    .out_sel_beq_bne(out_sel_beq_bne),
	    .out_fl_write_enable(out_fl_write_enable),
	    .out_sel_jt_jf(out_sel_jt_jf),
	    .out_is_branch(out_is_branch),
	    .out_is_jump(out_is_jump),
	    .out_wb_res_mux(out_wb_res_mux),
	    .out_reg_write_enable(out_reg_write_enable),

	    // Dados para propagar
	    .out_next_pc(out_next_pc),
	    .out_immediate(out_immediate),
	    .abs_addr(abs_addr),
	    .mem_addr(mem_addr),
	    .mem_data(mem_data),
	    .alu_out(alu_out),
	    .alu_flags_out(alu_flags_out),
	    .flag_addr(flag_addr),
	    .reg_dst(reg_dst)
    	);

    initial begin
        clk = 0;
        rst = 0;
        alu_src_mux = 0;
        alu_funct = 0;
        reg_dst_mux = 0;
        sel_j_jr = 0;

        // Dados para o EX
        in_next_pc = 0;
        in_immediate = 0;
        in_data_rs = 0;
        in_data_rt = 0;
        in_rs = 0;
        in_rt = 0;
        in_rd = 0;

        // Sinais para propagar
        in_mem_write_enable = 0;
        in_sel_beq_bne = 0;
        in_fl_write_enable = 0;
        in_sel_jt_jf = 0;
        in_is_branch = 0;
        in_is_jump = 0;
        in_wb_res_mux = 0;
        in_reg_write_enable = 0;

    end

    task alu_in;
        begin
            alu_src_mux = 1'b1;
            in_data_rt = $random;
            in_data_rs = $random;
            in_immediate = $random;
            alu_funct = `FN_ADD;


        end

    endtask

endmodule