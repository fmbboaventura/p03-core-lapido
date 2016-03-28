/***************************************************
 * Module: tb_util
 * Project: core_lapido
 * Author: Filipe Boaventura
 * Description: Modulo com tasks para auxiliar na
 * implementacao de testes.
 ***************************************************/
module tb_util ();

    task assert_equals;
        input [31:0] expected;
        input [31:0] actual;
        begin
            if (actual === expected) $display("OK!");
            else begin
                $display("ERRO! @ %t , Esperado: %d,  Obteve %d",
                $time, expected, actual);
                $stop;
            end
        end
    endtask

    // Gera numeros aleatorios de 32 bit entre 0 e max
    task rand_zero_max;
        input [31:0] max;
        output [31:0] result;
        begin
            result = $unsigned($random) % max;
        end
    endtask
endmodule // tb_util
