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
void ParseLine();
void Traducao();
void CriaTabelas(FILE *entrada);
void Add();

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
    AbrirArquivo(&codigo, "teste2.asm", "r");
    AbrirArquivo(&saida, "saida.txt", "w");

    CriaTabelas(codigo);

    for(i = 0; i < ind_tbLabels; i++)
    {
        printf("%s, %d\n", tbLabels[i].txtPalavra, tbLabels[i].endereco);
    }

    //IndexarLabels(&codigo);
    rewind(codigo); //coloca o ponteiro do arquivo no inicio do arquivo

    Traducao(codigo, saida);



    FecharArquivo(&codigo);
    FecharArquivo(&saida);
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

void Palavra_Ler_Arquivo(FILE *entrada, char **palavra)
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
    char letra;
    fscanf(entrada, "%c", &letra);
    while (letra != '\n')
        fscanf(entrada, "%c", &letra);
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

    int ra, rb, rc;
    unsigned int binario;

    palavra = malloc(sizeof(char) * TAM_LINHA);
    p = malloc(sizeof(char) * 3);
    p[0] = malloc(sizeof(char) * TAM_LINHA);
    p[1] = malloc(sizeof(char) * TAM_LINHA);
    p[2] = malloc(sizeof(char) * TAM_LINHA);

    Palavra_Ler_Arquivo(entrada, &palavra);
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

        if (palavra[0] == '.')
        {
            //printf("%s\n", palavra);
            instrucao = 0;
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
            printf("%s\n", palavra);
            //printf("INSTRUCAO\n");
            pc ++;
            binario = 0;
            if (strcmp(palavra, "add") == 0)
            {
                Palavra_Ler_Arquivo(entrada, &p[0]);
                Palavra_Ler_Arquivo(entrada, &p[1]);
                Palavra_Ler_Arquivo(entrada, &p[2]);
                rc = strtol(&p[0][1], NULL, 10);
                ra = strtol(&p[1][1], NULL, 10);
                rb = strtol(&p[2][1], NULL, 10);

                // põe o opcode no inicio da instrução
                binario = 0x00 << 26;

                // concatena com o registrador restino
                binario = binario | (rc << 21);

                // concatena com os registradores fonte
                binario = binario | (ra << 16);
                binario = binario | (rb << 11);

                // concatena com o function
                binario = binario | 0x20;
                /* code */
                //Add(ra, rb, rc, &binario);
                fprintf(saida, "%032d\n", binario);
            }
            else if (strcmp(palavra, "addinc") == 0)
            {
                Palavra_Ler_Arquivo(entrada, &p[0]);
                Palavra_Ler_Arquivo(entrada, &p[1]);
                Palavra_Ler_Arquivo(entrada, &p[2]);
                rc = strtol(&p[0][1], NULL, 10);
                ra = strtol(&p[1][1], NULL, 10);
                rb = strtol(&p[2][1], NULL, 10);

                // põe o opcode no inicio da instrução
                binario = 0x00 << 26;
                // concatena com o registrador restino
                binario = binario | (rc << 21);
                // concatena com os registradores fonte
                binario = binario | (ra << 16);
                binario = binario | (rb << 11);
                // concatena com o function
                binario = binario | 0x2F;
                /* code */
            }
            else if (strcmp(palavra, "deca") == 0)
            {
                Palavra_Ler_Arquivo (entrada, &p[0]);
                Palavra_Ler_Arquivo (entrada, &p[1]);
                rc = strtol(&p[0][1], NULL, 10);
                ra = strtol(&p[1][1], NULL, 10);

                // põe o opcode no inicio da instrução
                binario = 0x00 << 26;
                // concatena com o registrador restino
                binario = binario | (rc << 21);
                // concatena com os registradores fonte
                binario = binario | (ra << 16);
                // concatena com o function
                binario = binario | 0x2E;
            }
        }
        Palavra_Ler_Arquivo(entrada, &palavra);
        tam = strlen(palavra);
    }

}

void CriaTabelas(FILE *entrada){
    char *palavra, *label, *diretiva;
    int tam, i, num_instrucoes = 0;
    char instrucao, leia;
    int linhaCount = 1;

    palavra = malloc(sizeof(char) * TAM_LINHA);
    label = malloc(sizeof(char) * TAM_LINHA);

    for (i=0; i<TAM_LINHA; i++)
        palavra[i] = ' ';
    palavra[TAM_LINHA] = '\0';

    Palavra_Ler_Arquivo (entrada, &palavra);
    while(!feof(entrada))
    {
        leia = 1;
        instrucao = 1;
        tam = strlen(palavra);

        for (i=0; i<tam; i++)
        {
            if (palavra[i] == ';')
            {
                Linha_Saltar(entrada);
                linhaCount++;
                instrucao = 0;
            }
        }

        for (i = 1; i < tam; ++i)
        {
            if (palavra[i] == ':')
            {
                linhaCount++;
                palavra[i] = '\0';
                strcpy(label, palavra);
                LabelSalva(label, linhaCount);
                instrucao = 0;
                break;
            }
        }

        if(palavra[0] == '.')
        {
            // palavra contém a diretiva
            if (strcmp(".word", palavra) != 0)
            {
                // Diretivas, excerto .word,
                // Não contam como linha de código
                lineCount--;
            }
            //Linha_Saltar(entrada);
            linhaCount++;
            instrucao = 0;
        }

        if (instrucao)
         {
            Linha_Saltar(entrada);
            linhaCount++;
         }
        Palavra_Ler_Arquivo (entrada, &palavra);
    }
}

