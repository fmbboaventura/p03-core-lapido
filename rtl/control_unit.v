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
    input stall_pipeline,

    // Sinais para o estagio IF
    output reg is_jump,          // A instrucao eh um salto incondicional

    // Sinais para o estagio ID
    output reg sel_j_jr,         // Seleciona a fonte do endereco do salto incondicional

    // Sinais para o estagio EX
    output reg [5:0] alu_funct,  // Seleciona a operacao da alu
    output reg alu_src_mux,      // Seleciona o segundo operando da alu
    output reg [1:0] reg_dst_mux,// Seleciona o endereco do registrador de escrita
    output reg is_load,          // A instrucao eh um load
    output reg fl_write_enable,  // Habilita a escrita no registrador de flags

    // Sinais para o estagio MEM
    output reg mem_write_enable, // Habilita a escrita na memoria
    output reg sel_beq_bne,      // Seleciona entre beq e bne
    output reg sel_jt_jf,        // Seleciona entre jt e jf na fmu
    output reg is_branch,        // A instrucao eh um desvio pc-relative

    output reg sel_jflag_branch, // seletor do tipo do branch

    // Sinais para o estagio WB
    output reg [1:0] wb_res_mux, // Seleciona o dado que sera escrito no registrador
    output reg reg_write_enable // Habilita a escrita no banco de registradores
);

always @ ( opcode ) begin
    // Desabilita branches, saltos e escrita em blocos sequenciais
    is_load = 1'b0;
    is_jump = 1'b0;
    is_branch = 1'b0;
    mem_write_enable = 1'b0;
    reg_write_enable = 1'b0;
    fl_write_enable = 1'b0;
    reg_dst_mux = `REG_DST_RT;  // Seleciona rt como registrador de destino
    alu_src_mux = `ALU_SRC_IMM; // Seleciona o imediato como o operando da alu
    wb_res_mux  = `WB_ALU;      // Seleciona a saida da alu como o dado a ser escrito

    if(!stall_pipeline) // Soh decodifica se nao ha bolha
    case (opcode)
        `OP_STORE: begin
            mem_write_enable = 1'b1;
        end
        `OP_LOAD: begin
            wb_res_mux  = `WB_MEM; // Seleciona saida da memoria como o dado a ser escrito
            reg_write_enable = 1'b1;
            is_load = 1'b1;
        end
        `OP_J_TYPE: begin
            is_jump = 1'b1;
            sel_j_jr = `SEL_J; // Seleciona o imediato como endereco do salto
        end
        `OP_JAL: begin
            is_jump = 1'b1;
            reg_dst_mux = `REG_DST_15; // Seleciona o registrador 15
            sel_j_jr = `SEL_JR;        // Seleciona o valor do registrador como endereco do salto
            reg_write_enable = 1'b1;
            wb_res_mux = `WB_PC;       // Seleciona o pc+1 para ser escrito no r15
        end
        `OP_BEQ: begin
            is_branch = 1'b1;
            alu_src_mux = `ALU_SRC_REG; //  Seleciona o rt
            alu_funct = `FN_SUB;    // Subtrai o rs com o rt
            sel_beq_bne = `SEL_BEQ; // Avalia a flag zero
            sel_jflag_branch = `SEL_BRANCH;
        end
        `OP_BNE: begin
            is_branch = 1'b1;
            alu_src_mux = `ALU_SRC_REG; //  Seleciona o rt
            alu_funct = `FN_SUB;    // Subtrai os registradores
            sel_beq_bne = `SEL_BNE; // Avalia a flag true
            sel_jflag_branch = `SEL_BRANCH;
        end
        `OP_JT: begin
            is_branch = 1'b1;
            sel_jt_jf = `SEL_JT;
            sel_jflag_branch =`SEL_JFLAG;
        end
        `OP_JF: begin
            is_branch = 1'b1;
            sel_jt_jf = `SEL_JF;
            sel_jflag_branch =`SEL_JFLAG;
        end
        `OP_LOADLIT: begin
            wb_res_mux = `WB_IMM;
            reg_write_enable = 1'b1;
        end
        `OP_R_TYPE: begin
            reg_dst_mux = `REG_DST_RD;  // Seleciona rd como registrador de destino
            alu_src_mux = `ALU_SRC_REG; // Seleciona dado do registrador como operando da alu
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
            reg_write_enable = 1'b1;
            fl_write_enable = 1'b1;

            case (opcode)
                `OP_ADDI: begin
                    alu_funct = `FN_ADD;
                end
                `OP_ANDI: begin
                    alu_funct = `FN_AND;
                end
                `OP_ORI: begin
                    alu_funct = `FN_OR;
                end
                `OP_SLTI: begin
                    alu_funct = `FN_SLT;
                end
                `OP_LCL: begin
                    alu_funct = `OP_LCL;
                end
                `OP_LCH: begin
                    alu_funct = `OP_LCH;
                end
                default: begin
                end
            endcase
        end
    endcase
end

endmodule // control_unit
