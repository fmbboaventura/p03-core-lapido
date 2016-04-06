.module flags
.pseg
        ; Testa flags
        ;
	; r0 points to ARR1
        LABEL:
        lcl	r0, LOWBYTE ARR1
        lch	r0, HIGHBYTE ARR1
	zeros	r1
	deca	r2,r1
	store	r0,r2
	inca    r0,r0
	store	r0,r2
	inca    r0,r0
	store	r0,r2
	inca    r0,r0
	store	r0,r2
	inca    r0,r0
	store	r0,r2
	inca    r0,r0
	store	r0,r2
	inca    r0,r0
	store	r0,r2
	inca    r0,r0
	store	r0,r2
	deca	r0,r0
	deca	r0,r0
	deca	r0,r0
	deca	r0,r0
	deca	r0,r0
	deca	r0,r0
	deca	r0,r0
	passa	r3,r1 ; se r1 for zero, a flag zero = true
	jt.zero L1
	nop ;VERIFICAR O QUE É
	store	r0,r1
L1:	inca	r0,r0
	passb	r3,r1
	jf.zero L2
	nop
	store	r0,r1
L2:	inca	r0,r0
	zeros	r3
	deca	r3,r3
	inca	r3,r3
	jt.carry L31
	nop
	store	r0,r1
L31:	jf.overflow L3
	nop
	inca	r0,r0
	store	r0,r1
	deca	r0,r0
L3:	inca	r0,r0 ; teste do overflow
	inca	r0,r0
	lcl	r3,65535
	lch	r3,32767
	inca	r3,r3
	jt.overflow L4
	nop
	store	r0,r1
L4:	inca	r0,r0
	asr	r2,r2
        inca    r2,r2
	jt.zero L5
	nop
	store	r0,r1
L5:	inca	r0,r0
        deca    r2,r2
	lcl	r3,0
	lch	r3,32768
    sub  r3,r3,r1
    deca r3,r3
	jt.overflow L6
	nop
	store	r0,r1
L6:	inca	r0,r0
        passnota r2,r2
	jt.zero HALT
	nop
	store	r0,r1
HALT:   j HALT ;VER ESSE AQUI AINDA
        nop

.dseg ;INICIA O SEGMENTO DE DADOS
ARR1:
        .word  0               ; errou flag ZERO 	passa 		(FFFF->0)
        .word  0               ; errou flag ZERO 	passb 		(FFFF->0)
        .word  0               ; errou flag CARRY 	inca 		(FFFF->0)
        .word  0               ; errou flag OVERFLOW 	inca 		(FFFF->0)
        .word  0               ; errou flag OVERFLOW 	inca 		(FFFF->0)
        .word  0               ; errou flag ZERO 	asr+ inca  	(FFFF->0)
        .word  0               ; errou flag OVERFLOW 	subdeca  	(FFFF->0)
        .word  0               ; errou flag ZERO 	passnota  	(FFFF->0)
.end
