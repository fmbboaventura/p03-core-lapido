#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

// Numero de registradores de propósito geral
#define MAX_REGISTER 16

// Numero de flags
#define MAX_FLAGS 6

// Numero maximo de instruções
#define MAX_INSTRUCTION 1000

// Definindo a posição das flags no vetor
#define ZERO     0
#define NEG      1
#define CARRY    2
#define NEGZERO  3
#define OVERFLOW 4
#define TRUE     5

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

// Função que zera os registradores e flags
void clear_all();

// Lê o arquivo e armazena as instruções em um vetor
// Retorna o numero de instruções lidas
int read_instructions(FILE **arq, unsigned int *instruction);

// Converte uma string com uma sequencia de bits em um numero decimal
unsigned int convert_to_int(char *bit_string);

// Calcula potências de numeros inteiros sem sinal
unsigned int pow_unsig(unsigned int base, unsigned int exp);

// Executa as instruções no array
// *instruction: array com as instruções
// count_instruction: numero de instruções no array
// Retorna 0 caso não haja problemas. -1, caso contrário.
int execute(unsigned int *instruction, int count_instruction);

// Retorna o tipo da instrução
char identify_type(int opcode);

int main(int argc, char const *argv[]) {
    int exit_code = 0;
    FILE *arq_instructions;
    // Vetor contendo as instruções
    unsigned int *instruction;

    // numero de instruções
    int count_instruction;

    arq_instructions = fopen(argv[1], "rt");

    if (arq_instructions == NULL)
    {
        printf("Arquivo de instruções não foi aberto!\n");
        return -1;
    }

    instruction = malloc(sizeof(int) * MAX_INSTRUCTION);
    count_instruction = read_instructions(&arq_instructions, instruction);
    fclose(arq_instructions);

    exit_code = execute(instruction, count_instruction);

    free(instruction);
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

int read_instructions(FILE **arq, unsigned int *instruction)
{
    int i;
    char str_instruction[33];

    for (i = 0; (!feof(*arq)); i++)
    {
        fscanf(*arq, "%s", str_instruction);
        //printf("%s\n", str_instruction);
        instruction[i] = convert_to_int(str_instruction);
        //getchar();
    }
    //printf("%d\n", i);
    //getchar();
    return i;
}

unsigned int convert_to_int(char *bit_string)
{
    int i;
    unsigned int instruction = 0;

    for (i = 0; i < 32; i++)
    {
        if (bit_string[i] == '1')
            instruction += pow_unsig(2, 31 - i);
    }

    return instruction;
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

int execute(unsigned int *instruction, int count_instruction)
{
    int opcode;
    char type;

    for (pc = 0; pc < count_instruction; pc++)
    {
        // Desloca os bits da instrução para achar o opcode
        opcode = instruction[pc] >> sftOpcode;

        printf("0x%02x\n", opcode);
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
    else if (opcode == 0x01 || // lch
             opcode == 0x04 || // beq
             opcode == 0x05 || // bne
             opcode == 0x06 || // loadlit
             opcode == 0x07 || // lch
             opcode == 0x08 || // addi
             opcode == 0x09 || // jt
             opcode == 0x0a || // slti
             opcode == 0x0c || // andi
             opcode == 0x0d || // ori
             opcode == 0x23 || // load
             opcode == 0x2b)   // store
    {
        result = 'i';
    }
    else if (opcode == 0x02 || // j
             opcode == 0x03)   // jal
    {
        result = 'j';
    }
    else
    {
        printf("------------------------\n");
        printf("ERRO!! OPCODE 0x%02x DESCONHECIDO!!\n", opcode);
        printf("------------------------\n");
        result = 'e';
    }

    return result;
}
