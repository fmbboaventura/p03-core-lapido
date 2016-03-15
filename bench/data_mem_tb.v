/***************************************************
 * Module: data_mem_tb
 * Project: core_lapido
 * Author: Filipe Boaventura
 * Description: Teste da memoria de dados. Este teste
 * espera que o dado carregado na memoria seja o seg-
 * mento de dados do programa de testes buscabinaria.asm.
 * Execute o script de montagem do buscabinaria.asm antes
 * de iniciar este test bench.
 ***************************************************/
 `include "lapido_defs.v"

module data_mem_tb ();

    //Entradas
    reg clk;
	reg rst;
	reg [`DATA_MEM_ADDR_WIDTH-1:0] addr;
	reg [31:0] write_data;
	reg write_en;

    // Saida
	wire [31:0] read_data;

    reg [31:0] expected_mem_values [9:0];
    reg [31:0] temp_ram [`DATA_MEM_SIZE-1:0];
    reg [31:0] temp_read_data;
    integer ram_out;
    integer i;

    data_mem dut (
        .clk(clk),    // Clock
    	.rst(rst),
    	.addr(addr),
    	.write_data(write_data),
    	.write_en(write_en),
    	.read_data(read_data)
    );

    initial begin
        load_expected_mem_values;

        $monitor("Time: %t addr: %d write_data: %d write_en: %b read_data: %d clk: %b rst: %b",
                $time, addr, write_data, write_en, read_data, clk, rst);
        clk = 0;
        rst = 0;
        addr = 0;
        write_data = 0;
        write_en = 0;
        #10;
        test_rst;
        #5;
        test_rst;
        #5;
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

        copy_ram;
        rst = 1;
        #5;

        ram_out = $fopen("data/data_out.txt", "r");
		for (i = 0; i < `DATA_MEM_SIZE; i = i + 1) begin
            // Verificando se o conteudo do arquivo eh igual a memoria antes do reset
			$fscanf(ram_out,"%08H\n", temp_read_data);
            if (temp_read_data != temp_ram[i]) begin
                $display("ERRO! @ %t , Esperado (temp_ram[%d]): %d,  Obteve %d",
                $time, i, temp_ram[i], temp_read_data);
                $finish;
            end

            // Verificando se a memoria foi povoada com os dados do arquivo de entrada
            if(dut.ram[i] != expected_mem_values[i]) begin
                $display("ERRO! @ %t , Esperado (expected_mem_values[%d]): %d,  Obteve %d",
                $time, i, expected_mem_values[i], dut.ram[i]);
                $finish;
            end
		end
		$fclose(ram_out);
        $display("OK!");
    end
    endtask

    task load_expected_mem_values;
    begin
        expected_mem_values[0] = 32'h01;
        expected_mem_values[1] = 32'h03;
        expected_mem_values[2] = 32'h05;
        expected_mem_values[3] = 32'h06;
        expected_mem_values[4] = 32'h09;
        expected_mem_values[5] = 32'h0c;
        expected_mem_values[6] = 32'h0f;
        expected_mem_values[7] = 32'h14;
        expected_mem_values[8] = 32'h19;
        expected_mem_values[9] = 32'h1e;
    end
    endtask

    task copy_ram;
    begin
        for (i = 0; i < `DATA_MEM_SIZE; i = i + 1) begin
            temp_ram[i] = dut.ram[i];
        end
    end
    endtask
endmodule // data_mem_tb
