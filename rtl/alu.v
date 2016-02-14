/***************************************************
 * Module: alu
 * Project: core_lapido
 * Author:
 * Description: Unidade Logico Aritmetica do
 * processador LAPI DOpaCA LAMBA. Este modulo opera
 * dois valores de 32 bis, de acordo com o código de
 * seleção de operacao da alu. A saida eh um valor de
 * 33 bits, onde o 33th bit deve ser usado como a flag
 * carry e os demais 32 bits são o resultado da opera-
 * cao em si. O modulo tambem apresenta uma saida de
 * 5 bits para as flags restantes. A saida flags esta
 * organizada da seginte forma:
 * flags[0] = flag zero
 * flags[1] = flag true
 * flags[2] = flag neg
 * flags[3] = flag overflow
 * flags[4] = flag negzero
 ***************************************************/
 `include "lapido_defs.v"

module alu
(
    input [31:0] data_rs,   // Primeiro operando
    input [31:0] data_rt,   // Segundo operando
    input [5:0]  alu_funct, // Operacao da alu

    output reg [32:0] alu_res, // O 33th bit eh o carry da alu
    output reg [4:0] flags     // Demais flags
);

always @ ( * ) begin // quando qualquer entrada mudar, faca...
    case (alu_funct)
        `FN_ADD: begin
            alu_res = data_rs + data_rt;
            //flags[`FL_OVERFLOW] = logica do overflow aqui
            end
        `FN_SUB: begin
            alu_res = data_rs - data_rt;
            //flags[`FL_OVERFLOW] = logica do overflow aqui
            end
        `FN_AND: begin
            alu_res = data_rs & data_rt;
            //flags[`FL_OVERFLOW] = logica do overflow aqui
            end
        `FN_NAND: begin
            alu_res = data_rs ~& data_rt;
            //flags[`FL_OVERFLOW] = logica do overflow aqui
            end
        `FN_OR: begin
            alu_res = data_rs | data_rt;
            //flags[`FL_OVERFLOW] = logica do overflow aqui
            end
        `FN_NOR: begin
            alu_res = data_rs ~| data_rt;
            //flags[`FL_OVERFLOW] = logica do overflow aqui
            end
        `FN_XNOR: begin
            alu_res = data_rs ~^ data_rt;
            //flags[`FL_OVERFLOW] = logica do overflow aqui
            end
        `FN_XOR: begin
            alu_res = data_rs ^ data_rt;
            //flags[`FL_OVERFLOW] = logica do overflow aqui
            end
        `FN_NOT: begin
            alu_res = ~data_rs;
            //flags[`FL_OVERFLOW] = logica do overflow aqui
            end
        `FN_PASSA: begin
            alu_res = data_rs;
            //flags[`FL_OVERFLOW] = logica do overflow aqui
            end
        `FN_LSL: begin
            alu_res = data_rs << 1;
            //flags[`FL_OVERFLOW] = logica do overflow aqui
            end
        `FN_LSR: begin
            alu_res = data_rs >> 1;
            //flags[`FL_OVERFLOW] = logica do overflow aqui
            end
        `FN_ASL: begin
            alu_res = data_rs <<< 1;
            //flags[`FL_OVERFLOW] = logica do overflow aqui
            end
        `FN_ASR: begin
            alu_res = data_rs >>> 1;
            //flags[`FL_OVERFLOW] = logica do overflow aqui
            end
        `FN_SLT: begin
            if(data_rs < data_rt) 
                begin
                    alu_res = 1;
                end
            else
                begin
                    alu_res = 0;
                end
            //flags[`FL_OVERFLOW] = logica do overflow aqui
            end
        `FN_JR: begin
            //flags[`FL_OVERFLOW] = logica do overflow aqui
            end     
        default: begin
            flags[`FL_OVERFLOW] = 0; // essas operacoes nao causam oveflow
            //case (alu_funct) // TODO implementar case com os funct restantes

            //endcase
            end
    endcase

    flags[`FL_ZERO] = (alu_res == 0);
    flags[`FL_TRUE] = !flags[`FL_ZERO];
    flags[`FL_NEG] = alu_res[31];
end

endmodule // alu
