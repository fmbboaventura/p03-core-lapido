/***************************************************
 * Module: fmu
 * Project: core_lapido
 * Author: Filipe Boaventura
 * Description: Flag Management Unit. Módulo
 * responsável por armazenar as flags e decidir
 * o resultado das instrucoes jt e jr.
 ***************************************************/
`include "lapido_defs.v"

module fmu
(
    input clk,
    input [4:0] flag_code, // Codigo da flag a ser examinada
    input [5:0] flags_in,  // Entrada das flags da alu
    input write_enable,    // Sinal de controle. Autoriza a escrita das flags
    input sel_jt_jf,       // Sinal de controle. Seleciona entr jt e jf

    output jt_jf_ok        // Saida: condição de branch verdadeira ou falsa
);

reg [`FLAG_REG_WIDTH-1:0] flags;

// true == jt
// false == jf
assign jt_jf_ok = (sel_jt_jf) ? flags[flag_code] : !flags[flag_code];

always @ (posedge clk) begin
    if (write_enable) begin
        flags[5:0] <= flags_in;
    end
end

endmodule // fmu
