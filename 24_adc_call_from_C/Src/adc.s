// Directives
.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

// AHB2, PA5 is the User Led
// AHB2, PC123 is User Button
// PA1 is ADC12_IN6

.equ RCC_BASE, 				0x40021000
.equ RCC_CR_OFFSET,			0x0
.equ RCC_CFGR_OFFSET,		0x08
.equ RCC_CR,				(RCC_BASE + RCC_CR_OFFSET)
.equ RCC_CFGR,				(RCC_BASE + RCC_CFGR_OFFSET)

.equ RCC_CFGR_SW_MSI,		~(3 << 0)   // System clock switch, MSI
.equ RCC_CFGR_SWS,			(0x3 << 2)  // System clock status

// Bit positions
.equ RCC_CR_MSIRGSEL_CR,	(1 << 3)
.equ RCC_CR_MSIRANGE_RESET,	~(0xF << 4)
.equ RCC_CR_MSIRANGE_16MHZ,	(0x8 << 4)

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

.equ MODER_1_OUT_ANALOG,	(3 << 2)
.equ MODER_1_RESET,			~(3 << 2)  // Reset bits 2,3

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

/* ADC (AHB2) Related equ's */
.equ ADC_BASE, 			0x50040000
.equ ADC_1_OFFSET,		0x0
.equ ADC1,				(ADC_BASE + ADC_1_OFFSET)
.equ ADC_PCLK_EN,		(1 << 13)

.equ ADC_ISR_OFFSET,	0x0
.equ ADC1_ISR,			(ADC1 + ADC_ISR_OFFSET)
.equ ADC_ISR_ADRDY,		(1 << 0)

.equ ADC_CR_OFFSET,		0x08
.equ ADC_CR,			(ADC1 + ADC_CR_OFFSET)
.equ ADC_CR_ADSTART,	(1 << 2)
.equ ADC_CR_DEEPPWD, 	~(1 << 29)
.equ ADC_CR_ADVREGEN, 	(1 << 28)

.equ ADC_CFGR_OFFSET,		0x0C
.equ ADC_CFGR,				(ADC1 + ADC_CFGR_OFFSET)
.equ ADC_CFGR_JQDIS_RESET,	~(1 << 31)

.equ ADC_SQR_1_OFFSET,	0x30
.equ ADC_SQR1,			(ADC1 + ADC_SQR_1_OFFSET)
.equ ADC_SQR_L_CLEAR,	~(0xF << 0)
.equ ADC_SQ1_CLEAR,		~(0x1F << 6)
.equ ADC_SQ1,			(1 << 6)
.equ ADC_ENABLE,		(1 << 0)

.equ ADC_CSR_OFFSET,	0x300
.equ ADC_CSR,			(ADC_BASE + ADC_CSR_OFFSET)
.equ ADC_CSR_EOCMST,	(1 << 3)

.equ ADC_CDR_OFFSET,	0x30C
.equ ADC_CDR,			(ADC_BASE + ADC_CDR_OFFSET)

.equ SENS_THRESH,		3000

.section .text
.globl adc_init // So startup file sees the function
.globl led_init
.globl adc_read
.globl led_init
.globl led_control
.globl led_off
.globl led_on
.globl clock_init

clock_init:
	// Lets use MSI
	ldr r0,=RCC_CFGR
	ldr r1,[r0]
	and r1,#RCC_CFGR_SW_MSI
	str r1,[r0]

	// Wait for source to be updated
clock_wait:
	ldr r1,[r0]
	and r1,#RCC_CFGR_SWS

	// 0x0 means MSI as the clock source
	cmp r1,#00
	bne clock_wait

	// Configure MSI
	ldr r0,=RCC_CR
	ldr r1,[r0]

	orr r1,#RCC_CR_MSIRGSEL_CR
	and r1,#RCC_CR_MSIRANGE_RESET
	orr r1,#RCC_CR_MSIRANGE_16MHZ

	str r1,[r0]
	bx lr

adc_init:
	// 1. Enable PCLK to ADC pins GPIO
	ldr r0,=RCC_AHB2_ENR
	ldr r1,[r0]
	orr r1,#GPIO_A_EN
	str r1,[r0]
	// 2. Set ADC pin to analog mode (PA1) [This is the default, just for completeness sake]
	ldr r0,=GPIO_A_MODER
	ldr r1,[r0]
	and r1,#MODER_1_RESET
	orr r1,#MODER_1_OUT_ANALOG
	str r1,[r0]
	// 3. Enable PCLK to ADC
	ldr r0,=RCC_AHB2_ENR
	ldr r1,[r0]
	orr r1,#ADC_PCLK_EN
	str r1,[r0]

	// 3.1 Clear DEEPPWD bit
	ldr r0,=ADC_CR
	ldr r1,[r0]
	and r1,#ADC_CR_DEEPPWD
	str r1,[r0]
	// 3.2 Set ADVREGEN to enable ADC voltage regulator
	ldr r0,=ADC_CR
	ldr r1,[r0]
	orr r1,#ADC_CR_ADVREGEN
	str r1,[r0]

	ldr r0, =0x50000
	delay_loop:
	subs r0, r0, #1
	bne delay_loop

	// 4. Select software trigger for conversion [EXTEN defaults to hardware trigger detection disabled]
	// 5. Set conversion sequence starting channel
	ldr r0,=ADC_SQR1
	ldr r1,[r0]
	and r1,#ADC_SQR_L_CLEAR	// Clear L
	and r1,#ADC_SQ1_CLEAR	// Clear SQ1
	orr r1,#ADC_SQ1			// Set SQ1
	str r1,[r0]
	// 6. Set conversion sequence length. Defaults to 0000 => 1 conversion [Reset in step 5 anyway]
	// Clear the ADRDY bit in ADC_ISR by writing 1
	ldr r0,=ADC1_ISR
	ldr r1,[r0]
	orr r1,#ADC_ISR_ADRDY
	str r1,[r0]
	// 7. Enable ADC module
	ldr r0,=ADC_CR
	ldr r1,[r0]
	orr r1,#ADC_ENABLE
	str r1,[r0]

	// Wait till ADRDY flag is set, XXX it is never set, there is a bug somewhere here
	ldr r0,=ADC1_ISR
enable_loop:
	ldr r1,[r0]
	and r1,#ADC_ISR_ADRDY

	cmp r1,#01
	bne enable_loop

	ldr r0,=ADC1_ISR
	ldr r1,[r0]
	and r1,#ADC_ISR_ADRDY
	str r1,[r0]

	bx lr

adc_read:
	// 1. Start conversion
	ldr r0,=ADC_CR
	ldr r1,[r0]
	orr r1,#ADC_CR_ADSTART
	str r1,[r0]
	// 2. Wait for completion
	read_loop:
		ldr r0,=ADC_CSR
		ldr r1,[r0]
		and r1,#ADC_CSR_EOCMST

		cmp r1,#0x00
		beq read_loop

	// 3. Read contents of ADC register
	ldr r2,=ADC_CDR
	ldr r0,[r0]
	bx lr

led_init:
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
	bx lr

led_control:
	ldr r1,=SENS_THRESH
	cmp r0,r1
	bgt	led_on
	blt	led_off
	bx 	lr

led_off:
	ldr r5,=GPIO_A_BSRR
	mov r1,#GPIO_A5_BSRR_LOW
	str r1,[r5]
	bx lr

led_on:
	ldr r5,=GPIO_A_BSRR
	mov r1,#GPIO_A5_BSRR_HIGH
	str r1,[r5]
	bx lr

stop:
	b stop

.align
.end
