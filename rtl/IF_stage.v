/***************************************************
 * Module: IF_stage
 * Project: core_lapido
 * Author: Filipe Boaventura
 * Description: Modulo que representa o estagio
 * Instruction Fetch do pipeline.
 ***************************************************/
 `include "lapido_defs.v"

module IF_stage (
    input clk,
    input rst,
    input [`PC_WIDTH - 1:0] branch_addr,
    input branch_taken,
    input [`PC_WIDTH - 1:0] jump_addr,
    input is_jump,

    output [31:0] instruction,
    output reg [`PC_WIDTH - 1:0] next_pc
);

wire pc_write;
wire if_enable;
reg [`PC_WIDTH - 1:0] pc;

wire [31:0] imem_out; // Saida da Memoria de Instrucao

clk_counter counter(
    .clk(clk),
    .rst(rst),
    .if_enable(if_enable),
    .pc_write(pc_write)
);

ram imem(
    .read_file(0),
    .write_file(0),
    .WE(0),    // write enalbe. Memoria de instrucao nao pode ser escrita
    .ADRESS(pc),
    .DATA(x),
    .Q(imem_out)
);

mux2x1 mux(
    .in_a(imem_out),
    .in_b(`NOP_INSTRUCTION),
    .sel(if_enable),
    .out(instruction)
);

always @ (posedge clk or rst) begin
    if (rst) begin
       pc <= `PC_WIDTH'b0;
    end else begin
        next_pc <= pc + 1;
        if(pc_write) begin
            if(is_jump) begin pc <= jump_addr; end
            else if (branch_taken) begin pc <= branch_addr; end
            else begin pc <= next_pc; end
        end
    end
end

endmodule // IF_stage
// clk_counter counter(
//     .clk(clk),
//     .rst(rst),
//     .pc_write(pc_write)
// );
//
// always @ (posedge clk or rst) begin
//     if (rst) begin
//        pc <= `PC_WIDTH'b0;
//     end else if (pc_write) begin
//         if (is_jump) begin pc <= jump_addr; end
//         else if (branch_taken) begin pc <= branch_addr; end
//         else begin pc <= pc + 1;
//     end
// end
