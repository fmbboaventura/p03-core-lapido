.module testejal
.pseg
lcl r0, LOWBYTE RETURN
lch r0, HIGHBYTE RETURN
jal r0 ; pula pro ret
nop
EXIT: j EXIT
RETURN: ret
TESTE: nop
.dseg
.end
