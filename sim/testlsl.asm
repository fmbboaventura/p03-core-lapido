.module testei
.pseg
zeros r0
zeros r4
inca r3,r0
store r0,r3
inca r0,r0
store r0,r3
zeros r0
loadlit r1,1
lcl	r2,0
lch	r2,32768
lsl r1,r1
jf.carry L1
store r0,r4
inca r0,r0
L1: lsl r2,r2
jt.carry HALT
store r0,r4
HALT: j HALT
.dseg
.end
