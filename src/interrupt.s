.syntax unified
.cpu cortex-m0
.thumb

.equ nvic, 0xe000e100
.equ nvic_icpr, 0x180
.equ int5, 1 << 5

.global vtable

.section .text

.org 0x00
vtable:
	.word _stack_end
	.word reset_isr
.org 0x0c
	.word fault_isr
.org 0x54
	.word rad_isr
.org 0xc0

reset_isr:
	ldr r0, =_stack_end
	mov sp, r0
	b main

fault_isr:
	b fault_isr

rad_isr:
	// Clear interrupt
	ldr r0, =(nvic + nvic_icpr)
	ldr r1, =int5
	ldr r2, [r0]
	orrs r2, r2, r1
	str r2, [r0]
	bx lr
	// Do something
	movs r0, #0x27
	movs r1, #'a'
	b i2c_write_byte

.end
