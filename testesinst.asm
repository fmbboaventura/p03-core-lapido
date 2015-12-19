.module instrucoes

.pseg

	add r0,r1,r2
	sub r0,r1,r2
	zeros r0
	and r0,r1,r2
	or r0,r1,r2
	not r0,r1
	xor r0,r1,r2
	addnota r0,r1,r2
	nor r0,r1,r2
	xnor r0,r1,r2
	ornotb r0,r1,r2
	nand r0,r1,r2
	passa r0,r1
	passnota r0,r1
	inca r0,r1
	deca r0,r1
	addinc r0,r1,r2
	subdec r0,r1,r2
	lsl r0,r1
	lsr r0,r1
	asl r0,r1
	asr r0,r1
	slt r0,r1,r2
	jr r0
	div r0,r1,r2
	addi r0,r1,168
	andi r0,r1,168
	ori r0,r1,168
	slti r0,r1,168
	beq r0,r1,168
	bne r0,r1,168
	loadlit r0,168
	lch r0,168
	lcl r0,168
	load r0,r1
	store r0,r1
	jal r6
	jt.neg FIM
	jt.zero FIM
	jt.carry FIM
	jt.negzero FIM
	jt.true FIM
	jt.overflow FIM
	jf.neg FIM
	jf.zero FIM
	jf.carry FIM
	jf.negzero FIM
	jf.true FIM
	jf.overflow FIM
FIM: j FIM
	nop
.dseg
NADA:
.end
