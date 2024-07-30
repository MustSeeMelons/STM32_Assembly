// Directives
.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

val1 .req r1
val2 .req r2
sum  .req r3

.section .text
.globl __main // So startup file sees the function

__main:
	mov val1,#60
	mov val2,#40

	add sum,val1,val2
stop:
	b stop
	.align
	.end
