.syntax unified
.cpu cortex-m0
.thumb

.equ nvic, 0xe000e100
.equ nvic_icpr, 0x180
.equ int5, 1 << 5

.equ delay, (5000 * 48) / 4

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

.thumb_func
fault_isr:
	b fault_isr

.thumb_func
rad_isr:
	// Clear interrupt
	push {lr}
	bl exti_clear_int0
	// Blink led
	movs r0, #3
	movs r1, #1
	bl gpiob_set_bit
	ldr r2, =delay
delay:
	subs r2, r2, #1
	bne delay
	movs r1, #0
	bl gpiob_set_bit
	pop {pc}

.end
