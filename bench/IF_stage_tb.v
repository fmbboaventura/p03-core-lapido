/***************************************************
 * Module: IF_stage_tb
 * Project: core_lapido
 * Author: Filipe Boaventura
 * Description: Test bench para o modulo de busca de
 * instrucao.
 ***************************************************/
 `include "lapido_defs.v"

module IF_stage_tb ();
    reg clk;
    reg rst;
    reg [`PC_WIDTH - 1:0] branch_addr;
    reg branch_taken;
    reg [`PC_WIDTH - 1:0] jump_addr;
    reg is_jump;

    wire [31:0] instruction;
    wire [`PC_WIDTH - 1:0] next_pc;

    IF_stage dut
    (
        .clk(clk),
        .rst(rst),
        .branch_addr(branch_addr),
        .jump_addr(jump_addr),
        .is_branch(is_branch),
        .instruction(instruction),
        .next_pc(next_pc)
    );

    initial begin
        $monitor("clk: %b rst: %b pc: %d next_pc: %d instruction: %X branch_addr: %d jump_addr: %d is_branch: %b",
        clk, rst, dut.pc, next_pc, instruction, branch_addr, jump_addr, is_branch);

        clk = 0;
        rst = 0;
        branch_taken = 0;
        is_jump = 0;
        branch_addr = 0;
        jump_addr = 0;
        #10;
    end

    // Gerador de clock
    always begin
        #5  clk =  ! clk;
    end
endmodule // IF_stage_tb
