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
    reg cont_en;

    initial begin
        clk = 0;
        rst = 0;
        cont = 0;
        cont_en = 0;
        set_up;
    end

    // Gerador de clock
    always begin
        #5  clk =  ! clk;
    end

    always @ (posedge clk) begin
        if (!cont_en)
            $display("Instrucao no ID: %H tempo: %t",
                dut.id_stage.instruction_reg, $time);
    end

    always @ (posedge clk) begin
        if (cont_en) begin
            cont = cont + 1;
        end else begin
            check_halt;
        end
    end

    always @ (posedge clk) begin
        if(cont == 3) begin
            $display("Parado. Tempo: %t", $time);
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
            cont_en = 1;
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
        if (dut.MEM_branch_taken) begin
            $display("Desvio para o endereco: %d", dut.MEM_branch_addr);
        end
    end
    endtask

endmodule // lapido_top_tb
