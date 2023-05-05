.syntax unified
.cpu cortex-m0
.thumb

.equ addr, 0x27

// Flags
.equ flag_en, 0b00000100
.equ flag_rw, 0b00000010
.equ flag_rs, 0b00000001

// Other
.equ backlight, 0x08

// Commands
.equ clear_display, 0x01
.equ return_home, 0x02
.equ function_set, 0x20

.global lcd_init
.global lcd_write_char

.section .text
/** Public */

/** Initialize LCD display
*/
lcd_init:
	push {lr}
	push {r0}
	ldr r0, =return_home
	bl lcd_write8
	ldr r0, =clear_display
	bl lcd_write8
	ldr r0, =function_set
	bl lcd_write8
	pop {r0}
	pop {pc}

/** Write char to LCD
*	r0: data
*/
lcd_write_char:
	b lcd_write8_rs

/** Private */

/** LCD write of 8 bytes
*	r0: data
*/
lcd_write8:
	push {lr}
	push {r0}
	movs r1, #0xf0
	// Write top 4 bits
	ands r0, r0, r1
	push {r1}
	bl lcd_write4
	pop {r1}
	// Write bottom 4 bits
	pop {r0}
	lsls r0, r0, #4
	ands r0, r0, r1
	bl lcd_write4
	pop {pc}

/** LCD text write of 8 bytes
*	r0: data
*/
lcd_write8_rs:
	push {lr}
	push {r0}
	ldr r2, =flag_rs
	movs r1, #0xf0
	// Write top 4 bits
	ands r0, r0, r1
	orrs r0, r0, r2
	push {r1, r2}
	bl lcd_write4
	pop {r1, r2}
	// Write bottom 4 bits
	pop {r0}
	lsls r0, r0, #4
	ands r0, r0, r1
	orrs r0, r0, r2
	bl lcd_write4
	pop {pc}

/** Standard LCD write of 4 bytes
*	r0: data
*/
lcd_write4:
	push {lr}
	movs r1, r0
	ldr r0, =addr
	// First backlight write
	ldr r2, =backlight
	orrs r1, r1, r2
	bl i2c_write_byte
	// TODO: sleep
	// EN on write
	ldr r2, =flag_en
	orrs r1, r1, r2
	bl i2c_write_byte
	// TODO: sleep
	// EN off write
	mvns r2, r2
	ands r1, r1, r2
	bl i2c_write_byte
	// TODO: sleep
	pop {pc}
