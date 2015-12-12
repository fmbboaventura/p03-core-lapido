#include <stdio.h>
#include <stdlib.h>

#define MAX_TAB 100
#define TAM_PALAVRA 9

void AbrirArquivo (FILE **nome_arq, char *caminho_arq, char *modo);
void FecharArquivo (FILE **nome_arq);
void CarregaLabels ();

const int TAM_BUFFER = 255;

/*Definição da struct para label*/
typedef struct
{
   char *txtPalavra;
   int endereco;
} tipo_label;

tipo_label *tbLabels;

int main(){

	FILE *codigo;
	char *nome_arquivo;

    CarregaLabels();
	AbrirArquivo(&codigo, "teste1.asm", "r");

}

/*
 *Abre um arquivo passado como parâmetro
 */
void AbrirArquivo (FILE **arq, char *caminho_arq, char *modo)
{
   *arq = fopen (caminho_arq, modo);
   if (arq != NULL){
   		char buffer[TAM_BUFFER];
   		while(fgets(buffer, TAM_BUFFER, *arq)){
      		//printf("%s", buffer);
      		ParseLine(buffer);
    	}
   }
   else {
      printf ("O arquivo nao pode ser aberto.\n");
   }
   FecharArquivo(arq);
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

void CarregaLabels (){
   int i;
   // Alocacao da tabela de labels
   tbLabels = malloc(sizeof(tipo_label) * MAX_TAB);
   for (i=0; i<MAX_TAB; i++)
      tbLabels[i].txtPalavra = malloc(sizeof(char) * TAM_PALAVRA);
}

void ParseLine (char *line)
{
    char letra;
    int i;
    for(letra = line[i]; line[i] != 0; i++){
        if(isspace(letra))
            continue;
        if(letra == ';')
            return;

    }
    printf("%s\n", line);

}
