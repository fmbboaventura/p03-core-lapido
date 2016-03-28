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
        .branch_taken(branch_taken),
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
        .out_next_pc(out_next_pc)
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
    reg enable_test_IF;
    reg enable_test_ID;
    reg was_a_jump; // se a ultima instrucao decodificada foi um pulo

    // Blocos initial, aways e assigns executam paralelamente
    initial begin
        clk = 0;
        rst = 0;
        branch_taken = 0; // TODO: testar branch
        was_a_jump = 0;
        set_up;
    end

    // initial begin
    //     #40; // Espera o set_up ser concluido
    //     test_instruction_fetch;
    //     $stop;
    // end
    //
    // initial begin
    //     #60; // Espera pela conclusao do set_up e do IF
    //     test_instruction_decode;
    // end

    integer inst_in;
    task set_up;
        begin
            $display("------------------------------");
            $display("set_up %t", $time);
            $display("------------------------------");

            generate_instruction_mem_input_file;
            test_reset;

            expected_pc = 0;

            // Salva no registrador 0, o endereco alvo do jr
            dut_reg.registers[0] = 15;//inst_counter-1;
            // Salva no registrador 1, o endereco alvo do jal
            dut_reg.registers[1] = 16;//inst_counter;
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

            enable_test_IF = 1;
            #10;
            enable_test_ID = 1;
        end
    endtask

    always @ (posedge clk) begin
        if (enable_test_IF) test_instruction_fetch;
    end

    always @ (posedge clk) begin
        if (enable_test_ID) test_instruction_decode;
    end

    always @ (posedge clk) begin
        if (IF_ID_instruction == `INSTRUCTION_WIDTH'd8) begin
            $display("%b", IF_ID_instruction);
            $display("Salto para o mesmo endereco encontrado. %b", ID_IF_jump_addr);
            $display("Tempo: %t", $time);
            $display("Parando...");
            $stop;
        end
    end

    task test_instruction_fetch;
        begin
            $display("------------------------------");
            $display("test_instruction_fetch: %t", $time);
            $display("------------------------------");

            $display("Testando pc %d...", expected_pc);
            util.assert_equals(expected_pc, IF_ID_pc);

            $display("Testando Instrucao no IF %d...", IF_ID_instruction);
            if(ID_IF_is_jump)
                util.assert_equals(`NOP_INSTRUCTION, IF_ID_instruction);
            else util.assert_equals(generated_instructions[expected_pc], IF_ID_instruction);

            if(!HDU_stall_pipeline) begin
                if(ID_IF_is_jump) expected_pc = ID_IF_jump_addr;
                else if (branch_taken) expected_pc = branch_addr;
                else expected_pc = expected_pc + 1;
            end
        end
    endtask

    task test_instruction_decode;
        reg [5:0] ID_opcode;
        reg [5:0] ID_funct;
        reg [4:0] ID_rs;
        reg [4:0] ID_rt;
        reg [4:0] ID_rd;
        reg [31:0] ID_imm;
        reg [31:0] ID_jump_addr;
        reg [31:0] expected_instruction;
        begin
            $display("------------------------------");
            $display("test_instruction_decode: %t", $time);
            $display("------------------------------");
            $display("Testando Instrucao no ID %d...", dut_ID.instruction_reg);
            if (was_a_jump)
                expected_instruction = `NOP_INSTRUCTION;
            else
                expected_instruction = generated_instructions[IF_ID_pc-1];

            util.assert_equals(expected_instruction, dut_ID.instruction_reg);

            ID_opcode = expected_instruction[31:26];
            ID_funct = expected_instruction[5:0];
            ID_rs = expected_instruction[25:21];
            ID_rt = expected_instruction[20:16];
            ID_rd = expected_instruction[15:11];
            ID_imm = {{16{expected_instruction[15]}}, expected_instruction[15:0]};
            ID_jump_addr = {6'b000000, expected_instruction[25:0]};

            $display("ID_stage: Testando campo rs %d...", ID_rs);
            util.assert_equals(ID_rs, out_rs);
            util.assert_equals(ID_rs, ID_REG_rs);

            $display("ID_stage: Testando saida do banco de registradores data_rs %d...", ID_rs);
            if(ID_rs == 0) begin
                util.assert_equals(15, REG_ID_data_rs);
            end else if(ID_rs == 1) begin
                util.assert_equals(16, REG_ID_data_rs);
            end else begin
                util.assert_equals(ID_rs, REG_ID_data_rs);
            end

            $display("ID_stage: Testando campo rt %d...", ID_rt);
            util.assert_equals(ID_rt, ID_HDU_out_rt);
            util.assert_equals(ID_rt, ID_REG_rt);

            $display("ID_stage: Testando Testando saida do banco de registradores data_rt %d...", ID_rt);
            if(ID_rt == 0) begin
                util.assert_equals(15, REG_ID_data_rt);
            end else if(ID_rt == 1) begin
                util.assert_equals(16, REG_ID_data_rt);
            end else begin
                util.assert_equals(ID_rt, REG_ID_data_rt);
            end

            $display("ID_stage: Testando campo rd %d...", out_rd);
            util.assert_equals(ID_rd, out_rd);

            $display("ID_stage: Testando campo imediato...", out_imm);
            util.assert_equals(ID_imm, out_imm);

            $display("ID_stage: Testando is_jump...");
            util.assert_equals((ID_opcode == `OP_JAL || ID_opcode == `OP_J_TYPE) ||
                (ID_opcode == `OP_R_TYPE && ID_funct == `FN_JR), ID_IF_is_jump);
            was_a_jump = ID_IF_is_jump;

            if(ID_IF_is_jump) begin
                $display("ID_stage: Testando jump_addr %b %d...", dut_ID.sel_j_jr, ID_IF_jump_addr);
                if(dut_ID.sel_j_jr) begin
                    util.assert_equals(ID_jump_addr, ID_IF_jump_addr);
                end else if (ID_rs == 0) begin
                    util.assert_equals(15, ID_IF_jump_addr);
                end else if (ID_rs == 1) begin
                    util.assert_equals(16, ID_IF_jump_addr);
                end
            end

            //test_control_output(ID_opcode, ID_funct);
        end
    endtask

    task test_control_output;
        input [5:0] ID_opcode;
        input [5:0] ID_funct;

        // Sinais para o estagio EX
        reg [5:0] exp_alu_funct;  // Seleciona a operacao da alu
        reg exp_alu_src_mux;      // Seleciona o segundo operando da alu
        reg [1:0] exp_reg_dst_mux;// Seleciona o endereco do registrador de escrita
        reg exp_is_load;          // A instrucao eh um load
        reg exp_fl_write_enable;  // Habilita a escrita no registrador de flags

        // Sinais para o estagio MEM
        reg exp_mem_write_enable; // Habilita a escrita na memoria
        reg exp_sel_beq_bne;      // Seleciona entre beq e bne
        reg exp_sel_jt_jf;        // Seleciona entre jt e jf na fmu
        reg exp_is_branch;        // A instrucao eh um desvio pc-relative
        reg exp_sel_jflag_branch; // seletor do tipo do branch

        // Sinais para o estagio WB
        reg [1:0] exp_wb_res_mux; // Seleciona o dado que sera escrito no registrador
        reg exp_reg_write_enable; // Habilita a escrita no banco de registradores
        begin
            $display("------------------------------");
            $display("test_control_output %t:", $time);
            $display("------------------------------");

            // gerando valores esperados
            exp_alu_funct = (ID_opcode == `OP_R_TYPE) ? ID_funct :
                (ID_opcode == `OP_ADDI) ? `FN_ADD :
                (ID_opcode == `OP_ANDI) ? `FN_AND :
                (ID_opcode == `OP_ORI)  ? `FN_OR  :
                (ID_opcode == `OP_SLTI) ? `FN_SLT :
                (ID_opcode == `OP_LCL)  ? `OP_LCL :
                (ID_opcode == `OP_LCH)  ? `OP_LCH :
                ((ID_opcode == `OP_BEQ) ||
                 (ID_opcode == `OP_BNE)) ? `FN_SUB : 6'bx;

            exp_alu_src_mux = ((ID_opcode == `OP_R_TYPE) ||
                (ID_opcode == `OP_BEQ) ||
                (ID_opcode == `OP_BNE)) ? `ALU_SRC_REG : `ALU_SRC_IMM;

            exp_reg_dst_mux = (ID_opcode == `OP_R_TYPE) ? `REG_DST_RD :
                (ID_opcode == `OP_JAL) ? `REG_DST_15 : `REG_DST_RT;

            exp_is_load = (ID_opcode == `OP_LOAD);

            exp_fl_write_enable = ((ID_opcode == `OP_R_TYPE) && (ID_funct != `FN_JR)) ||
                (ID_opcode == `OP_ADDI) ||
                (ID_opcode == `OP_ANDI) ||
                (ID_opcode == `OP_ORI)  ||
                (ID_opcode == `OP_SLTI) ||
                (ID_opcode == `OP_LCL)  ||
                (ID_opcode == `OP_LCH)  ||
                (ID_opcode == `OP_BEQ)  ||
                (ID_opcode == `OP_BNE);

            exp_mem_write_enable = (ID_opcode == `OP_STORE);

            exp_sel_beq_bne = (ID_opcode == `OP_BEQ) ? `SEL_BEQ :
                (ID_opcode == `OP_BNE) ? `SEL_BNE : 1'bx;

            exp_sel_jt_jf = (ID_opcode == `OP_JT) ? `SEL_JT :
                (ID_opcode == `OP_JF) ? `SEL_JF : 1'bx;

            exp_is_branch = (ID_opcode == `OP_BEQ) ||
                (ID_opcode == `OP_BNE) ||
                (ID_opcode == `OP_JT)  ||
                (ID_opcode == `OP_JF);

            exp_sel_jflag_branch =
                ((ID_opcode == `OP_BEQ) || (ID_opcode == `OP_BNE)) ? `SEL_BRANCH :
                ((ID_opcode == `OP_JT) || (ID_opcode == `OP_JF))   ? `SEL_JFLAG  :
                1'bx;

            exp_wb_res_mux = (ID_opcode == `OP_LOAD) ? `WB_MEM :
                (ID_opcode == `OP_LOADLIT) ? `WB_IMM :
                (ID_opcode == `OP_JAL) ? `WB_PC : `WB_ALU;

            exp_reg_write_enable =  ((ID_opcode == `OP_R_TYPE) && (ID_funct != `FN_JR)) ||
                (ID_opcode == `OP_ADDI)    ||
                (ID_opcode == `OP_ANDI)    ||
                (ID_opcode == `OP_ORI)     ||
                (ID_opcode == `OP_SLTI)    ||
                (ID_opcode == `OP_LCL)     ||
                (ID_opcode == `OP_LCH)     ||
                (ID_opcode == `OP_BEQ)     ||
                (ID_opcode == `OP_BNE)     ||
                (ID_opcode == `OP_LOAD)    ||
                (ID_opcode == `OP_LOADLIT) ||
                (ID_opcode == `OP_JAL);

            // ---------------- estagio EX ------------------
            $display("Testando alu_func %06h", out_alu_funct);
            util.assert_equals(exp_alu_funct, out_alu_funct);

            $display("Testando alu_src_mux %b", out_alu_src_mux);
            util.assert_equals(exp_alu_src_mux, out_alu_src_mux);

            $display("Testando reg_dst_mux %b", out_reg_dst_mux);
            util.assert_equals(exp_reg_dst_mux, out_reg_dst_mux);

            $display("Testando is_load %b", ID_HDU_out_is_load);
            util.assert_equals(exp_is_load, ID_HDU_out_is_load);

            $display("Testando fl_write_enable %b", out_fl_write_enable);
            util.assert_equals(exp_fl_write_enable, out_fl_write_enable);

            // ----------------- estagio MEM -----------------
            $display("Testando mem_write_enable %b", out_mem_write_enable);
            util.assert_equals(exp_mem_write_enable, out_mem_write_enable);

            $display("Testando sel_beq_bne %b", out_sel_beq_bne);
            util.assert_equals(exp_sel_beq_bne, out_sel_beq_bne);

            $display("Testando sel_jt_jf %b", out_sel_jt_jf);
            util.assert_equals(exp_sel_jt_jf, out_sel_jt_jf);

            $display("Testando is_branch %b", out_is_branch);
            util.assert_equals(exp_is_branch, out_is_branch);

            $display("Testando sel_jflag_branch %b", out_sel_jflag_branch);
            util.assert_equals(exp_sel_jflag_branch, out_sel_jflag_branch);

            // ------------------- estagio WB -----------------
            $display("Testando wb_res_mux %b", out_wb_res_mux);
            util.assert_equals(exp_wb_res_mux, out_wb_res_mux);

            $display("Testando reg_write_enable %b", out_reg_write_enable);
            util.assert_equals(exp_reg_write_enable, out_reg_write_enable);
        end
    endtask

    task test_reset;
        begin
            $display("------------------------------");
            $display("test_reset:");
            $display("------------------------------");

            // Reset fica em 1 durante 1 ciclo
            rst = 1;
            #10;
            rst = 0;

            // Verifica se as saidas estão conforme o esperado
            $display("-----------------------------------");
            $display("Testando saidas do IF para o ID...:");
            $display("-----------------------------------");
            $display("Testando IF_ID_pc...");
            util.assert_equals(0, IF_ID_pc);
            $display("Testando IF_ID_instruction...");
            util.assert_equals(`NOP_INSTRUCTION, IF_ID_instruction);

            $display("-----------------------------------");
            $display("Testando saidas do ID para o IF...:");
            $display("-----------------------------------");
            $display("Testando ID_IF_is_jump...");
            util.assert_equals(0, ID_IF_is_jump);

            $display("-----------------------------------");
            $display("Testando saidas do ID para o EX...:");
            $display("-----------------------------------");
            $display("Testando ID_HDU_out_is_load");
            util.assert_equals(0, ID_HDU_out_is_load);

            $display("Testando out_fl_write_enable");
            util.assert_equals(0, out_fl_write_enable);

            $display("Testando out_reg_write_enable");
            util.assert_equals(0, out_reg_write_enable);

            $display("Testando out_mem_write_enable");
            util.assert_equals(0, out_mem_write_enable);

            $display("Testando out_is_branch");
            util.assert_equals(0, out_is_branch);
        end
    endtask

    task generate_instruction_mem_input_file;
        begin
            create_funct_array;
            create_opcode_array;
            inst_counter = 0;
            inst_in = $fopen("data/inst_in.txt", "w");

            // Cria um arquivo com instrucoes que sera lido pela memoria

            // um jal (usando r1) para a instrução 16
            // O registrador e inicializado no set_up
            $display("Gerando instrucao JAL...");
            inst = 32'b0;
            inst[31:26] = `OP_JAL;
            inst[25:21] = 5'b00001;
            $fwrite(inst_in,"%08H\n", inst);
            generated_instructions[inst_counter] = inst;
            inst_counter = inst_counter + 1;
            $display("Instrucao gerada: %b", inst);

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

            // um jr (usando registrador 0) para a instrucao 15
            // O registrador eh inicializado no set_up
            $display("Gerando instrucao JR...");
            inst = 32'b0;
            inst[31:26] = `OP_R_TYPE;
            inst[5:0]   = `FN_JR;
            $fwrite(inst_in,"%08H\n", inst);
            generated_instructions[inst_counter] = inst;
            inst_counter = inst_counter + 1;
            $display("Instrucao gerada: %b", inst);

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

            // um jump para a instrucao 1
            $display("Gerando instrucao J...");
            inst = 32'b0;
            inst[31:26] = `OP_J_TYPE;
            inst[25:0]  = 26'b1;
            $fwrite(inst_in,"%08H\n", inst);
            generated_instructions[inst_counter] = inst;
            inst_counter = inst_counter + 1;
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
