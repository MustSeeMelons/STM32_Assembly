// Naming a few registers
count	.req r0
max 	.req r1
pointer	.req r2
next	.req r3

mydata: .word 69,87,86,45,75

// Directives
.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

.section .text
.globl __main // So startup file sees the function

__main:
	mov count,#5
	mov max, #0

	// Load mem address of mydata into r2
	ldr	pointer,=mydata
compare:
	// load value at mem address found in r2[pointer] into r3[next]
	ldr next, [pointer]

	// compare max with r3[next] and update condition flags
	cmp max, next

	// branch to ctnu if max is equal or greater than r3[next]
	bhs loop_continue

	mov max, next

loop_continue:
	// Move pointer along to point to the next element
	add pointer, pointer, #4

	// Subtract, store and update flags ('s)
	subs count, count, #1

	bne compare

stop:
	b stop

.align
.end
