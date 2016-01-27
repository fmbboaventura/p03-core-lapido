;r1 index do primeiro loop
;r2 index do segundo loop
.module
.pseg

 		lcl r0,LOWBYTE ARR1
        lch r0,HIGHBYTE ARR1
        loadlit r5,5	;r5 tem o tamanho do array
       	;zeros r1 ; index do primeiro loop e zero
		zeros r7 ; sempre 0, utilizado para os ifs
		loadlit r8,1 ; sempre 1 para comparação
		deca r3, r5; numero de elementos menos 1
		passa r1, r3;
	   	LOOP1:
				zeros r2 ; index do segundo loop e zero
				LOOP2:
						load r10, r2 ; carrega o elemento do index r2
						inca r4, r2 ; r4 é um rgistrador auxiliar para guardar r2 + 1
						load r11,r4 ; carrega o elemento do index r2 + 1
						;addi r11, r10, 1 ; contêm o próximo elemento do index r2, v[r2 +1]
						slt r12,r11,r10; verifica se o elemento do index r2 é maior que seu sucessor
						bne  r12, r7, TROCA ; vai para TROCA se r12 != 0
				CONT:
						inca r2,r2 ; index do segundo loop e incrementado
						slt r6, r2,r1 ; verifica se o index do segundo loop é menor que o do primeiro
						bne r6, r7, LOOP2 ; se for menor, continua LOOP2
						deca r1,r1 ; index do primeiro loop e incrementado
						slt r6, r1,r8 ; verifica se r1 é maior que 1
						beq r6, r7, LOOP1 ; pula para o LOOP1 se r1 > 1
						beq	r1, r8, LOOP1 ; pula para o LOOP1 se r1 == 1
						j HALT
				TROCA:
						store r2, r11
						store r4, r10
						j CONT
				HALT:
					j HALT

.dseg

ARR1:
                .word   8
                .word   9
                .word   3
                .word   5
                .word   1


.end
