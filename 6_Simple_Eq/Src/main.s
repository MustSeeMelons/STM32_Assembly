// Solving P = Q + R + S
// Q = 2, R = 4, S = 5

.equ Q, 2
.equ R, 4
.equ S, 5

// Directives
.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

.section .text
.globl __main // So startup file sees the function

__main:
	mov r1, #Q
	mov r2, #R
	mov r3, #S

	add r0,r1,r2
	add r0,r0,r3
stop:
	b stop

.align
.end
