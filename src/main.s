.syntax unified
.cpu cortex-m0
.thumb

// AHBEN offset
.equ ahben_off, 0x14

// RCC
.equ rcc, 0x40021000
.equ ahben, rcc + ahben_off

// GPIO register offsets
.equ mode_off, 0x00
.equ data_off, 0x14

// GPIOA
.equ gpiob, 0x48000400
.equ gpiob_mode, gpiob + mode_off
.equ gpiob_data, gpiob + data_off

// Values
.equ gpiob_en, 0b1 << 18
.equ mode3_out, 0b01 << 6
.equ data3_bit, 0b1 << 3

.global main
.section .text

main:
	bl gpio_en
	bl port3_out
	bl port3_high
loop:
	nop
	b loop

gpio_en:
	ldr r0, =ahben
	ldr r1, =gpiob_en
	// Enable GPIOA
	ldr r2, [r0]
	orrs r2, r1
	str r2, [r0]
	bx lr

port3_out:
	ldr r0, =gpiob_mode
	ldr r1, =mode3_out
	// Set port 0 mode to out
	ldr r2, [r0]
	orrs r2, r1
	str r2, [r0]
	bx lr

port3_high:
	ldr r0, =gpiob_data
	ldr r1, =data3_bit
	// Set port 0 to high
	ldr r2, [r0]
	orrs r2, r1
	str r2, [r0]
	bx lr

port3_low:
	ldr r0, =gpiob_data
	ldr r1, =data3_bit
	// Set port 0 to high
	ldr r2, [r0]
	eors r2, r1
	str r2, [r0]
	bx lr

.end
