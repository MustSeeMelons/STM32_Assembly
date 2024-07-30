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
	mov r2,#0 			// accumulated sum
loop:
	ldrsb r1,[r0] 		// (sb == signed byte)
	add r2,r2,r1 		// add to accumulator
	add r0,r0,#1 		// move pointer forward
	subs r3,r3,#1 		// reduce counter
	// Branch if not equal to zero
	bne loop

stop:
	b stop

.align
.end
