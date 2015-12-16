.module buscabinaria
.pseg

		;Implementacao do algoritmo de busca binária aplicado a um array ordenado
	;Considerando que r15 tem o valor buscado
     	lcl r0,LOWBYTE ARR1
     	lch r0,HIGHBYTE ARR1
LOOP:
     	add r4,r2,r3 ;soma valor de inicio do index pelo valor final
		div r1,r4,2 ;r5 é igual a 2
		beq r15,r1(r0), EXIT; colocar a condição pra verificar se o valor foi encontrado	
		slt r6,r15,r1(r0) ;se o valor de r15 for menor que o valor na posiçao do array armazena 1 em r6  
		jt.true	MENOR; colocar condição para verificar se o valor do index é menor que o valor buscado
		j MAIOR; colocar condição para verificar se o valor do index é maior que o valor buscado
MAIOR: 	
		inca r2,r4,1    ; valor de inicio é incrementado em mais um
		j LOOP
MENOR: 
		deca r3, r4,1
		j LOOP
EXIT:  

.dseg

ARR1:
        .word   10
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
STACK:
.end
