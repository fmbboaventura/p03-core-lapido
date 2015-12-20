#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

// Numero de registradores de propósito geral
#define MAX_REGISTER 16

// Numero de flags
#define MAX_FLAGS 6

// Tamanho máximo da memória
#define MAX_MEM 1000

// Rerotno do decode_j_type caso encontre um halt;
#define HALT 1

// Definindo a posição das flags no vetor
#define ZERO     0
#define NEG      1
#define CARRY    2
#define NEGZERO  3
#define OVERFLOW 4
#define _TRUE    5

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

// Registrador específico para armazenar o pc em uma execução do jal
int reg_jal = 0;

// Função que zera os registradores e flags
void clear_all();

// Lê o arquivo e armazena as palavras em um vetor
// Retorna o numero de palavras lidas
int read_words(FILE **arq, unsigned int *mem);

// Converte uma string com uma sequencia de bits em um numero decimal
unsigned int convert_to_int(char *bit_string);

// Calcula potências de numeros inteiros sem sinal
unsigned int pow_unsig(unsigned int base, unsigned int exp);

// Executa as instruções no array
// ATENÇÂO: não faz distinção entre dados e
// intruções. O código deve conter um halt para
// terminar a execução.
// *mem: array representando a memória
// count_mem: numero de posições válidas no array
// Retorna 0 caso não haja problemas. -1, caso contrário.
int execute(unsigned int *mem, int count_mem);

// Retorna o tipo da instrução
char identify_type(int opcode);

// Decodifica e executa instruções do tipo r
int decode_r_type(unsigned int instruction);

// Decodifica e executa instruções do tipo i
int decode_i_type(unsigned int instruction, int opcode, unsigned int *mem);

// Decodifica e executa instruções do tipo j
int decode_j_type(unsigned int instruction, int opcode);

void write_results(char const *file_name, int exit_code, unsigned int *mem);

int main(int argc, char const *argv[]) {
    int exit_code = 0;
    FILE *arq_mem;
    // Vetor representando a memória
    unsigned int *mem;
    // numero de espaços válidos
    int count_mem;

    char const default_output_file[8] = "res.txt";

    arq_mem = fopen(argv[1], "rt");

    if (arq_mem == NULL)
    {
        printf("Arquivo de instruções não foi aberto!\n");
        return -1;
    }

    mem = malloc(sizeof(int) * MAX_MEM);
    count_mem = read_words(&arq_mem, mem);
    fclose(arq_mem);

    exit_code = execute(mem, count_mem);

    if(argc == 3)
        write_results(argv[argc-1], exit_code, mem);
    else
        write_results(default_output_file, exit_code, mem);

    free(mem);
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

int read_words(FILE **arq, unsigned int *mem)
{
    int i;
    char word[33];

    for (i = 0; (!feof(*arq)); i++)
    {
        fscanf(*arq, "%s", word);
        mem[i] = convert_to_int(word);
    }
    //printf("%d\n", i);
    //getchar();
    return i;
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

int execute(unsigned int *mem, int count_mem)
{
    int opcode;
    int exit_code = 0;
    char type;

    for (pc = 0; pc < count_mem; pc++)
    {
        // Desloca os bits da instrução para achar o opcode
        opcode = mem[pc] >> sftOpcode;
        // Identifica o tipo da instrução
        type = identify_type(opcode);

        if (type == 'r')
        {
            if(decode_r_type(mem[pc]) == -1)
                return -1;
        }
        else if (type == 'i')
        {
            // apenas duas instruções do tipo i acessam a memoria
            if(exit_code = decode_i_type(mem[pc], opcode, mem) == -1)
                return -1;
        }
        else if (type == 'j')
        {
            exit_code = decode_j_type(mem[pc], opcode);
            if(exit_code == HALT)
                return 0;
            else if (exit_code == -1)
                return -1;
        }
        else
        {
            return -1;
        }
    }
    return 0;
}

char identify_type(int opcode)
{
    char result;

    if (opcode == 0x00)
    {
        result == 'r';
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

int decode_r_type(unsigned int instruction)
{
    // Identifica os campos da instrução
    int rd = instruction >> sftRd;
    int rs = instruction >> sftRs;
    int rt = instruction >> sftRt;
    int func = instruction & 0x3F;

    if (rd >= MAX_REGISTER ||
        rs >= MAX_REGISTER ||
        rt >= MAX_REGISTER)
    {
        printf("----------------------------------\n");
        printf("ERRO!! INDICE DO REGISTRADOR >= %d\n", MAX_REGISTER);
        printf("----------------------------------\n");
        return -1;
    }

    // add rd = rs + rt
    if (func == 0x20)
    {
        registers[rd] = registers[rs] + registers[rt];
        // TODO: checar as flags
    }
    //sub e zeros
    else if (func == 0x22)
    {
        registers[rd] = registers[rs] - registers[rt];
    }
    //and
    else if (func == 0x24)
    {
        registers[rd] = registers[rs] & registers[rt];
    }
    //or
    else if (func == 0x25)
    {
        registers[rd] = registers[rs] | registers[rt];
    }
    //not
    else if (func == 0x21)
    {
        registers[rd] = !registers[rs];
    }
    //xor
    else if (func == 0x26)
    {
        registers[rd] = registers[rs] ^ registers[rt];
    }
    //addnota
    else if (func == 0x23)
    {
        registers[rd] = (!registers[rs]) & registers[rt];
    }
    //nor
    else if (func == 0x27)
    {
        registers[rd] = !(registers[rs] | registers[rt]);
    }
    //xnor
    else if (func == 0x28)
    {
        registers[rd] = !(registers[rs] ^ registers[rt]);
    }
    //ornotb
    else if (func == 0x29)
    {
        registers[rd] = registers[rs] | (!registers[rt]);
    }
    //nand
    else if (func == 0x1B)
    {
        registers[rd] = !(registers[rs] & registers[rt]);
    }
    //passa
    else if (func == 0x2B)
    {
        registers[rd] = registers[rs];
    }
    //passnota
    else if (func == 0x2C)
    {
        registers[rd] = !registers[rs];
    }
    //inca
    else if (func == 0x2D)
    {
        registers[rd] = registers[rs] + 1;
    }
    //deca
    else if (func == 0x2E)
    {
        registers[rd] = registers[rs] - 1;
    }
    //addinc
    else if (func == 0x2F)
    {
        registers[rd] = registers[rs] + registers[rt] + 1;
    }
    //subdec
    else if (func == 0x30)
    {
        registers[rd] = registers[rs] - registers[rt] - 1;
    }
    //lsl
    else if (func == 0x00)
    {
        registers[rd] = registers[rs] << 1;
    }
    //lsr
    else if (func == 0x02)
    {
        unsigned int temp = registers[rs] >> 1;
        registers[rd] = temp;
    }
    //asl
    else if (func == 0x04)
    {
        registers[rd] = registers[rs] << 1;
    }
    //asr
    else if (func == 0x03)
    {
        registers[rd] = registers[rs] >> 1;
    }
    //slt
    else if (func == 0x2A)
    {
        if (registers[rs] < registers[rt])
            registers[rd] == 1;
    }
    //jr
    else if (func == 0x08)
    {
        // - 1 por causa do incremento do for
        pc = registers[rs] - 1;
    }
    //div
    else if (func == 0x1A)
    {
        registers[rd] = registers[rs] / registers[rt];
    }
    else {
        printf("-------------------------------------\n");
        printf("ERRO!! FUNCTION 0x%02x DESCONHECIDO!!\n", func);
        printf("-------------------------------------\n");
        return -1;
    }
    return 0;
}

int decode_i_type(unsigned int instruction, int opcode, unsigned int *mem)
{
    // Identifica os campos da instrução
    int rd = instruction >> sftRd;
    int rs = instruction >> sftRs;
    int imm = instruction & 0xFFFF;

    if (rd >= MAX_REGISTER ||
        rs >= MAX_REGISTER)
    {
        printf("----------------------------------\n");
        printf("ERRO!! INDICE DO REGISTRADOR >= %d\n", MAX_REGISTER);
        printf("----------------------------------\n");
        return -1;
    }

    // lch
    if(opcode == 0x07)
    {
        registers[rd] = (imm << 16) | (registers[rd] & 0xffff);
    }
    // jal
    else if(opcode == 0x03)
    {
        // Guarda o endereço da próxima instrução
        reg_jal = pc + 1;

        // Menos um por causa do incremento do for
        pc = registers[rd] - 1;
    }
    // beq
    else if (opcode == 0x04)
    {
        if (registers[rd] == registers[rs])
            pc = pc + imm; // Não decrementa pois seria pc + imm + 1
    }
    // bne
    else if (opcode == 0x05)
    {
        if (registers[rd] != registers[rs])
            pc = pc + imm; // Não decrementa pois seria pc + imm + 1
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
    }
    // jt
    else if (opcode == 0x09)
    {
        // rd contém o código da condição
        if (rd == 0x04 && flags[NEG]      ||
            rd == 0x05 && flags[ZERO]     ||
            rd == 0x06 && flags[CARRY]    ||
            rd == 0x07 && flags[NEGZERO]  ||
            rd == 0x00 && flags[_TRUE]    ||
            rd == 0x00 && flags[OVERFLOW])
        {
            // Decrementa pra compensar o incremento do for
                pc = imm - 1;
        }
    }
    // jf
    else if (opcode == 0x10)
    {
        // rd contém o código da condição
        if (rd == 0x04 && !flags[NEG]      ||
            rd == 0x05 && !flags[ZERO]     ||
            rd == 0x06 && !flags[CARRY]    ||
            rd == 0x07 && !flags[NEGZERO]  ||
            rd == 0x00 && !flags[_TRUE]    ||
            rd == 0x00 && !flags[OVERFLOW])
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
    }
    // ori
    else if (opcode == 0x0d)
    {
        registers[rd] = registers[rs] | imm;
    }
    // load
    else if (opcode == 0x23)
    {
        registers[rd] = mem[registers[rs]];
    }
    // store
    else if (opcode == 0x2b)
    {
        mem[registers[rs]] = registers[rd];
    }
    return 0;
}

int decode_j_type(unsigned int instruction, int opcode)
{
    // Identifica os campos da instrução
    int address = (instruction & 0x3FFFFFF);

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

void write_results(char const *file_name, int exit_code, unsigned int *mem)
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
        fprintf(arq_out, "mem[%d]: %x\n", i, mem[i]);
    }

    fclose(arq_out);
}
