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
            $display("Instrucao no ID: %H", dut.id_stage.instruction_reg);
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

endmodule // lapido_top_tb
