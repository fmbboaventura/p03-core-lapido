/***************************************************
 * Module: control_unit
 * Project: core_lapido
 * Author: Filipe Boaventura
 * Description: Unidade de Controle do processador
 * LAPI DOpaCA LAMBA. Gera sinais de controle para o
 * datapah de acordo com o opcode fornecido.
 ***************************************************/
module control_unit
(
    input [5:0] opcode,   // opcode da instrucao

    output reg reg_dst_mux, // Seleciona o endereco do registrador de escrita
    output reg [1:0] wb_res_mux, // Seleciona o dado que sera escrito no registrador
    output reg reg_write_enable, // Habilita a escrita no banco de registradores
    output reg alu_src_mux,      // Seleciona o segundo operando da alu
    output reg mem_write_enable, // Habilita a escrita na memoria
    output reg fl_write_enable,  // Habilita a escrita no registrador de flags
    output reg sel_jt_jf,        // Seleciona entre jt e jf na fmu
    output reg sel_beq_bne,      // Seleciona entre beq e bne
    output reg sel_branch_jflag, // Seleciona o tipo de branch a ser executado
    output reg is_branch,        // A instrucao eh um desvio pc-relative
    output reg is_jump,          // A instrucao eh um salto incondicional
);

always @ ( opcode ) begin
    case (opcode)
        `OP_STORE: begin
            reg_write_enable = 1'b1;
            mem_write_enable = 1'b1;
            fl_write_enable  = 1'b0;
        end
        default: begin
            mem_write_enable = 1'b0; // As instrucoes restantes nao escrevem na memoria
            case (opcode)
                `OP_LOAD: begin
                    reg_dst_mux = 1'b0; // Seleciona rt como registrador de destino
                    wb_res_mux  = 2'b1; // Seleciona saida da memoria como o dado a ser escrito
                    reg_write_enable = 1'b1;
                    fl_write_enable  = 1'b0; // Desabilita a escrita no registrador de flags
                end
                `OP_R_TYPE: begin
                    reg_dst_mux = 1'b1; // Seleciona rd como registrador de destino
                    wb_res_mux  = 2'b0; // Seleciona a saida da alu como o dado a ser escrito
                    alu_src_mux = 1'b0; // Seleciona dado do registrador como operando da alu
                    reg_write_enable = 1'b1;
                    fl_write_enable  = 1'b1;
                end
                default: ;
            endcase
        end
    endcase
end

endmodule // control_unit
