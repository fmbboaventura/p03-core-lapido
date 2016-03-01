/***************************************************
 * Module: clk_counter_tb
 * Project: core_lapido
 * Author: Filipe Boaventura
 * Description: Test Bench criado para o modulo
 * fmu.
 ***************************************************/
module clk_counter_tb ();

// Entradas
reg clk;
reg rst;

// Saidas
wire if_enable;
wire pc_write;

integer old_count;

// Instanciando o Design Under Test (DUT)
clk_counter dut
(
    .clk(clk),
    .rst(rst),
    .if_enable(if_enable),
    .pc_write(pc_write)
);

initial begin
    $monitor("clk: %b rst: %b pc_write: %b if_enable: %b count: %d Time: %t",
    clk, rst, pc_write, if_enable, dut.counter, $time);

    clk = 0;
    rst = 0;
    #10;
    test_rst;
    test_pc_write_false;
    test_if_enable_true;

    old_count = dut.counter;
    #9; // espera um ciclo de clock
    repeat(3) begin
        test_count;
        test_pc_write_false;
        test_if_enable_false;
        old_count = dut.counter;
        #10;
    end
    test_count;
    test_pc_write_true;
    test_if_enable_false;
    old_count = -1;
    #10;
    test_count;
    test_pc_write_false;
    test_if_enable_true;
    $stop;
end

// Gerador de clock
always begin
    #5  clk =  ! clk;
end

task test_rst;
begin
    $display("------------------------------");
    $display("test_rst:");
    $display("------------------------------");
    rst = 1;
    #1; // Espera uma unidade de tempo para fazer o teste e zerar o rst
    if (dut.counter == 0) $display("OK!");
    else $display("ERRO! @ %t , Esperado (counter): %d,  Obteve %d",
    $time, 4, dut.counter);
    rst = 0;
end
endtask

task test_pc_write_false;
begin
    $display("------------------------------");
    $display("test_pc_write_false:");
    $display("------------------------------");
    if (pc_write == 0) $display("OK!");
    else $display("ERRO! @ %t , Esperado (pc_write): %b,  Obteve %b",
    $time, 0, pc_write);
end
endtask

task test_pc_write_true;
begin
    $display("------------------------------");
    $display("test_pc_write_true:");
    $display("------------------------------");
    if (pc_write == 1) $display("OK!");
    else $display("ERRO! @ %t , Esperado (pc_write): %b,  Obteve %b",
    $time, 1, pc_write);
end
endtask

task test_if_enable_true;
begin
    $display("------------------------------");
    $display("test_if_enable_true:");
    $display("------------------------------");
    if (if_enable == 1) $display("OK!");
    else $display("ERRO! @ %t , Esperado (if_enable): %b,  Obteve %b",
    $time, 1, if_enable);
end
endtask

task test_if_enable_false;
begin
    $display("------------------------------");
    $display("test_if_enable_false:");
    $display("------------------------------");
    if (if_enable == 0) $display("OK!");
    else $display("ERRO! @ %t , Esperado (if_enable): %b,  Obteve %b",
    $time, 0, if_enable);
end
endtask

task test_count;
begin
    $display("------------------------------");
    $display("test_count:");
    $display("------------------------------");
    if (dut.counter == (old_count + 1)) $display("OK!");
    else begin
        $display("ERRO! @ %t , Esperado (dut.count): %d,  Obteve %d",
        $time, old_count + 1, dut.counter);
        $stop;
    end
end
endtask

endmodule // clk_counter_tb
