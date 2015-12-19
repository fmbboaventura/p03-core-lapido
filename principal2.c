#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#define MAX_TAB 100
#define TAM_PALAVRA 9
#define TAM_LINHA 80

void AbrirArquivo (FILE **nome_arq, char *caminho_arq, char *modo);
void FecharArquivo (FILE **nome_arq);
void CarregaVetorLabels ();
void LabelSalva(char *txtPalavra, int endereco);
void Traducao();
void CriaTabelas(FILE *entrada);
void EscreveBinario(unsigned int instrucao, FILE *saida);

const int TAM_BUFFER = 255;

/*Definição da struct para label*/
typedef struct
{
    char *txtPalavra;
    int endereco;
} tipo_label;



tipo_label *tbLabels;
int lineCount = 1;
int ind_tbLabels = 0;

int main()
{
    int i;
    FILE *codigo;
    FILE *saida;
    char *nome_arquivo;

    CarregaVetorLabels();
    AbrirArquivo(&codigo, "testesinst.asm", "r");
    AbrirArquivo(&saida, "saida.txt", "w");

    CriaTabelas(codigo);

    for(i = 0; i < ind_tbLabels; i++)
    {
        printf("%s, %d\n", tbLabels[i].txtPalavra, tbLabels[i].endereco);
    }

    //IndexarLabels(&codigo);
    rewind(codigo); //coloca o ponteiro do arquivo no inicio do arquivo
    Traducao(codigo, saida);
    printf("Traducao concluida\n");
    getchar();
    FecharArquivo(&codigo);
    FecharArquivo(&saida);
    exit(0);
}

/*
 *Abre um arquivo passado como parâmetro
 */
void AbrirArquivo (FILE **arq, char *caminho_arq, char *modo)
{
    if (!((*arq) = fopen (caminho_arq, modo)))
   {
      printf ("O arquivo nao pode ser aberto.\n");
      exit (0);
   }
}

/*
 *Fecha o arquivo especificado
 */
void FecharArquivo (FILE **arq)
{
    if (fclose (*arq))
    {
        printf ("O arquivo nao pode ser fechado.\n");
    }
}

void CarregaVetorLabels ()
{
    int i;
    // Alocacao da tabela de labels
    tbLabels = malloc(sizeof(tipo_label) * MAX_TAB);
    for (i=0; i<MAX_TAB; i++)
        tbLabels[i].txtPalavra = malloc(sizeof(char) * TAM_PALAVRA);
}

/*void IndexarLabels(FILE **arq)
{
    int i;
    if (arq != NULL)
    {
        char buffer[TAM_BUFFER];
        while(fgets(buffer, TAM_BUFFER, *arq))
        {
            // Pega a linha a partir do primeiro caractere
            // que não é um espaço
            for(i = 0; isspace(buffer[i]); i++);
            //printf("%s\n", &buffer[i]);
            LerLinha(&buffer[i]);
            //ParseLine(buffer, &lineCount);
        }
    }
}

/*void LerLinha (char *linha)
{
    char letra;
    char *palavra;
    int i = 0;
    int tamanhoLinha = strlen(linha);

    // Se a linha começa com ;, ignore
    if(linha[0] == ';') return;

    // Verifica se é diretiva
    if(linha[0] == '.')
    {
        for (i = 0; !isspace(linha[i]); i++);
        palavra = malloc(sizeof(char) * i);
        palavra[i] = '\0';
        strncpy(palavra, linha, i);
        // palavra contém a diretiva

        if (strncmp(".word", palavra, i) != 0)
        {
            // Diretivas, excerto .word,
            // Não contam como linha de código
            lineCount--;
        }
    } else // caso contrário, examina a linha para extrair
    {      // labels ou campos das instruções
        for (i = 0; i < tamanhoLinha; i++)
        {
            // Lê a linha caractere por caractere
            letra = linha[i];

            // Se achou um label
            if(letra == ':')
            {
                palavra = malloc(sizeof(char) * i);
                palavra[i] = '\0';
                strncpy(palavra, linha, i);

                // Salva o label no endereço atual
                LabelSalva(palavra, lineCount);

                // Se o label estiver sozinho na linha
                // não conte seu endereço
                if(linha[i + 1] == '\n')
                {
                    lineCount--;
                }

                // ######## detectar a instrução #######
            }
        }
    }
    // Incrementa o endereço da instrução
    lineCount++;
}*/

void LerPalavra(FILE *entrada, char **palavra)
{
    char letra;
    int index = 0;

    fscanf(entrada, "%c", &letra);
    while (isspace(letra))
    {
        if (feof(entrada))
            return;
        fscanf(entrada, "%c", &letra);
    }
    while ((!isspace(letra)) && (letra != ','))
    {
        if (feof(entrada))
            return;
        (*palavra)[index] = letra;
        index ++;
        fscanf(entrada, "%c", &letra);
    }
    (*palavra)[index] = '\0';
}

void Linha_Saltar (FILE *entrada)
{
    //printf("saltou linha\n");
    char letra;
    fscanf(entrada, "%c", &letra);
    //printf("%d %c\n", letra, letra);
    while (letra != '\n')
    {
        fscanf(entrada, "%c", &letra);
        //printf("%d %c\n", letra, letra);
    }
}

//*txtPalavra = nome da LABEL
//endereço = endereço de memória da LABEL
void LabelSalva(char *txtPalavra, int endereco)
{
    strcpy(tbLabels[ind_tbLabels].txtPalavra, txtPalavra);
    tbLabels[ind_tbLabels].endereco = endereco;
    ind_tbLabels ++;
}

void Traducao(FILE *entrada, FILE *saida){
    int tam, i, pc = 0;
    char instrucao, leia, ok;
    char *palavra;
    char **p;

    int ra, rb, rc, c;
    unsigned int binario;

    int sftOpcode = 26;
    int sftRd = 21;
    int sftRs = 16;
    int sftRt = 11;
    int shamt = 6; // Não use o shamt por enquanto

    palavra = malloc(sizeof(char) * TAM_LINHA);
    p = malloc(sizeof(char) * 3);
    p[0] = malloc(sizeof(char) * TAM_LINHA);
    p[1] = malloc(sizeof(char) * TAM_LINHA);
    p[2] = malloc(sizeof(char) * TAM_LINHA);

    LerPalavra(entrada, &palavra);
    tam = strlen(palavra);
    while(!feof(entrada))
    {
        instrucao = 1;

        //VERIFICA COMENTARIO
        for(i=0; i<tam; i++)
        {
            if (palavra[i] == ';')
            {
                //printf("Comentario\n");
                Linha_Saltar(entrada);
                /* salta a linha */
                instrucao = 0;
            }
        }

        //VERIFICA SE É LABEL
        for (i=1; i<tam; i++)
        {
            if (palavra[i] == ':')
            {
                //printf("LABEL\n");
                instrucao = 0;
                //LerLinha(); //chama a função
            }
            /* code */
        }

        // Se for diretiva e não for uma declaração de constante
        if (palavra[0] == '.')
        {
            //printf("%s\n", palavra);
            instrucao = 0;
            if (strcmp(palavra, ".word") == 0) {
              printf("constante\n");
              LerPalavra (entrada, &p[0]);
              c = strtol(&p[0][0], NULL, 10);
              printf("%d\n", c);
              EscreveBinario(c, saida);
            }
        }

        //FIM DO CODIGO
        if (strcmp(palavra, ".end") == 0)
        {
            //printf("FIM DO CODIGO\n");
            instrucao = 0;
        }

        //AÍ VEM O SEGMENTO DE INSTRUÇÕES
        if (instrucao)
        {
            //printf("%s\n", palavra);
            //printf("INSTRUCAO\n");
            pc ++;
            binario = 0;
            if (strcmp(palavra, "add") == 0)
            {
                LerPalavra(entrada, &p[0]);
                LerPalavra(entrada, &p[1]);
                LerPalavra(entrada, &p[2]);
                rc = strtol(&p[0][1], NULL, 10);
                ra = strtol(&p[1][1], NULL, 10);
                rb = strtol(&p[2][1], NULL, 10);

                // põe o opcode no inicio da instrução
                binario = 0x00 << sftOpcode;

                // concatena com o registrador restino
                binario = binario | (rc << sftRd);

                // concatena com os registradores fonte
                binario = binario | (ra << sftRs);
                binario = binario | (rb << sftRt);

                // concatena com o function
                binario = binario | 0x20;
                //Add(ra, rb, rc, &binario);
                //fprintf(saida, "%x\n", binario);
				        EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "addinc") == 0)
            {
                LerPalavra(entrada, &p[0]);
                LerPalavra(entrada, &p[1]);
                LerPalavra(entrada, &p[2]);
                rc = strtol(&p[0][1], NULL, 10);
                ra = strtol(&p[1][1], NULL, 10);
                rb = strtol(&p[2][1], NULL, 10);

                // põe o opcode no inicio da instrução
                binario = 0x00 << sftOpcode;
                // concatena com o registrador restino
                binario = binario | (rc << sftRd);
                // concatena com os registradores fonte
                binario = binario | (ra << sftRs);
                binario = binario | (rb << sftRt);
                // concatena com o function
                binario = binario | 0x2F;
				        EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "deca") == 0)
            {
                LerPalavra (entrada, &p[0]);
                LerPalavra (entrada, &p[1]);
                rc = strtol(&p[0][1], NULL, 10);
                ra = strtol(&p[1][1], NULL, 10);

                // põe o opcode no inicio da instrução
                binario = 0x00 << sftOpcode;
                // concatena com o registrador restino
                binario = binario | (rc << sftRd);
                // concatena com os registradores fonte
                binario = binario | (ra << sftRs);
                // concatena com o function
                binario = binario | 0x2E;
				        EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "inca") == 0)
            {
                LerPalavra (entrada, &p[0]);
                LerPalavra (entrada, &p[1]);
                rc = strtol(&p[0][1], NULL, 10);
                ra = strtol(&p[1][1], NULL, 10);

                // põe o opcode no inicio da instrução
                binario = 0x00 << sftOpcode;
                // concatena com o registrador restino
                binario = binario | (rc << sftRd);
                // concatena com os registradores fonte
                binario = binario | (ra << sftRs);
                // concatena com o function
                binario = binario | 0x2D;
				        EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "sub") == 0)
            {
                LerPalavra (entrada, &p[0]);
                LerPalavra (entrada, &p[1]);
                LerPalavra (entrada, &p[2]);
                rc = strtol(&p[0][1], NULL, 10);
                ra = strtol(&p[1][1], NULL, 10);
                rb = strtol(&p[2][1], NULL, 10);

                binario = 0x00 << sftOpcode;
                binario = binario | (rc << sftRd);
                binario = binario | (ra << sftRs);
                binario = binario | (rb << sftRt);
                binario = binario | 0x22;
				        EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "subdec") == 0)
            {
                LerPalavra (entrada, &p[0]);
                LerPalavra (entrada, &p[1]);
                LerPalavra (entrada, &p[2]);
                rc = strtol(&p[0][1], NULL, 10);
                ra = strtol(&p[1][1], NULL, 10);
                rb = strtol(&p[2][1], NULL, 10);

                binario = 0x00 << sftOpcode;
                binario = binario | (rc << sftRd);
                binario = binario | (ra << sftRs);
                binario = binario | (rb << sftRt);
                binario = binario | 0x30;
				        EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "and") == 0)
            {
                LerPalavra (entrada, &p[0]);
                LerPalavra (entrada, &p[1]);
                LerPalavra (entrada, &p[2]);
                rc = strtol(&p[0][1], NULL, 10);
                ra = strtol(&p[1][1], NULL, 10);
                rb = strtol(&p[2][1], NULL, 10);

                binario = 0x00 << sftOpcode;
                binario = binario | (rc << sftRd);
                binario = binario | (ra << sftRs);
                binario = binario | (rb << sftRt);
                binario = binario | 0x24;
				        EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "andnota") == 0)
            {
                LerPalavra (entrada, &p[0]);
                LerPalavra (entrada, &p[1]);
                LerPalavra (entrada, &p[2]);
                rc = strtol(&p[0][1], NULL, 10);
                ra = strtol(&p[1][1], NULL, 10);
                rb = strtol(&p[2][1], NULL, 10);

                binario = 0x00 << sftOpcode;
                binario = binario | (rc << sftRd);
                binario = binario | (ra << sftRs);
                binario = binario | (rb << sftRt);
                binario = binario | 0x23;
				        EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "nand") == 0)
            {
                LerPalavra (entrada, &p[0]);
                LerPalavra (entrada, &p[1]);
                LerPalavra (entrada, &p[2]);
                rc = strtol(&p[0][1], NULL, 10);
                ra = strtol(&p[1][1], NULL, 10);
                rb = strtol(&p[2][1], NULL, 10);

                binario = 0x00 << sftOpcode;
                binario = binario | (rc << sftRd);
                binario = binario | (ra << sftRs);
                binario = binario | (rb << sftRt);
                binario = binario | 0x2A;
				        EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "nor") == 0)
            {
                LerPalavra (entrada, &p[0]);
                LerPalavra (entrada, &p[1]);
                LerPalavra (entrada, &p[2]);
                rc = strtol(&p[0][1], NULL, 10);
                ra = strtol(&p[1][1], NULL, 10);
                rb = strtol(&p[2][1], NULL, 10);

                binario = 0x00 << sftOpcode;
                binario = binario | (rc << sftRd);
                binario = binario | (ra << sftRs);
                binario = binario | (rb << sftRt);
                binario = binario | 0x27;
				        EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "or") == 0)
            {
                LerPalavra (entrada, &p[0]);
                LerPalavra (entrada, &p[1]);
                LerPalavra (entrada, &p[2]);
                rc = strtol(&p[0][1], NULL, 10);
                ra = strtol(&p[1][1], NULL, 10);
                rb = strtol(&p[2][1], NULL, 10);

                binario = 0x00 << sftOpcode;
                binario = binario | (rc << sftRd);
                binario = binario | (ra << sftRs);
                binario = binario | (rb << sftRt);
                binario = binario | 0x25;
				        EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "ornotb") == 0)
            {
                LerPalavra (entrada, &p[0]);
                LerPalavra (entrada, &p[1]);
                LerPalavra (entrada, &p[2]);
                rc = strtol(&p[0][1], NULL, 10);
                ra = strtol(&p[1][1], NULL, 10);
                rb = strtol(&p[2][1], NULL, 10);

                binario = 0x00 << sftOpcode;
                binario = binario | (rc << sftRd);
                binario = binario | (ra << sftRs);
                binario = binario | (rb << sftRt);
                binario = binario | 0x29;
				        EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "xor") == 0)
            {
                LerPalavra (entrada, &p[0]);
                LerPalavra (entrada, &p[1]);
                LerPalavra (entrada, &p[2]);
                rc = strtol(&p[0][1], NULL, 10);
                ra = strtol(&p[1][1], NULL, 10);
                rb = strtol(&p[2][1], NULL, 10);

                binario = 0x00 << sftOpcode;
                binario = binario | (rc << sftRd);
                binario = binario | (ra << sftRs);
                binario = binario | (rb << sftRt);
                binario = binario | 0x26;
				        EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "xnor") == 0)
            {
                LerPalavra (entrada, &p[0]);
                LerPalavra (entrada, &p[1]);
                LerPalavra (entrada, &p[2]);
                rc = strtol(&p[0][1], NULL, 10);
                ra = strtol(&p[1][1], NULL, 10);
                rb = strtol(&p[2][1], NULL, 10);

                binario = 0x00 << sftOpcode;
                binario = binario | (rc << sftRd);
                binario = binario | (ra << sftRs);
                binario = binario | (rb << sftRt);
                binario = binario | 0x28;
				        EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "asl") == 0)
            {
                LerPalavra (entrada, &p[0]);
                LerPalavra (entrada, &p[1]);
                rc = strtol(&p[0][1], NULL, 10);
                ra = strtol(&p[1][1], NULL, 10);

                binario = 0x00 << sftOpcode;
                binario = binario | (rc << sftRd);
                binario = binario | (ra << sftRs);
                binario = binario | 0x04;
                EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "asr") == 0)
            {
                LerPalavra (entrada, &p[0]);
                LerPalavra (entrada, &p[1]);
                rc = strtol(&p[0][1], NULL, 10);
                ra = strtol(&p[1][1], NULL, 10);

                binario = 0x00 << sftOpcode;
                binario = binario | (rc << sftRd);
                binario = binario | (ra << sftRs);
                binario = binario | 0x03;
                EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "lsl") == 0)
            {
                LerPalavra (entrada, &p[0]);
                LerPalavra (entrada, &p[1]);
                rc = strtol(&p[0][1], NULL, 10);
                ra = strtol(&p[1][1], NULL, 10);

                binario = 0x00 << sftOpcode;
                binario = binario | (rc << sftRd);
                binario = binario | (ra << sftRs);
                binario = binario | 0x00;
                EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "lsr") == 0)
            {
                LerPalavra (entrada, &p[0]);
                LerPalavra (entrada, &p[1]);
                rc = strtol(&p[0][1], NULL, 10);
                ra = strtol(&p[1][1], NULL, 10);

                binario = 0x00 << sftOpcode;
                binario = binario | (rc << sftRd);
                binario = binario | (ra << sftRs);
                binario = binario | 0x02;
                EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "passa") == 0)
            {
                LerPalavra (entrada, &p[0]);
                LerPalavra (entrada, &p[1]);
                rc = strtol(&p[0][1], NULL, 10);
                ra = strtol(&p[1][1], NULL, 10);

                binario = 0x00 << sftOpcode;
                binario = binario | (rc << sftRd);
                binario = binario | (ra << sftRs);
                binario = binario | 0x2B;
                EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "passanota") == 0)
            {
                LerPalavra (entrada, &p[0]);
                LerPalavra (entrada, &p[1]);
                rc = strtol(&p[0][1], NULL, 10);
                ra = strtol(&p[1][1], NULL, 10);

                binario = 0x00 << sftOpcode;
                binario = binario | (rc << sftRd);
                binario = binario | (ra << sftRs);
                binario = binario | 0x2C;
                EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "zeros") == 0)
            {
                LerPalavra (entrada, &p[0]);
                rc = strtol(&p[0][1], NULL, 10);
                // Implementa o zeros como um sub rc,rc,rc
                ra = rc;
                rb = rc;

                binario = 0x00 << sftOpcode;
                binario = binario | (rc << sftRd);
                binario = binario | (rc << sftRs);
                binario = binario | (rc << sftRt);
                binario = binario | 0x22;
                EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "not") == 0)
            {
                LerPalavra (entrada, &p[0]);
                LerPalavra (entrada, &p[1]);
                rc = strtol(&p[0][1], NULL, 10);
                ra = strtol(&p[1][1], NULL, 10);

                binario = 0x00 << sftOpcode;
                binario = binario | (rc << sftRd);
                binario = binario | (ra << sftRs);
                binario = binario | 0x21;
                EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "slt") == 0)
            {
                LerPalavra (entrada, &p[0]);
                LerPalavra (entrada, &p[1]);
                LerPalavra (entrada, &p[2]);
                rc = strtol(&p[0][1], NULL, 10);
                ra = strtol(&p[1][1], NULL, 10);
                rb = strtol(&p[2][1], NULL, 10);

                binario = 0x00 << sftOpcode;
                binario = binario | (rc << sftRd);
                binario = binario | (ra << sftRs);
                binario = binario | (rb << sftRt);
                binario = binario | 0x2A;
                EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "div") == 0)
            {
                LerPalavra (entrada, &p[0]);
                LerPalavra (entrada, &p[1]);
                LerPalavra (entrada, &p[2]);
                rc = strtol(&p[0][1], NULL, 10);
                ra = strtol(&p[1][1], NULL, 10);
                rb = strtol(&p[2][1], NULL, 10);

                binario = 0x00 << sftOpcode;
                binario = binario | (rc << sftRd);
                binario = binario | (ra << sftRs);
                binario = binario | (rb << sftRt);
                binario = binario | 0x1A;
                EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "jr"))
            {
                LerPalavra (entrada, &p[0]);
                rc = strtol(&p[0][1], NULL, 10);

                binario = 0x00 << sftOpcode;
                binario = binario | (rc << sftRd);
                binario = binario | 0x22;
                EscreveBinario(binario, saida);
            }
            //TERMNA O TIPO R

            //COMEÇA O TIPO I
            if (strcmp(palavra, "addi") == 0)
            {
                LerPalavra (entrada, &p[0]);
                LerPalavra (entrada, &p[1]);
                LerPalavra (entrada, &p[2]);
                rc = strtol(&p[0][1], NULL, 10);
                ra = strtol(&p[1][1], NULL, 10);
                c = strtol(&p[2][1], NULL, 10);

                binario = 0x08 << sftOpcode;
                binario = binario | (rc << sftRd);
                binario = binario | (ra << sftRs);
                if(c > 0xFFFF) exit(-1);
                binario = binario | c;

                EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "andi") == 0)
            {
                LerPalavra (entrada, &p[0]);
                LerPalavra (entrada, &p[1]);
                LerPalavra (entrada, &p[2]);
                rc = strtol(&p[0][1], NULL, 10);
                ra = strtol(&p[1][1], NULL, 10);
                c = strtol(&p[2][1], NULL, 10);

                binario = 0x0C << sftOpcode;
                binario = binario | (rc << sftRd);
                binario = binario | (ra << sftRs);
                if(c > 0xFFFF) exit(-1);
                binario = binario | c;

                EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "ori") == 0)
            {
                LerPalavra (entrada, &p[0]);
                LerPalavra (entrada, &p[1]);
                LerPalavra (entrada, &p[2]);
                rc = strtol(&p[0][1], NULL, 10);
                ra = strtol(&p[1][1], NULL, 10);
                c = strtol(&p[2][1], NULL, 10);

                binario = 0x0D << sftOpcode;
                binario = binario | (rc << sftRd);
                binario = binario | (ra << sftRs);
                if(c > 0xFFFF) exit(-1);
                binario = binario | c;

                EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "slti") == 0)
            {
                LerPalavra (entrada, &p[0]);
                LerPalavra (entrada, &p[1]);
                LerPalavra (entrada, &p[2]);
                rc = strtol(&p[0][1], NULL, 10);
                ra = strtol(&p[1][1], NULL, 10);
                c = strtol(&p[2][1], NULL, 10);

                binario = 0x0A << sftOpcode;
                binario = binario | (rc << sftRd);
                binario = binario | (ra << sftRs);
                if(c > 0xFFFF) exit(-1);
                binario = binario | c;

                EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "beq") == 0 )
            {
                LerPalavra (entrada, &p[0]);
                LerPalavra (entrada, &p[1]);
                LerPalavra (entrada, &p[2]);
                rc = strtol(&p[0][1], NULL, 10);
                ra = strtol(&p[1][1], NULL, 10);
                c = strtol(&p[2][1], NULL, 10);

                binario = 0x04 << sftOpcode;
                binario = binario | (rc << sftRd);
                binario = binario | (ra << sftRs);
                bool label = false;
                int i;

                for (i = 0; i < MAX_TAB; i++)
                {
                    if (strcmp(p[2], tbLabels[i].txtPalavra) == 0)
                    {
                        binario = binario | tbLabels[i].endereco;
                        label = true;
                        break;
                    }
                }
                if (!label)
                    binario = binario | c;
                EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "bne") == 0 )
            {
                LerPalavra (entrada, &p[0]);
                LerPalavra (entrada, &p[1]);
                LerPalavra (entrada, &p[2]);
                rc = strtol(&p[0][1], NULL, 10);
                ra = strtol(&p[1][1], NULL, 10);
                c = strtol(&p[2][1], NULL, 10);

                binario = 0x05 << sftOpcode;
                binario = binario | (rc << sftRd);
                binario = binario | (ra << sftRs);
                bool label = false;
                int i;

                for (i = 0; i < MAX_TAB; i++)
                {
                    if (strcmp(p[2], tbLabels[i].txtPalavra) == 0)
                    {
                        binario = binario | tbLabels[i].endereco;
                        label = true;
                        break;
                    }
                }
                if (!label)
                    binario = binario | c;
                EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "loadlit") == 0) //SEE
            {
                LerPalavra (entrada, &p[0]);
                LerPalavra (entrada, &p[1]);
                rc = strtol(&p[0][1], NULL, 10);
                c = strtol(&p[1][1], NULL, 10);

                binario = 0x08 << sftOpcode;
                binario = binario | (rc << sftRd);
                if(c > 0xFFFF) exit(-1);
                binario = binario | c;

                EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "lch") == 0)
            {
                LerPalavra (entrada, &p[0]);
                rc = strtol(&p[0][1], NULL, 10);
                LerPalavra (entrada, &p[1]);

        				bool highbyte = false;
                        if (strcmp(p[1], "HIGHBYTE") == 0)
        				{
                            LerPalavra (entrada, &p[1]);
        					highbyte = true;
        				}

                binario = 0x07 << sftOpcode;
                binario = binario | (rc << sftRd);

                //printf("%s\n", p[1]);

                char label = 0;
                int i;
                for (i = 0; i < MAX_TAB; i++)
                {
                    if (strcmp(p[1], tbLabels[i].txtPalavra) == 0)
                    {
                        label = 1;
                        break;
                    }
                }
                if(label)
        				{
        					if(highbyte)
                            	binario = binario | ((tbLabels[i].endereco) >> 16);
        					else
        						binario = binario | tbLabels[i].endereco;
        				}
                        else
        				{
        					if(highbyte)
                            	binario = binario | ((strtol(p[1], NULL, 10)) >> 16);
        					else
        						binario = binario | strtol(p[1], NULL, 10);
        				}
                EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "lcl") == 0)
            {
                LerPalavra (entrada, &p[0]);
                rc = strtol(&p[0][1], NULL, 10);
                LerPalavra (entrada, &p[1]);
        				bool lowbyte = false;
                        if (strcmp(p[1], "LOWBYTE") == 0)
        				{
                            LerPalavra (entrada, &p[1]);
        					lowbyte = true;
        				}

                binario = 0x08 << sftOpcode;
                binario = binario | (rc << sftRd);

                //printf("%s\n", p[1]);

                char label = 0;
                int i;
                for (i = 0; i < MAX_TAB; i++)
                {
                    if (strcmp(p[1], tbLabels[i].txtPalavra) == 0)
                    {
                        label = 1;
                        break;
                    }
                }
                if(label)
        				{
        					if(lowbyte)
                            	binario = binario | ((tbLabels[i].endereco) & 0xFFFF);
        					else
        						binario = binario | tbLabels[i].endereco;
        				}
                else
        				{
        					if(lowbyte)
                            	binario = binario | ((strtol(p[1], NULL, 10)) & 0xFFFF);
        					else
        						binario = binario | strtol(p[1], NULL, 10);
        				}
                EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "jt.neg") == 0)
            {
                int i;
                char label = 0;

                binario = 0x09 << sftOpcode;
                binario = binario | (0x04 << sftRd);
                LerPalavra(entrada, &p[0]);
                c = strtol(&p[0][1], NULL, 10);
                if(c > 0xFFFF)
                    exit -1;
                for (i = 0; i < MAX_TAB; i++)
                {
                    if (strcmp(p[0], tbLabels[i].txtPalavra) == 0)
                    {
                        binario = binario | (tbLabels[i].endereco);
                        label = 1;
                        break;
                    }
                }
                if (label)
                    binario = binario | c;
                EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "jt.zero") == 0)
            {
                int i;
                char label = 0;

                binario = 0x09 << sftOpcode;
                binario = binario | (0x05 << sftRd);
                LerPalavra(entrada, &p[0]);
                c = strtol(&p[0][1], NULL, 10);
                if(c > 0xFFFF)
                    exit -1;
                for (i = 0; i < MAX_TAB; i++)
                    {
                        if (strcmp(p[0], tbLabels[i].txtPalavra) == 0)
                        {
                            binario = binario | (tbLabels[i].endereco);
                            label = 1;
                            break;
                        }
                    }
                if(label)
                    binario = binario | c;
                EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "jt.carry") == 0)
            {
                int i;
                char label = 0;

                binario = 0x09 << sftOpcode;
                binario = binario | (0x06 << sftRd);
                LerPalavra(entrada, &p[0]);
                c = strtol(&p[0][1], NULL, 10);
                if(c > 0xFFFF)
                    exit -1;
                for (i = 0; i < MAX_TAB; i++)
                    {
                        if (strcmp(p[0], tbLabels[i].txtPalavra) == 0)
                        {
                            binario = binario | (tbLabels[i].endereco);
                            label = 1;
                            break;
                        }
                    }
                if(label)
                    binario = binario | c;
                EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "jt.negzero") == 0)
            {
                int i;
                char label = 0;

                binario = 0x09 << sftOpcode;
                binario = binario | (0x07 << sftRd);
                LerPalavra(entrada, &p[0]);
                c = strtol(&p[0][1], NULL, 10);
                if(c > 0xFFFF)
                    exit -1;
                for (i = 0; i < MAX_TAB; i++)
                    {
                        if (strcmp(p[0], tbLabels[i].txtPalavra) == 0)
                        {
                            binario = binario | (tbLabels[i].endereco);
                            label = 1;
                            break;
                        }
                    }
                if(label)
                    binario = binario | c;
                EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "jt.true") == 0)
            {
                int i;
                char label = 0;

                binario = 0x09 << sftOpcode;
                binario = binario | (0x00 << sftRd);
                LerPalavra(entrada, &p[0]);
                c = strtol(&p[0][1], NULL, 10);
                if(c > 0xFFFF)
                    exit -1;
                for (i = 0; i < MAX_TAB; i++)
                    {
                        if (strcmp(p[0], tbLabels[i].txtPalavra) == 0)
                        {
                            binario = binario | (tbLabels[i].endereco);
                            label = 1;
                            break;
                        }
                    }
                if(label)
                    binario = binario | c;
                EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "jt.overflow") == 0)
            {
                int i;
                char label = 0;

                binario = 0x09 << sftOpcode;
                binario = binario | (0x03 << sftRd);
                LerPalavra(entrada, &p[0]);
                c = strtol(&p[0][1], NULL, 10);
                if(c > 0xFFFF)
                    exit -1;
                for (i = 0; i < MAX_TAB; i++)
                    {
                        if (strcmp(p[0], tbLabels[i].txtPalavra) == 0)
                        {
                            binario = binario | (tbLabels[i].endereco);
                            label = 1;
                            break;
                        }
                    }
                if (label)
                    binario = binario | c;
                EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "jf.neg") == 0)
            {
                int i;
                char label = 0;

                binario = 0x10 << sftOpcode;
                binario = binario | (0x04 << sftRd);
                LerPalavra(entrada, &p[0]);
                c = strtol(&p[0][1], NULL, 10);
                if(c > 0xFFFF)
                    exit -1;
                for (i = 0; i < MAX_TAB; i++)
                    {
                        if (strcmp(p[0], tbLabels[i].txtPalavra) == 0)
                        {
                            binario = binario | (tbLabels[i].endereco);
                            label = 1;
                            break;
                        }
                    }
                if(label)
                    binario = binario | c;
                EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "jf.zero") == 0)
            {
                int i;
                char label = 0;

                binario = 0x10 << sftOpcode;
                binario = binario | (0x05 << sftRd);
                LerPalavra(entrada, &p[0]);
                c = strtol(&p[0][1], NULL, 10);
                if(c > 0xFFFF)
                    exit -1;
                for (i = 0; i < MAX_TAB; i++)
                    {
                        if (strcmp(p[0], tbLabels[i].txtPalavra) == 0)
                        {
                            binario = binario | (tbLabels[i].endereco);
                            label = 1;
                            break;
                        }
                    }
                if(label)
                    binario = binario | c;
                EscreveBinario(binario, saida);;
            }
            else if (strcmp(palavra, "jf.carry") == 0)
            {
                int i;
                char label = 0;

                binario = 0x10 << sftOpcode;
                binario = binario | (0x06 << sftRd);
                LerPalavra(entrada, &p[0]);
                c = strtol(&p[0][1], NULL, 10);
                if(c > 0xFFFF)
                    exit -1;
                for (i = 0; i < MAX_TAB; i++)
                    {
                        if (strcmp(p[0], tbLabels[i].txtPalavra) == 0)
                        {
                            binario = binario | (tbLabels[i].endereco);
                            label = 1;
                            break;
                        }
                    }
                if(label)
                    binario = binario | c;
                EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "jf.negzero") == 0)
            {
                int i;
                char label = 0;

                binario = 0x10 << sftOpcode;
                binario = binario | (0x07 << sftRd);
                LerPalavra(entrada, &p[0]);
                c = strtol(&p[0][1], NULL, 10);
                if(c > 0xFFFF)
                    exit -1;
                for (i = 0; i < MAX_TAB; i++)
                    {
                        if (strcmp(p[0], tbLabels[i].txtPalavra) == 0)
                        {
                            binario = binario | (tbLabels[i].endereco);
                            label = 1;
                            break;
                        }
                    }
                if(label)
                    binario = binario | c;
                EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "jf.true") == 0)
            {
                int i;
                char label = 0;

                binario = 0x10 << sftOpcode;
                binario = binario | (0x00 << sftRd);
                LerPalavra(entrada, &p[0]);
                c = strtol(&p[0][1], NULL, 10);
                if(c > 0xFFFF)
                    exit -1;
                for (i = 0; i < MAX_TAB; i++)
                    {
                        if (strcmp(p[0], tbLabels[i].txtPalavra) == 0)
                        {
                            binario = binario | (tbLabels[i].endereco);
                            label = 1;
                            break;
                        }
                    }
                if(label)
                    binario = binario | c;
                EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "jf.overflow") == 0)
            {
                int i;
                char label = 0;

                binario = 0x10 << sftOpcode;
                binario = binario | (0x03 << sftRd);
                LerPalavra(entrada, &p[0]);
                c = strtol(&p[0][1], NULL, 10);
                if(c > 0xFFFF)
                    exit -1;
                for (i = 0; i < MAX_TAB; i++)
                    {
                        if (strcmp(p[0], tbLabels[i].txtPalavra) == 0)
                        {
                            binario = binario | (tbLabels[i].endereco);
                            label = 1;
                            break;
                        }
                    }
                if(label)
                    binario = binario | c;
                EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "load") == 0)
            {
                LerPalavra (entrada, &p[0]);
                LerPalavra (entrada, &p[1]);
                //LerPalavra (entrada, &p[2]);
                rc = strtol(&p[0][1], NULL, 10);
                ra = strtol(&p[1][1], NULL, 10);
                //c = strtol(&p[2][1], NULL, 10);
                //printf("%s\n", p[2]);
                binario = 0x23 << sftOpcode;
                binario = binario | (rc << sftRd);
                binario = binario | (ra << sftRs);
                EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "store") == 0)
            {
                LerPalavra (entrada, &p[0]);
                LerPalavra (entrada, &p[1]);
                //LerPalavra (entrada, &p[2]);
                rc = strtol(&p[0][1], NULL, 10);
                ra = strtol(&p[1][1], NULL, 10);
                //c = strtol(&p[2][1], NULL, 10);
                //printf("%s\n", p[2]);
                binario = 0x2B << sftOpcode;
                binario = binario | (rc << sftRd);
                binario = binario | (ra << sftRs);
                EscreveBinario(binario, saida);
            }
            //TIPO J
            //JUMP INCONDICIONAL
            else if (strcmp(palavra, "j") == 0)
            {
                int i;

                LerPalavra (entrada, &p[0]);
                for (i = 0; i < MAX_TAB; i++)
                {
                    if (strcmp(p[0], tbLabels[i].txtPalavra) == 0)
                        break;
                }

                binario = 0x02 << sftOpcode;
                binario = binario | ((tbLabels[i].endereco) << sftRd);

                EscreveBinario(binario, saida);
                //COMO TRATAR HALT AQUI?
            }
            else if (strcmp(palavra, "jal") == 0)
            {
                LerPalavra (entrada, &p[0]);
                rc = strtol(&p[0][1], NULL, 10);

                binario = 0x03 << sftOpcode;
                binario = binario | (rc << sftRd);
                EscreveBinario(binario, saida);
            }
            else if (strcmp(palavra, "nop") == 0)
            {
                // Implementando o nop como um addi r0,r0,0
                rc = 0;
                ra = rc;
                c = 0;

                binario = 0x08 << sftOpcode;
                binario = binario | (rc << sftRd);
                binario = binario | (ra << sftRs);
                binario = binario | c;
                EscreveBinario(binario, saida);
            }

        //fprintf(saida, "%x\n", binario);
        }
        LerPalavra(entrada, &palavra);
        tam = strlen(palavra);
        //printf("%s\n", palavra);
    }
}


void EscreveBinario(unsigned int instrucao, FILE *saida)
{
	unsigned int max = 0x80000000;
    int i;
    int bit;

    for (i = 0; i < 32; i++)
    {
        if(instrucao >= max) bit = 1;
        else bit = 0;
        //printf("instrução %d, bit %d", instrucao, bit);
        //getchar();
        instrucao = instrucao << 1;
        fprintf(saida, "%d", bit);
    }
    fprintf(saida, "\n");
}

void CriaTabelas(FILE *entrada){
    char *palavra, *label, *diretiva;
    int tam, i, num_instrucoes = 0;
    char instrucao, leia;
    int linhaCount = 0;

    palavra = malloc(sizeof(char) * TAM_LINHA);
    label = malloc(sizeof(char) * TAM_LINHA);

    for (i=0; i<TAM_LINHA; i++)
        palavra[i] = ' ';
    palavra[TAM_LINHA] = '\0';

    LerPalavra (entrada, &palavra);
    while(!feof(entrada))
    {
        leia = 1;
        instrucao = 1;
        tam = strlen(palavra);

        //printf("%s %d\n", palavra, linhaCount);
        //getchar();

        for (i=0; i<tam; i++)
        {
            //SE FOR COMENTARIO
            if (palavra[i] == ';')
            {
                Linha_Saltar(entrada);
                //linhaCount++;
                instrucao = 0;
            }
        }

        for (i = 1; i < tam; ++i)
        {
            //SE FOR LABEL
            if (palavra[i] == ':')
            {
                //linhaCount++;
                //printf("%s\n", palavra);
                //getchar();
                // if(palavra[i] != '\n')
                // {
                //     printf("Label na mesma linha do código\n");
                //     lineCount++;
                // }
                // else
                // {
                //     printf("Label sozinho na linha\n" );
                // }
                palavra[i] = '\0';
                //PEGA A SAIDA DA FUNÇÃO LERPALAVRA QUANDO ACHA A LABEL, E SALVA
                strcpy(label, palavra);
                LabelSalva(label, linhaCount);
                instrucao = 0;
                break;
            }
        }

        if(palavra[0] == '.')
        {
            // palavra contém a diretiva
            if (strcmp(".word", palavra) == 0)
            {
                // Diretivas, excerto .word,
                // Não contam como linha de código
                lineCount++;
            }
            else if (strcmp(".module", palavra) == 0)
            {
                Linha_Saltar(entrada);
            }
            instrucao = 0;
        }
        //SE FOR INSTRUÇÃO, DESCONSIDERA E PULA A LINHA, JA QUE AGENTE SÓ QUER LABELS
        if (instrucao)
         {
            if(strcmp("nop", palavra) != 0)
              Linha_Saltar(entrada);
            linhaCount++;
         }
         //LÊ MAIS UMA PALAVRA
        LerPalavra (entrada, &palavra);
    }
}
