// Directives
.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

.section .text
.globl __main // So startup file sees the function

__main:
	ldr r3,=0xdeadbeef
	ldr r4,=0xbabeface

	push {r3}
	push {r4}

	pop {r5}
	pop {r6}
stop:
	b stop

.align
.end
