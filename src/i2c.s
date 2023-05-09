.syntax unified
.cpu cortex-m0
.thumb

// Locations
.equ rcc, 0x40021000
.equ i2c, 0x40005400

// Offsets
.equ apb1en_off, 0x1c
.equ cr1_off, 0x00
.equ cr2_off, 0x04
.equ timing_off, 0x10
.equ isr_off, 0x18
.equ icr_off, 0x1c
.equ datatx_off, 0x28

// Values
.equ i2c1_en, 0b1 << 21
.equ gpio_mode_alt, 0b10
.equ scl_pin, 9
.equ sda_pin, 10
.equ stopf, 0b1 << 5
.equ nackf, 0b1 << 4

// Masks (AND)
.equ cr1_pe_mask, 0xfffffffe
.equ cr1_filter_mask, 0xffffe0ff
.equ timing_mask, 0x0f00ffff
// Masks (OR)
.equ cr1_pe_on, 0x00000001
.equ cr2_write_byte, 0x02012000
.equ timing_sm, 0x10420f13

.global i2c_enable
.global i2c_setup
.global i2c_write_byte

.section .text
/** Public */

/** Enable Clock for I2C1
*/
i2c_enable:
	push {r0-r2}
	ldr r0, =(rcc + apb1en_off)
	ldr r1, [r0]
	ldr r2, =i2c1_en
	orrs r1, r2
	str r1, [r0]
	pop {r0-r2}
	bx lr

/** Setup I2C pins, timings and settings
*/
i2c_setup:
	push {lr}
	push {r0-r2}
	bl i2c_take_pins
	bl i2c_configure
	pop {r0-r2}
	pop {pc}

/** Write data to I2C
*	Preserves registers
*	r0: addr
*	r1: data
*/
i2c_write_byte:
	push {r0-r4}
	// Write data
	ldr r2, =(i2c + datatx_off)
	movs r3, r1
	str r3, [r2]
	// Set address & initiate write
	ldr r2, =(i2c + cr2_off)
	ldr r3, =cr2_write_byte
	lsls r0, r0, #1
	orrs r3, r3, r0
	movs r4, r3
	str r4, [r2]
	// Wait for stop
	ldr r2, =(i2c + isr_off)
wait:
	ldr r3, [r2]
	ldr r4, =stopf
	ands r3, r3, r4
	beq wait
	// Cleanup CR2
	ldr r2, =(i2c + cr2_off)
	movs r3, #0
	str r3, [r2]
	// Reset flag
	ldr r2, =(i2c + icr_off)
	ldr r3, =stopf
	ldr r4, [r2]
	orrs r4, r4, r3
	str r4, [r2]
	pop {r0-r4}
	bx lr

/** Private */

/** Put I2C pins into alternate mode
*/
i2c_take_pins:
	push {lr}
	// SCL pin
	ldr r0, =scl_pin
	ldr r1, =gpio_mode_alt
	bl gpioa_set_mode
	// SDA pin
	ldr r0, =sda_pin
	ldr r1, =gpio_mode_alt
	bl gpioa_set_mode
	// Debug
	bl af_test
	pop {pc}

/** Configure I2C settings
*/
i2c_configure:
	// Disable for config
	ldr r0, =(i2c + cr1_off)
	ldr r1, =cr1_pe_mask
	ldr r2, [r0]
	ands r2, r2, r1
	str r2, [r0]
	// Enable analog filter only
	ldr r1, =cr1_filter_mask
	ands r2, r2, r1
	str r2, [r0]
	// Configure timing to standard mode
	ldr r0, =(i2c + timing_off)
	ldr r1, =timing_mask
	ldr r2, [r0]
	ands r2, r2, r1
	ldr r1, =timing_sm
	orrs r2, r2, r1
	str r2, [r0]
	// Reenable I2C
	ldr r0, =(i2c + cr1_off)
	ldr r1, =cr1_pe_on
	ldr r2, [r0]
	orrs r2, r2, r1
	str r2, [r0]
	bx lr
