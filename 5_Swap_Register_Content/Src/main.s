// Directives
.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

.section .text
.globl __main // So startup file sees the function

__main:
	ldr r0,=0xBABEFACE
	ldr r1,=0xDEADBEEF

	// Swap registers using exclusive or
	eor r0,r0,r1 // xor r0,r1, store result into r0
	eor r1,r0,r1
	eor r0,r0,r1
stop:
	b stop

.align
.end
