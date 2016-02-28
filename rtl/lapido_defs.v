/***************************************************
 * Module:
 * Project: core_lapido
 * Author:  Filipe Boaventura
 * Description: Arquivo contendo as definicoes de
 * varios aspectios do processador LAPI DOpaCA LAMBA
 ***************************************************/

`define PC_WIDTH           32
`define REGISTER_FILE_SIZE 16
`define GPR_WIDTH          32
`define FLAG_REG_WIDTH     32

/***************** Instrucao NOP *******************/
`define NOP_INSTRUCTION 32'h20000000 // addi r0,r0,0

/**************** Codigo das flags *****************/
`define FL_ZERO     5'b00000
`define FL_TRUE     5'b00001
`define FL_NEG      5'b00010
`define FL_OVERFLOW 5'b00011
`define FL_NEGZERO  5'b00100
`define FL_CARRY    5'b00101

/******************** opcode ***********************/
`define OP_R_TYPE 6'h00
`define OP_J_TYPE 6'h02
`define OP_JAL    6'h03
`define OP_LOAD   6'h23
`define OP_STORE  6'h2B
`define OP_BEQ    6'h04
`define OP_BNE    6'h05
`define OP_JT     6'h09
`define OP_JF     6'h10

/******************* funct *********************/
`define FN_ADD  6'h20
`define FN_SUB  6'h22
`define FN_AND  6'h24
`define FN_OR   6'h25
`define FN_NOT  6'h21
`define FN_XOR  6'h26
`define FN_NOR  6'h27
`define FN_XNOR 6'h28
`define FN_NAND 6'h1B
`define FN_LSL  6'h00
`define FN_LSR  6'h02
`define FN_ASL  6'h04
`define FN_ASR  6'h03
`define FN_SLT  6'h2A
`define FN_JR   6'h08

//TODO: Alu op e alu ctrl?

/*************** Sinais de controle ****************/
`define CTRL_LCL 2'b01
`define CTRL_LCH 2'b10
