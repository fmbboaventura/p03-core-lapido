#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

// Numero de registradores de propósito geral
#define MAX_REGISTER 16

// Numero de flags
#define MAX_FLAGS 6

// Tamanho máximo da memória
#define MAX_MEM 1000

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

int main(int argc, char const *argv[]) {
    int exit_code = 0;
    FILE *arq_mem;
    // Vetor representando a memória
    unsigned int *mem;

    // numero de espaços válidos
    int count_mem;

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
    char type;

    for (pc = 0; pc < count_mem; pc++)
    {
        // Desloca os bits da instrução para achar o opcode
        opcode = mem[pc] >> sftOpcode;
        // Identifica o tipo da instrução
        type = identify_type(opcode);


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
