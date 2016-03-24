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

    // Do estagio MEM
    input [`PC_WIDTH - 1:0] branch_addr,
    input branch_taken,

    // Do estagio ID
    input [`PC_WIDTH - 1:0] jump_addr,
    input is_jump,

    // Do hazard_detection_unit
    input stall_pipeline,

    // Para o estagio ID
    output reg [`INSTRUCTION_WIDTH-1:0] instruction,
    output reg [`PC_WIDTH - 1:0] pc
);

wire [`INSTRUCTION_WIDTH-1:0] imem_instruction;

instruction_mem imem(
    .rst(rst),
    .addr(pc),
    .instruction(imem_instruction)
);

always @ (posedge clk or posedge rst) begin
    if (rst) begin
       pc <= `PC_WIDTH'b0;
    end else begin
        if(!stall_pipeline) begin
            if(is_jump) begin pc <= jump_addr; end
            else if (branch_taken) begin pc <= branch_addr; end
            else begin pc <= pc + `PC_WIDTH'b1; end
        end
    end
end

always @ (posedge clk) begin
    if (branch_taken || is_jump) instruction <= `NOP_INSTRUCTION;
    else instruction <= imem_instruction;
end

endmodule
