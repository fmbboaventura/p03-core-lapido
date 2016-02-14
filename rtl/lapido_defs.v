/***************************************************
 * Module:
 * Project: core_lapido
 * Author:  Filipe Boaventura
 * Description: Arquivo contendo as definicoes de
 * varios aspectios do processador LAPI DOpaCA LAMBA
 ***************************************************/

`define PC_WIDTH       32
`define FLAG_REG_WIDTH 32

/***************** Instrucao NOP *******************/
`define NOP_INSTRUCTION 32'h20000000 // addi r0,r0,0

/**************** Codigo das flags *****************/
`define FL_ZERO     5'b00000
`define FL_TRUE     5'b00001
`define FL_NEG      5'b00010
`define FL_OVERFLOW 5'b00011
`define FL_NEGZERO  5'b00100
`define FL_CARRY    5'b00101

/******************* ALU funct *********************/
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
