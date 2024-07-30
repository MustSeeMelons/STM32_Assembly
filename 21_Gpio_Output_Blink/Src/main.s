// Directives
.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

// AHB2, PA5 is the User Led
.equ RCC_BASE, 				0x40021000
.equ AHB2ENR_OFFSET, 		0x4C

.equ RCC_AHB2_ENR, 			(RCC_BASE + AHB2ENR_OFFSET)

.equ GPIOA_BASE, 			0x48000000
.equ GPIO_A_MODER_OFFSET, 	0x0 // This is true for all GPIOx

.equ GPIO_A_MODER,			(GPIOA_BASE + GPIO_A_MODER_OFFSET)

.equ GPIO_A_EN,				(1 << 0)	// First bit
.equ MODER_5_OUT,			(1 << 10)
.equ MODER_5_RESET,			~(3 << 10)  // Reset bits 10,11
.equ GPIO_A_5_HIGH,			(1 << 5)
.equ GPIO_A_5_LOW,			0

.equ ONE_SEC,				1333333 // 4 Mhz

// .equ GPIO_A_5_LOW,			~(1 << 5)

.equ GPIO_A_ODR_OFFSET,		0x14 // Also true for all GPIOx
.equ GPIO_A_ODR,			(GPIOA_BASE + GPIO_A_ODR_OFFSET)

.section .text
.globl __main // So startup file sees the function

__main:
	// XXX Enable PCLK for GPIOA
	// Point r0 to RCC_AHB1ENR (load address)
	ldr r0,=RCC_AHB2_ENR
	// Load value found at address r0 into r1
	ldr r1, [r0]
	// Perform an OR, result in r1
	orr r1,#GPIO_A_EN
	// Store updated value back
	str r1,[r0]

	// XXX Set PA5 as output
	ldr r0,=GPIO_A_MODER
	ldr r1,[r0]
	and r1,#MODER_5_RESET
	orr r1,#MODER_5_OUT
	str r1,[r0]

	mov r1,#0
	ldr	r2,=GPIO_A_ODR
blink:
	// TODO we are nuking the whole register, shoulb be targeting specific bit instead
	mov r1,#GPIO_A_5_HIGH
	str r1,[r2]
	ldr r3,=ONE_SEC
	bl delay

	mov r1,#GPIO_A_5_LOW
	str r1,[r2]
	ldr r3,=ONE_SEC
	bl delay

	b blink

delay:
	subs r3,r3,#1
	bne delay
	bx lr

.align
.end
