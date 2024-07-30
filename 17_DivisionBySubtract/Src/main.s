// (A + 8B + 7C -27)/4
// A=25,B=19,C=99


// Directives
.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

.section .text
.globl __main // So startup file sees the function

__main:
	mov r0,#25
	mov r1,#19

	// r0 = r0 + 8B
	add r0,r0,r1,lsl #3

	mov r1,#99
	mov r2,#7

	// Add 7C to R0, result in R0
	mla r0,r1,r2,r0
	sub r0,r0,#27

	mov r0,r0,asr #2
stop:
	b stop

.align
.end
