#include <stdio.h>
#include <stdlib.h>

void AbrirArquivo (FILE **nome_arq, char *caminho_arq, char *modo);
void FecharArquivo (FILE **nome_arq);

const int TAM_BUFFER = 255;

int main(){

	FILE *codigo;
	char *nome_arquivo;

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
      		printf("%s", buffer);
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