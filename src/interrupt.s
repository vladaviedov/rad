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

.thumb_func
fault_isr:
	b fault_isr

.thumb_func
rad_isr:
	push {lr}
	movs r0, #3
	movs r1, #1
	cmp r2, r1
	beq off
	// Turn on
	push {r0, r1, r2}
	bl gpiob_set_bit
	pop {r0, r1, r2}
	movs r2, #1
	pop {pc}
off:
	// Turn off
	movs r1, #0
	push {r0, r1, r2}
	bl gpiob_set_bit
	pop {r0, r1, r2}
	movs r2, #0
	pop {pc}

.end
