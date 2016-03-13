/***************************************************
 * Module: IF_stage_tb
 * Project: core_lapido
 * Author: Filipe Boaventura
 * Description: Test bench para o modulo de busca de
 * instrucao.
 ***************************************************/
 `include "lapido_defs.v"

module IF_stage_tb ();

    // Entradas
    reg clk;
    reg rst;
    reg [`PC_WIDTH - 1:0] branch_addr;
    reg branch_taken;
    reg [`PC_WIDTH - 1:0] jump_addr;
    reg is_jump;

    // Saidas
    wire [31:0] instruction;
    wire [`PC_WIDTH - 1:0] next_pc;

    reg [31:0] expected_mem_values [7:0];
    integer i;
    integer fetched_instruction;
    integer expected_pc;

    IF_stage dut
    (
        .clk(clk),
        .rst(rst),
        .branch_addr(branch_addr),
        .branch_taken(branch_taken),
        .jump_addr(jump_addr),
        .is_jump(is_jump),
        .instruction(instruction),
        .next_pc(next_pc)
    );

    initial begin
        load_expected_mem_values;

        $monitor("Time: %t clk: %b rst: %b pc: %d next_pc: %d instruction: %H branch_addr: %d branch_taken: %b jump_addr: %d is_jump: %b",
        $time, clk, rst, dut.pc, next_pc, instruction, branch_addr, branch_taken, jump_addr, is_jump);

        clk = 0;
        rst = 0;
        branch_taken = 0;
        is_jump = 0;
        branch_addr = 0;
        jump_addr = 0;
        #10;
        set_up;

        // Testa a execucao das instrucoes na ordem em que estao na memoria (sem saltos ou branchs)
        for (i = 0; i < 8; i = i + 1) begin
            expected_pc = i;
            fetched_instruction = instruction;
            repeat (5) begin
                test_instruction_fetch;
                #10;
            end
        end

        for (i = 7; i >= 0; i = i - 1) begin
            branch_taken = 0;
            branch_addr = i; // O IF_stage ja recebe o branch calculado
            expected_pc = branch_addr;
            #10; // Espera um ciclo.
            branch_taken = 1;
            repeat (4) begin // na terceira iteracao, o contador esta no 4 e habilita o write_pc
                test_instruction_fetch; // Devem ser nops nas 3 primeiras iteracoes
                #10;
            end
        end

        branch_taken = 0;
        //$stop;

        for (i = 7; i >= 0; i = i - 1) begin
            is_jump = 0;
            jump_addr = i;
            expected_pc = jump_addr;
            #10; // Espera um ciclo.
            is_jump = 1;
            repeat (4) begin // na terceira iteracao, o contador esta no 4 e habilita o write_pc
                test_instruction_fetch; // Devem ser nops nas 3 primeiras iteracoes
                #10;
            end
        end
        is_jump = 0;
        $stop;
    end

    // Gerador de clock
    always begin
        #5  clk =  ! clk;
    end

    task set_up;
    begin
        $display("------------------------------");
        $display("set_up:");
        $display("------------------------------");
        rst = 1;
        #10; // Para povoar a memoria, o read_file tem que estar ativo quando o clock for de 0 para 1
        for (i = 0; i < 8; i = i + 1) begin
            if (dut.imem.ram_mem[i] == expected_mem_values[i]) $display("OK!");
            else begin
                $display("ERRO! @ %t , Esperado (imem[%d]): %h,  Obteve %h",
                $time, i, expected_mem_values[i], dut.imem.ram_mem[i]);
                $stop;
            end
        end

        rst = 0;
    end
    endtask

    task test_instruction_fetch;
    begin
        $display("------------------------------");
        $display("test_instruction_fetch:");
        $display("------------------------------");
        if(dut.counter.if_enable) begin
            if(instruction == expected_mem_values[expected_pc]) $display("OK!");
            else begin
                $display("ERRO! @ %t , Esperado (expected_mem_values[%d]): %h,  Obteve %h",
                $time, expected_pc, expected_mem_values[expected_pc], instruction);
                $stop;
            end
        end else begin
            if(instruction == `NOP_INSTRUCTION) $display("OK!");
            else begin
                $display("ERRO! @ %t , Esperado (NOP): %h,  Obteve %h",
                $time, `NOP_INSTRUCTION, instruction);
                $stop;
            end
        end
    end
    endtask

    task load_expected_mem_values;
    begin
        expected_mem_values[0] = 32'h400a4801;
        expected_mem_values[1] = 32'h50016bff;
        expected_mem_values[2] = 32'h70060000;
        expected_mem_values[3] = 32'ha0118d50;
        expected_mem_values[4] = 32'h95608180;
        expected_mem_values[5] = 32'h15030000;
        expected_mem_values[6] = 32'h30060000;
        expected_mem_values[7] = 32'h82ec2fff;
    end
    endtask

endmodule // IF_stage_tb
