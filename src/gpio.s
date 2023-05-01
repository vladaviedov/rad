.syntax unified
.cpu cortex-m0
.thumb

// Locations
.equ rcc, 0x40021000
.equ gpioa, 0x48000000
.equ gpiob, 0x48000400

// Offsets
.equ ahben_off, 0x14
.equ mode_off, 0x00
.equ data_off, 0x14

// Values
.equ gpioa_en, 0b1 << 17
.equ gpiob_en, 0b1 << 18

.global gpio_enable
.global gpioa_set_mode
.global gpiob_set_mode
.global gpioa_set_bit
.global gpiob_set_bit

.section .text
/** Public */

/**	Enable Clock for GPIOs (A + B)
*/
gpio_enable:
	ldr r0, =(rcc + ahben_off)
	ldr r1, [r0]
	ldr r2, =gpioa_en
	orrs r1, r2
	ldr r2, =gpiob_en
	orrs r1, r2
	str r1, [r0]
	bx lr

/**	Set mode for a GPIOA pin
*	r0: port
*	r1: value
*/
gpioa_set_mode:
	ldr r2, =(gpioa + mode_off)
	push {lr}
	bl gpio_set_mode
	pop {pc}

/**	Set mode for a GPIOA pin
*	r0: port
*	r1: value
*/
gpiob_set_mode:
	ldr r2, =(gpiob + mode_off)
	push {lr}
	bl gpio_set_mode
	pop {pc}

/**	Set bit for a GPIOA pin
*	r0: port
*	r1: value
*/
gpioa_set_bit:
	ldr r2, =(gpioa + data_off)
	push {lr}
	bl gpio_set_bit
	pop {pc}

/** Set bit for GPIOB pin
*	r0: port
*	r1: value
*/
gpiob_set_bit:
	ldr r2, =(gpiob + data_off)
	push {lr}
	bl gpio_set_bit
	pop {pc}

/** Private */

/** Set mode for GPIO
*	r0: port
*	r1: value
*	r2: reg_addr
*/
gpio_set_mode:
	// Compute bit masks
	movs r4, #2
	muls r0, r0, r4
	movs r4, #0b11
	lsls r4, r4, r0
	mvns r4, r4
	lsls r1, r1, r0
	// Set bit
	ldr r3, [r2]
	ands r3, r3, r4
	orrs r3, r3, r1
	str r3, [r2]
	bx lr

/** Set mode for GPIO
*	r0: port
*	r1: value
*	r2: reg_addr
*/
gpio_set_bit:
	// Compute bit masks
	movs r4, #0b1
	lsls r4, r4, r0
	mvns r4, r4
	lsls r1, r1, r0
	// Set bit
	ldr r3, [r2]
	ands r3, r3, r4
	orrs r3, r3, r1
	str r3, [r2]
	bx lr
