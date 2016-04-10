/******************************************************
 * Module: lapido_top_tb
 * Project: core_lapido
 * Author: Filipe Boaventura
 * Description: Modulo para facilitar na execucao de
 * programas de teste no processador LAPI DOpaCA LAMBA.
 * os arquivos de saida do assembler devem ser colocados
 * no diretorio rtl/data, com os nomes data_in.txt para
 * o segmento de dados, e inst_in.txt, para o segmento
 * de instrucoes.
 ******************************************************/
 `include "lapido_defs.v"
 `include "tb_util.v"
module lapido_top_tb ();

    // Entradas
    reg clk;
    reg rst;

    lapido_top dut(.clk(clk), .rst(rst));
    tb_util util();

    integer cont;
    integer inst_cont;
    integer clk_cont;
    integer bubbles;
    reg halt_found;

    initial begin
        clk = 0;
        rst = 0;
        cont = 0;
        inst_cont = 0;
        clk_cont = 0;
        bubbles = 0;
        halt_found = 0;
        set_up;
    end

    // Gerador de clock
    always begin
        #5  clk =  ! clk;
    end

    always @ (posedge clk) begin
        if(!halt_found) begin
            clk_cont = clk_cont + 1;
            inst_cont = inst_cont + 1;
            if(dut.ID_is_jump) begin
                bubbles = bubbles + 1;
            end else if (dut.EX_branch_taken) begin
                bubbles = bubbles + 3;
            end else if (dut.HDU_stall_pipeline) begin
                bubbles = bubbles + 2;
            end
        end
    end

    always @ (posedge clk) begin
        if(!halt_found) begin
            if(dut.ID_is_jump) begin
                inst_cont = inst_cont - 1;
            end else if (dut.EX_branch_taken) begin
                inst_cont = inst_cont - 3;
            end else if (dut.HDU_stall_pipeline) begin
                inst_cont = inst_cont - 2;
            end
        end
    end

    always @ (posedge clk) begin
        if (!halt_found)
            $display("Instrucao no ID: %H tempo: %t",
                dut.id_stage.instruction_reg, $time);
    end

    always @ (posedge clk) begin
        if (halt_found) begin
            cont = cont + 1;
        end else begin
            check_halt;
        end
    end

    always @ (posedge clk) begin
        if(cont == 3) begin
            $display("Parado. Tempo: %t", $time);
            $display("CPI: %d", (clk_cont/(inst_cont-bubbles)));
            $stop;
        end
    end

    always @ (posedge clk) begin
        display_branch_jump_target;
        check_branch_jump_out_of_bounds;
    end

    task set_up;
    begin
        $display("------------------------------");
        $display("set_up:");
        $display("------------------------------");
        rst = 1;
        #10;
        rst = 0;
    end
    endtask

    task check_halt;
    begin
         if((dut.ID_jump_addr == dut.IF_pc-1) && dut.ID_is_jump) begin
            $display("Halt encontrado. Parando...");
            $display("Tempo: %t", $time);
            halt_found = 1;
        end
    end
    endtask

    task check_branch_jump_out_of_bounds;
    begin
        if(^dut.id_stage.instruction_reg === 1'bx) begin
            $display("ERRO! %t Salto/branch para endereco invalido!", $time);
            $stop;
        end
    end
    endtask

    task display_branch_jump_target;
    begin
        if(dut.ID_is_jump) begin
            $display("Salto para o endereco: %d", dut.ID_jump_addr);
        end
        if (dut.EX_branch_taken) begin
            $display("Desvio para o endereco: %d", dut.EX_branch_addr);
        end
    end
    endtask

endmodule // lapido_top_tb
