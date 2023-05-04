.syntax unified
.cpu cortex-m0
.thumb

.global main

.section .text

main:
	// Light on-board LED
	bl gpio_enable
	// Set GPIOB port 3 to out
	movs r0, #3
	movs r1, #0b01
	bl gpiob_set_mode
	// Set GPIOB port 3 to high
	movs r0, #3
	movs r1, #1
	bl gpiob_set_bit
	// Enable I2C
	bl i2c_enable
	bl i2c_setup
	// LCD setup
	bl lcd_init
	movs r0, #'c'
	bl lcd_write_char
loop:
	nop
	b loop

.end
