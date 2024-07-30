// Directives
.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

.section .text
.globl __main // So startup file sees the function

__main:
	ldr r0, =A 	// point r0 to mem location A
	mov r1, #5 	// place 5 into r1
	str r1,[r0]	// store r1 content into memory pointed to by r0

	ldr r0, =D
	mov r1, #4
	str r1, [r0]

	ldr r0, =C
	mov r1, #200
	str r1, [r0]
stop:
	b stop

.section .data
	A: .space 4 // Allocate 4 bytes
	D: .space 4
	C: .space 4

.align
.end
