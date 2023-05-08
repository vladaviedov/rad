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
	// Hello World
	movs r0, #'H'
	bl lcd_write_char
	movs r0, #'e'
	bl lcd_write_char
	movs r0, #'l'
	bl lcd_write_char
	movs r0, #'l'
	bl lcd_write_char
	movs r0, #'o'
	bl lcd_write_char
	movs r0, #' '
	bl lcd_write_char
	movs r0, #'W'
	bl lcd_write_char
	movs r0, #'o'
	bl lcd_write_char
	movs r0, #'r'
	bl lcd_write_char
	movs r0, #'l'
	bl lcd_write_char
	movs r0, #'d'
	bl lcd_write_char
	movs r0, #'!'
	bl lcd_write_char
	bl exti_enable 
	bl exti_link_pa0
	wfi
loop:
	nop
	b loop

.end
