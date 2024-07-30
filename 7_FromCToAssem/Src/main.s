// Directives
.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

.section .text
.globl __main // So startup file sees the function
.global num
.globl adder

__main:
	ldr r1,=num
	mov r0,#100
	str r0,[r1] // store r0 value into address held by r1

	bl adder
stop:
	b stop

.align
.end
