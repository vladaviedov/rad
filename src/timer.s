.syntax unified
.cpu cortex-m0
.thumb

// Locations
.equ rcc, 0x40021000
.equ tim2, 0x40000000

// Offsets
.equ rcc_apb1enr_off, 0x1c
.equ tim2_cr1_off, 0x00
.equ tim2_dier_off, 0x0c
.equ tim2_sr_off, 0x10
.equ tim2_ccmr1_off, 0x18
.equ tim2_arr_off, 0x2c
.equ tim2_cnt_off, 0x24
.equ tim2_ccr1_off, 0x34

// Values
.equ rcc_tim2_en, 1 << 0
.equ tim2_nvic_int, 15
.equ tim2_en, 1 << 0
.equ cc1_int_en, 1 << 1
.equ cc1_output_preload, 1 << 3
.equ cc1if, 1 << 1
.equ target_value, 0x03000000

.global timer_setup
.global timer_start
.global timer_clear_int
.global timer_read

.section .text
/** Public */

/** Setup timer 2
*/
timer_setup:
	push {lr}
	push {r0-r2}
	// Clock enable
	ldr r0, =(rcc + rcc_apb1enr_off)
	ldr r1, =rcc_tim2_en
	ldr r2, [r0]
	orrs r2, r2, r1
	str r2, [r0]
	// Enable CC1 interrupt
	ldr r0, =(tim2 + tim2_dier_off)
	ldr r1, =cc1_int_en
	ldr r2, [r0]
	orrs r2, r2, r1
	str r2, [r0]
	// Set preload
	ldr r0, =(tim2 + tim2_ccr1_off)
	ldr r1, =target_value
	str r1, [r0]
	ldr r0, =(tim2 + tim2_arr_off)
	str r1, [r0]
	// Modify NVIC
	ldr r0, =tim2_nvic_int
	bl nvic_enable_int
	movs r1, #0
	bl nvic_set_priority
	pop {r0-r2}
	pop {pc}

/** Start timer 2
*/
timer_start:
	push {r0-r2}
	ldr r0, =(tim2 + tim2_cr1_off)
	ldr r1, =tim2_en
	ldr r2, [r0]
	orrs r2, r2, r1
	str r2, [r0]
	pop {r0-r2}
	bx lr

/** Clear timer 2 interrupt
*/
timer_clear_int:
	push {r0-r2}
	ldr r0, =(tim2 + tim2_sr_off)
	ldr r1, =cc1if
	mvns r1, r1
	ldr r2, [r0]
	ands r2, r2, r1
	str r2, [r0]
	pop {r0-r2}
	bx lr

/** Private */

.end
