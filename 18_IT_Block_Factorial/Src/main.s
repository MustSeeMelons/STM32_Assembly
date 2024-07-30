// Directives
.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

.section .text
.globl __main // So startup file sees the function

__main:
	mov r6,#4
	mov r7,#1
loop:
	cmp r6,#0

	// If r6 is greater than zero, then execute the next 3 instructions [t count mattress!]
	ittt GT
	mulgt r7,r6,r7 // Multiply if r6 is greather than 0
	subgt r6,r6,#1 // Subtract 1 from R6 if r6 is greather than 0
	bgt loop	// Brancg if r6 is greater than 0
stop:
	b stop

.align
.end
