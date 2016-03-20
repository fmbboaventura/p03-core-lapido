/***************************************************
 * Module: IF_ID_integration_tb
 * Project: core_lapido
 * Author: Filipe Boaventura
 * Description: Este modulo testa a integracao entre
 * os modulos IF_stage, ID_stage, register_file e
 * hazard_detection_unit.
 ***************************************************/
`include "lapido_defs.v"
module IF_ID_integration_tb ();
    // Entradas
    reg clk;
    reg rst;
    reg [`PC_WIDTH - 1:0] branch_addr;
    reg branch_taken;

    // Do estagio ID para o IF
    wire [`PC_WIDTH - 1:0] ID_IF_jump_addr;
    wire ID_IF_is_jump;

    // Do estagio IF para o ID
    wire [`INSTRUCTION_WIDTH-1:0] IF_ID_instruction;
    wire [`PC_WIDTH - 1:0] IF_ID_next_pc;

    // Do banco de registradores para o estagio ID
    wire [`GPR_WIDTH-1:0] REG_ID_data_rs;
    wire [`GPR_WIDTH-1:0] REG_ID_data_rt;

    // Do estagio ID para o banco de registradores
    wire [`GRP_ADDR_WIDTH-1:0] ID_REG_rs;
    wire [`GRP_ADDR_WIDTH-1:0] ID_REG_rt;

    // Saidas para os demais estagios
    wire [5:0] out_alu_funct;
    wire out_alu_src_mux;
    wire [1:0] out_reg_dst_mux;
    wire out_fl_write_enable;
    wire out_mem_write_enable;
    wire out_sel_beq_bne;
    wire out_sel_jt_jf;
    wire out_is_branch;
    wire out_sel_jflag_branch;
    wire [1:0] out_wb_res_mux;
    wire out_reg_write_enable;
    wire [4:0] out_rd;
    wire [4:0] out_rs;
    wire [`GPR_WIDTH-1:0] out_imm;
    wire [`PC_WIDTH-1:0] out_next_pc;
    wire [`GPR_WIDTH-1:0] out_data_rs;
    wire [`GPR_WIDTH-1:0] out_data_rt;

    // Entradas para o hazard_detection_unit
    wire [4:0] ID_HDU_out_rt;
    wire ID_HDU_out_is_load;

    // Saida do hazard_detection_unit
    wire HDU_stall_pipeline;

    IF_stage dut_IF
    (
        .clk(clk),
        .rst(rst),
        .branch_addr(branch_addr),
        .branch_taken(branch_taken),
        .jump_addr(ID_IF_jump_addr),
        .is_jump(ID_IF_is_jump),
        .stall_pipeline(HDU_stall_pipeline),
        .instruction(IF_ID_instruction),
        .next_pc(IF_ID_next_pc)
    );

    hazard_detection_unit dut_hdu
    (
        .ID_EX_is_load(ID_HDU_out_is_load),
        .ID_EX_rt(ID_HDU_out_rt),
        .IF_ID_rs(IF_ID_instruction[25:21]),
        .IF_ID_rt(IF_ID_instruction[20:16]),
        .stall_pipeline(HDU_stall_pipeline)
    );

    register_file dut_reg
    (
        .clk(clk),
        .rst(rst),
        .en(1'b0),
        .rd(5'bx),
        .rs(ID_REG_rs),
        .rt(ID_REG_rt),
        .data(32'bx),
        .data_rs(REG_ID_data_rs),
        .data_rt(REG_ID_data_rt)
    );

    ID_stage dut_ID
    (
        .clk(clk),
        .rst(rst),
        .instruction(IF_ID_instruction),
        .next_pc(IF_ID_next_pc),
        .data_rs(REG_ID_data_rs),
        .data_rt(REG_ID_data_rt),
        .stall_pipeline(HDU_stall_pipeline),
        .rs(ID_REG_rs),
        .rt(ID_REG_rt),
        .jump_addr(ID_IF_jump_addr),
        .is_jump(ID_IF_is_jump),
        .out_alu_funct(out_alu_funct),
        .out_alu_src_mux(out_alu_src_mux),
        .out_reg_dst_mux(out_reg_dst_mux),
        .out_is_load(ID_HDU_out_is_load),
        .out_fl_write_enable(out_fl_write_enable),
        .out_mem_write_enable(out_mem_write_enable),
        .out_sel_beq_bne(out_sel_beq_bne),
        .out_sel_jt_jf(out_sel_jt_jf),
        .out_is_branch(out_is_branch),
        .out_sel_jflag_branch(out_sel_jflag_branch),
        .out_wb_res_mux(out_wb_res_mux),
        .out_reg_write_enable(out_reg_write_enable),
        .out_rd(out_rd),
        .out_rs(out_rs),
        .out_rt(ID_HDU_out_rt),
        .out_imm(out_imm),
        .out_next_pc(out_next_pc),
        .out_data_rs(out_data_rs),
        .out_data_rt(out_data_rt)
    );

    // Gerador de clock
    always begin
        #5  clk =  ! clk;
    end

    reg [5:0] funct_array[14:0];
    reg [5:0] opcode_array[15:0];
    reg [`INSTRUCTION_WIDTH-1:0] inst;
    integer inst_counter;
    integer i;
    reg [31:0] field;

    initial begin
        clk = 0;
        rst = 0;
        #20;

        set_up;

    end

    integer inst_in;
    task set_up;
        begin
            $display("------------------------------");
            $display("set_up:");
            $display("------------------------------");

            generate_instruction_mem_input_file;

            rst = 1;
            #20;
            rst = 0;
        end
    endtask

    task generate_instruction_mem_input_file;
        begin
            create_funct_array;
            create_opcode_array;
            inst_counter = 0;
            inst_in = $fopen("data/inst_in.txt", "w");

            // Cria um arquivo com instrucoes que sera lido pela memoria
            $display("Gerando instrucoes do tipo R...");
            for (i = 0; i < 15; i = i+1) begin
                inst = 32'b0;
                inst[31:26] = `OP_R_TYPE;
                inst[5:0]   = funct_array[i];
                rand_zero_max(15, field); // rs
                inst[25:21] = field[4:0];

                if(funct_array[i] != `FN_JR) begin
                    rand_zero_max(15, field); // rt
                    inst[20:16] = field[4:0];
                end

                if(funct_array[i] != `FN_NOT ||
                   funct_array[i] != `FN_LSL ||
                   funct_array[i] != `FN_LSR ||
                   funct_array[i] != `FN_ASL ||
                   funct_array[i] != `FN_ASR) begin
                   rand_zero_max(15, field); // rd
                   inst[15:11] = field[4:0];
                end

                $fwrite(inst_in,"%08H\n", inst);
                inst_counter = inst_counter + 1;
                $display("Instrucao gerada: %b", inst);
                // dut_IF.imem.mem[inst_counter] = inst;
                // $display("Instrucao gerada: %b", dut_IF.imem.mem[inst_counter]);
                // inst_counter = inst_counter + 1;
            end

            for (i = 2; i < 16; i = i+1) begin

            end
            $fclose(inst_in);
        end
    endtask

    task create_funct_array;
        begin
            funct_array[0] = `FN_ADD;
            funct_array[1] = `FN_SUB;
            funct_array[2] = `FN_AND;
            funct_array[3] = `FN_OR;
            funct_array[4] = `FN_NOT;
            funct_array[5] = `FN_XOR;
            funct_array[6] = `FN_NOR;
            funct_array[7] = `FN_XNOR;
            funct_array[8] = `FN_NAND;
            funct_array[9] = `FN_LSL;
            funct_array[10] = `FN_LSR;
            funct_array[11] = `FN_ASL;
            funct_array[12] = `FN_ASR;
            funct_array[13] = `FN_SLT;
            funct_array[14] = `FN_JR;
        end
    endtask

    task create_opcode_array;
        begin
            opcode_array[0] = `OP_R_TYPE;
            opcode_array[1] = `OP_J_TYPE;
            opcode_array[2] = `OP_JAL;
            opcode_array[3] = `OP_LOAD;
            opcode_array[4] = `OP_STORE;
            opcode_array[5] = `OP_BEQ;
            opcode_array[6] = `OP_BNE;
            opcode_array[7] = `OP_JT;
            opcode_array[8] = `OP_JF;
            opcode_array[9] = `OP_ADDI;
            opcode_array[10] = `OP_ANDI;
            opcode_array[11] = `OP_ORI;
            opcode_array[12] = `OP_SLTI;
            opcode_array[13] = `OP_LCL;
            opcode_array[14] = `OP_LCH;
            opcode_array[15] = `OP_LOADLIT;
        end
    endtask
    // Gera numeros aleatorios de 32 bit entre 0 e max
    task rand_zero_max;
        input [31:0] max;
        output [31:0] result;
        begin
            result = $unsigned($random) % max;
        end
    endtask
endmodule // IF_ID_integration_tb
