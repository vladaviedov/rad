.syntax unified
.cpu cortex-m0
.thumb

// Locations
.equ rcc, 0x40021000
.equ syscfg, 0x40010000
.equ exti, 0x40010400

// Offsets
.equ rcc_apb2enr_off, 0x18
.equ syscfg_exticr1_off, 0x08
.equ exti_imr_off, 0x00
.equ exti_rtsr_off, 0x08
.equ exti_ftsr_off, 0x0c
.equ exti_pr_off, 0x14

// Values
.equ syscfg_en, 1 << 0
.equ exti_gpioa_mask, 0xfffffff0
.equ exti_gpioa_link, 0x0 << 0
.equ exti0, 1 << 0

.global exti_enable
.global exti_link_pa0
.global exti_clear_int0

.section .text
/** Public */

/** Enable EXTI */
exti_enable:
	// Enable Clock for SYSCFG
	ldr r0, =(rcc + rcc_apb2enr_off)
	ldr r1, =syscfg_en
	ldr r2, [r0]
	orrs r2, r2, r1
	str r2, [r0]
	bx lr

exti_link_pa0:
	push {lr}
	// Set A pin for EXTI0
	ldr r0, =(syscfg + syscfg_exticr1_off)	
	ldr r1, =exti_gpioa_mask
	ldr r2, [r0]
	ands r2, r2, r1
	ldr r1, =exti_gpioa_link
	orrs r2, r2, r1
	str r2, [r0]
	// Set GPIO mode and pullups
	movs r0, #0
	movs r1, #0b00
	bl gpioa_set_mode
	movs r0, #0
	movs r1, #0b00
	bl gpioa_set_pupd
	// Enable mask
	ldr r0, =(exti + exti_imr_off)
	ldr r1, =exti0
	ldr r2, [r0]
	orrs r2, r2, r1
	str r2, [r0]
	// Enable falling edge
	ldr r0, =(exti + exti_ftsr_off)
	ldr r2, [r0]
	orrs r2, r2, r1
	str r2, [r0]
	// Disable rising edge
	mvns r1, r1
	ldr r0, =(exti + exti_rtsr_off)
	ldr r2, [r0]
	ands r2, r2, r1
	str r2, [r0]
	// Enable int & set priority
	movs r0, #5
	bl nvic_enable_int
	movs r1, #0b00
	bl nvic_set_priority
	pop {pc}

exti_clear_int0:
	ldr r0, =(exti + exti_pr_off)
	ldr r1, =exti0
	ldr r2, [r0]
	str r1, [r0]
	ldr r2, [r0]
	bx lr

/** Private */

.end
