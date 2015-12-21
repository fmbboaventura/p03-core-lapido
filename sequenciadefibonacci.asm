 for(i = 0; i < n; i++)
  {
    auxiliar = a + b;
    a = b;
    b = auxiliar;
 
    // Imprimo o número na tela.
    printf("%d\n", auxiliar);
  }

	;Admite-se que r1 possui a quantidade de vezes que será incrementada a sequência
	;Admite-se que r2 e o termo 1
	;Admite-se que r3 e o termo 2
	;r0 é utilizado como index do loop
.module
.pseg
			zeros r0, 0 ; contador do loop é zerado
LOOP: 
			add r4,r2,r3 ; r4 e um registrador auxiliar 
			passa r2,r3 ; r2 recebe o termo 2 que passa a ser o valor do termo 1
			passa r3,r4 ; r3 recebe o auxiliar que passa a ser o valor do termo 2
			zeros r7,0 ; verificação do if
			addi r0,r0,1 ; incrementa o contador do loop
			slt r6, r0,r1 ; verifica se r0 é menor que o número de elementos desejado na sequência
			bne r6, r7, LOOP ; se index for diferente do número de elementos continua LOOP1			
			j HALT ; r6 é igual a r7 e o número delementos foi atingido, chegando ao fim			
HALT: j HALT 				
.end
