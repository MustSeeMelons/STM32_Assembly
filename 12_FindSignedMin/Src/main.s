// Directives
.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

.section .data

SIGN_DATA: .byte +13,-10,+9,+14,-18,-9,+12,-19,+16

.section .text
.globl __main // So startup file sees the function

__main:
	ldr r0,=SIGN_DATA 	// data pointer
	mov r3,#9 			// counter

	// Assume min value as the first element
	ldrsb r2, [r0]
	add r0,r0,#1
loop:
	ldrsb r1, [r0]
	cmp r1,r2

	// Branch if r1 is greater than r2 (or qual)
	bge next
	mov r2,r1
next:
	add r0,r0,#1
	subs r3,r3,#1

	// Branch if != 0
	bne loop

stop:
	b stop

.align
.end
