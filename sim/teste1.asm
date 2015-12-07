.module flags
.pseg
        ; Testa flags
        ;       
	; r0 points to ARR1
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
	passa	r3,r1
	jt.zero L1
	nop
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
L3:	inca	r0,r0
	inca	r0,r0
	lcl	r3,255
	lch	r3,127
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
	lch	r3,128
        subdec  r3,r3,r1
	jt.overflow L6
	nop
	store	r0,r1
L6:	inca	r0,r0
        passnota r2,r2
	jt.zero HLT
	nop
	store	r0,r1
HALT:   j HALT
        nop
	;; 
.dseg
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
