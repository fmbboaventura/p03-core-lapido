for(i = 0; i<5; i++){
		for(int j = 0; j<4; j++){
			if(vet[j] > vet[j + 1]){
				aux = vet[j];
				vet[j] = vet[j+1];
				vet[j+1] = aux;
			}
		}
	}
	 			
				;r1 index do primeiro loop
				;r2 index do segundo loop
.module
.pseg

 		lcl r0,LOWBYTE ARR1
        lch r0,HIGHBYTE ARR1
        load r5,r0	;r5 tem o numero de elementos que constituem o array
       	zeros r1, 0 ; index do primeiro loop e zero 
		zeros r7,0 ; sempre 0, utilizado para os ifs
		................................................................................................................................
	   	LOOP1: 
				zeros r2, 0 ; index do segundo loop e zero
				deca r3, r5, 1; numero de elementos menos 1
				_____________________________________________________________________________________________________________
				LOOP2:
						load r10, r0 ; contêm o elemento do index r2 // admite-se que recebe o valor refente ao index?
						addi r11, r10, 1 ; contêm o próximo elemento do index r2, v[r2 +1] 
						slt r12,r10,r11; verifica se o contúdo do index r10 é menor que seu sucessor
						bne  r12, r7, TROCA ; vai para TROCA se r12 <= 0  
						J LOOP2 ;se r12 > r7 elemento do index r1 é menor que elemento de index r2
						
						TROCA:  
								passa r13, r10 ; atribui valor do elemento de r10 a um registrador auxiliar
								passa r10, r11 ; atribui valor do elemento de r11 ao index de r10
								passa r11, r13 ; atribui valor do elemento auxiliar (antigo r10) ao registrador r11
								
				addi r2,r2,1 ; index do primeiro loop e incrementado
				slti r6, r2,r3 ; verifica se r2 é menor que o número de elementos do array menos 1
				beq r6, r7, LOOP2 ; se index for menor que o número de elementos continua LOOP2
				_____________________________________________________________________________________________________________
				addi r1,r1,1 ; index do primeiro loop e incrementado
				slti r6, r1,r5 ; verifica se r1 é menor que o número de elementos do array
				beq r6, r7, LOOP1 ; se index for menor que o número de elementos continua LOOP1			
				J HALT
				.......................................................................................................................
		
		HALT: 
				j HALT
				
.dseg

ARR1:
        .word   5
                .word   8
                .word   9
                .word   3
                .word   5
                .word   1
                
STACK:
.end