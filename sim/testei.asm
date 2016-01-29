.module testei
.pseg
zeros r0
addi r0,r0,2
addi r0,r0,-3
ori r0,r0,-1
andi r0,r0,0
slti r0,r0,-1
HALT: j HALT
.dseg
.end
