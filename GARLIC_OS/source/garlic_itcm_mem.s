@;==============================================================================
@;
@;	"garlic_itcm_mem.s":	código de rutinas de soporte a la carga de
@;							programas en memoria (version 2.0)
@;
@;==============================================================================

NUM_FRANJAS = 768
INI_MEM_PROC = 0x01002000


.section .dtcm,"wa",%progbits
	.align 2

	.global _gm_zocMem
_gm_zocMem:	.space NUM_FRANJAS			@; vector de ocupación de franjas mem.


.section .itcm,"ax",%progbits

	.arm
	.align 2


	.global _gm_reubicar
	@; Rutina de soporte a _gm_cargarPrograma(), que interpreta los 'relocs'
	@; de un fichero ELF, contenido en un buffer *fileBuf, y ajustar las
	@; direcciones de memoria correspondientes a las referencias de tipo
	@; R_ARM_ABS32, a partir de las direcciones de memoria destino de código
	@; (dest_code) y datos (dest_data), y según el valor de las direcciones de
	@; las referencias a reubicar y de las direcciones de inicio de los
	@; segmentos de código (pAddr_code) y datos (pAddr_data)
	@;Parámetros:
	@; R0: dirección inicial del buffer de fichero (char *fileBuf)
	@; R1: dirección de inicio de segmento de código (unsigned int pAddr_code)
	@; R2: dirección de destino en la memoria (unsigned int *dest_code)
	@; R3: dirección de inicio de segmento de datos (unsigned int pAddr_data)
	@; (pila): dirección de destino en la memoria (unsigned int *dest_data)
	@;Resultado:
	@; cambio de las direcciones de memoria que se tienen que ajustar
_gm_reubicar:
push {r0-r12,lr}
	ldr r4,[sp,#14*4]	@;PONEMOS DIRECCIONES ARRIBA DE LA PILA
	push {r1,r2,r3,r4}
	
	ldr r3,[r0,#28]		@;COGEMOS DIRECCION FINAL DEL pAddr_code
	add r3,r0
	ldr r3,[r3,#16]
	add r3,r1

	ldr r10,[r0,#32]		@;Cargamos en r3 header.e_shoff
	add r10, r0			@;Cargamos en r4 la direccion de memoria del primer byte de la tabla de secciones
	ldrh r9,[r0,#48] 	@;Cargamos en r5 el num de secciones
	ldrh r6,[r0,#46]	@;Cargamos en r6 el tamaño de cada seccion
	mov r8,#0
.LmirarSeccionSiguiente:
	mla r4,r6,r8,r10  	@;Cargamos en r4 la posicion del primer byte de la seccion
	ldr R3,[R4,#4] 		@; R3= tipo de la seccion
	cmp R3,#9
	bne .LfinSeccion 	@; si secc de tipo 9(tipo reubicador) -> acceder
	ldr r3,[R4, #16]  	@; R3= offset reubicador
	add r3, r0, r3 		@; r3 = pos reubic
	ldr r11,[r4,#20]	@;R11 = tamaÃ±o de la seccion
	mov r4,r11,lsr#3	@; dividimos entre el tamaÃ±o del reubicador
	mov r11, r4
	mov r4, #1
.LmirarReubSig:
	add r3, #8			@; siguiente reubicador
	ldr R5,[R3, #4] 	@; R3= info del reubicador (si 2 bits bajos = 2 -> R_ARM_ABS32)
	and R5, #0xF	
	cmp R5,#2
	bne .LNoR_ARM_ABS32 	@; Si no es R_ARM_ABS32	-> mirar siguente reubicador
						@; para cada reubicador R_ARM_ABS32:
	ldr R7,[R3]	  		@; R7=direccion sobre la que hay que aplicar la reubicacion
	cmp r7,r12
	blt .Lcodigo		@; si hay un segmento -> codigo, si no -> 
	ldr r1,[sp,#8]
	ldr r2,[sp,#12]
	b .LReubicar
.Lcodigo:
	ldr r1,[sp]
	ldr r2,[sp,#4]
.LReubicar:
	sub r7, r1			@; r_ofs-pAdr -> nº de diferencia(linea donde se encuentra el codigo)
	ldr r12,[r2,r7]		@; direcc donde se han de guardar las lineas
	sub r12, r1			@;	
	add r12, r2
	str r12,[r2,r7]
.LNoR_ARM_ABS32:
	add r4,#1
	cmp r4,r11
	blt .LmirarReubSig	
.LfinSeccion:
	add R8,#1			@; siguiente seccion
	cmp R8,R9			@; si no ultima seccion -> mirar siguiente
	blo .LmirarSeccionSiguiente
	pop {r0-r3}
	pop {r0-r12,pc}

	.global _gm_reservarMem
	@; Rutina para reservar un conjunto de franjas de memoria libres
	@; consecutivas que proporcionen un espacio suficiente para albergar
	@; el tamaño de un segmento de código o datos del proceso (según indique
	@; tipo_seg), asignado al número de zócalo que se pasa por parámetro;
	@; también se encargará de invocar a la rutina _gm_pintarFranjas(), para
	@; representar gráficamente la ocupación de la memoria de procesos;
	@; la rutina devuelve la primera dirección del espacio reservado; 
	@; en el caso de que no quede un espacio de memoria consecutivo del
	@; tamaño requerido, devuelve cero.
	@;Parámetros:
	@;	R0: el número de zócalo que reserva la memoria
	@;	R1: el tamaño en bytes que se quiere reservar
	@;	R2: el tipo de segmento reservado (0 -> código, 1 -> datos)
	@;Resultado:
	@;	R0: dirección inicial de memoria reservada (0 si no es posible)
_gm_reservarMem:
	push {r1-r8,lr}
	mov r3,#0
	mov r4,r1		
.LMasBloques:				@;Buscamos cuantos bloques del vector se necesitan
	sub r4,#32				@; Se restan los bytes que se asignaran
	add r3,#1				@; se suma una unidad a la medida del zocalo
	cmp r4,#0				@; se mira que si ya se han asignado todos los bytes, si no -> asigna otro espacio en el zocalo
	bgt .LMasBloques

	ldr r4,=_gm_zocMem
	mov r5,#0		@;contador de franjas (r5<768)
	mov r6,#0		@;contador de franjas libres 
.LNoFinFranjas:
	ldrb r7,[r4,r5]
	cmp r7,#0		
	addeq r6,#1		@; si franja de zocalo libre -> r6 = 1
	movne r6,#0     @; si franja de zocalo no libre -> r6 = 0 
	cmp r6,#1		
	moveq r8,r5		@;Si franja libre -> guardar posicion
	cmp r6,r3		@; mirar si ya se han asignado todas las franjas
	beq .LHayEspacio @; si -> seguir
	add r5,#1		 @; no -> sumar una franja para guardar
	cmp r5,#NUM_FRANJAS	@; si el numero de franjas que necesitamos es mas pequeño del que tenemos
	blt .LNoFinFranjas	@; mirar la siguiente franja
	b .LNoEspacio @; si no -> devolver 0
.LHayEspacio:
	mov r5,#0
	add r4,r8		@;Nos situamos en la primera franja
.LIntroduceFranja:
	strb r0,[r4,r5]	@; guardamos numero de zocalo en la primera franja libre
	add r5,#1		@; pasamos a la siguiente franja
	cmp r5,r3		@; miramos si es la ultima franja
	blt .LIntroduceFranja	@; si no -> seguir asignando el nº de zocalo a las franjas
	mov r1,r8		
	mov r3,r2
	mov r2,r6
	bl _gm_pintarFranjas
	ldr r6,=INI_MEM_PROC
	add r5,r6,r8,lsl#5		@; r5 = memo inicial + tamaño de bytes a reservar * 32
	mov r0,r5
	b .LFin
.LNoEspacio:
	mov r0,#0
.LFin:
	pop {r1-r8,pc}


	.global _gm_liberarMem
	@; Rutina para liberar todas las franjas de memoria asignadas al proceso
	@; del zócalo indicado por parámetro; también se encargará de invocar a la
	@; rutina _gm_pintarFranjas(), para actualizar la representación gráfica
	@; de la ocupación de la memoria de procesos.
	@;Parámetros:
	@;	R0: el número de zócalo que libera la memoria
_gm_liberarMem:
	push {r1-r9,lr}
	ldr r1,=_gm_zocMem
	mov r2,#0			@;Contador de franjas
	ldr r3,=NUM_FRANJAS
	mov r4,#0			@;r4 = Contiene el valor 0
	mov r6,#0			@;R6 = Comprueba cuando empieza un bloque
	mov r8,#0			@;r8 = Numero de franjas a pintar
	mov r9,#0			@;r9 = Booleano (codigo o datos)
.LmirarSigFranj:
	ldrb r5,[r1,r2]		@;r5 = nºde zocalo que tiene reservada la memoria
	cmp r5,r0			@; comparar con nº de zocalo del cual queremos liberar memo
	bne .LnoNZocalo		@;Si no es igual
	cmp r6,#0
	bne .Lnoprimera     @;Si no es la primera franja del bloque
	add r6,#1			@;Si es la primera franja del bloque se indica que se pasa a la segunda
	mov r7,r2			@;y se guarda la primera franja
.Lnoprimera:
	add r8,#1			@; se añade 1 al numero de franjas a pintar
	strb r4,[r1,r2]		@; se desasigna el zocalo de la franja
	b .Lnoencontrado
.LnoNZocalo:
	cmp r6,#0
	beq .Lnoencontrado	@;Si todavia no hemos encontrado la primera franja del bloque
	mov r6,#0			@;Si se ha encontrado se pone a 0 
	cmp r9,#0
	bne .Ldatos		@;Si r9 no es 0, es un segmento de datos, ya que no es el primero
	add r9,#1
.Ldatos:
	mov r10,r0
	mov r11,r3
	mov r3, #0
	mov r12,r1
	mov r1,r7
	mov r0, #0
	bl _gm_pintarFranjas
	mov r0,r10
	mov r3,r11
	mov r1, r12
	mov r8,#0			@; franjas ya pintadas
.Lnoencontrado:
	add r2,#1			@; se mira la siguiente franja
	cmp r2,r3			@; si esta es menor al n de franjas totales
	blt .LmirarSigFranj
	pop {r1-r9,pc}


	.global _gm_pintarFranjas
	@; Rutina para para pintar las franjas verticales correspondientes a un
	@; conjunto de franjas consecutivas de memoria asignadas a un segmento
	@; (de código o datos) del zócalo indicado por parámetro.
	@;Parámetros:
	@;	R0: el número de zócalo que reserva la memoria (0 para borrar)
	@;	R1: el índice inicial de las franjas
	@;	R2: el número de franjas a pintar
	@;	R3: el tipo de segmento reservado (0 -> código, 1 -> datos)
_gm_pintarFranjas:
	push {r0-r11,lr}
	mov r4,#0x6200000    	@;R4=Base mapa caracteres    
	add r4,#0xc000			@;tile num: 768 * 64 bytes baldosa
	
	ldr r5,=_gs_colZoc
	ldrb r9,[r5,r0]			@;R9= Cogemos color (bits bajos)
	mov r10,r9,lsl#8		@;R10= Color bits altos
	mov r6, r1				@;R6= bit (1 para marcar bits altos 0 para marcar bits bajos)
	mov r5,#0				@;R5= Num baldosas a saltar
	mov r7,#0				@;R7= resto que saltaremos
.LsaltoNBald:
	cmp r6,#8				@; si indice < 8 -> pasar a mirar franjas
	blt .LsaltoNFranj
	sub r6,#8				
	add r5,#1				@; sino -> cambiar color, seguir mirando
	b .LsaltoNBald	
	
.LsaltoNFranj:
	cmp r6,#2				@; si indice <2 -> calcular bits
	blt .LcalculoOffs
	sub r6,#2
	add r7,#2				@; sino -> 
	b .LsaltoNFranj
	
.LcalculoOffs:
	mov r5,r5,lsl#6			@;Calculamos numero de bytes a desplazar
	add r4,r5				@;R4= Primer byte de la baldosa a pintar
	add r4,r7				@;R4= Primer byte a pintar
	mov r8,#0				@;R8= Contador de franjas

	cmp r3,#0
	beq .LCodigo
.LDatos:
	cmp r6,#1
	beq .LBitsAltosD		@;Se pintan los bits 1 y 3 de la franja izquierda del conjunto					
	ldrh r11,[r4,#16]
	and r11,#0xFF00
	orr r11,r9
	strh r11,[r4,#16]
	ldrh r11,[r4,#32]
	and r11,#0xFF00
	orr r11,r9
	strh r11,[r4,#32]
	add r6,#1
	add r8,#1
	cmp r8,r2
	blt .LDatos
	b .Lfin
	
.LBitsAltosD:				@;Se pintan los bits 2 y 4 de la franja derecha del conjunto
	ldrh r11,[r4,#24]
	and r11,#0xFF
	orr r11,r10
	strh r11,[r4,#24]
	ldrh r11,[r4,#40]
	and r11,#0xFF
	orr r11,r10
	strh r11,[r4,#40]
	cmp r7,#6
	bne .LnofinalD
	add r4,#56
	mov r7,#-2
.LnofinalD:
	add r4,#2
	sub r6,#1
	add r8,#1
	add r7,#2
	cmp r8,r2
	blt .LDatos
	
.LCodigo:
	cmp r6,#1
	beq .LBitsAltosC
						@;Se pinta la franja izquierda del conjunto
	ldrh r11,[r4,#16]
	and r11,#0xFF00
	orr r11,r9
	strh r11,[r4,#16]
	ldrh r11,[r4,#24]
	and r11,#0xFF00
	orr r11,r9
	strh r11,[r4,#24]
	ldrh r11,[r4,#32]
	and r11,#0xFF00
	orr r11,r9
	strh r11,[r4,#32]
	ldrh r11,[r4,#40]
	and r11,#0xFF00
	orr r11,r9
	strh r11,[r4,#40]
	add r6,#1
	add r8,#1
	cmp r8,r2
	blt .LCodigo
	b .Lfin
	
.LBitsAltosC:				@;Se pinta la franja derecha del conjunto
	ldrh r11,[r4,#16]
	and r11,#0xFF
	orr r11,r10
	strh r11,[r4,#16]
	ldrh r11,[r4,#24]
	and r11,#0xFF
	orr r11,r10
	strh r11,[r4,#24]
	ldrh r11,[r4,#32]
	and r11,#0xFF
	orr r11,r10
	strh r11,[r4,#32]
	ldrh r11,[r4,#40]
	and r11,#0xFF
	orr r11,r10
	strh r11,[r4,#40]
	cmp r7,#6
	bne .LnofinalC
	add r4,#56
	mov r7,#-2
.LnofinalC:
	add r4,#2
	sub r6,#1
	add r8,#1
	add r7,#2
	cmp r8,r2
	blt .LCodigo
.Lfin:	
	pop {r0-r11,pc}


	.global _gm_rsiTIMER1
	@; Rutina de Servicio de Interrupción (RSI) para actualizar la representa-
	@; ción de la pila y el estado de los procesos activos.
_gm_rsiTIMER1:
	push {r0-r12,lr}
	mov r0,#0x6200000
	ldr r1,=0x12e
	add r0,r1
	ldr r1,=_gd_pcbs
	ldr r2,=_gd_stacks
	ldr r3,=0xB003D00
	mov r4,#0
	mov r12,#119
	
.LporProceso:
	mov r11,#0
	cmp r4,#0
	beq .LSO
	mov r5,#24
	mul r5,r4
	ldr r6,[r1,r5]				@;Miramos si PID activo
	cmp r6,#0
	mov r7,r12
	mov r8,r12
	beq .LCambiarBald
	add r5,#8
	ldr r6,[r1,r5]				@;R6= SP
	add r5,r2,r4,lsl#9
	sub r5,r6
.LnConfig:
	cmp r5,#32
	blt .LPonerBald
	sub r5,#32
	add r11,#1
	b .LnConfig

.LSO:
	mov r5,#24
	mul r5,r4
	add r5,#8
	ldr r6,[r1,r5]				@;R6= SP
	cmp r6,#0
	mov r7,r12
	mov r8,r12
	beq .LCambiarBald
	sub r5,r3,r6
.LnConfigSO:
	cmp r5,#61
	blt .LPonerBald
	sub r5,#61
	add r11,#1
	b .LnConfigSO
	
.LPonerBald:	
	cmp r11,#8
	bge .LCompleta
	add r7,r12,r11
	mov r8,r12
	b .LCambiarBald
.LCompleta:
	sub r11,#8
	add r7,r12,#8
	add r8,r12,r11
.LCambiarBald:
	strh r7,[r0]
	add r0,#2
	strh r8,[r0]
	add r0,#4
	mov r11,#0
	strh r11,[r0]
	add r0,#58
	add r4,#1
	cmp r4,#16
	blt .LporProceso
	
	@;AQUI EMPIEZA REPRESENTACION DE ESTADO
	mov r0,#0x6200000
	ldr r1,=0x134
	add r0,r1 
	mov r1,#178			@; R azul
	ldr r2,=_gd_pidz
	and r2,#0xF			@;Nos quedamos con zocalo de proceso RUN
	mov r2,r2,lsl#6
	strh r1,[r0,r2]
	@;Miramos cola de ready
	mov r1,#57			@; Y blanca
	ldr r2,=_gd_qReady
	ldr r3,=_gd_nReady
	ldr r3,[r3]
	mov r4,#0
.LPerProcRdy:
	cmp r3,#0
	beq .LfinRdy
	ldrb r5,[r2,r4]
	mov r5,r5,lsl#6
	strh r1,[r0,r5]
	add r4,#1
	sub r3,#1
	b .LPerProcRdy
.LfinRdy:
	mov r1,#34			@; B blanca
	ldr r2,=_gd_qDelay
	ldr r3,=_gd_nDelay
	ldr r3,[r3]
	mov r4,#0
.LPerProcDly:
	cmp r3,#0
	beq .LfinDly
	ldrb r5,[r2,r4]
	and r5,#0xFF0000
	mov r5,r5,lsr#7
	strh r1,[r0,r5]
	add r4,#1
	sub r3,#1
	b .LPerProcDly
.LfinDly:
	
	pop {r0-r12,pc}

.end