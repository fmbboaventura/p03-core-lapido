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
    test_rst; // Testa se o rst poe o contador no zero
    test_pc_write_false; // O pc write so pode ser 1 quando o contador eh 4
    test_if_enable_true; // O if enable tem que ser 1 quando o contador ta no zero

    old_count = dut.counter; // Nesse ponto, o contador deve ser 0
    #9; // espera um ciclo de clock. O contador passa a ser 1
    repeat(3) begin
        test_count; // testa se o valor atual do contador eh == valor antigo + 1
        test_pc_write_false; // deve ser falso pra qualquer valor != de 4
        test_if_enable_false; // deve ser falso pra qualquer valor != de 0
        old_count = dut.counter; // atualiza o valor antigo
        #10; // espera um ciclo para atualizar o contador
    end
    test_count; // nesse ponto, o contador deve ser 4 e o valor antigo 3
    test_pc_write_true; // testa se o pc write foi acertado
    test_if_enable_false; // deve ser falso pra qualquer valor != de 0
    old_count = -1;
    #10; // espera mais um ciclo de clock. O valor do contador deve ir para 0
    test_count; // testa se o contador == -1 +1
    test_pc_write_false;
    test_if_enable_true; // testa se o fetch foi habilitado
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
