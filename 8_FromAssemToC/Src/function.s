// Directives
.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

.section .text
.globl func

func:
	mov r0,#121 // r0 is the return register
	bx lr
	.align
	.end
