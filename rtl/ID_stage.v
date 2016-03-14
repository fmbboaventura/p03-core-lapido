/***************************************************
 * Module: ID_stage
 * Project: core_lapido
 * Author: Filipe Boaventura
 * Description: Modulo responsavel pela busca de
 * operandos e decodificacao da instrucao.
 ***************************************************/
`include "lapido_defs.v"

module ID_stage
(
    input clk,
    input rst,

    // Do estagio if
    input [`INSTRUCTION_WIDTH-1:0] instruction,
    input [`PC_WIDTH-1:0] next_pc,

    // Do banco de registradores
    input [`GPR_WIDTH-1:0] data_rs,
    input [`GPR_WIDTH-1:0] data_rt,

    // Para o banco de registradores
    output [`GRP_ADDR_WIDTH-1:0] rs,
    output [`GRP_ADDR_WIDTH-1:0] rt,

    // Para o estagio EX
    output reg [193:0] pipeline_reg_out
);

// pc + 1 para o proximo estagio
reg [`PC_WIDTH-1:0] out_next_pc;

wire [`GPR_WIDTH-1:0] out_data_rs;
wire [`GPR_WIDTH-1:0] out_data_rt;

/**** Registrador de instrucao e campos da instrucao ****/
reg [`INSTRUCTION_WIDTH-1:0] instruction_reg;
wire	[5:0]		ir_opcode;
wire	[5:0]		ir_funct;
wire	[4:0]		ir_rd;
wire	[4:0]		ir_rs;
wire	[4:0]		ir_rt;
wire	[15:0]		ir_imm;
wire    [25:0]      ir_jaddr;

/***************** Sinais de Controle *******************/
// Sinais para o estagio EX
wire [5:0] alu_funct;  // Seleciona a operacao da alu
wire alu_src_mux;      // Seleciona o segundo operando da alu
wire sel_j_jr;         // Seleciona a fonte do endereco do salto incondicional
wire [1:0] reg_dst_mux;// Seleciona o endereco do registrador de escrita
wire is_jump;          // A instrucao eh um salto incondicional

// Sinais para o estagio MEM
wire mem_write_enable; // Habilita a escrita na memoria
wire sel_beq_bne;      // Seleciona entre beq e bne
wire fl_write_enable;  // Habilita a escrita no registrador de flags
wire sel_jt_jf;        // Seleciona entre jt e jf na fmu
wire is_branch;        // A instrucao eh um desvio pc-relative
wire sel_jflag_branch; // seletor do tipo do branch

// Sinais para o estagio WB
wire [1:0] wb_res_mux; // Seleciona o dado que sera escrito no registrador
wire reg_write_enable; // Habilita a escrita no banco de registradores

always @ (posedge clk) begin
    instruction_reg <= instruction;
    out_next_pc <= next_pc;
end

assign ir_opcode = instruction_reg[31:26];
assign ir_funct  = instruction_reg[5:0];
assign ir_rd     = instruction_reg[15:11];
assign ir_rs     = instruction_reg[25:21];
assign ir_rt     = instruction_reg[20:16];
assign ir_imm    = instruction_reg[15:0];
assign ir_jaddr  = instruction_reg[25:0];

control_unit ctrl
(
    .opcode(ir_opcode),
    .funct(ir_funct),
    .alu_funct(alu_funct),
    .alu_src_mux(alu_src_mux),
    .sel_j_jr(sel_j_jr),
    .reg_dst_mux(reg_dst_mux),
    .is_jump(is_jump),
    .mem_write_enable(mem_write_enable),
    .sel_beq_bne(sel_beq_bne),
    .fl_write_enable(fl_write_enable),
    .sel_jt_jf(sel_jt_jf),
    .is_branch(is_branch),
    .sel_jflag_branch(sel_jflag_branch),
    .wb_res_mux(wb_res_mux),
    .reg_write_enable(reg_write_enable)
);

assign rs = (ir_rs < `REGISTER_FILE_SIZE)? ir_rs : `GRP_ADDR_WIDTH'h0;
assign rt = (ir_rt < `REGISTER_FILE_SIZE)? ir_rt : `GRP_ADDR_WIDTH'h0;
assign out_data_rs = data_rs;
assign out_data_rt = data_rt;

always @ (posedge clk or posedge rst) begin
    if (rst) begin
        pipeline_reg_out <= 0;
    end else begin
        pipeline_reg_out[193:0] <= {
            wb_res_mux[1:0],               //pipeline_reg_out[193:192]
            reg_write_enable,              //pipeline_reg_out[191]
            mem_write_enable,              //pipeline_reg_out[190]
            sel_beq_bne,                   //pipeline_reg_out[189]
            fl_write_enable,               //pipeline_reg_out[188]
            sel_jt_jf,                     //pipeline_reg_out[187]
            is_branch,                     //pipeline_reg_out[186]
            sel_jflag_branch,              //pipeline_reg_out[185]
            alu_funct[5:0],                //pipeline_reg_out[184:180]
            alu_src_mux,                   //pipeline_reg_out[179]
            sel_j_jr,                      //pipeline_reg_out[178]
            reg_dst_mux[1:0],              //pipeline_reg_out[177:176]
            is_jump,                       //pipeline_reg_out[175]
            ir_rs[4:0],                    //pipeline_reg_out[174:170]
            ir_rt[4:0],                    //pipeline_reg_out[169:165]
            ir_rd[4:0],                    //pipeline_reg_out[164:160]
            out_data_rs[`GPR_WIDTH-1:0],   //pipeline_reg_out[159:128]
            out_data_rt[`GPR_WIDTH-1:0],   //pipeline_reg_out[127:96]
            {{16{ir_imm[15]}}, ir_imm},    //pipeline_reg_out[95:64]
            {{6{ir_jaddr[25]}}, ir_jaddr}, //pipeline_reg_out[63:32]
            out_next_pc[`PC_WIDTH-1:0]     //pipeline_reg_out[31:0]
        };
    end
end

endmodule // ID_stage
