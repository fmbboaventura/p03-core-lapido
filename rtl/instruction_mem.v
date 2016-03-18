/***************************************************
 * Module: instruction_mem
 * Project: core_lapido
 * Author: Filipe Boaventura
 * Description: Modulo de simulacao. Memoria somente
 * de leitura usada como memoria de instrucao. As ins-
 * trucoes sao carregadas do arquivo rtl/data/inst_in.txt.
 ***************************************************/
`include "lapido_defs.v"

module instruction_mem
(
    input rst,
    input [`PC_WIDTH-1:0] addr,

    output [`INSTRUCTION_WIDTH-1:0] instruction
);

reg [`INSTRUCTION_WIDTH-1:0] mem [`INST_MEM_SIZE-1:0];

integer inst_in;
integer data;
integer i;

always @ (posedge rst) begin
    inst_in = $fopen("data/inst_in.txt", "r");
    for (i = 0; i < `INST_MEM_SIZE; i = i + 1) begin
        $fscanf(inst_in,"%08H", data);
        if($feof(inst_in)) i = `INST_MEM_SIZE;
        else mem[i] = data;
    end
    $fclose(inst_in);
end

assign instruction = mem[addr];

endmodule // instruction_mem
