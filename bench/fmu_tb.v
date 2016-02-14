/***************************************************
 * Module: fmu_tb
 * Project: core_lapido
 * Author: Filipe Boaventura
 * Description: Test Bench criado para o modulo
 * fmu.
 ***************************************************/
module fmu_tb ();

    // Entradas
    reg clk;
    reg [4:0] flag_code;
    reg [5:0] flags_in;
    reg write_enable;
    reg sel_jt_jf;

    // Saidas
    wire jt_jf_ok;

    // Instanciando o Design Under Test (DUT)
    fmu dut (
        .clk(clk),
        .flag_code(flag_code),
        .flags_in(flags_in),
        .write_enable(write_enable),
        .sel_jt_jf(sel_jt_jf),
        .jt_jf_ok(jt_jf_ok)
    );

    // Inicializando os sinais de entrada
    initial begin
        clk = 0;
        flag_code = 0;
        flags_in = 0;
        write_enable = 0;
        sel_jt_jf = 0;

        test_jt_jf;
    end

    // Gerador de clock
    always begin
        #5  clk =  ! clk;
    end

    initial begin
        $display("\t\ttempo clk flag_code flags_in write_enable sel_jt_jf jt_jf_ok");
        $monitor("%d \t%b \t%b \t%b \t%b \t%b \t%b",
            $time, clk, flag_code, flags_in, write_enable, sel_jt_jf, jt_jf_ok);
    end

    task test_jt_jf;
    integer i;
    begin
        write_enable = 1;
        #5;
        repeat (2) begin
            repeat (2) begin
                for (i = 0; i < 6; i = i + 1) begin
                    flag_code = i;
                    #5;
                end
                flags_in = ~flags_in;//6'b111111;
                #5;
            end
            sel_jt_jf = ~sel_jt_jf;
        end
    end
    endtask

endmodule // fmu_tb
