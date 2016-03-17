/***************************************************
 * Module: fowarding_unit
 * Project: core_lapido
 * Author: Filipe Boaventura
 * Description: Modulo responsavel por fazer o
 * adiantamento de dados para evitar data hazards.
 ***************************************************/
`include "lapido_defs.v"

module fowarding_unit
(
    input [4:0] ID_EX_rs,
    input [4:0] ID_EX_rt,
    input EX_MEM_reg_write_enable,
    input [4:0] EX_MEM_rd,
    input MEM_WB_reg_write_enable,
    input [4:0] MEM_WB_rd,
    output reg [1:0] fowardA,
    output reg [1:0] fowardB
);

always @ ( * ) begin
    if (EX_MEM_reg_write_enable &&
            EX_MEM_rd == ID_EX_rs) begin
        fowardA = `FOWARD_EX;
    end else if (MEM_WB_reg_write_enable &&
            MEM_WB_rd == ID_EX_rs &&
            EX_MEM_rd != ID_EX_rs) begin
        fowardA = `FOWARD_MEM;
    end else begin fowardA = `NO_FOWARD; end

    if (EX_MEM_reg_write_enable &&
            EX_MEM_rd == ID_EX_rt) begin
        fowardB = `FOWARD_EX;
    end else if (MEM_WB_reg_write_enable &&
            MEM_WB_rd == ID_EX_rt &&
            EX_MEM_rd != ID_EX_rt) begin
        fowardB = `FOWARD_MEM;
    end else begin fowardB = `NO_FOWARD; end
end

endmodule // fowarding_unit
