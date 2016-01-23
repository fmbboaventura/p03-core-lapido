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
#define F_NEG      1
#define F_CARRY    2
#define F_NEGZERO  3
#define F_OVERFLOW 4
#define F_TRUE     5

// Contador de programa
int pc=0;

// Vetor simbolizando o banco de registradores
int registers[MAX_REGISTER];

// Vetor contendo as flags
bool flags[MAX_FLAGS];

// Variaveis para auxiliar na descoberta dos campos das instruções
int sftOpcode = 26;
int sftRd = 21;
int sftRs = 16;
int sftRt = 11;

// Vetor representando a memória de instrução
unsigned int *inst_mem;

// Vetor representando a memória de dados
unsigned int *data_mem;

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
// ATENÇÂO: não faz distinção entre dados e
// intruções. O código deve conter um halt para
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
        return -1;
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
        printf("%s\n", word);
        if (strcmp("*", word) == 0) break;
        //getchar();
        inst_mem[instr_count] = convert_to_int(word);
    }

    printf("Segmento de dados\n");
    for(data_count = 0; (!feof(*arq)); data_count++)
    {
        fscanf(*arq, "%s", word);
        printf("%s\n", word);
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
        printf("%d\n", pc);
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
        printf("ERRO!! OPCODE 0x%02x DESCONHECIDO!!\n", opcode);
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

    printf("%x\n", instruction);
    printf("rd %d rs %d rt %d func %x\n", rd, rs, rt, func);
    //getchar();

    // add rd = rs + rt
    if (func == 0x20)
    {
        registers[rd] = registers[rs] + registers[rt];

        flags[F_OVERFLOW] = sum_check_overflow(registers[rs], registers[rt], registers[rd]);
        flags[F_CARRY] = check_carry(registers[rs], registers[rt]);
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] <= 0);
    }
    //sub e zeros
    else if (func == 0x22)
    {
        registers[rd] = registers[rs] - registers[rt];

        flags[F_OVERFLOW] = sub_check_overflow(registers[rs], registers[rt], registers[rd]);
        flags[F_CARRY] = check_carry(registers[rs], registers[rt]);
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] <= 0);
    }
    //and
    else if (func == 0x24)
    {
        registers[rd] = registers[rs] & registers[rt];
        flags[F_OVERFLOW] = false;
        flags[F_CARRY] = false;
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] <= 0);
    }
    //or
    else if (func == 0x25)
    {
        registers[rd] = registers[rs] | registers[rt];

        flags[F_OVERFLOW] = false;
        flags[F_CARRY] = false;
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] <= 0);
    }
    //not
    else if (func == 0x21)
    {
        registers[rd] = !registers[rs];

        flags[F_OVERFLOW] = false;
        flags[F_CARRY] = false;
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] <= 0);
    }
    //xor
    else if (func == 0x26)
    {
        registers[rd] = registers[rs] ^ registers[rt];

        flags[F_OVERFLOW] = false;
        flags[F_CARRY] = false;
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] <= 0);
    }
    //andnota
    else if (func == 0x23)
    {
        registers[rd] = (!registers[rs]) & registers[rt];

        flags[F_OVERFLOW] = false;
        flags[F_CARRY] = false;
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] <= 0);
    }
    //nor
    else if (func == 0x27)
    {
        registers[rd] = !(registers[rs] | registers[rt]);

        flags[F_OVERFLOW] = false;
        flags[F_CARRY] = false;
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] <= 0);
    }
    //xnor
    else if (func == 0x28)
    {
        registers[rd] = !(registers[rs] ^ registers[rt]);

        flags[F_OVERFLOW] = false;
        flags[F_CARRY] = false;
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] <= 0);
    }
    //ornotb
    else if (func == 0x29)
    {
        registers[rd] = registers[rs] | (!registers[rt]);

        flags[F_OVERFLOW] = false;
        flags[F_CARRY] = false;
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] <= 0);
    }
    //nand
    else if (func == 0x1B)
    {
        registers[rd] = !(registers[rs] & registers[rt]);

        flags[F_OVERFLOW] = false;
        flags[F_CARRY] = false;
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] <= 0);
    }
    //passa
    else if (func == 0x2B)
    {
        registers[rd] = registers[rs];

        flags[F_OVERFLOW] = false;
        flags[F_CARRY] = false;
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] <= 0);
    }
    //passnota
    else if (func == 0x2C)
    {
        registers[rd] = !registers[rs];

        flags[F_OVERFLOW] = false;
        flags[F_CARRY] = false;
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] <= 0);
    }
    //inca
    else if (func == 0x2D)
    {
        registers[rd] = registers[rs] + 1;

        flags[F_OVERFLOW] = sum_check_overflow(registers[rs], 1, registers[rd]);
        flags[F_CARRY] = check_carry(registers[rs], 1);
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] <= 0);
    }
    //deca
    else if (func == 0x2E)
    {
        registers[rd] = registers[rs] - 1;

        flags[F_OVERFLOW] = sub_check_overflow(registers[rs], 1, registers[rd]);
        flags[F_CARRY] = check_carry(registers[rs], -1);
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] <= 0);
    }
    //addinc
    else if (func == 0x2F)
    {
        registers[rd] = registers[rs] + registers[rt] + 1;

        flags[F_OVERFLOW] = sum_check_overflow(registers[rs] + registers[rt], 1, registers[rd]);
        flags[F_CARRY] = check_carry(registers[rs] + registers[rt], 1);
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] <= 0);
    }
    //subdec
    else if (func == 0x30)
    {
        registers[rd] = registers[rs] - registers[rt] - 1;

        flags[F_OVERFLOW] = sub_check_overflow(registers[rs] - registers[rt], 1, registers[rd]);
        flags[F_CARRY] = check_carry(registers[rs] - registers[rt], -1);
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] <= 0);
    }
    //lsl
    else if (func == 0x00)
    {
        registers[rd] = registers[rs] << 1;

        flags[F_OVERFLOW] = false;
        flags[F_CARRY] = false;
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] <= 0);
    }
    //lsr
    else if (func == 0x02)
    {
        unsigned int temp = registers[rs] >> 1;
        registers[rd] = temp;

        flags[F_OVERFLOW] = false;
        flags[F_CARRY] = false;
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] <= 0);
    }
    //asl
    else if (func == 0x04)
    {
        registers[rd] = registers[rs] << 1;

        flags[F_OVERFLOW] = false;
        flags[F_CARRY] = false;
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] <= 0);
    }
    //asr
    else if (func == 0x03)
    {
        registers[rd] = registers[rs] >> 1;

        flags[F_OVERFLOW] = false;
        flags[F_CARRY] =false;
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] <= 0);
    }
    //slt
    else if (func == 0x2A)
    {
        if (registers[rs] < registers[rt])
            registers[rd] == 1;

            flags[F_OVERFLOW] = false;
            flags[F_CARRY] = false;
            flags[F_ZERO] = (registers[rd] == 0);
            flags[F_TRUE] = (registers[rd] != 0);
            flags[F_NEGZERO] = (registers[rd] <= 0);
            flags[F_NEG] = (registers[rd] <= 0);
    }
    //jr
    else if (func == 0x08)
    {
        // - 1 por causa do incremento do for
        pc = registers[rs] - 1;

        // Altera flag aqui?
    }
    //div
    else if (func == 0x1A)
    {

        registers[rd] = registers[rs] / registers[rt];

        flags[F_OVERFLOW] = false;
        flags[F_CARRY] = false;
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] <= 0);
    }
    else {
        printf("-------------------------------------\n");
        printf("ERRO!! FUNCTION 0x%02x DESCONHECIDO!!\n", func);
        printf("-------------------------------------\n");
        abort();
    }
}

void decode_i_type(unsigned int instruction, int opcode)
{
    // Identifica os campos da instrução
    int rd = (instruction >> sftRd) & 0x1f;
    int rs = (instruction >> sftRs) & 0x1f;
    int imm = instruction & 0xFFFF;

    printf("%x\n", instruction);
    printf("rd %d rs %d imm %d\n", rd, rs, imm);
    //getchar();

    // lch
    if(opcode == 0x07)
    {
        registers[rd] = (imm << 16) | (registers[rd] & 0xffff);

        flags[F_OVERFLOW] = false;
        flags[F_CARRY] = false;
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] <= 0);
    }
    // jal
    else if(opcode == 0x03)
    {
        // Guarda o endereço da próxima instrução
        registers[7] = pc + 1;

        // Menos um por causa do incremento do for
        pc = registers[rd] - 1;

        // Altera flag aqui?
    }
    // beq
    else if (opcode == 0x04)
    {

        if (registers[rd] == registers[rs])
            pc = imm - 1; // Não decrementa pois seria pc + imm + 1

        // muda flag aqui?
    }
    // bne
    else if (opcode == 0x05)
    {
        if (registers[rd] != registers[rs])
            pc = imm - 1; // Não decrementa pois seria pc + imm + 1

        // muda flag aqui?
    }
    // loadlit
    else if (opcode == 0x06)
    {
        registers[rd] = imm;
    }
    // lcl
    else if (opcode == 0x01)
    {
        registers[rd] = imm | (registers[rd] & 0xffff0000);
    }
    // addi
    else if (opcode == 0x08)
    {
        registers[rd] = registers[rs] + imm;

        flags[F_OVERFLOW] = sum_check_overflow(registers[rs], imm, registers[rd]);
        flags[F_CARRY] = check_carry(registers[rs], imm);
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] <= 0);
    }
    // jt
    else if (opcode == 0x09)
    {
        // rd contém o código da condição
        if (rd == 0x04 && flags[F_NEG]      ||
            rd == 0x05 && flags[F_ZERO]     ||
            rd == 0x06 && flags[F_CARRY]    ||
            rd == 0x07 && flags[F_NEGZERO]  ||
            rd == 0x00 && flags[F_TRUE]    ||
            rd == 0x00 && flags[F_OVERFLOW])
        {
            // Decrementa pra compensar o incremento do for
                pc = imm - 1;
        }
    }
    // jf
    else if (opcode == 0x10)
    {
        // rd contém o código da condição
        if (rd == 0x04 && !flags[F_NEG]      ||
            rd == 0x05 && !flags[F_ZERO]     ||
            rd == 0x06 && !flags[F_CARRY]    ||
            rd == 0x07 && !flags[F_NEGZERO]  ||
            rd == 0x00 && !flags[F_TRUE]    ||
            rd == 0x00 && !flags[F_OVERFLOW])
        {
            // Decrementa pra compensar o incremento do for
                pc = imm - 1;
        }
    }
    // slti
    else if (opcode == 0x0a)
    {
        if (registers[rs] == imm)
            registers[rd] = 1;
    }
    // andi
    else if (opcode == 0x0c)
    {
        registers[rd] = registers[rs] & imm;

        flags[F_OVERFLOW] = false;
        flags[F_CARRY] = false;
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] <= 0);
    }
    // ori
    else if (opcode == 0x0d)
    {
        registers[rd] = registers[rs] | imm;

        flags[F_OVERFLOW] = false;
        flags[F_CARRY] = false;
        flags[F_ZERO] = (registers[rd] == 0);
        flags[F_TRUE] = (registers[rd] != 0);
        flags[F_NEGZERO] = (registers[rd] <= 0);
        flags[F_NEG] = (registers[rd] <= 0);
    }
    // load
    else if (opcode == 0x23)
    {
        registers[rd] = data_mem[registers[rs]];
    }
    // store
    else if (opcode == 0x2b)
    {
        data_mem[registers[rs]] = registers[rd];
    }
}

int decode_j_type(unsigned int instruction, int opcode)
{
    // Identifica os campos da instrução
    int address = (instruction & 0x3FFFFFF);

    printf("%x\n", instruction);
    printf("address %d\n", address);
    //getchar();

    // jump
    if(opcode == 0x02)
    {
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
        fprintf(arq_out, "mem[%d]: %x\n", i, data_mem[i]);
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

    if (op1 < 0) sign_op2 = 1;
    else sign_op2 = 0;

    if (op1 < 0) sign_res = 1;
    else sign_res = 0;

    return ((sign_op1 == sign_op2) == sign_res);
}

bool sub_check_overflow(int op1, int op2, int res)
{
    unsigned int sign_op1;
    unsigned int sign_op2;
    unsigned int sign_res;

    if (op1 < 0) sign_op1 = 1;
    else sign_op1 = 0;

    // inverte por causa da subtração
    if (op1 < 0) sign_op2 = 0;
    else sign_op2 = 1;

    if (op1 < 0) sign_res = 1;
    else sign_res = 0;

    return ((sign_op1 == sign_op2) == sign_res);
}

bool check_carry(unsigned int op1, unsigned int op2)
{
    return ((op2 > 0 && op1 > UINT_MAX - op2) ||
            (op1 > 0) && op2 > UINT_MAX - op1);
}
