	.arch armv5te
	.eabi_attribute 23, 1
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 1
	.eabi_attribute 30, 6
	.eabi_attribute 34, 0
	.eabi_attribute 18, 4
	.file	"FARE.c"
	.text
	.align	2
	.global	lim
	.syntax unified
	.arm
	.fpu softvfp
	.type	lim, %function
lim:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 0, uses_anonymous_args = 0
	str	lr, [sp, #-4]!
	sub	sp, sp, #20
	str	r0, [sp, #4]
	bl	GARLIC_random
	mov	r3, r0
	str	r3, [sp, #12]
	ldr	r3, [sp, #4]
	add	r2, r3, #1
	mov	r3, r2
	lsl	r3, r3, #1
	add	r3, r3, r2
	str	r3, [sp, #8]
	ldr	r3, [sp, #12]
	cmp	r3, #1
	bhi	.L4
	mov	r3, #2
	str	r3, [sp, #12]
	b	.L3
.L5:
	bl	GARLIC_random
	mov	r3, r0
	str	r3, [sp, #12]
.L4:
	ldr	r2, [sp, #12]
	ldr	r3, [sp, #8]
	cmp	r2, r3
	bhi	.L5
.L3:
	ldr	r3, [sp, #12]
	mov	r0, r3
	add	sp, sp, #20
	@ sp needed
	ldr	pc, [sp], #4
	.size	lim, .-lim
	.align	2
	.global	div
	.syntax unified
	.arm
	.fpu softvfp
	.type	div, %function
div:
	@ args = 0, pretend = 0, frame = 32
	@ frame_needed = 0, uses_anonymous_args = 0
	str	lr, [sp, #-4]!
	sub	sp, sp, #36
	str	r0, [sp, #12]
	str	r1, [sp, #8]
	str	r2, [sp, #4]
	ldr	r2, [sp, #12]
	ldr	r3, [sp, #8]
	add	r3, r2, r3
	str	r3, [sp, #28]
	ldr	r3, [sp, #4]
	str	r3, [sp, #24]
	add	r3, sp, #16
	add	r2, sp, #20
	ldr	r1, [sp, #24]
	ldr	r0, [sp, #28]
	bl	GARLIC_divmod
	ldr	r3, [sp, #20]
	mov	r0, r3
	add	sp, sp, #36
	@ sp needed
	ldr	pc, [sp], #4
	.size	div, .-div
	.section	.rodata
	.align	2
.LC0:
	.ascii	"-- Programa FARE V2 -  PID (%d) --\012\000"
	.align	2
.LC1:
	.ascii	"Serie de farey amb el numero %d: \012\000"
	.align	2
.LC2:
	.ascii	"\012\000"
	.align	2
.LC3:
	.ascii	"0/1, 1/\000"
	.align	2
.LC4:
	.ascii	"%d, \000"
	.align	2
.LC5:
	.ascii	" %d/%d,\000"
	.text
	.align	2
	.global	_start
	.syntax unified
	.arm
	.fpu softvfp
	.type	_start, %function
_start:
	@ args = 0, pretend = 0, frame = 40
	@ frame_needed = 0, uses_anonymous_args = 0
	str	lr, [sp, #-4]!
	sub	sp, sp, #44
	str	r0, [sp, #4]
	ldr	r0, [sp, #4]
	bl	lim
	str	r0, [sp, #36]
	bl	GARLIC_pid
	mov	r3, r0
	mov	r1, r3
	ldr	r0, .L13
	bl	GARLIC_printf
	ldr	r1, [sp, #36]
	ldr	r0, .L13+4
	bl	GARLIC_printf
	ldr	r0, .L13+8
	bl	GARLIC_printf
	mov	r3, #0
	str	r3, [sp, #24]
	mov	r3, #1
	str	r3, [sp, #28]
	mov	r3, #1
	str	r3, [sp, #16]
	ldr	r3, [sp, #36]
	str	r3, [sp, #20]
	ldr	r0, .L13+12
	bl	GARLIC_printf
	ldr	r1, [sp, #36]
	ldr	r0, .L13+16
	bl	GARLIC_printf
	b	.L10
.L11:
	ldr	r3, [sp, #36]
	ldr	r1, [sp, #28]
	ldr	r2, [sp, #20]
	mov	r0, r3
	bl	div
	str	r0, [sp, #32]
	add	r3, sp, #8
	add	r2, sp, #24
	ldm	r2, {r0, r1}
	stm	r3, {r0, r1}
	add	r3, sp, #24
	add	r2, sp, #16
	ldm	r2, {r0, r1}
	stm	r3, {r0, r1}
	ldr	r3, [sp, #16]
	mov	r2, r3
	ldr	r3, [sp, #32]
	mul	r3, r2, r3
	ldr	r2, [sp, #8]
	sub	r3, r3, r2
	mov	r2, r3
	ldr	r3, [sp, #20]
	mov	r1, r3
	ldr	r3, [sp, #32]
	mul	r3, r1, r3
	ldr	r1, [sp, #12]
	sub	r3, r3, r1
	str	r2, [sp, #16]
	str	r3, [sp, #20]
	ldr	r3, [sp, #16]
	ldr	r2, [sp, #20]
	mov	r1, r3
	ldr	r0, .L13+20
	bl	GARLIC_printf
.L10:
	ldr	r3, [sp, #20]
	cmp	r3, #1
	bgt	.L11
	ldr	r0, .L13+8
	bl	GARLIC_printf
	mov	r3, #0
	mov	r0, r3
	add	sp, sp, #44
	@ sp needed
	ldr	pc, [sp], #4
.L14:
	.align	2
.L13:
	.word	.LC0
	.word	.LC1
	.word	.LC2
	.word	.LC3
	.word	.LC4
	.word	.LC5
	.size	_start, .-_start
	.ident	"GCC: (devkitARM release 46) 6.3.0"
