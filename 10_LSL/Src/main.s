// Directives
.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

.section .text
.globl __main // So startup file sees the function

__main:
	mov r0, #0x11
	lsl r1, r0, #1 // Left shift by one, store in r1
	lsl r2, r1, #1
stop:
	b stop

.align
.end
