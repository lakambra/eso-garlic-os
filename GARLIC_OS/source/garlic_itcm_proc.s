@;==============================================================================
@;
@;	"garlic_itcm_proc.s":	código de las rutinas de control de procesos (2.0)
@;						(ver "garlic_system.h" para descripción de funciones)
@;
@;==============================================================================

.section .itcm,"ax",%progbits

	.arm
	.align 2
	
	.global _gp_WaitForVBlank
	@; rutina para pausar el procesador mientras no se produzca una interrupción
	@; de retrazado vertical (VBL); es un sustituto de la "swi #5", que evita
	@; la necesidad de cambiar a modo supervisor en los procesos GARLIC
_gp_WaitForVBlank:
	push {r0-r1, lr}
	ldr r0, =__irq_flags
.Lwait_espera:
	mcr p15, 0, lr, c7, c0, 4	@; HALT (suspender hasta nueva interrupción)
	ldr r1, [r0]			@; R1 = [__irq_flags]
	tst r1, #1				@; comprobar flag IRQ_VBL
	beq .Lwait_espera		@; repetir bucle mientras no exista IRQ_VBL
	bic r1, #1
	str r1, [r0]			@; poner a cero el flag IRQ_VBL
	pop {r0-r1, pc}


	.global _gp_IntrMain
	@; Manejador principal de interrupciones del sistema Garlic
_gp_IntrMain:
	mov	r12, #0x4000000
	add	r12, r12, #0x208	@; R12 = base registros de control de interrupciones	
	ldr	r2, [r12, #0x08]	@; R2 = REG_IE (máscara de bits con int. permitidas)
	ldr	r1, [r12, #0x0C]	@; R1 = REG_IF (máscara de bits con int. activas)
	and r1, r1, r2			@; filtrar int. activas con int. permitidas
	ldr	r2, =irqTable
.Lintr_find:				@; buscar manejadores de interrupciones específicos
	ldr r0, [r2, #4]		@; R0 = máscara de int. del manejador indexado
	cmp	r0, #0				@; si máscara = cero, fin de vector de manejadores
	beq	.Lintr_setflags		@; (abandonar bucle de búsqueda de manejador)
	ands r0, r0, r1			@; determinar si el manejador indexado atiende a una
	beq	.Lintr_cont1		@; de las interrupciones activas
	ldr	r3, [r2]			@; R3 = dirección de salto del manejador indexado
	cmp	r3, #0
	beq	.Lintr_ret			@; abandonar si dirección = 0
	mov r2, lr				@; guardar dirección de retorno
	blx	r3					@; invocar el manejador indexado
	mov lr, r2				@; recuperar dirección de retorno
	b .Lintr_ret			@; salir del bucle de búsqueda
.Lintr_cont1:	
	add	r2, r2, #8			@; pasar al siguiente índice del vector de
	b	.Lintr_find			@; manejadores de interrupciones específicas
.Lintr_ret:
	mov r1, r0				@; indica qué interrupción se ha servido
.Lintr_setflags:
	str	r1, [r12, #0x0C]	@; REG_IF = R1 (comunica interrupción servida)
	ldr	r0, =__irq_flags	@; R0 = dirección flags IRQ para gestión IntrWait
	ldr	r3, [r0]
	orr	r3, r3, r1			@; activar el flag correspondiente a la interrupción
	str	r3, [r0]			@; servida (todas si no se ha encontrado el maneja-
							@; dor correspondiente)
	mov	pc,lr				@; retornar al gestor de la excepción IRQ de la BIOS


	.global _gp_rsiVBL
	@; Manejador de interrupciones VBL (Vertical BLank) de Garlic:
	@; se encarga de actualizar los tics, intercambiar procesos, etc.
_gp_rsiVBL:
	push {r4-r7, lr}
	ldr r4, =_gd_tickCount			@; r4 = @_gd_tickCount (contador de tics)
	ldr r5, [r4]					@; r5 = _gd_tickCount
	
	add r5, #1						@; _gd_tickCount++ *incrementar el contador de tics general _gd_tickCount
	str r5, [r4]					@; _gd_tickCount = _gd_tickCount++
	bl _gp_actualizarDelay			@; *a cada interrupción de retroceso vertical se decremente el contador de tics de todos los procesos retardados
	
	ldr r4, =_gd_nReady				@; r4 = @_gd_nReady (cola de Ready)
	ldr r5, [r4]					@; r5 = _gd_nReady
	cmp r5, #0						@; si _gd_nReady == 0 --> *en caso de que la cola este vacia, la RSI finalizará sin cambio de contexto
	beq .Lfin_gp_rsiVBL				 
	
	ldr r4, =_gd_pidz				@; r4 = @_gd_pidz (ident de proc + zocalo)
	ldr r5, [r4]					@; r5 = _gd_pidz
	cmp r5, #0						@; si _gd_pidz == 0 --> *si el proceso actual a desbancar es el del sistema operativo, pasar a salvar el contexto del proceso
	beq .Lsalvar_contexto
	
	lsr r5, #4						@; PID en 28 bits altos, zócalo en 4 bits bajos --> nos quitamos los 4 bits bajos
	cmp r5, #0						@; si PID == 0 -->  *en este caso no hay que salvar el contexto del proceso actual
	beq .Lrestaurar_contexto		
	
.Lsalvar_contexto:	
	ldr r4, =_gd_nReady				@; r4 = dirección _gd_nReady
	ldr r5, [r4]					@; r5 = número de procesos en READY
	ldr r6, =_gd_pidz				@; r6 = dirección _gd_pidz 
	bl _gp_salvarProc				@; *salvar el contexto del proceso actual
	str r5, [r4]					@; r5 = nuevo número de procesos en READY (+1)

.Lrestaurar_contexto:
	ldr r4, =_gd_nReady				@; r4 = dirección _gd_nReady
	ldr r5, [r4]					@; r5 = número de procesos en READY
	ldr r6, =_gd_pidz				@; r6 = dirección _gd_pidz
	bl _gp_restaurarProc			@; *restaurar el proceso del siguiente proceso de la cola de Ready
	
.Lfin_gp_rsiVBL:
	ldr r4, =_gd_pidz				@; r4 = @_gd_pidz
	ldr r5, [r6]					@; r5 = _gd_pidz
	and r5, #15						@; r5 = WXYZh && 000Fh --> 000Zh (4 bits de menys pes = zocalo)
	
	ldr r4, =_gd_pcbs				@; r4 = @_gd_pcbs
	mov r6, #24						@; "_gd_pcbs: .space 16 * 6 * 4" --> 16 procesos que ocupan 6*4 bytes
	mla r7, r5, r6, r4				@; r7 = @gd_pcbs + (24*numero_de_zocalo)
	
	ldr r4, [r7, #20]				@; r4 = _gd_pcbs[procesoActual].workTicks
	add r4, #1						@; *incrementar el contador de tics de trabajo de los procesos activos
	str r4, [r7, #20]			
	
	pop {r4-r7, pc}


	@; Rutina para salvar el estado del proceso interrumpido en la entrada
	@; correspondiente del vector _gd_pcbs
	@;Parámetros
	@; R4: dirección _gd_nReady
	@; R5: número de procesos en READY
	@; R6: dirección _gd_pidz
	@;Resultado
	@; R5: nuevo número de procesos en READY (+1)
_gp_salvarProc:
	push {r8-r11, lr}
	
	ldr r8, [r6]					@; r8 = _gd_pidz
	ldr r9, =_gd_qReady				@; r9 = _gd_qReady
	
	lsr r10, r8, #31				@; cogemos el bit mas alto de la variable global _gd_pidz
	and r8, #15						@; r8 = WXYZh && 000Fh --> 000Zh (4 bits de menys pes = zocalo)
	
	cmp r10, #1 					@; *atendiendo a la marca de aviso no debe poner el zócalo del proceso en la cola de READY
	beq .Lno_guardar_cola
	
	strb r8, [r9, r5]				@; *guardar el número de zócalo del proceso a desbancar en la última posición de la cola de Ready
	add r5, #1						@; número_de_procesos_en_READY++ (return)
	
.Lno_guardar_cola:
	ldr r9, =_gd_pcbs				@; r9 = @_gd_pcbs
	mov r10, #24					@; "_gd_pcbs: .space 16 * 6 * 4" --> 16 procesos que ocupan 6*4 bytes
	mla r9, r10, r8, r9				@; r9 = @gd_pcbs + (24*numero_de_zocalo)
	
	mov r10, sp						@; r8 = @SP_irq
	ldr r8, [r10, #60]				@; r10 =  valor de @SP_irq + 60
	str r8, [r9, #4]				@; *guardar el valor del R15 del proceso a desbancar en el campo PC del elemento _gd_pcbs[z]
	
	mrs r11, SPSR					@; r11 = SPSR (CSPR del proceso)
	str r11, [r9, #12]				@; *guardar el CPSR del proceso a desbancar en el campo Status del elemento _gd_pcbs[z]
	
	mrs r8, CPSR					@; r8 = CPSR
	orr r8, #0x1F					@; 11111b 1Fh System (privileged User mode)
	msr CPSR, r8					@; *cambiar al modo de ejecución del proceso interrumpido
	
	@; *apilar el valor de los registros R0-R12 + R14 del proceso a desbancar en su propia pila
	push {r14}						@; Apilamos r14
	ldr r8, [r10, #56]				@; r8 = r12 (posición 14 de SP_irq)
	push {r8}						@; Apilamos r12
	ldr r8, [r10, #12]				@; r8 = r11 (posición 3 de SP_irq)
	push {r8}						@; Apilamos r11
	ldr r8, [r10, #8]				@; r8 = r10 (posición 2 de SP_irq)
	push {r8}						@; Apilamos r10
	ldr r8, [r10, #4]				@; r8 = r9 (posición 1 de SP_irq)
	push {r8}						@; Apilamos r9
	ldr r8, [r10]					@; r8 = r8 (posición 0 de SP_irq)
	push {r8}						@; Apilamos r8
	ldr r8, [r10, #32]				@; r8 = r7 (posición 8 de SP_irq)
	push {r8}						@; Apilamos r7
	ldr r8, [r10, #28]				@; r8 = r6 (posición 7 de SP_irq)
	push {r8}						@; Apilamos r6
	ldr r8, [r10, #24]				@; r8 = r5 (posición 6 de SP_irq)
	push {r8}						@; Apilamos r5
	ldr r8, [r10, #20]				@; r8 = r4 (posición 5 de SP_irq)
	push {r8}						@; Apilamos r4
	ldr r8, [r10, #52]				@; r8 = r3 (posición 13 de SP_irq)
	push {r8}						@; Apilamos r3
	ldr r8, [r10, #48]				@; r8 = r2 (posición 12 de SP_irq)
	push {r8}						@; Apilamos r2
	ldr r8, [r10, #44]				@; r8 = r1 (posición 11 de SP_irq)
	push {r8}						@; Apilamos r1
	ldr r8, [r10, #40]				@; r8 = r0 (posición de 10 SP_irq)
	push {r8}						@; Apilamos r0
	
	str r13, [r9, #8]				@; guardar el valor del registro R13 del proceso a desbancar en el campo SP del elemento _gd_pcbs[z]

	mrs r8, CPSR					@; r8 = CPSR
	and r8, #0xFFFFFFE0				@; guardamos los datos menos el modo anterior
	orr r8, #0x12					@; 10010b 12h IRQ (normal Interrupt ReQuest)
	msr CPSR, r8					@; *volver al modo de ejecución IRQ 
	
	pop {r8-r11, pc}


	@; Rutina para restaurar el estado del siguiente proceso en la cola de READY
	@;Parámetros
	@; R4: dirección _gd_nReady
	@; R5: número de procesos en READY
	@; R6: dirección _gd_pidz
_gp_restaurarProc:
	push {r8-r11, lr}
	
	ldr r8, =_gd_qReady 			@; r8 = @_gd_qReady 
	ldrb r9, [r8] 					@; *recuperar el número de zócalo del proceso a restaurar de la primera posición de la cola de Ready
	sub r5, #1						@; número_de_procesos_en_READY--
	str r5, [r4]					@; _gd_nReady = número_de_procesos_en_READY
	
	@; tenemos que desplzar la cola un hueco a la izquierda
	mov r10, #0						@; r10 = 0 (i = 0)
	
.Ldesplazar_cola:
	cmp r10, r5						@; si r9 == número_de_procesos_en_READY --> fin bucle
	beq .Lfin_desplazar_cola		
	
	add r10, #1						@; r10++ --> para acceder a la siguiente posicion de la cola
	ldrb r11, [r8, r10]				@; r11 = _gd_nReady + r10
	sub r10, #1						@; r10-- --> para acceder a la posicion nueva
	strb r11, [r8, r10]				@; _gd_nReady + r10 = r11
	add r10, #1						@; i++
	b .Ldesplazar_cola	

.Lfin_desplazar_cola:
	ldr r8, =_gd_pcbs				@; r8 = @_gd_pcbs
	mov r10, #24					@; "_gd_pcbs: .space 16 * 6 * 4" --> 16 procesos que ocupan 6*4 bytes
	mla r11, r10, r9, r8			@; r11 = @gd_pcbs + (24*numero_de_zocalo) 
	
	ldr r10, [r11]					@; r11 = PID del proceso
	lsl r10, #4						@; r11 = PID + 4 bits
	orr r10, r9						@; añadimos los 4 bits de menos peso --> zocalo
	str r10, [r6]					@; *guardar el PID i número de zócalo del proceso a restaurar en la variable global _gd_pidz
	
	ldr r8, [r11, #4]				@; *recuperar el valor del R15 anterior del proceso a restaurar
	mov r9, sp						@; r9 = @SP_irq
	str r8, [r9, #60]				@; *copiarlo en la posición correspondiente de pila del modo IRQ
	
	ldr r8, [r11, #12]				@; *recuperar el CPSR del proceso a restaurar
	msr SPSR, r8					@; SPSR_irq = CPSR
	
	mrs r8, CPSR					@; r8 = CPSR
	orr r8, #0x1F					@; 11111b 1Fh System (privileged User mode)
	msr CPSR, r8					@; *cambiar al modo de ejecución del proceso a restaurar
	
	ldr r13, [r11, #8]				@; *recuperar el valor del registro R13 del proceso a restaurar
	
	@; *desapilar el valor de los registros R0-R12 + R14 de la pila del proceso a restaurar, y copiarlos en la pila del modo IRQ
	pop {r10}						@; Desapilamos r0
	str r10, [r9, #40]				@; r10 = r0 (posición de 10 SP_irq)
	pop {r10}						@; Desapilamos r1
	str r10, [r9, #44]				@; r10 = r1 (posición 11 de SP_irq)
	pop {r10}						@; Desapilamos r2
	str r10, [r9, #48]				@; r10 = r2 (posición 12 de SP_irq)
	pop {r10}						@; Desapilamos r3
	str r10, [r9, #52]				@; r10 = r3 (posición 13 de SP_irq)
	pop {r10}						@; Desapilamos r4
	str r10, [r9, #20]				@; r10 = r4 (posición 5 de SP_irq)
	pop {r10}						@; Desapilamos r5
	str r10, [r9, #24]				@; r10 = r5 (posición 6 de SP_irq)
	pop {r10}						@; Desapilamos r6
	str r10, [r9, #28]				@; r10 = r6 (posición 7 de SP_irq)
	pop {r10}						@; Desapilamos r7
	str r10, [r9, #32]				@; r10 = r7 (posición 8 de SP_irq)
	pop {r10}						@; Desapilamos r10
	str r10, [r9]					@; r10 = r8 (posición 0 de SP_irq)
	pop {r10}						@; Desapilamos r9
	str r10, [r9, #4]				@; r10 = r9 (posición 1 de SP_irq)
	pop {r10}						@; Desapilamos r10
	str r10, [r9, #8]				@; r10 = r10 (posición 2 de SP_irq)
	pop {r10}						@; Desapilamos r11
	str r10, [r9, #12]				@; r10 = r11 (posición 3 de SP_irq)
	pop {r10}						@; Desapilamos R12
	str r10, [r9, #56]				@; r10 = R12 (posición 14 de SP_irq)
	pop {r14}						@; Desapilamos R14
	
	mrs r10, CPSR					@; r10 = CPSR
	and r10, #0xFFFFFFE0			@; guardamos los datos menos el modo anterior
	orr r10, #0x12					@; 10010b 12h IRQ (normal Interrupt ReQuest)
	msr CPSR, r10					@; *volver al modo de ejecución IRQ
	
	pop {r8-r11, pc}
	
	
	@; Rutina para actualizar la cola de procesos retardados, poniendo en
	@; cola de READY aquellos cuyo número de tics de retardo sea 0
_gp_actualizarDelay:
	push {r0-r9, lr}
	
	ldr r0, =_gd_nDelay				@; r0 = @_gd_nDelay
	ldr r1, =_gd_qDelay				@; r0 = @_gd_qDelay
	ldr r2, =_gd_nReady				@; r0 = @_gd_nReady
	ldr r3, =_gd_qReady				@; r0 = @_gd_qReady
 
	ldr r4, [r0]					@; r4 = _gd_nDelay
	mov r5, #0						@; r5 = 0 (i = 0)
	cmp r4, r5						@; si no hay procesos en la cola, fuera
	beq .Lfin_gp_actualizarDelay		
	
.Lmirar_cola:
	ldr r6, [r1, r5, lsl #2]		@; r6 = @_gd_qDelay + i
	sub r6, #1						@; *a cada interrupción de retroceso vertical se decremente el contador de tics de todos los procesos retardados
	
	lsl r7, r6, #16					@; obtenemos el contador de tics
	lsr r7, #16						@; recuperamos los bits para comparar 
	cmp r7, #0						@; *cuando el contador de tics de un proceso retardado llegue a 0
	bne .Lguardar_delay 			@; será necesario sacar al proceso de la cola de DELAY y ponerlo en la cola de READY
	
	lsr r7, r6,	#24					@; obtenemos el numero de zocalo
	ldr r8, [r2]					@; r8 = _gd_nReady
	
	strb r7, [r3, r8]				
	
	add r8, #1						@; _gd_nReady++
	str r8, [r2]					
	
	sub r4, #1						@; _gd_nDelay--
	str r4, [r0]
	
	cmp r4, r5						@; si _gd_nDelay == i, fuera
	beq .Lfin_gp_actualizarDelay
	
	mov r7, r5						@; r7 = r5 (j = i)
	
.Lreordenar_cola:
	add r8, r7, #1					@; r8 = j+1
	
	ldr r9, [r1, r8, lsl #2]		@; cogemos el valor de _gd_qDelay[j+1]
	str r9, [r1, r7, lsl #2]		@; guardamos el valor en _gd_qDelay[j]
	
	add r7, #1						@; j++
	cmp r7, r4						@; si _gd_nDelay == j, fuera
	blo .Lreordenar_cola
	b .Lsiguiente_cola
	
.Lguardar_delay:
	str r6, [r1, r5, lsl #2]		@; guardamos el contador con un tic menos
	add r5, #1						@; i++
	
.Lsiguiente_cola:	
	cmp r5, r4						@; si _gd_nDelay == i, fuera
	blo .Lmirar_cola
	
.Lfin_gp_actualizarDelay:
	pop {r0-r9, pc}
	
	.global _gp_numProc
	@;Resultado
	@; R0: número de procesos total
_gp_numProc:
	push {r1-r2, lr}
	mov r0, #1				@; contar siempre 1 proceso en RUN
	ldr r1, =_gd_nReady
	ldr r2, [r1]			@; R2 = número de procesos en cola de READY
	add r0, r2				@; añadir procesos en READY
	ldr r1, =_gd_nDelay
	ldr r2, [r1]			@; R2 = número de procesos en cola de DELAY
	add r0, r2				@; añadir procesos retardados
	pop {r1-r2, pc}


	.global _gp_crearProc
	@; prepara un proceso para ser ejecutado, creando su entorno de ejecución y
	@; colocándolo en la cola de READY
	@;Parámetros
	@; R0: intFunc funcion,
	@; R1: int zocalo,
	@; R2: char *nombre
	@; R3: int arg
	@;Resultado
	@; R0: 0 si no hay problema, >0 si no se puede crear el proceso
_gp_crearProc:
	push {r4-r7, lr}
	
	bl _gp_inhibirIRQs				
	
	cmp r1, #0						@; *rechazar la llamada si zócalo = 0
	beq .Lerr_gp_crearProc
	
	ldr r4, =_gd_pcbs				@; r4 = @_gd_pcbs
	mov r5, #24						@; "_gd_pcbs: .space 16 * 6 * 4" --> 16 procesos que ocupan 6*4 bytes
	mla r6, r1, r5, r4				@; r6 = @gd_pcbs + (24*numero_de_zocalo)
	
	ldr r4, [r6]					@; r4 = gd_pcbs + (24*numero_de_zocalo)
	cmp r4, #0						@; *si el zócalo ya está ocupado por otro proceso --> error
	bne .Lerr_gp_crearProc
	
	ldr r4, =_gd_pidCount			@; r4 = @_gd_pidCount
	ldr r5, [r4]					@; r5 = _gd_pidCount
	add r5, #1						@; _gd_pidCount++ *obtener un PID para el nuevo proceso 
	str r5, [r4]					@; *incrementando la variable global _gd_pidCount
	str r5, [r6]					@; *guardarlo en el campo PID del _gd_pcbs[z]
	
	add r0, #4						@; intFunc funcion++ *sumándole 4 para compensar el decremento que sufrirá la primera vez que se restaure el proceso
	str r0, [r6, #4]				@; *guardar la dirección de la rutina inicial del proceso en el campo PC del elemento _gd_pcbs[z]
	
	ldr r4, [r2]					@; r4 = 4 primeros caracteres de char *nombre
	str r2, [r6, #16]				@; *guardar los cuatro primeros caracteres del nombre en clave del programa en el campo keyName del elemento _gd_pcbs[z]

	ldr r4, =_gd_stacks				@; @_gd_stacks
	mov r5, #512					@; _gd_stacks: .space 15 * 128 * 4 --> 15 pilas que ocupan 128*4 bytes
	mla r7, r1, r5, r4				@; r7 = @_gd_stacks + (512*numero_de_zocalo) 
	sub r7, #4						@; retrasamos el top de la pila --> int SP *calcular la dirección base de la pila del proceso
	
	ldr r4, =_gp_terminarProc		@; @_gp_terminarProc()
	str r4, [r7]					@; *R14 deberá contener la dirección de retorno del proceso
	
	@; tenemos que asignar todos los registros de la pila
	mov r4, #0						@; r4 = 0 --> *que será cero para todos excepto para R0 y R14
	mov r5, #0						@; r5 = 0 (i = 0)
	
.Lasignar_registros:
	cmp r5, #12						@; #12 para que mire los siguientes 12 registros
	beq .Lfin_asignar_registros
	
	sub r7, #4						@; retrasamos el top de la pila --> int SP 
	str r4, [r7]					@; *guardar en la pila del proceso el valor inicial de los registros R1-R12
	add r5, #1						@; i++
	b .Lasignar_registros
	
.Lfin_asignar_registros:
	sub r7, #4						@; retrasamos el top de la pila --> int SP 
	str r3, [r7]					@; *R0 deberá contener el valor del argumento
	
	str r7, [r6, #8]				@; *guardar el valor actual del registro R13 del proceso a crear en el campo SP del elemento _gd_pcbs[z]
	
	mov r5, #0x1F					@; *modo sistema + flag I = 0 + flag T = 0 + resto de flags a cero
	str r5, [r6, #12]				@; *guardar el valor inicial del registro CPSR en el campo Status del elemento _gd_pcbs[z]
	
	str r4, [r6, #20]				@; *inicializar otros campos del elemento _gd_pcbs[z], como el contador de tics de trabajo workTicks
	
	ldr r4, =_gd_qReady				@; r4 = @_gd_qReady
	ldr r5, =_gd_nReady				@; r5 = @_gd_nReady
	ldr r6, [r5]					@; r6 = _gd_qReady = número de procesos en READY
	
	strb r1, [r4, r6]				@; *guardar el número de zócalo en la última posición de la cola de Ready
	add r6, #1						@; número de procesos en READY++
	str r6, [r5]					@; *incrementar en número de procesos pendientes en la variable _gd_nReady
	
	mov r0, #0						@; r0 = 0 si no hay problema
	b .Lfin_gp_crearProc
	
.Lerr_gp_crearProc:
	mov r0, #1						@; r0 > 0 si no se puede crear el proceso
	
.Lfin_gp_crearProc:
	bl _gp_desinhibirIRQs			

	pop {r4-r7, pc}
	

	@; Rutina para terminar un proceso de usuario:
	@; pone a 0 el campo PID del PCB del zócalo actual, para indicar que esa
	@; entrada del vector _gd_pcbs está libre; también pone a 0 el PID de la
	@; variable _gd_pidz (sin modificar el número de zócalo), para que el código
	@; de multiplexación de procesos no salve el estado del proceso terminado.
_gp_terminarProc:		
	ldr r0, =_gd_pidz
	ldr r1, [r0]			@; R1 = valor actual de PID + zócalo
	and r1, r1, #0xf		@; R1 = zócalo del proceso desbancado
	bl _gp_inhibirIRQs
	str r1, [r0]			@; guardar zócalo con PID = 0, para no salvar estado			
	ldr r2, =_gd_pcbs
	mov r10, #24
	mul r11, r1, r10
	add r2, r11				@; R2 = dirección base _gd_pcbs[zocalo]
	mov r3, #0
	str r3, [r2]			@; pone a 0 el campo PID del PCB del proceso
	str r3, [r2, #20]		@; borrar porcentaje de USO de la CPU
	ldr r0, =_gd_sincMain
	ldr r2, [r0]			@; R2 = valor actual de la variable de sincronismo
	mov r3, #1
	mov r3, r3, lsl r1		@; R3 = máscara con bit correspondiente al zócalo
	orr r2, r3
	str r2, [r0]			@; actualizar variable de sincronismo
	bl _gp_desinhibirIRQs
.LterminarProc_inf:
	bl _gp_WaitForVBlank	@; pausar procesador
	b .LterminarProc_inf	@; hasta asegurar el cambio de contexto

	.global _gp_matarProc
	@; Rutina para destruir un proceso de usuario:
	@; borra el PID del PCB del zócalo referenciado por parámetro, para indicar
	@; que esa entrada del vector _gd_pcbs está libre; elimina el índice de
	@; zócalo de la cola de READY o de la cola de DELAY, esté donde esté;
	@; Parámetros:
	@;	R0:	zócalo del proceso a matar (entre 1 y 15).
_gp_matarProc:
	push {r1-r6, lr} 
	
	bl _gp_inhibirIRQs				 
	
	ldr r1, =_gd_pcbs				@; r1 = @_gd_pcbs
	mov r2, #24						@; "_gd_pcbs: .space 16 * 6 * 4" --> 16 procesos que ocupan 6*4 bytes
	mla r3, r0, r2, r1				@; r3 = @gd_pcbs + (24*numero_de_zocalo)
	
	mov r2, #0						@; r2 = 0 (i = 0)
	str r2, [r3]					@; *poner el campo _gd_pcbs[z].PID a cero
	str r2, [r3, #20]				@; ponemos el campo _gd_pcbs[z].PID a cero para que se muestre bien
	
	ldr r1, =_gd_qReady				@; r1 = @_gd_qReady	
	ldr r3, =_gd_nReady				@; r3 = @_gd_nReady
	
	ldr r4, [r3]					@; r4 = _gd_nReady
	cmp r4, r2						@; si _gd_nReady == 0, fuera
	beq .Ldelay

.Lmirar_cola_ready:
	ldrb r5, [r1, r2]				@; r5 = _gd_qReady[i]
	cmp r5, r0						@; *buscar el valor de z en la cola de READY
	bne .Lsiguiente_cola_ready
	
.Lreordenar_cola_ready:				@; *eliminarlo en caso de haberlo encontrado
	add r5, r2, #1					@; j = i+1
	cmp r5, r4						@; si _gd_nReady == j, fuera
	beq .Lfin_reordenar_cola_ready	
	
	ldrb r6, [r1, r5]				@; r6 = _gd_qReady[j]
	strb r6, [r1, r2]				@; _gd_qReady[i] = r6
	
	add r2, #1						@; i++
	b .Lreordenar_cola_ready
	
.Lfin_reordenar_cola_ready:
	sub r4, #1						@; _gd_nReady--
	str r4, [r3]					
	b .Lfin_gp_matarProc
	
.Lsiguiente_cola_ready:
	add r2, #1						@; i++
	cmp r2, r4						@; si _gd_nReady == i, fuera
	blo	.Lmirar_cola_ready
	
.Ldelay:
	ldr r1, =_gd_qDelay				@; r1 = @_gd_qDelay
	ldr r3, =_gd_nDelay				@; r2 = @_gd_nDelay
	ldr r4, [r3]					@; r3 = _gd_nDelay
	mov r2, #0						@; r2 = 0 (i = 0)
	cmp r4, r2						@; si _gd_nDelay == 0, fuera
	beq .Lfin_gp_matarProc
	
.Lmirar_cola_delay:
	ldr r5, [r1, r2, lsl #2]		@; r5 = _gd_qDelay[i]
	lsr r5, #24						@; obtenemos el numero de zocalo
	cmp r5, r0						@; * buscar el valor de z en la cola de DELAY
	bne .Lsiguiente_cola_delay
	
	add r5, r2, #1					@; j = i+1
	
.Lreordenar_cola_delay:				@; *eliminarlo en caso de haberlo encontrado
	cmp r5, r4						@; si _gd_nDelay == j, fuera
	beq .Lfin_reordenar_cola_delay	
	
	ldrb r6, [r1, r5, lsl #2]		@; r6 = _gd_qDelay[j]
	strb r6, [r1, r2, lsl #2]		@; _gd_qDelay[i] = r6
	
	add r2, #4						@; i = i +1
	add r5, #1						@; j++
	b .Lreordenar_cola_delay

.Lfin_reordenar_cola_delay:
	sub r4, #1						@; _gd_nDelay--
	str r4, [r3]					
	b .Lfin_gp_matarProc

.Lsiguiente_cola_delay:
	add r2, #1						@; i++
	cmp r2, r4						@; si _gd_nDelay == i, fuera
	blo	.Lmirar_cola_delay
	
.Lfin_gp_matarProc:
	bl _gp_desinhibirIRQs			 
	
	pop {r1-r6, pc}
	
	
	.global _gp_retardarProc
	@; retarda la ejecución de un proceso durante cierto número de segundos,
	@; colocándolo en la cola de DELAY
	@;Parámetros
	@; R0: int nsec
_gp_retardarProc:
	push {r1-r8, lr}
	
	mov r1, #60						@; Sabemos que en 1 segundo se efectuan 60 tics 
	mul r2, r1, r0					@; r2 = nsec*60 *calcular cuantos tics corresponden al número de segundos a retardar el proceso
	
	ldr r3, =_gd_pidz				@; r3 = @_gd_pidz
	ldr r4, [r3]					@; r4 = _gd_pidz
	cmp r4, #0						@; si _gd_pidz == 0 --> es del sistema operativo
	beq .Lfin_gp_retardarProc
	
	and r5, r4, #0xF				@; guardamos los 4 bits de menos peso que es el zocalo del proceso
	lsl r5, #24						@; *construir un word con los 8 bits altos igual al zócalo del proceso actual
	orr r5, r2						@; *los 16 bits bajos con el número de tics a retardar
	
	ldr r6, =_gd_qDelay				@; r6 = @_gd_qDelay
	ldr r7, =_gd_nDelay				@; r7 = @_gd_nDelay
	ldr r8, [r7]					@; r8 = _gd_nDelay
	
	str r5, [r6, r8, lsl #2]		@; *incluir este valor en el vector _gd_qDelay[]  
	add r8, #1						@; _gd_nDelay++
	str r8, [r7]					@; *incrementar _gd_nDelay
	
	orr r4, #0x80000000				@; 8 en hexadecimal es 1000
	str r4, [r3]					@; *fijar el bit más alto de la variable global _gd_pidz a 1
	
	bl _gp_WaitForVBlank			@; *forzar cesión de la CPU invocando a la función _gp_WaitForVBlank()
	
.Lfin_gp_retardarProc:
	pop {r1-r8, pc}


	.global _gp_inihibirIRQs
	@; pone el bit IME (Interrupt Master Enable) a 0, para inhibir todas
	@; las IRQs y evitar así posibles problemas debidos al cambio de contexto
_gp_inhibirIRQs:
	push {r0-r1, lr}
	
	ldr r0, =0x4000208				@; r0 = @REG_IME --> en C seria "*((vuint32 *) 0x4000208)"
	ldr r1, [r0]					@; r1 = REG_IME
	bic r1, #1						@; *pone el bit IME (Interrupt Master Enable) a 0
	str r1, [r0]	

	pop {r0-r1, pc}


	.global _gp_desinihibirIRQs
	@; pone el bit IME (Interrupt Master Enable) a 1, para desinhibir todas
	@; las IRQs
_gp_desinhibirIRQs:
	push {r0-r1, lr}
	
	ldr r0, =0x4000208				@; r0 = @REG_IME --> en C seria "*((vuint32 *) 0x4000208)"
	ldr r1, [r0]					@; r1 = REG_IME
	orr r1, #1						@; *pone el bit IME (Interrupt Master Enable) a 1
	str r1, [r0]	

	pop {r0-r1, pc}


	.global _gp_rsiTIMER0
	@; Rutina de Servicio de Interrupción (RSI) para contabilizar los tics
	@; de trabajo de cada proceso: suma los tics de todos los procesos y calcula
	@; el porcentaje de uso de la CPU, que se guarda en los 8 bits altos de la
	@; entrada _gd_pcbs[z].workTicks de cada proceso (z) y, si el procesador
	@; gráfico secundario está correctamente configurado, se imprime en la
	@; columna correspondiente de la tabla de procesos.
_gp_rsiTIMER0:
	push {r0-r9, lr}
	
	ldr r4, =_gd_pcbs				@; r4 = @_gd_pcbs
	ldr r1, [r4, #20]				@; r1 = _gd_pcbs[0].workTicks 
	and r1, #0x00FFFFFF				@; "contador de ciclos de trabajo (24 bits bajos)"
	
	mov r5, #1						@; r5 = 1 (i = 1)
	mov r6, #24						@; "_gd_pcbs: .space 16 * 6 * 4" --> 16 procesos que ocupan 6*4 bytes
	
.Lsumar_workticks_pcbs:
	mla r7, r6, r5, r4				@; r7 = @gd_pcbs + (24*numero_de_zocalo)
	ldr r8, [r7]					@; r8 = gd_pcbs[i]
	cmp r8, #0						@; miramos si hay o no un porceso en ejecucion con este zocalo 
	beq .Lsiguiente_pcb
	
	ldr r8, [r7, #20]				@; r8 = _gd_pcbs[i].workTicks
	and r8, #0x00FFFFFF				@; "contador de ciclos de trabajo (24 bits bajos)"
	add r1, r8						@; *sumar los tics de trabajo (workTicks) de todos los procesos activos
	
.Lsiguiente_pcb:
	add r5, #1						@; i++
	cmp r5, #15						@; si i > 15, fuera
	ble .Lsumar_workticks_pcbs
	
	add r2, r4, #20					@; r2 = @_gd_pcbs[0].workTicks
	ldr r0, [r2]					@; r0 = _gd_pcbs[0].workTicks
	
	and r0, #0x00FFFFFF				@; "contador de ciclos de trabajo (24 bits bajos)"
	mov r9, #100					@; r9 = 100
	mul r0, r9						@; tics = tics * 100 --> para sacar el porcentaje
	ldr r3, =_gd_residuo 			@; r3 = @_gd_residuo
	
	bl _ga_divmod					@; _gd_pcbs[i].workTicks = [(tics*100)/tics_totales]%
	
	mov r5, #0						@; r5 = 0 (i = 0)
	
	b .Lescribir_porcentage	

.Lcalcular_porcentage:		
	mla r7, r6, r5, r4				@; r7 = @gd_pcbs + (24*numero_de_zocalo)
	ldr r8, [r7]					@; r8 = gd_pcbs[i]
	cmp r8, #0						@; miramos si hay o no un porceso en ejecucion con este zocalo 
	beq .Lcalcular_porcentage_sig
	
	add r2, r7, #20					@; r2 = @_gd_pcbs[i].workTicks
	ldr r0, [r2]					@; r0 = _gd_pcbs[i].workTicks
	
	and r0, #0x00FFFFFF				@; "contador de ciclos de trabajo (24 bits bajos)"
	mul r0, r9						@; tics = tics * 100 --> para sacar el porcentage
	ldr r3, =_gd_residuo 			@; r3 = @_gd_residuo
	
	bl _ga_divmod					@; _gd_pcbs[i].workTicks = [(tics*100)/tics_totales]% *calcular el porcentaje de los tics de trabajo de cada proceso respecto al total
	
.Lescribir_porcentage:
	mov r7, r1						@; r7 = tics_totales
	
	ldr r3, [r2]					@; r3 = _gd_pcbs[i].workTicks
	lsl r8, r3, #24					@; *poner a cero los tics de trabajo de cada proceso
	str r8, [r2]					@; *guarda el porcentaje calculado en los 8 bits altos del campo _gd_pcbs[z].workTicks
	
	ldr r0, =_gd_porcentaje			@; r0 = @_gd_porcentaje
	mov r1, #4						@; r1 = 4 --> "length"
	mov r2, r3						@; r2 = [(tics*100)/tics_totales]%	--> "num"
	
	bl _gs_num2str_dec
	
	ldr r0, =_gd_porcentaje 		@; r0 = @_gd_porcentaje			
	add r1, r5, #4					@; r1 = i(num_zocalo)+4(parte_superior_tabla) --> "fil"
	mov r2, #28						@; r2 = 28(columna_uso) --> "col" 
	mov r3, #0						@; r3 = 0(blanco) --> "color"
	
	bl _gs_escribirStringSub		@; "rutina para escribir un string"
	
	mov r1, r7						@; r1 = tics_totales
	
.Lcalcular_porcentage_sig:
	add r5, #1						@; i++
	cmp r5, #15						@; si i > 15, fuera
	ble .Lcalcular_porcentage
	
	ldr r0, =_gd_sincMain			@; @_gd_sincMain
	ldr r1, [r0]					@; _gd_sincMain
	orr r1, #1						@; *poner a uno el bit 0 de la variable global _gd_sincMain
	str r1, [r0]	
	
	pop {r0-r9, pc}
	
.end

