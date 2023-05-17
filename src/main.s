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
	movs r1, #0
	bl gpiob_set_bit
	// Enable I2C
	bl i2c_enable
	bl i2c_setup
	// LCD setup
	bl lcd_init
	// Hello World
	ldr r0, =hello_world
	movs r1, 12
	bl lcd_write_str
	// Interrupt setup
	bl exti_enable 
	bl exti_link_pa0
	bl timer_setup
	bl timer_start
	movs r5, #0
	movs r6, #0
	movs r7, #0
loop:
	nop
	b loop

hello_world:
	.ascii "Hello World!"

.end
