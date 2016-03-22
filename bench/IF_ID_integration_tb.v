/***************************************************
 * Module: IF_ID_integration_tb
 * Project: core_lapido
 * Author: Filipe Boaventura
 * Description: Este modulo testa a integracao entre
 * os modulos IF_stage, ID_stage, register_file e
 * hazard_detection_unit.
 ***************************************************/
`include "lapido_defs.v"
`include "tb_util.v"
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
    wire [`PC_WIDTH - 1:0] IF_ID_pc;

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
        .pc(IF_ID_pc)
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
        .pc(IF_ID_pc),
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

    tb_util util();

    // Gerador de clock
    always begin
        #5  clk =  ! clk;
    end

    reg [5:0] funct_array[14:0];
    reg [5:0] opcode_array[15:0];
    reg [`INSTRUCTION_WIDTH-1:0] inst;
    reg [`INSTRUCTION_WIDTH-1:0] generated_instructions [`INST_MEM_SIZE-1:0];
    integer inst_counter;
    integer i;
    integer expected_pc;
    reg [31:0] field;

    // Blocos initial, aways e assigns executam paralelamente
    initial begin
        clk = 0;
        rst = 0;
        branch_taken = 0; // TODO: testar branch
        #20;

        set_up;
    end

    initial begin
        #40; // Espera o set_up ser concluido
        test_instruction_fetch;
        $stop;
    end

    initial begin
        #60; // Espera pela conclusao do set_up e do IF
        test_instruction_decode;
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
            // Salva no registrador 0, o endereco alvo do jr
            dut_reg.registers[0] = inst_counter-1;
            // Salva no registrador 1, o endereco alvo do jal
            dut_reg.registers[1] = inst_counter-1;
            // // Salva em cada registrador o seu numero
            dut_reg.registers[2] = 2;
            dut_reg.registers[3] = 3;
            dut_reg.registers[4] = 4;
            dut_reg.registers[5] = 5;
            dut_reg.registers[6] = 6;
            dut_reg.registers[7] = 7;
            dut_reg.registers[8] = 8;
            dut_reg.registers[9] = 9;
            dut_reg.registers[10] = 10;
            dut_reg.registers[11] = 11;
            dut_reg.registers[12] = 12;
            dut_reg.registers[13] = 13;
            dut_reg.registers[14] = 14;
            dut_reg.registers[15] = 15;
        end
    endtask

    task test_instruction_fetch;
        begin
            $display("------------------------------");
            $display("test_instruction_fetch:");
            $display("------------------------------");
            for (i = 0; i < inst_counter; i = i+1) begin
                inst = IF_ID_instruction;
                expected_pc = i;
                #10;
                $display("Testando Instrucao no IF %d...", IF_ID_instruction);
                util.assert_equals(generated_instructions[expected_pc], IF_ID_instruction);
                $display("Testando pc %d...", expected_pc);
                util.assert_equals(expected_pc, IF_ID_pc);
                if (HDU_stall_pipeline) i = i-1;//inst_counter = inst_counter-1;
                else if(ID_IF_is_jump && ID_IF_jump_addr != i) i = ID_IF_jump_addr-1;
            end
        end
    endtask

    task test_instruction_decode;
        begin
            $display("------------------------------");
            $display("test_instruction_decode:");
            $display("------------------------------");
            $display("Testando Instrucao no ID %d...", dut_ID.instruction_reg);
            util.assert_equals(generated_instructions[expected_pc-1], dut_ID.instruction_reg);
        end
    endtask

    task generate_instruction_mem_input_file;
        begin
            create_funct_array;
            create_opcode_array;
            inst_counter = 0;
            inst_in = $fopen("data/inst_in.txt", "w");

            // Cria um arquivo com instrucoes que sera lido pela memoria
            $display("Gerando instrucoes do tipo R (Exceto JR)...");
            for (i = 0; i < 14; i = i+1) begin
                inst = 32'b0;
                inst[31:26] = `OP_R_TYPE;
                inst[5:0]   = funct_array[i];
                util.rand_zero_max(15, field); // rs
                inst[25:21] = field[4:0];

                if(funct_array[i] != `FN_JR) begin
                    util.rand_zero_max(15, field); // rt
                    inst[20:16] = field[4:0];
                end

                if(funct_array[i] != `FN_NOT ||
                   funct_array[i] != `FN_LSL ||
                   funct_array[i] != `FN_LSR ||
                   funct_array[i] != `FN_ASL ||
                   funct_array[i] != `FN_ASR) begin
                   util.rand_zero_max(15, field); // rd
                   inst[15:11] = field[4:0];
                end

                $fwrite(inst_in,"%08H\n", inst);
                generated_instructions[inst_counter] = inst;
                inst_counter = inst_counter + 1;
                $display("Instrucao gerada: %b", inst);
            end

            $display("Gerando instrucoes do tipo I...");
            for (i = 3; i < 16; i = i+1) begin
                inst = 32'b0;
                inst[31:26] = opcode_array[i];
                if (opcode_array[i] == `OP_JT || opcode_array[i] == `OP_JF) begin
                    util.rand_zero_max(5, field); // flag code
                end else begin
                    util.rand_zero_max(15, field); //rs
                end
                inst[25:21] = field[4:0];

                // As instrucoes dentro da condicao nao possuem o campo rt
                if (opcode_array[i] != `OP_JT &&
                    opcode_array[i] != `OP_JF &&
                    opcode_array[i] != `OP_LCL &&
                    opcode_array[i] != `OP_LCH &&
                    opcode_array[i] != `OP_LOADLIT &&
                    opcode_array[i] != `OP_JAL) begin
                    util.rand_zero_max(15, field); // rt
                    inst[20:16] = field[4:0];
                end

                // Gerando imediato
                if (opcode_array[i] != `OP_LOAD &&
                    opcode_array[i] != `OP_STORE) begin
                    util.rand_zero_max(32'hFFFF, field); // rt
                    inst[15:0] = field[15:0];
                end
                $fwrite(inst_in,"%08H\n", inst);
                generated_instructions[inst_counter] = inst;
                inst_counter = inst_counter + 1;
                $display("Instrucao gerada: %b", inst);
            end

            $display("Gerando instrucoes de salto incondicional (J/JR/JAL)...");
            // um jal (usando r1) para duas instrucoes a frente
            inst = 32'b0;
            inst[31:26] = `OP_JAL;
            inst[25:21] = 5'b00001;
            //inst[25:0]  = (inst_counter+2)[25:0];
            $fwrite(inst_in,"%08H\n", inst);
            generated_instructions[inst_counter] = inst;
            inst_counter = inst_counter + 1;
            $display("Instrucao gerada: %b", inst);

            // um jump para o mesmo endereco
            inst = 32'b0;
            inst[31:26] = `OP_J_TYPE;
            inst[25:0]  = inst_counter[25:0];
            $fwrite(inst_in,"%08H\n", inst);
            generated_instructions[inst_counter] = inst;
            inst_counter = inst_counter + 1;
            $display("Instrucao gerada: %b", inst);

            // um jr (usando registrador 0) para a instrucao anterior
            inst = 32'b0;
            inst[31:26] = `OP_R_TYPE;
            inst[5:0]   = `FN_JR;
            //inst[25:0]  = (inst_counter-1);
            $fwrite(inst_in,"%08H\n", inst);
            generated_instructions[inst_counter] = inst;
            //inst_counter = inst_counter + 1;
            $display("Instrucao gerada: %b", inst);
            $display("Foram geradas %d Instrucoes", inst_counter);
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
endmodule // IF_ID_integration_tb
