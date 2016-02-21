#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <limits.h>

// Numero de registradores de propósito geral
#define MAX_REGISTER 16

// Numero de flags
#define MAX_FLAGS 6

// Tamanho máximo da memória
#define MAX_MEM 1000

// Rerotno do decode_j_type caso encontre um halt;
#define HALT 1

// Definindo a posição das flags no vetor
#define F_ZERO     0
#define F_TRUE     1
#define F_NEG      2
#define F_OVERFLOW 3
#define F_NEGZERO  4
#define F_CARRY    5

// Contador de programa
int pc=0;

// Vetor simbolizando o banco de registradores
int registers[MAX_REGISTER];

// Vetor contendo as flags
bool flags[MAX_FLAGS];

// Variaveis para auxiliar na descoberta dos campos das instruções
int sftOpcode = 26;
int sftRs = 21;//16;
int sftRt = 16;//11;
int sftRd = 11;//21;

// Vetor representando a memória de instrução
unsigned int *inst_mem;

// Vetor representando a memória de dados
int *data_mem;

// numero de instruçõs na memória
int instr_count;

// numero de de dados na memória
int data_count;

char const default_output_file[8] = "res.txt";

// Função que zera os registradores e flags
void clear_all();

// Lê o arquivo e inicializa as memórias
void read_words(FILE **arq);

// Converte uma string com uma sequencia de bits em um numero decimal
unsigned int convert_to_int(char *bit_string);

// Calcula potências de numeros inteiros sem sinal
unsigned int pow_unsig(unsigned int base, unsigned int exp);

// Executa as instruções no array
// O código deve conter um halt para
// terminar a execução.
void execute();

// Retorna o tipo da instrução
char identify_type(int opcode);

// Decodifica e executa instruções do tipo r
void decode_r_type(unsigned int instruction);

// Decodifica e executa instruções do tipo i
void decode_i_type(unsigned int instruction, int opcode);

// Decodifica e executa instruções do tipo j
int decode_j_type(unsigned int instruction, int opcode);

void write_results(char const *file_name, int exit_code);

void abort();

bool sum_check_overflow(int op1, int op2, int res);

bool sub_check_overflow(int op1, int op2, int res);

bool check_carry(unsigned int op1, unsigned int op2);

int main(int argc, char const *argv[]) {
    int exit_code = 0;
    FILE *arq_mem;

    arq_mem = fopen(argv[1], "rt");

    if (arq_mem == NULL)
    {
        printf("Arquivo de entrada não foi aberto!\n");
        return EXIT_FAILURE;
    }

    inst_mem = malloc(sizeof(int) * MAX_MEM);
    data_mem  = malloc(sizeof(int) * MAX_MEM);

    read_words(&arq_mem);
    fclose(arq_mem);

    execute();

    // Se algo der errado, o programa aborta antes de chegar aqui
    if(argc == 3)
        write_results(argv[argc-1], EXIT_SUCCESS);
    else
        write_results(default_output_file, EXIT_SUCCESS);

    free(inst_mem);
    free(data_mem);
    return exit_code;
}

void clear_all()
{
    int i;

    for (i = 0; i < MAX_REGISTER; i++)
    {
        registers[i] = 0;
    }

    for (i = 0; i < MAX_FLAGS; i++)
    {
        flags[i] = false;
    }
}

void read_words(FILE **arq)
{
    int i;
    char word[33];

    for (instr_count = 0; (!feof(*arq)); instr_count++)
    {
        fscanf(*arq, "%s", word);
        //printf("%s\n", word);
        if (strcmp("*", word) == 0) break;
        //getchar();
        inst_mem[instr_count] = convert_to_int(word);
    }

    //printf("Segmento de dados\n");
    for(data_count = 0; 1 == 1; data_count++)
    {
        fscanf(*arq, "%s", word);
        if(feof(*arq)) break;
        //printf("%s\n", word);
        //getchar();
        data_mem[data_count] = convert_to_int(word);
    }

}

unsigned int convert_to_int(char *bit_string)
{
    int i;
    unsigned int word = 0;

    for (i = 0; i < 32; i++)
    {
        if (bit_string[i] == '1')
            word += pow_unsig(2, 31 - i);
    }

    return word;
}

unsigned int pow_unsig(unsigned int base, unsigned int exp)
{
    unsigned int i = 0;
    unsigned int res = 1;

    for (i = 0; i < exp; i++)
    {
        res *= base;
    }

    return res;
}

void execute()
{
    int opcode;
    int exit_code = 0;
    char type;

    for (pc = 0; pc < instr_count; pc++)
    {
        printf("PC = %d\n", pc);
        // Desloca os bits da instrução para achar o opcode
        opcode = inst_mem[pc] >> sftOpcode;
        // Identifica o tipo da instrução
        type = identify_type(opcode);

        if (type == 'r') //ERRO AQUI
        {
            decode_r_type(inst_mem[pc]);
        }
        else if (type == 'i')
        {
            decode_i_type(inst_mem[pc], opcode);
        }
        else if (type == 'j')
        {
            exit_code = decode_j_type(inst_mem[pc], opcode);
            if(exit_code == HALT)
                break;
        }
        else abort();

        //getchar();
        printf("Breakpoint\n");
    }
}

char identify_type(int opcode)
{
    char result;

    if (opcode == 0x00)
    {
        result = 'r';
    }
    else if (opcode == 0x01 || // lcl
             opcode == 0x03 || // jal
             opcode == 0x04 || // beq
             opcode == 0x05 || // bne
             opcode == 0x06 || // loadlit
             opcode == 0x07 || // lch
             opcode == 0x08 || // addi
             opcode == 0x09 || // jt
             opcode == 0x0a || // slti
             opcode == 0x0c || // andi
             opcode == 0x0d || // ori
             opcode == 0x10 || // jf
             opcode == 0x23 || // load
             opcode == 0x2b)   // store
    {
        result = 'i';
    }
    else if (opcode == 0x02) // jump
    {
        result = 'j';
    }
    else
    {
        printf("-----------------------------------\n");
        printf("ERRO!! OPCODE 0x%02X DESCONHECIDO!!\n", opcode);
        printf("-----------------------------------\n");
        result = 'e';
    }

    return result;
}

void decode_r_type(unsigned int instruction)
{
    // Identifica os campos da instrução
    int rd = (instruction >> sftRd) & 0x1f;
    int rs = (instruction >> sftRs) & 0x1f;
    int rt = (instruction >> sftRt) & 0x1f;
    int func = instruction & 0x3F;
    int temp_rs = registers[rs];
    int temp_rt = registers[rt];

    printf("%X\n", instruction);
    printf("rd %d rs %d rt %d func %X\n", rd, rs, rt, func);
    printf("%d %d\n", temp_rs, temp_rt);
    //getchar();

    // add rd = rs + rt
    if (func == 0x20)
    {
        printf("add\n");
        registers[rd] = temp_rs + temp_rt;

        flags[F_OVERFLOW] = sum_check_overflow(temp_rs, temp_rt, registers[rd]);
        flags[F_CARRY] = check_carry(temp_rs, temp_rt);
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] < 0);
    }
    //sub e zeros
    else if (func == 0x22)
    {
        printf("sub/zeros\n");
        registers[rd] = temp_rs - temp_rt;

        flags[F_OVERFLOW] = sub_check_overflow(temp_rs, temp_rt, registers[rd]);
        flags[F_CARRY] = check_carry(temp_rs, temp_rt);
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] < 0);
    }
    //and
    else if (func == 0x24)
    {
        printf("and\n");
        registers[rd] = temp_rs & temp_rt;
        flags[F_OVERFLOW] = false;
        flags[F_CARRY] = false;
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] < 0);
    }
    //or
    else if (func == 0x25)
    {
        printf("or\n");
        registers[rd] = temp_rs | temp_rt;

        flags[F_OVERFLOW] = false;
        flags[F_CARRY] = false;
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] < 0);
    }
    //not
    else if (func == 0x21)
    {
        printf("not\n");
        registers[rd] = !temp_rs;

        flags[F_OVERFLOW] = false;
        flags[F_CARRY] = false;
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] < 0);
    }
    //xor
    else if (func == 0x26)
    {
        printf("xor\n");
        registers[rd] = temp_rs ^ temp_rt;

        flags[F_OVERFLOW] = false;
        flags[F_CARRY] = false;
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] < 0);
    }
    //andnota
    else if (func == 0x23)
    {
        printf("andnota\n");
        registers[rd] = (!temp_rs) & temp_rt;

        flags[F_OVERFLOW] = false;
        flags[F_CARRY] = false;
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] < 0);
    }
    //nor
    else if (func == 0x27)
    {
        printf("nor\n");
        registers[rd] = !(temp_rs | temp_rt);

        flags[F_OVERFLOW] = false;
        flags[F_CARRY] = false;
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] < 0);
    }
    //xnor
    else if (func == 0x28)
    {
        printf("xnor\n");
        registers[rd] = !(temp_rs ^ temp_rt);

        flags[F_OVERFLOW] = false;
        flags[F_CARRY] = false;
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] < 0);
    }
    //ornotb
    else if (func == 0x29)
    {
        printf("ornotb\n");
        registers[rd] = temp_rs | (!temp_rt);

        flags[F_OVERFLOW] = false;
        flags[F_CARRY] = false;
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] < 0);
    }
    //nand
    else if (func == 0x1B)
    {
        printf("nand\n");
        registers[rd] = !(temp_rs & temp_rt);

        flags[F_OVERFLOW] = false;
        flags[F_CARRY] = false;
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] < 0);
    }
    //passa
    else if (func == 0x2B)
    {
        printf("passa/passb\n");
        registers[rd] = temp_rs;

        flags[F_OVERFLOW] = false;
        flags[F_CARRY] = false;
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] < 0);
    }
    //passnota
    else if (func == 0x2C)
    {
        printf("passnota\n");
        registers[rd] = !temp_rs;

        flags[F_OVERFLOW] = false;
        flags[F_CARRY] = false;
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] < 0);
    }
    //inca
    else if (func == 0x2D)
    {
        printf("inca\n");
        registers[rd] = temp_rs + 1;

        flags[F_OVERFLOW] = sum_check_overflow(temp_rs, 1, registers[rd]);
        flags[F_CARRY] = check_carry(temp_rs, 1);
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] < 0);
    }
    //deca
    else if (func == 0x2E)
    {
        printf("deca\n");
        registers[rd] = temp_rs - 1;

        flags[F_OVERFLOW] = sub_check_overflow(temp_rs, 1, registers[rd]);
        flags[F_CARRY] = check_carry(temp_rs, -1);
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] < 0);
    }
    //addinc
    else if (func == 0x2F)
    {
        printf("addinc\n");
        registers[rd] = temp_rs + temp_rt + 1;

        flags[F_OVERFLOW] = sum_check_overflow(temp_rs + temp_rt, 1, registers[rd]);
        flags[F_CARRY] = check_carry(temp_rs + temp_rt, 1);
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] < 0);
    }
    //subdec
    else if (func == 0x30)
    {
        printf("subdec\n");
        registers[rd] = temp_rs - temp_rt - 1;

        flags[F_OVERFLOW] = sub_check_overflow(temp_rs - temp_rt, 1, registers[rd]);
        flags[F_CARRY] = check_carry(temp_rs - temp_rt, -1);
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] < 0);
    }
    //lsl
    else if (func == 0x00)
    {
        printf("lsl\n");
        registers[rd] = temp_rs << 1;

        // Verifica se o msb é 1
        flags[F_CARRY] = (temp_rs & 0x80000000);
        flags[F_OVERFLOW] = false;
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] < 0);
    }
    //lsr
    else if (func == 0x02)
    {
        printf("lsr\n");
        unsigned int temp = temp_rs >> 1;
        registers[rd] = temp;

        flags[F_OVERFLOW] = false;
        flags[F_CARRY] = false;
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] < 0);
    }
    //asl
    else if (func == 0x04)
    {
        printf("asl\n");
        registers[rd] = temp_rs << 1;

        flags[F_OVERFLOW] = (temp_rs & 0x80000000) ^ (temp_rs & 0x40000000);
        flags[F_CARRY] = (temp_rs & 0x80000000);
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] < 0);
    }
    //asr
    else if (func == 0x03)
    {
        printf("asr\n");
        registers[rd] = temp_rs >> 1;

        flags[F_OVERFLOW] = false;
        flags[F_CARRY] =false;
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] < 0);
    }
    //slt
    else if (func == 0x2A)
    {
        printf("slt\n");
        if (temp_rs < temp_rt)
            registers[rd] = 1;
        else registers[rd] = 0;

            flags[F_OVERFLOW] = false;
            flags[F_CARRY] = false;
            flags[F_ZERO] = (registers[rd] == 0);
            flags[F_TRUE] = (registers[rd] != 0);
            flags[F_NEGZERO] = (registers[rd] <= 0);
            flags[F_NEG] = (registers[rd] < 0);
    }
    //jr
    else if (func == 0x08)
    {
        printf("jr\n");
        // - 1 por causa do incremento do for
        pc = temp_rs - 1;//registers[rd] - 1;
        printf("pc = %d\n", pc);
    }
    //div
    else if (func == 0x1A)
    {
        printf("div\n");
        registers[rd] = temp_rs / temp_rt;

        flags[F_OVERFLOW] = false;
        flags[F_CARRY] = false;
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] < 0);
    }
    else {
        printf("-------------------------------------\n");
        printf("ERRO!! FUNCTION 0x%02X DESCONHECIDO!!\n", func);
        printf("-------------------------------------\n");
        abort();
    }
    printf("rd: %d\n", registers[rd]);
}

void decode_i_type(unsigned int instruction, int opcode)
{
    // Identifica os campos da instrução
    int rd = (instruction >> sftRt) & 0x1f; // O registrador de destino no tipo I é o rt
    int rs = (instruction >> sftRs) & 0x1f;
    // sign extend o imediato
    int imm = (instruction & 0xFFFF) | ((instruction & 0x8000) ? 0xFFFF0000 : 0);
    int temp_rs = registers[rs];

    printf("%X\n", instruction);
    printf("rt %d rs %d imm %d\n", rd, rs, imm);
    //getchar();

    // lch
    if(opcode == 0x07)
    {
        printf("lch\n");
        registers[rd] = (imm << 16) | (registers[rd] & 0xffff);

        // flags[F_OVERFLOW] = false;
        // flags[F_CARRY] = false;
        // flags[F_ZERO] = (registers[rd] == 0);
        // flags[F_TRUE] = (registers[rd] != 0);
        // flags[F_NEGZERO] = (registers[rd] <= 0);
        // flags[F_NEG] = (registers[rd] < 0);
    }
    // jal
    else if(opcode == 0x03)
    {
        printf("jal\n");
        // Guarda o endereço da próxima instrução
        registers[15] = pc + 1;
        printf("r15 = %d\n", registers[15]);

        // Menos um por causa do incremento do for
        pc = temp_rs - 1;//registers[rd] - 1;
        printf("pc = %d\n", pc);

        // Altera flag aqui?
    }
    // beq
    else if (opcode == 0x04)
    {

        printf("beq\n");
        if (registers[rd] == temp_rs)
        {
            pc = pc +imm; // Não decrementa pois seria pc + imm + 1
            printf("%d %d\n", registers[rd], temp_rs);
            printf("Pulou\n");
        }
        // muda flag aqui?
    }
    // bne
    else if (opcode == 0x05)
    {
        printf("bne\n");
        if (registers[rd] != temp_rs)
        {
            pc = pc + imm; // Não decrementa pois seria pc + imm + 1
            printf("%d %d\n", registers[rd], temp_rs);
            printf("Pulou\n");
        }
        // muda flag aqui?
    }
    // loadlit
    else if (opcode == 0x06)
    {
        printf("loadlit\n");
        registers[rd] = imm;
    }
    // lcl
    else if (opcode == 0x01)
    {
        printf("lcl\n");
        registers[rd] = imm | (registers[rd] & 0xffff0000);
    }
    // addi
    else if (opcode == 0x08)
    {
        printf("addi\n");
        registers[rd] = temp_rs + imm;

        flags[F_OVERFLOW] = sum_check_overflow(temp_rs, imm, registers[rd]);
        flags[F_CARRY] = check_carry(temp_rs, imm);
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] < 0);
    }
    // jt
    else if (opcode == 0x09)
    {
        printf("JT\n");
        // rd contém o código da condição
        // if (rd == 0x04 && flags[F_NEG]      ||
        //     rd == 0x05 && flags[F_ZERO]     ||
        //     rd == 0x06 && flags[F_CARRY]    ||
        //     rd == 0x07 && flags[F_NEGZERO]  ||
        //     rd == 0x00 && flags[F_TRUE]    ||
        //     rd == 0x03 && flags[F_OVERFLOW])
        if(flags[rs])
        {
            // No urisc, o jt e o jf são pc relative
            printf("Pulou\n");
                pc = pc + imm;
        }
    }
    // jf
    else if (opcode == 0x10)
    {
        printf("JF\n");
        // rd contém o código da condição
        // if (rd == 0x04 && !flags[F_NEG]      ||
        //     rd == 0x05 && !flags[F_ZERO]     ||
        //     rd == 0x06 && !flags[F_CARRY]    ||
        //     rd == 0x07 && !flags[F_NEGZERO]  ||
        //     rd == 0x00 && !flags[F_TRUE]    ||
        //     rd == 0x03 && !flags[F_OVERFLOW])
        if(!flags[rs])
        {
            // Decrementa pra compensar o incremento do for
            printf("Pulou\n");
                pc = pc + imm;
        }
    }
    // slti
    else if (opcode == 0x0a)
    {
        printf("slti\n");
        if (temp_rs == imm)
            registers[rd] = 1;
        else registers[rd] = 0;

        flags[F_OVERFLOW] = false;
        flags[F_CARRY] = false;
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] < 0);
    }
    // andi
    else if (opcode == 0x0c)
    {
        printf("andi\n");
        registers[rd] = temp_rs & imm;

        flags[F_OVERFLOW] = false;
        flags[F_CARRY] = false;
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] < 0);
    }
    // ori
    else if (opcode == 0x0d)
    {
        printf("ori\n");
        registers[rd] = temp_rs | imm;

        flags[F_OVERFLOW] = false;
        flags[F_CARRY] = false;
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] < 0);
    }
    // load
    else if (opcode == 0x23)
    {
        printf("load\n");
        registers[rd] = data_mem[temp_rs];
        flags[F_ZERO] = (registers[rd] == 0);
    }
    // store
    else if (opcode == 0x2b)
    {
        printf("store\n");
        data_mem[temp_rs] = registers[rd];
        //printf("%d %d\n", data_mem[registers[rd]], registers[rd]);
        //getchar();
    }
    printf("rd: %d\n", registers[rd]);
}

int decode_j_type(unsigned int instruction, int opcode)
{
    // Identifica os campos da instrução
    int address = (instruction & 0x3FFFFFF);

    printf("%X\n", instruction);
    printf("address %d\n", address);
    //getchar();

    // jump
    if(opcode == 0x02)
    {
        printf("JUMP\n");
        // Se pc == address, é um halt
        if (pc == address)
        {
            return HALT;
        }
        pc = address - 1; // decrementa por causa do incremento do for
        return 0;
    }

    // se algo saiu errado...
    return -1;
}

void write_results(char const *file_name, int exit_code)
{
    int i;
    FILE *arq_out = fopen(file_name, "w");

    fprintf(arq_out, "Simulador LAPI DOpaCA LAMBA ver. 1.0\n\n");
    fprintf(arq_out, "exit_code: %d\n", exit_code);
    fprintf(arq_out, "Registradores:\n");

    for (i = 0; i < MAX_REGISTER; i++)
    {
        fprintf(arq_out, "r%d: %d\n", i, registers[i]);
    }

    fprintf(arq_out, "Memória:\n");

    for (i = 0; i < MAX_MEM; i++)
    {
        fprintf(arq_out, "mem[%d]: %d\n", i, data_mem[i]);
    }

    fclose(arq_out);
}

void abort()
{
    write_results(default_output_file, EXIT_FAILURE);
    exit(EXIT_FAILURE);
}

bool sum_check_overflow(int op1, int op2, int res)
{
    unsigned int sign_op1;
    unsigned int sign_op2;
    unsigned int sign_res;

    if (op1 < 0) sign_op1 = 1;
    else sign_op1 = 0;

    if (op2 < 0) sign_op2 = 1;
    else sign_op2 = 0;

    if (res < 0) sign_res = 1;
    else sign_res = 0;

    //printf("%d %d %d\n", op1, op2, res);
    //printf("%d %d %d\n", sign_op1, sign_op2, sign_res);
    //printf("%d\n", ((sign_op1 == sign_op2) && sign_op1 != sign_res));

    return ((sign_op1 == sign_op2) && sign_op1 != sign_res);
}

bool sub_check_overflow(int op1, int op2, int res)
{
    unsigned int sign_op1;
    unsigned int sign_op2;
    unsigned int sign_res;

    if (op1 < 0) sign_op1 = 1;
    else sign_op1 = 0;

    // inverte por causa da subtração
    if (op2 < 0) sign_op2 = 0;
    else sign_op2 = 1;

    if (res < 0) sign_res = 1;
    else sign_res = 0;

    //printf("%d %d %d\n", op1, op2, res);
    //printf("%d %d %d\n", sign_op1, sign_op2, sign_res);
    //printf("%d\n", ((sign_op1 == sign_op2) && sign_op1 != sign_res));

    return ((sign_op1 == sign_op2) && sign_op1 != sign_res);
}

bool check_carry(unsigned int op1, unsigned int op2)
{
    return ((op2 > 0 && op1 > UINT_MAX - op2) ||
            (op1 > 0) && op2 > UINT_MAX - op1);
}
