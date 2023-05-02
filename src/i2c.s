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
.equ datatx_off, 0x28

// Values
.equ i2c1_en, 0b1 << 21
.equ gpio_mode_alt, 0b10
.equ scl_pin, 9
.equ sda_pin, 10

// Masks (AND)
.equ cr1_pe_mask, 0xfffffffe
.equ cr1_filter_mask, 0xffffe0ff
.equ timing_mask, 0x0f00ffff
// Masks (OR)
.equ cr1_pe_on, 0x00000001
.equ cr1_filter_analog, 0x00001000
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
	ldr r0, =(rcc + apb1en_off)
	ldr r1, [r0]
	ldr r2, =i2c1_en
	orrs r1, r2
	str r1, [r0]
	bx lr

/** Setup I2C pins, timings and settings
*/
i2c_setup:
	push {lr}
	bl i2c_take_pins
	bl i2c_configure
	pop {pc}

/** Write data to I2C
*	r0: addr
*	r1: data
*/
i2c_write_byte:
	// Write data

	// Set address & initiate write
	ldr r2, =(i2c + cr2_off)
	ldr r3, =cr2_write_byte
	orrs r3, r3, r0
	movs r4, r3
	str r4, [r2]
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
	ldr r1, =cr1_filter_analog
	orrs r2, r2, r1
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
