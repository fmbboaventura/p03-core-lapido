/***************************************************
 * Module: lapido_top_tb
 * Project:
 * Author:
 * Description:
 ***************************************************/
module lapido_top_tb ();

    // Entradas
    reg clk;
    reg rst;

    lapido_top dut(.clk(clk), .rst(rst));

    initial begin
        clk = 0;
        rst = 0;
        #10;
        set_up;
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

        rst = 0;
    end
    endtask

endmodule // lapido_top_tb
