.syntax unified
.cpu cortex-m0
.thumb

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
.org 0x7c
	.word timer_isr
.org 0xc0

.thumb_func
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
	adds r5, r5, #1
	adds r6, r6, #1
	pop {pc}

.thumb_func
timer_isr:
	push {lr}
	bl timer_clear_int
	// Write current counter
	movs r0, #20
	bl lcd_move_to
	movs r0, #' '
	bl lcd_write_char
	bl lcd_write_char
	bl lcd_write_char
	movs r0, #20
	bl lcd_move_to
	movs r0, r5
	bl lcd_write_num
	movs r5, #0
	// Write cumulative counter
	movs r0, #30
	bl lcd_move_to
	movs r0, #' '
	bl lcd_write_char
	bl lcd_write_char
	bl lcd_write_char
	movs r0, #30
	bl lcd_move_to
	movs r0, r6
	bl lcd_write_num
	// Print minute count
	adds r7, r7, #1
	movs r0, #15
	bl lcd_move_to
	movs r0, #' '
	bl lcd_write_char
	bl lcd_write_char
	bl lcd_write_char
	movs r0, #15
	bl lcd_move_to
	movs r0, r7
	bl lcd_write_num
	pop {pc}

.end
