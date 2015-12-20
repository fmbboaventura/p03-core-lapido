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

// Função que zera os registradores e flags
void clear_all();

// Lê o arquivo e armazena as instruções em um vetor
void read_instructions(FILE **arq, unsigned int *instructions);

// Converte uma string com uma sequencia de bits em um numero decimal
unsigned int convert_to_int(char *bit_string);

// Calcula potências de numeros inteiros sem sinal
unsigned int pow_unsig(unsigned int base, unsigned int exp);

int main(int argc, char const *argv[]) {
    FILE *arq_instructions;
    // Vetor contendo as instruções
    unsigned int *instruction;

    arq_instructions = fopen(argv[1], "rt");

    if (arq_instructions == NULL)
    {
        printf("Arquivo de instruções não foi aberto!\n");
        return -1;
    }

    instruction = malloc(sizeof(int) * MAX_INSTRUCTION);
    read_instructions(&arq_instructions, instruction);

    // int i;
    // for (i = 0; i < 52; i++)
    // {
    //     printf("%u\n", instruction[i]);
    // }

    return 0;
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

void read_instructions(FILE **arq, unsigned int *instructions)
{
    int i;
    char str_instruction[33];

    for (i = 0; (!feof(*arq)); i++)
    {
        fscanf(*arq, "%s", str_instruction);
        //printf("%s\n", str_instruction);
        instructions[i] = convert_to_int(str_instruction);
        //getchar();
    }
    //printf("%d\n", i);
    //getchar();
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
