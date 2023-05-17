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
.equ set_address, 0x80
.equ cursor_off, 0x0c

.global lcd_init
.global lcd_clear
.global lcd_write_char
.global lcd_write_str
.global lcd_write_num
.global lcd_move_to

.section .text
/** Public */

/** Initialize LCD display
*/
lcd_init:
	push {lr}
	push {r0-r2}
	ldr r0, =return_home
	movs r1, #0
	bl lcd_write8
	ldr r0, =clear_display
	movs r1, #0
	bl lcd_write8
	ldr r0, =function_set
	movs r1, #0
	bl lcd_write8
	ldr r0, =cursor_off
	movs r1, #0
	bl lcd_write8
	pop {r0-r2}
	pop {pc}

/** Clear CLD display
*/
lcd_clear:
	push {lr}
	push {r0-r2}
	ldr r0, =return_home
	movs r1, #0
	bl lcd_write8
	ldr r0, =clear_display
	movs r1, #0
	bl lcd_write8
	pop {r0-r2}
	pop {pc}

/** Write char to LCD
*	r0: char
*/
lcd_write_char:
	push {lr}
	push {r0-r2}
	movs r1, #1
	bl lcd_write8
	pop {r0-r2}
	pop {pc}

/** Write string to LCD
*	r0: string
*	r1: length
*/
lcd_write_str:
	push {lr}
	push {r0-r3}
	movs r2, r0
	movs r3, #0
str_loop:
	subs r1, r1, #1
	blo str_end
	ldrb r0, [r2, r3]
	adds r3, r3, #1
	bl lcd_write_char
	b str_loop
str_end:
	pop {r0-r3}
	pop {pc}

/** Write number to display
*	r0: value
*/
lcd_write_num:
	push {lr}
	push {r0-r4}
	bl num_to_data_arr
	movs r2, r0
num_loop:
	pop {r0}
	movs r1, #1
	push {r2}
	bl lcd_write8
	pop {r2}
	subs r2, r2, #1
	bne num_loop
	pop {r0-r4}
	pop {pc}

/** Move cursor to location
*	r0: location
*/
lcd_move_to:
	push {lr}
	push {r0-r2}
	ldr r1, =set_address
	orrs r1, r1, r0
	movs r0, r1
	movs r1, #0
	bl lcd_write8
	pop {r0-r2}
	pop {pc}

/** Private */

/** LCD write of 8 bytes
*	r0: data
*	r1: rs
*/
lcd_write8:
	push {lr}
	movs r2, #0xf0
	// Write top 4 bits
	push {r0}
	ands r0, r0, r2
	orrs r0, r0, r1
	push {r1, r2}
	bl lcd_write4
	pop {r1, r2}
	// Write bottom 4 bits
	pop {r0}
	lsls r0, r0, #4
	ands r0, r0, r2
	orrs r0, r0, r1
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

/** Convert number to writable characters
*	r0: number
*	Returns:
*	r0: byte count
*/
num_to_data_arr:
	push {lr}
	pop {r4}
	movs r1, #10
	movs r3, #0
recurse:
	adds r3, r3, #1
	bl math_mod
	adds r2, r2, #'0'
	push {r2}
	bl math_div
	movs r0, r2
	bne recurse
	// Done
	movs r0, r3
	bx r4
