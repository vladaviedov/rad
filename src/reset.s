.syntax unified
.cpu cortex-m0
.thumb

.global vtable
.global reset_handler

.section .text

vtable:
	.word _stack_end
	.word reset_handler

reset_handler:
	ldr r0, =_stack_end
	mov sp, r0
	b main

.end
