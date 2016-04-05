/***************************************************
 * Module: bru
 * Project: core_lapido
 * Author: Filipe Boaventura
 * Description: Branch Resolution Unit. Modulo res-
 * ponsavel por analizar o eestado das flags e deci-
 * o resultado das instrucoes jt, jf, beq e bne
 ***************************************************/
`include "lapido_defs.v"

module bru (
    input [4:0] flag_code,  // Codigo da flag a ser examinada
    input [5:0] flags_in,   // Entrada das flags da alu
    input sel_jt_jf,        // Sinal de controle. Seleciona entre jt e jf
    input sel_beq_bne,      // Sinal de controle. Seleciona entre beq e bne
    input sel_jflag_branch, // Seletor do tipo do branch
    input is_branch,        // Habilita a avaliacao do branch
    output branch_taken);   // Resultado do branch

    wire jt_jf_ok;
    wire beq_bne_ok;
    wire [2:0] flag_code_safe;

    // Examina se o codigo da flag esta dentro do limite de 5
    assign flag_code_safe = (flag_code > 5'h5) ? 5'h5 : flag_code[2:0];
    
    assign jt_jf_ok = (sel_jt_jf) ? flags_in[flag_code_safe] : !flags_in[flag_code_safe];

    assign beq_bne_ok = (sel_beq_bne)? flags_in[`FL_TRUE] : flags_in[`FL_ZERO];

    assign branch_taken = (sel_jflag_branch)? beq_bne_ok & is_branch : jt_jf_ok & is_branch;

endmodule // bru
