.syntax unified
.cpu cortex-m0
.thumb

.global math_div
.global math_mod

.section .text

/** Divide
*	r0: first operand
*	r1: second operand
*	Returns:
*	r2: r0 / r1
*/
math_div:
	push {r0-r1}
	movs r2, #0
div_loop:
	subs r0, r0, r1
	blo div_end
	adds r2, r2, #1
	b div_loop
div_end:
	pop {r0-r1}
	bx lr

/** Modulo
*	r0: first operand
*	r1: second operand
*	Returns:
*	r2: r0 % r1
*/
math_mod:
	push {lr}
	push {r0-r1}
	bl math_div
	muls r2, r2, r1
	subs r0, r0, r2
	movs r2, r0
	pop {r0-r1}
	pop {pc}

.end
