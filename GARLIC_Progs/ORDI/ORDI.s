	.arch armv5te
	.eabi_attribute 23, 1
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 1
	.eabi_attribute 30, 6
	.eabi_attribute 34, 0
	.eabi_attribute 18, 4
	.file	"ORDI.c"
	.section	.rodata
	.align	2
.LC0:
	.ascii	"-- Programa ORDI --\012\000"
	.align	2
.LC1:
	.ascii	"%3Array %2of %1size %d, %0random.\012\000"
	.align	2
.LC2:
	.ascii	"%d.\012\012\000"
	.align	2
.LC3:
	.ascii	"%d, \000"
	.align	2
.LC4:
	.ascii	"Array of size %d, sorted.\012\000"
	.align	2
.LC5:
	.ascii	"%d.\012\000"
	.text
	.align	2
	.global	_start
	.syntax unified
	.arm
	.fpu softvfp
	.type	_start, %function
_start:
	@ args = 0, pretend = 0, frame = 32
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r4, r5, r6, r7, r8, fp, lr}
	add	fp, sp, #24
	sub	sp, sp, #36
	str	r0, [fp, #-56]
	mov	r3, sp
	mov	r8, r3
	ldr	r3, [fp, #-56]
	cmp	r3, #0
	bge	.L2
	mov	r3, #0
	str	r3, [fp, #-56]
	b	.L3
.L2:
	ldr	r3, [fp, #-56]
	cmp	r3, #3
	ble	.L3
	mov	r3, #3
	str	r3, [fp, #-56]
.L3:
	ldr	r0, .L20
	bl	GARLIC_printf
	ldr	r3, [fp, #-56]
	add	r2, r3, #1
	mov	r3, r2
	lsl	r3, r3, #2
	add	r3, r3, r2
	lsl	r3, r3, #1
	str	r3, [fp, #-40]
	ldr	r1, [fp, #-40]
	mov	r3, r1
	sub	r3, r3, #1
	str	r3, [fp, #-44]
	mov	r2, r1
	mov	r3, #0
	lsl	r7, r3, #5
	orr	r7, r7, r2, lsr #27
	lsl	r6, r2, #5
	mov	r2, r1
	mov	r3, #0
	lsl	r5, r3, #5
	orr	r5, r5, r2, lsr #27
	lsl	r4, r2, #5
	lsl	r3, r1, #2
	add	r3, r3, #3
	add	r3, r3, #7
	lsr	r3, r3, #3
	lsl	r3, r3, #3
	sub	sp, sp, r3
	mov	r3, sp
	add	r3, r3, #3
	lsr	r3, r3, #2
	lsl	r3, r3, #2
	str	r3, [fp, #-48]
	mov	r3, #0
	str	r3, [fp, #-32]
	b	.L4
.L5:
	bl	GARLIC_random
	mov	r1, r0
	ldr	r3, [fp, #-48]
	ldr	r2, [fp, #-32]
	str	r1, [r3, r2, lsl #2]
	ldr	r3, [fp, #-32]
	add	r3, r3, #1
	str	r3, [fp, #-32]
.L4:
	ldr	r2, [fp, #-32]
	ldr	r3, [fp, #-40]
	cmp	r2, r3
	bcc	.L5
	ldr	r1, [fp, #-40]
	ldr	r0, .L20+4
	bl	GARLIC_printf
	mov	r3, #0
	str	r3, [fp, #-32]
	b	.L6
.L9:
	ldr	r3, [fp, #-40]
	sub	r2, r3, #1
	ldr	r3, [fp, #-32]
	cmp	r2, r3
	bne	.L7
	ldr	r3, [fp, #-48]
	ldr	r2, [fp, #-32]
	ldr	r3, [r3, r2, lsl #2]
	mov	r1, r3
	ldr	r0, .L20+8
	bl	GARLIC_printf
	b	.L8
.L7:
	ldr	r3, [fp, #-48]
	ldr	r2, [fp, #-32]
	ldr	r3, [r3, r2, lsl #2]
	mov	r1, r3
	ldr	r0, .L20+12
	bl	GARLIC_printf
.L8:
	ldr	r3, [fp, #-32]
	add	r3, r3, #1
	str	r3, [fp, #-32]
.L6:
	ldr	r2, [fp, #-32]
	ldr	r3, [fp, #-40]
	cmp	r2, r3
	bcc	.L9
	mov	r3, #0
	str	r3, [fp, #-32]
	mov	r3, #1
	str	r3, [fp, #-32]
	b	.L10
.L14:
	ldr	r3, [fp, #-48]
	ldr	r2, [fp, #-32]
	ldr	r3, [r3, r2, lsl #2]
	str	r3, [fp, #-52]
	ldr	r3, [fp, #-32]
	sub	r3, r3, #1
	str	r3, [fp, #-36]
	b	.L11
.L13:
	ldr	r3, [fp, #-36]
	add	r2, r3, #1
	ldr	r3, [fp, #-48]
	ldr	r1, [fp, #-36]
	ldr	r1, [r3, r1, lsl #2]
	ldr	r3, [fp, #-48]
	str	r1, [r3, r2, lsl #2]
	ldr	r3, [fp, #-36]
	sub	r3, r3, #1
	str	r3, [fp, #-36]
.L11:
	ldr	r3, [fp, #-36]
	cmp	r3, #0
	blt	.L12
	ldr	r3, [fp, #-48]
	ldr	r2, [fp, #-36]
	ldr	r2, [r3, r2, lsl #2]
	ldr	r3, [fp, #-52]
	cmp	r2, r3
	bgt	.L13
.L12:
	ldr	r3, [fp, #-36]
	add	r2, r3, #1
	ldr	r3, [fp, #-48]
	ldr	r1, [fp, #-52]
	str	r1, [r3, r2, lsl #2]
	ldr	r3, [fp, #-32]
	add	r3, r3, #1
	str	r3, [fp, #-32]
.L10:
	ldr	r2, [fp, #-32]
	ldr	r3, [fp, #-40]
	cmp	r2, r3
	bcc	.L14
	ldr	r1, [fp, #-40]
	ldr	r0, .L20+16
	bl	GARLIC_printf
	mov	r3, #0
	str	r3, [fp, #-32]
	b	.L15
.L18:
	ldr	r3, [fp, #-40]
	sub	r2, r3, #1
	ldr	r3, [fp, #-32]
	cmp	r2, r3
	bne	.L16
	ldr	r3, [fp, #-48]
	ldr	r2, [fp, #-32]
	ldr	r3, [r3, r2, lsl #2]
	mov	r1, r3
	ldr	r0, .L20+20
	bl	GARLIC_printf
	b	.L17
.L16:
	ldr	r3, [fp, #-48]
	ldr	r2, [fp, #-32]
	ldr	r3, [r3, r2, lsl #2]
	mov	r1, r3
	ldr	r0, .L20+12
	bl	GARLIC_printf
.L17:
	ldr	r3, [fp, #-32]
	add	r3, r3, #1
	str	r3, [fp, #-32]
.L15:
	ldr	r2, [fp, #-32]
	ldr	r3, [fp, #-40]
	cmp	r2, r3
	bcc	.L18
	mov	r3, #0
	mov	sp, r8
	mov	r0, r3
	sub	sp, fp, #24
	@ sp needed
	pop	{r4, r5, r6, r7, r8, fp, pc}
.L21:
	.align	2
.L20:
	.word	.LC0
	.word	.LC1
	.word	.LC2
	.word	.LC3
	.word	.LC4
	.word	.LC5
	.size	_start, .-_start
	.ident	"GCC: (devkitARM release 46) 6.3.0"
