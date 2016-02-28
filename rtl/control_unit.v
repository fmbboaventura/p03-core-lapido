/***************************************************
 * Module: control_unit
 * Project: core_lapido
 * Author: Filipe Boaventura
 * Description: Unidade de Controle do processador
 * LAPI DOpaCA LAMBA. Gera sinais de controle para o
 * datapah de acordo com o opcode e o func fornecido.
 ***************************************************/

`include "lapido_defs.v"

module control_unit
(
    input [5:0] opcode,   // opcode da instrucao
    input [5:0] funct,    // funct do formato R

    // Sinais para o estagio EX
    output reg [5:0] alu_funct,  // Seleciona a operacao da alu
    output reg alu_src_mux,      // Seleciona o segundo operando da alu
    output reg sel_j_jr,         // Seleciona a fonte do endereco do salto incondicional
    output reg [1:0] reg_dst_mux,// Seleciona o endereco do registrador de escrita
    output reg is_jump,          // A instrucao eh um salto incondicional

    // Sinais para o estagio MEM
    output reg mem_write_enable, // Habilita a escrita na memoria
    output reg sel_beq_bne,      // Seleciona entre beq e bne
    output reg fl_write_enable,  // Habilita a escrita no registrador de flags
    output reg sel_jt_jf,        // Seleciona entre jt e jf na fmu
    output reg is_branch,        // A instrucao eh um desvio pc-relative

    // Sinais para o estagio WB
    output reg [1:0] wb_res_mux, // Seleciona o dado que sera escrito no registrador
    output reg reg_write_enable // Habilita a escrita no banco de registradores
);

always @ ( opcode ) begin
    is_jump = 1'b0;
    is_branch = 1'b0;
    reg_dst_mux = 2'b0; // Seleciona rt como registrador de destino
    alu_src_mux = 2'b1; // Seleciona o imediato como o operando da alu
    mem_write_enable = 1'b0;
    reg_write_enable = 1'b0;
    fl_write_enable = 1'b0;
    case (opcode)
        `OP_STORE: begin
            mem_write_enable = 1'b1;
        end
        `OP_LOAD: begin
            wb_res_mux  = 2'b1; // Seleciona saida da memoria como o dado a ser escrito
            reg_write_enable = 1'b1;
        end
        `OP_J_TYPE: begin
            is_jump = 1'b1;
            sel_j_jr = 1'b1; // Seleciona o imediato como endereco do salto
        end
        `OP_JAL: begin
            is_jump = 1'b1;
            reg_dst_mux = 2'b10; // Seleciona o registrador 15
            sel_j_jr = 1'b0; // Seleciona o valor do registrador como endereco do salto
            reg_write_enable = 1'b1;
            wb_res_mux = 2'b10; // Seleciona o pc+1 para ser escrito no r15
        end
        `OP_BEQ: begin
            is_branch = 1'b1;
            sel_beq_bne = 1'b0;
        end
        `OP_BNE: begin
            is_branch = 1'b1;
            sel_beq_bne = 1'b1;
        end
        `OP_JT: begin
            is_branch = 1'b1;
            sel_jt_jf = 1'b1;
        end
        `OP_JF: begin
            is_branch = 1'b1;
            sel_jt_jf = 1'b0;
        end
        `OP_R_TYPE: begin
            reg_dst_mux = 1'b1; // Seleciona rd como registrador de destino
            wb_res_mux  = 2'b0; // Seleciona a saida da alu como o dado a ser escrito
            alu_src_mux = 1'b0; // Seleciona dado do registrador como operando da alu

            case (funct)
                `FN_JR: begin
                    is_jump = 1'b1;
                end
                default: begin
                    alu_funct = funct;
                    reg_write_enable = 1'b1;
                    fl_write_enable  = 1'b1;
                end
            endcase
        end
        default: begin
        end
    endcase
end

endmodule // control_unit
