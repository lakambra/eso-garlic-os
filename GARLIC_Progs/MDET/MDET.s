	.arch armv5te
	.eabi_attribute 23, 1
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 1
	.eabi_attribute 30, 6
	.eabi_attribute 34, 0
	.eabi_attribute 18, 4
	.file	"MDET.c"
	.section	.rodata
	.align	2
.LC0:
	.ascii	"-- Programa MDET  -  PID (%d) --\012\000"
	.align	2
.LC1:
	.ascii	"%3-%d\011\000"
	.align	2
.LC2:
	.ascii	"%2%d\011\000"
	.align	2
.LC3:
	.ascii	"\012\000"
	.align	2
.LC4:
	.ascii	"(%d)\011ERROR MATRIZ 5X5\012\000"
	.align	2
.LC5:
	.ascii	"%0(%d)\011DETERMINANTE = -%d\012\000"
	.align	2
.LC6:
	.ascii	"%0(%d)\011DETERMINANTE = %d\012\000"
	.text
	.align	2
	.global	_start
	.syntax unified
	.arm
	.fpu softvfp
	.type	_start, %function
_start:
	@ args = 0, pretend = 0, frame = 120
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r4, r5, r6, r7, r8, r9, r10, fp, lr}
	add	fp, sp, #32
	sub	sp, sp, #124
	str	r0, [fp, #-112]
	mov	r3, sp
	mov	r10, r3
	mov	r3, #0
	str	r3, [fp, #-52]
	ldr	r3, [fp, #-112]
	add	r3, r3, #2
	str	r3, [fp, #-72]
	ldr	lr, [fp, #-72]
	ldr	r9, [fp, #-72]
	sub	r3, lr, #1
	str	r3, [fp, #-76]
	mov	r3, lr
	mov	r2, r3
	mov	r3, #0
	lsl	r5, r3, #5
	orr	r5, r5, r2, lsr #27
	lsl	r4, r2, #5
	mov	r3, lr
	lsl	r8, r3, #2
	sub	r3, r9, #1
	str	r3, [fp, #-80]
	mov	r3, lr
	mov	r4, r3
	mov	r5, #0
	mov	r3, r9
	mov	r0, r3
	mov	r1, #0
	mul	r2, r0, r5
	mul	r3, r4, r1
	add	r3, r2, r3
	umull	r6, r7, r4, r0
	add	r3, r3, r7
	mov	r7, r3
	lsl	r3, r7, #5
	str	r3, [fp, #-120]
	ldr	r3, [fp, #-120]
	orr	r3, r3, r6, lsr #27
	str	r3, [fp, #-120]
	lsl	r3, r6, #5
	str	r3, [fp, #-124]
	mov	r3, lr
	mov	r4, r3
	mov	r5, #0
	mov	r3, r9
	mov	r0, r3
	mov	r1, #0
	mul	r2, r0, r5
	mul	r3, r4, r1
	add	ip, r2, r3
	umull	r2, r3, r4, r0
	add	r1, ip, r3
	mov	r3, r1
	lsl	r1, r3, #5
	str	r1, [fp, #-128]
	ldr	r1, [fp, #-128]
	orr	r1, r1, r2, lsr #27
	str	r1, [fp, #-128]
	lsl	r3, r2, #5
	str	r3, [fp, #-132]
	mov	r3, lr
	mov	r2, r9
	mul	r3, r2, r3
	lsl	r3, r3, #2
	add	r3, r3, #3
	add	r3, r3, #7
	lsr	r3, r3, #3
	lsl	r3, r3, #3
	sub	sp, sp, r3
	mov	r3, sp
	add	r3, r3, #3
	lsr	r3, r3, #2
	lsl	r3, r3, #2
	str	r3, [fp, #-84]
	ldr	r3, [fp, #-112]
	cmp	r3, #0
	bge	.L2
	mov	r3, #0
	str	r3, [fp, #-112]
	b	.L3
.L2:
	ldr	r3, [fp, #-112]
	cmp	r3, #3
	ble	.L3
	mov	r3, #3
	str	r3, [fp, #-112]
.L3:
	bl	GARLIC_pid
	mov	r3, r0
	mov	r1, r3
	ldr	r0, .L31
	bl	GARLIC_printf
	mov	r3, #0
	str	r3, [fp, #-40]
	b	.L4
.L8:
	mov	r3, #0
	str	r3, [fp, #-44]
	b	.L5
.L7:
	bl	GARLIC_random
	str	r0, [fp, #-48]
	bl	GARLIC_random
	str	r0, [fp, #-88]
	ldr	r2, [fp, #-48]
	ldr	r3, .L31+4
	smull	r1, r3, r2, r3
	asr	r1, r3, #1
	asr	r3, r2, #31
	sub	r1, r1, r3
	mov	r3, r1
	lsl	r3, r3, #2
	add	r3, r3, r1
	lsl	r3, r3, #1
	add	r3, r3, r1
	sub	r3, r2, r3
	str	r3, [fp, #-48]
	ldr	r3, [fp, #-88]
	and	r3, r3, #1
	cmp	r3, #0
	beq	.L6
	ldr	r3, [fp, #-48]
	rsb	r3, r3, #0
	str	r3, [fp, #-48]
.L6:
	lsr	r2, r8, #2
	ldr	r3, [fp, #-84]
	ldr	r1, [fp, #-40]
	mul	r1, r2, r1
	ldr	r2, [fp, #-44]
	add	r2, r1, r2
	ldr	r1, [fp, #-48]
	str	r1, [r3, r2, lsl #2]
	ldr	r3, [fp, #-44]
	add	r3, r3, #1
	str	r3, [fp, #-44]
.L5:
	ldr	r2, [fp, #-44]
	ldr	r3, [fp, #-72]
	cmp	r2, r3
	blt	.L7
	ldr	r3, [fp, #-40]
	add	r3, r3, #1
	str	r3, [fp, #-40]
.L4:
	ldr	r2, [fp, #-40]
	ldr	r3, [fp, #-72]
	cmp	r2, r3
	blt	.L8
	mov	r3, #0
	str	r3, [fp, #-40]
	b	.L9
.L14:
	mov	r3, #0
	str	r3, [fp, #-44]
	b	.L10
.L13:
	ldr	r3, [fp, #-112]
	mov	r0, r3
	bl	GARLIC_delay
	lsr	r2, r8, #2
	ldr	r3, [fp, #-84]
	ldr	r1, [fp, #-40]
	mul	r1, r2, r1
	ldr	r2, [fp, #-44]
	add	r2, r1, r2
	ldr	r3, [r3, r2, lsl #2]
	cmp	r3, #0
	bge	.L11
	lsr	r2, r8, #2
	lsr	r1, r8, #2
	ldr	r3, [fp, #-84]
	ldr	r0, [fp, #-40]
	mul	r0, r1, r0
	ldr	r1, [fp, #-44]
	add	r1, r0, r1
	ldr	r3, [r3, r1, lsl #2]
	rsb	r1, r3, #0
	ldr	r3, [fp, #-84]
	ldr	r0, [fp, #-40]
	mul	r0, r2, r0
	ldr	r2, [fp, #-44]
	add	r2, r0, r2
	str	r1, [r3, r2, lsl #2]
	lsr	r2, r8, #2
	ldr	r3, [fp, #-84]
	ldr	r1, [fp, #-40]
	mul	r1, r2, r1
	ldr	r2, [fp, #-44]
	add	r2, r1, r2
	ldr	r3, [r3, r2, lsl #2]
	mov	r1, r3
	ldr	r0, .L31+8
	bl	GARLIC_printf
	lsr	r2, r8, #2
	lsr	r1, r8, #2
	ldr	r3, [fp, #-84]
	ldr	r0, [fp, #-40]
	mul	r0, r1, r0
	ldr	r1, [fp, #-44]
	add	r1, r0, r1
	ldr	r3, [r3, r1, lsl #2]
	rsb	r1, r3, #0
	ldr	r3, [fp, #-84]
	ldr	r0, [fp, #-40]
	mul	r0, r2, r0
	ldr	r2, [fp, #-44]
	add	r2, r0, r2
	str	r1, [r3, r2, lsl #2]
	b	.L12
.L11:
	lsr	r2, r8, #2
	ldr	r3, [fp, #-84]
	ldr	r1, [fp, #-40]
	mul	r1, r2, r1
	ldr	r2, [fp, #-44]
	add	r2, r1, r2
	ldr	r3, [r3, r2, lsl #2]
	mov	r1, r3
	ldr	r0, .L31+12
	bl	GARLIC_printf
.L12:
	ldr	r3, [fp, #-44]
	add	r3, r3, #1
	str	r3, [fp, #-44]
.L10:
	ldr	r2, [fp, #-44]
	ldr	r3, [fp, #-72]
	cmp	r2, r3
	blt	.L13
	ldr	r0, .L31+16
	bl	GARLIC_printf
	ldr	r3, [fp, #-40]
	add	r3, r3, #1
	str	r3, [fp, #-40]
.L9:
	ldr	r2, [fp, #-40]
	ldr	r3, [fp, #-72]
	cmp	r2, r3
	blt	.L14
	ldr	r3, [fp, #-72]
	cmp	r3, #2
	bne	.L15
	ldr	r3, [fp, #-84]
	ldr	r3, [r3]
	lsr	r1, r8, #2
	ldr	r2, [fp, #-84]
	add	r1, r1, #1
	ldr	r2, [r2, r1, lsl #2]
	mul	r2, r3, r2
	ldr	r3, [fp, #-84]
	ldr	r3, [r3, #4]
	lsr	r0, r8, #2
	ldr	r1, [fp, #-84]
	ldr	r1, [r1, r0, lsl #2]
	mul	r3, r1, r3
	sub	r3, r2, r3
	str	r3, [fp, #-52]
	b	.L16
.L15:
	ldr	r3, [fp, #-72]
	cmp	r3, #3
	bne	.L17
	ldr	r3, [fp, #-84]
	ldr	r3, [r3]
	lsr	r1, r8, #2
	ldr	r2, [fp, #-84]
	add	r1, r1, #1
	ldr	r2, [r2, r1, lsl #2]
	mul	r3, r2, r3
	lsr	r1, r8, #2
	ldr	r2, [fp, #-84]
	add	r1, r1, #1
	ldr	r2, [r2, r1, lsl #3]
	mul	r3, r2, r3
	str	r3, [fp, #-52]
	ldr	r3, [fp, #-84]
	ldr	r3, [r3, #8]
	lsr	r1, r8, #2
	ldr	r2, [fp, #-84]
	add	r1, r1, #1
	ldr	r2, [r2, r1, lsl #2]
	mul	r3, r2, r3
	lsr	r1, r8, #2
	ldr	r2, [fp, #-84]
	ldr	r2, [r2, r1, lsl #3]
	mul	r3, r2, r3
	ldr	r2, [fp, #-52]
	sub	r3, r2, r3
	str	r3, [fp, #-52]
	ldr	r3, [fp, #-84]
	ldr	r3, [r3, #4]
	lsr	r1, r8, #2
	ldr	r2, [fp, #-84]
	add	r1, r1, #2
	ldr	r2, [r2, r1, lsl #2]
	mul	r3, r2, r3
	lsr	r1, r8, #2
	ldr	r2, [fp, #-84]
	ldr	r2, [r2, r1, lsl #3]
	mul	r3, r2, r3
	ldr	r2, [fp, #-52]
	add	r3, r2, r3
	str	r3, [fp, #-52]
	ldr	r3, [fp, #-84]
	ldr	r3, [r3, #4]
	lsr	r1, r8, #2
	ldr	r2, [fp, #-84]
	ldr	r2, [r2, r1, lsl #2]
	mul	r3, r2, r3
	lsr	r1, r8, #2
	ldr	r2, [fp, #-84]
	add	r1, r1, #1
	ldr	r2, [r2, r1, lsl #3]
	mul	r3, r2, r3
	ldr	r2, [fp, #-52]
	sub	r3, r2, r3
	str	r3, [fp, #-52]
	lsr	r2, r8, #2
	ldr	r3, [fp, #-84]
	ldr	r2, [r3, r2, lsl #2]
	lsr	r3, r8, #2
	ldr	r1, [fp, #-84]
	lsl	r3, r3, #3
	add	r3, r1, r3
	ldr	r3, [r3, #4]
	mul	r3, r2, r3
	ldr	r2, [fp, #-84]
	ldr	r2, [r2, #8]
	mul	r3, r2, r3
	ldr	r2, [fp, #-52]
	add	r3, r2, r3
	str	r3, [fp, #-52]
	lsr	r2, r8, #2
	ldr	r3, [fp, #-84]
	add	r2, r2, #2
	ldr	r2, [r3, r2, lsl #2]
	lsr	r3, r8, #2
	ldr	r1, [fp, #-84]
	lsl	r3, r3, #3
	add	r3, r1, r3
	ldr	r3, [r3, #4]
	mul	r3, r2, r3
	ldr	r2, [fp, #-84]
	ldr	r2, [r2]
	mul	r3, r2, r3
	ldr	r2, [fp, #-52]
	sub	r3, r2, r3
	str	r3, [fp, #-52]
	b	.L16
.L17:
	ldr	r3, [fp, #-72]
	cmp	r3, #4
	bne	.L18
	mov	r3, sp
	mov	r9, r3
	mov	r3, #1
	str	r3, [fp, #-68]
	mov	r3, #0
	str	r3, [fp, #-92]
	ldr	r3, [fp, #-72]
	sub	ip, r3, #1
	ldr	r3, [fp, #-72]
	sub	lr, r3, #1
	sub	r3, ip, #1
	str	r3, [fp, #-96]
	mov	r3, ip
	mov	r2, r3
	mov	r3, #0
	lsl	r1, r3, #5
	str	r1, [fp, #-136]
	ldr	r1, [fp, #-136]
	orr	r1, r1, r2, lsr #27
	str	r1, [fp, #-136]
	lsl	r3, r2, #5
	str	r3, [fp, #-140]
	mov	r3, ip
	lsl	r3, r3, #2
	sub	r2, lr, #1
	str	r2, [fp, #-100]
	mov	r2, ip
	mov	r6, r2
	mov	r7, #0
	mov	r2, lr
	mov	r4, r2
	mov	r5, #0
	mul	r1, r4, r7
	mul	r2, r6, r5
	add	r2, r1, r2
	umull	r0, r1, r6, r4
	add	r2, r2, r1
	mov	r1, r2
	lsl	r2, r1, #5
	str	r2, [fp, #-144]
	ldr	r2, [fp, #-144]
	orr	r2, r2, r0, lsr #27
	str	r2, [fp, #-144]
	lsl	r2, r0, #5
	str	r2, [fp, #-148]
	mov	r2, ip
	mov	r6, r2
	mov	r7, #0
	mov	r2, lr
	mov	r4, r2
	mov	r5, #0
	mul	r1, r4, r7
	mul	r2, r6, r5
	add	r2, r1, r2
	umull	r0, r1, r6, r4
	add	r2, r2, r1
	mov	r1, r2
	lsl	r2, r1, #5
	str	r2, [fp, #-152]
	ldr	r2, [fp, #-152]
	orr	r2, r2, r0, lsr #27
	str	r2, [fp, #-152]
	lsl	r2, r0, #5
	str	r2, [fp, #-156]
	mov	r2, ip
	mov	r1, lr
	mul	r2, r1, r2
	lsl	r2, r2, #2
	add	r2, r2, #3
	add	r2, r2, #7
	lsr	r2, r2, #3
	lsl	r2, r2, #3
	sub	sp, sp, r2
	mov	r2, sp
	add	r2, r2, #3
	lsr	r2, r2, #2
	lsl	r2, r2, #2
	str	r2, [fp, #-104]
	mov	r2, #0
	str	r2, [fp, #-56]
	b	.L19
.L26:
	mov	r2, #0
	str	r2, [fp, #-60]
	b	.L20
.L25:
	mov	r2, #0
	str	r2, [fp, #-64]
	b	.L21
.L24:
	ldr	r1, [fp, #-64]
	ldr	r2, [fp, #-56]
	cmp	r1, r2
	bge	.L22
	lsr	r1, r3, #2
	lsr	r0, r8, #2
	ldr	r2, [fp, #-60]
	add	ip, r2, #1
	ldr	r2, [fp, #-84]
	mul	ip, r0, ip
	ldr	r0, [fp, #-64]
	add	r0, ip, r0
	ldr	r0, [r2, r0, lsl #2]
	ldr	r2, [fp, #-104]
	ldr	ip, [fp, #-60]
	mul	ip, r1, ip
	ldr	r1, [fp, #-64]
	add	r1, ip, r1
	str	r0, [r2, r1, lsl #2]
	b	.L23
.L22:
	lsr	r1, r3, #2
	lsr	ip, r8, #2
	ldr	r2, [fp, #-60]
	add	lr, r2, #1
	ldr	r2, [fp, #-64]
	add	r0, r2, #1
	ldr	r2, [fp, #-84]
	mul	ip, lr, ip
	add	r0, ip, r0
	ldr	r0, [r2, r0, lsl #2]
	ldr	r2, [fp, #-104]
	ldr	ip, [fp, #-60]
	mul	ip, r1, ip
	ldr	r1, [fp, #-64]
	add	r1, ip, r1
	str	r0, [r2, r1, lsl #2]
.L23:
	ldr	r2, [fp, #-64]
	add	r2, r2, #1
	str	r2, [fp, #-64]
.L21:
	ldr	r1, [fp, #-64]
	ldr	r2, [fp, #-72]
	cmp	r1, r2
	blt	.L24
	ldr	r2, [fp, #-60]
	add	r2, r2, #1
	str	r2, [fp, #-60]
.L20:
	ldr	r1, [fp, #-60]
	ldr	r2, [fp, #-72]
	cmp	r1, r2
	blt	.L25
	ldr	r2, [fp, #-104]
	ldr	r2, [r2]
	lsr	r0, r3, #2
	ldr	r1, [fp, #-104]
	add	r0, r0, #1
	ldr	r1, [r1, r0, lsl #2]
	mul	r2, r1, r2
	lsr	r0, r3, #2
	ldr	r1, [fp, #-104]
	add	r0, r0, #1
	ldr	r1, [r1, r0, lsl #3]
	mul	r2, r1, r2
	str	r2, [fp, #-92]
	ldr	r2, [fp, #-104]
	ldr	r2, [r2, #8]
	lsr	r0, r3, #2
	ldr	r1, [fp, #-104]
	add	r0, r0, #1
	ldr	r1, [r1, r0, lsl #2]
	mul	r2, r1, r2
	lsr	r0, r3, #2
	ldr	r1, [fp, #-104]
	ldr	r1, [r1, r0, lsl #3]
	mul	r2, r1, r2
	ldr	r1, [fp, #-92]
	sub	r2, r1, r2
	str	r2, [fp, #-92]
	ldr	r2, [fp, #-104]
	ldr	r2, [r2, #4]
	lsr	r0, r3, #2
	ldr	r1, [fp, #-104]
	add	r0, r0, #2
	ldr	r1, [r1, r0, lsl #2]
	mul	r2, r1, r2
	lsr	r0, r3, #2
	ldr	r1, [fp, #-104]
	ldr	r1, [r1, r0, lsl #3]
	mul	r2, r1, r2
	ldr	r1, [fp, #-92]
	add	r2, r1, r2
	str	r2, [fp, #-92]
	ldr	r2, [fp, #-104]
	ldr	r2, [r2, #4]
	lsr	r0, r3, #2
	ldr	r1, [fp, #-104]
	ldr	r1, [r1, r0, lsl #2]
	mul	r2, r1, r2
	lsr	r0, r3, #2
	ldr	r1, [fp, #-104]
	add	r0, r0, #1
	ldr	r1, [r1, r0, lsl #3]
	mul	r2, r1, r2
	ldr	r1, [fp, #-92]
	sub	r2, r1, r2
	str	r2, [fp, #-92]
	lsr	r1, r3, #2
	ldr	r2, [fp, #-104]
	ldr	r1, [r2, r1, lsl #2]
	lsr	r2, r3, #2
	ldr	r0, [fp, #-104]
	lsl	r2, r2, #3
	add	r2, r0, r2
	ldr	r2, [r2, #4]
	mul	r2, r1, r2
	ldr	r1, [fp, #-104]
	ldr	r1, [r1, #8]
	mul	r2, r1, r2
	ldr	r1, [fp, #-92]
	add	r2, r1, r2
	str	r2, [fp, #-92]
	lsr	r1, r3, #2
	ldr	r2, [fp, #-104]
	add	r1, r1, #2
	ldr	r1, [r2, r1, lsl #2]
	lsr	r2, r3, #2
	ldr	r0, [fp, #-104]
	lsl	r2, r2, #3
	add	r2, r0, r2
	ldr	r2, [r2, #4]
	mul	r2, r1, r2
	ldr	r1, [fp, #-104]
	ldr	r1, [r1]
	mul	r2, r1, r2
	ldr	r1, [fp, #-92]
	sub	r2, r1, r2
	str	r2, [fp, #-92]
	ldr	r2, [fp, #-84]
	ldr	r1, [fp, #-56]
	ldr	r2, [r2, r1, lsl #2]
	ldr	r1, [fp, #-68]
	mul	r2, r1, r2
	ldr	r1, [fp, #-92]
	mul	r2, r1, r2
	ldr	r1, [fp, #-52]
	add	r2, r1, r2
	str	r2, [fp, #-52]
	ldr	r2, [fp, #-68]
	rsb	r2, r2, #0
	str	r2, [fp, #-68]
	ldr	r2, [fp, #-56]
	add	r2, r2, #1
	str	r2, [fp, #-56]
.L19:
	ldr	r1, [fp, #-56]
	ldr	r2, [fp, #-72]
	cmp	r1, r2
	blt	.L26
	mov	sp, r9
	b	.L16
.L18:
	ldr	r3, [fp, #-112]
	mov	r0, r3
	bl	GARLIC_delay
.L16:
	ldr	r3, [fp, #-72]
	cmp	r3, #5
	bne	.L27
	bl	GARLIC_pid
	mov	r3, r0
	mov	r1, r3
	ldr	r0, .L31+20
	bl	GARLIC_printf
	b	.L28
.L27:
	ldr	r3, [fp, #-112]
	mov	r0, r3
	bl	GARLIC_delay
	ldr	r3, [fp, #-52]
	cmp	r3, #0
	bge	.L29
	ldr	r3, [fp, #-52]
	rsb	r3, r3, #0
	str	r3, [fp, #-52]
	bl	GARLIC_pid
	mov	r3, r0
	ldr	r2, [fp, #-52]
	mov	r1, r3
	ldr	r0, .L31+24
	bl	GARLIC_printf
	b	.L28
.L29:
	bl	GARLIC_pid
	mov	r3, r0
	ldr	r2, [fp, #-52]
	mov	r1, r3
	ldr	r0, .L31+28
	bl	GARLIC_printf
.L28:
	mov	r3, #0
	mov	sp, r10
	mov	r0, r3
	sub	sp, fp, #32
	@ sp needed
	pop	{r4, r5, r6, r7, r8, r9, r10, fp, pc}
.L32:
	.align	2
.L31:
	.word	.LC0
	.word	780903145
	.word	.LC1
	.word	.LC2
	.word	.LC3
	.word	.LC4
	.word	.LC5
	.word	.LC6
	.size	_start, .-_start
	.ident	"GCC: (devkitARM release 46) 6.3.0"
