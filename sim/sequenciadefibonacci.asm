	;Admite-se que r3 possui a quantidade de vezes que será incrementada a sequência
	;Admite-se que r1 e o termo 1
	;Admite-se que r2 e o termo 2
	;r0 é utilizado como index do loop
.module
.pseg
			lcl r10, LOWBYTE ARR1
        	lch r10, HIGHBYTE ARR1
			loadlit r3, 5 ; n-ésimo numero de fibonacci
			;inca r10,r10 ;aponta para o primeiro elemento do array
			loadlit r1, 1 ; inicializa os termos
			loadlit r2, 1
			loadlit r0, 2 ; inicializa o contador do loop
			store r10,r1 ; salva o primeiro termo
			inca r10,r10 ; incrementa o index do array
			store r10,r2 ; salva o segundo termo
			zeros r7    ; para verificação do if
LOOP:
			add r4,r1,r2 ; r4 e um registrador auxiliar
			inca r10,r10 ; incrementa o index do array
			store r10,r4 ; salva o novo termo no array
			passa r1,r2 ; r1 recebe o termo 2 que passa a ser o valor do termo 1
			passa r2,r4 ; r2 recebe o auxiliar que passa a ser o valor do termo 2
			inca r0,r0  ; incrementa o contador do loop
			slt r6, r0,r3 ; verifica se r0 é menor que o número de elementos desejado na sequência
			bne r6, r7, LOOP ; se index for diferente do número de elementos continua LOOP

HALT: j HALT 		 ;r6 é igual a r7 e o número de elementos foi atingido, chegando ao fim

.dseg
ARR1:
	.word 0
.end
