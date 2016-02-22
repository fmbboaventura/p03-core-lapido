.module buscabinaria
.pseg

		;Implementacao do algoritmo de busca binária aplicado a um array ordenado
		;Considerando que r15 tem o valor buscado
     	lcl r0,LOWBYTE ARR1
     	lch r0,HIGHBYTE ARR1 ; r0 contém o limite inferior do array
		loadlit r14,10 ; r14 contém o tamanho do array
		deca r1,r14 ; r1 contém o limite superior do array
		loadlit r15,31
		zeros r13     ; r13 comtém 0 para comparações
LOOP:
     	add r4,r0,r1 ;soma os limites...
		asr r4,r4    ;... e divide por 2 para achar o meio
		load  r3,r4; carrega em r3 o elemento do meio
		beq r15,r3, EXIT ; salta pro fim caso tenha encontrado o valor desejado
		slt r6,r15,r3 ;se o valor de r15 for menor que o valor na posiçao do array armazena 1 em r6
		beq r6,r13 MAIOR ; colocar condição para verificar se o valor do index é menor que o valor buscado
		j MENOR ; colocar condição para verificar se o valor do index é maior que o valor buscado
CONT:
		slt r7,r0,r1 ; r7 = 1 se r0 < r1
		bne r7,r13,LOOP
		beq	r0,r1,LOOP
		loadlit r4,-1
		j EXIT
MAIOR:
		inca r0,r4
		j CONT
MENOR:
		deca r1, r4
		j CONT
EXIT:  	j EXIT

.dseg

ARR1:
                .word   1
                .word   3
                .word   5
                .word   6
                .word   9
                .word   12
                .word   15
                .word   20
                .word   25
                .word   30
.end
