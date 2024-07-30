// Directives
.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

.section .text
.globl __main // So startup file sees the function

__main:
	ldr r0,=60
	mov r1,#10
	mov r2,#0
top:
	cmp r0,r1

	// Branch to stop if r0 is lower than r1
	blo stop

	sub r0,r0,r1
	add r2,r2,#1
	b	top
stop:
	b stop

.align
.end
