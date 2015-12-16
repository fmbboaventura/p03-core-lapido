#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#define MAX_TAB 100
#define TAM_PALAVRA 9

void AbrirArquivo (FILE **nome_arq, char *caminho_arq, char *modo);
void FecharArquivo (FILE **nome_arq);
void CarregaVetorLabels ();
void LabelSalva(char *txtPalavra, int endereco);
void ParseLine();

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
    AbrirArquivo(&codigo, "teste1.asm", "r");
    AbrirArquivo(&saida, "saida.txt", "w");

    IndexarLabels(&codigo);
    rewind(codigo); //coloca o ponteiro do arquivo no inicio do arquivo

    for(i = 0; i < ind_tbLabels; i++)
    {
        printf("%s, %d\n", tbLabels[i].txtPalavra, tbLabels[i].endereco);
    }

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

void IndexarLabels(FILE **arq)
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

void LerLinha (char *linha)
{
    char letra;
    char *palavra;
    int i = 0;
    int tamanhoLinha = strlen(linha);

    if(linha[0] == ';') return;

    if(linha[0] == '.')
    {
        for (i = 0; !isspace(linha[i]); i++);
        palavra = malloc(sizeof(char) * i);
        palavra[i] = '\0';
        strncpy(palavra, linha, i);
        // palavra contém a diretiva
        // guardar em algum lugar

        if (strncmp(".word", palavra, i) != 0)
        {
            lineCount--;
        }
    } else
    {
        for (i = 0; i < tamanhoLinha; i++)
        {
            letra = linha[i];

            if(letra == ':')
            {
                palavra = malloc(sizeof(char) * i);
                palavra[i] = '\0';
                strncpy(palavra, linha, i);
                //printf("%s\n", palavra);

                LabelSalva(palavra, lineCount);

                if(linha[i + 1] == '\n')
                {
                    lineCount--;
                }
            }
        }
    }
    lineCount++;
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

    tam = strlen(txtPalavra);
    while(!feof(entrada)){
        instrucao = 1;

        //VERIFICA COMENTARIO
        for(i=0; i<tam, i++){
            if (palavra[i] == ';')
            {
                /* salta a linha */
                instrucao = 0;
            }
        }

        //VERIFICA SE É LABEL
        for (i=1; i<tam, i++)
        {
            if (palavra[i] == ':')
            {
                instrucao = 0;
                LerLinha(); //chama a função
            }
            /* code */
        }

        //FIM DO CODIGO
        if (strcmp(txtPalavra, ".end") == 0)
            instrucao = 0;

        //AÍ VEM O SEGMENTO DE INSTRUÇÕES
    }

}
