// Directives
.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

// AHB2, PA5 is the User Led
// AHB2, PC123 is User Button

.equ RCC_BASE, 				0x40021000
.equ AHB2ENR_OFFSET, 		0x4C

.equ RCC_AHB2_ENR, 			(RCC_BASE + AHB2ENR_OFFSET)

.equ GPIOA_BASE, 			0x48000000
.equ GPIOC_BASE,			0x48000800
.equ GPIO_MODER_OFFSET, 	0x0 // This is true for all GPIOx

.equ GPIO_A_MODER,			(GPIOA_BASE + GPIO_MODER_OFFSET)
.equ GPIO_C_MODER,			(GPIOC_BASE + GPIO_MODER_OFFSET)

.equ GPIO_A_EN,				(1 << 0)	// First bit
.equ GPIO_C_EN,				(1 << 2)
.equ MODER_5_OUT,			(1 << 10)
.equ MODER_5_RESET,			~(3 << 10)  // Reset bits 10,11

.equ MODER_13_RESET,		~(3 << 26)  // Reset bits 26,27

.equ GPIO_A5_BSRR_HIGH,		(1 << 5)
.equ GPIO_A5_BSRR_LOW,		(1 << 21)

.equ ONE_SEC,				1333333 // 4 Mhz

.equ GPIO_A_BSRR_OFFSET,	0x18
.equ GPIO_A_BSRR,			(GPIOA_BASE + GPIO_A_BSRR_OFFSET)

.equ GPIO_A_ODR_OFFSET,		0x14 // Also true for all GPIOx
.equ GPIO_C_IDR_OFFSET,		0x10
.equ GPIO_A_ODR,			(GPIOA_BASE + GPIO_A_ODR_OFFSET)
.equ GPIO_C_IDR,			(GPIOC_BASE + GPIO_C_IDR_OFFSET)

.equ BTN_ON,	0x0
.equ BTN_OFF,	(1 << 13)
.equ BTN_PIN,	(1 << 13)

.section .text
.globl __main // So startup file sees the function

__main:
	bl gpio_init
loop:
	bl get_input

	cmp r0,#BTN_ON
	beq turn_led_on

	cmp r0,#BTN_OFF
	beq turn_led_off

	b loop

turn_led_off:
	mov r1,#0
	ldr r2,=GPIO_A_BSRR
	mov r1,#GPIO_A5_BSRR_LOW
	str r1,[r2]
	b loop

turn_led_on:
	mov r1,#0
	ldr r2,=GPIO_A_BSRR
	mov r1,#GPIO_A5_BSRR_HIGH
	str r1,[r2]
	b loop

get_input:
	ldr r1,=GPIO_C_IDR
	ldr r0,[r1]
	and r0,r0,#BTN_PIN
	bx lr

gpio_init:
	// Enable PCLK for Port A
	ldr r0,=RCC_AHB2_ENR
	ldr r1,[r0]
	orr r1,#GPIO_A_EN
	str r1,[r0]

	// Set PA5 as output
	ldr r0,=GPIO_A_MODER
	ldr r1,[r0]
	and r1,#MODER_5_RESET
	orr r1,#MODER_5_OUT
	str r1,[r0]

	// Enable PCLK for Port C
	ldr r0,=RCC_AHB2_ENR
	ldr r1,[r0]
	orr r1,#GPIO_C_EN
	str r1,[r0]

	// Set PC13 as input, 00 is input, defaults to 11 (analog)
	ldr r0,=GPIO_C_MODER
	ldr r1,[r0]
	and r1,#MODER_13_RESET
	str r1,[r0]

	bx lr

stop:
	b stop

.align
.end
