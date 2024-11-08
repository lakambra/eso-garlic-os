@;==============================================================================
@;
@;	"garlic_itcm_graf.s":	cÃ³digo de rutinas de soporte a la gestiÃ³n de
@;							ventanas grÃ¡ficas (versiÃ³n 2.0)
@;
@;==============================================================================

NVENT	= 16					@; nÃºmero de ventanas totales
PPART	= 4					@; nÃºmero de ventanas horizontales o verticales
							@; (particiones de pantalla)
L2_PPART = 2				@; log base 2 de PPART

VCOLS	= 32				@; columnas y filas de cualquier ventana
VFILS	= 24
PCOLS	= VCOLS * PPART		@; nÃºmero de columnas totales (en pantalla)
PFILS	= VFILS * PPART		@; nÃºmero de filas totales (en pantalla)

WBUFS_LEN = 68				@; longitud de cada buffer de ventana (324)

.section .itcm,"ax",%progbits

	.arm
	.align 2


	.global _gg_escribirLinea
	@; Rutina para escribir toda una linea de caracteres almacenada en el
	@; buffer de la ventana especificada;
	@;ParÃ¡metros:
	@;	R0: ventana a actualizar (int v)
	@;	R1: fila actual (int f)
	@;	R2: nÃºmero de caracteres a escribir (int n)
_gg_escribirLinea:
	push {r3-r7, lr}

	@;COLUMNA --> (v % ppart) * VCOLS
	mov r3, #PPART		@; r4 = PPART
	sub r3, r3, #1		@; PPART-
	and r4, r0, r3		@; r4 = r0 and r4 (v and PPART-1)
	mov r3, #VCOLS		@; r3 = VCOLS
	mul r5, r3, r4		@; r5= (v % ppart) * VCOLS
	
	@;FILA --> (v / ppart) * PCOLS * VFILS
	mov r3, #L2_PPART	@; r3 = L2_PPART
	lsr r4, r0, r3		@; r6 = ( v / PPART), shif right de 1 o 2 bits, depende de fase
	mov r3, #PCOLS		@; r3 = PCOLS
	mul r6, r3, r4		@; r6 = PCOLS * ( v / PPART)
	
	mov r7, #VFILS		@; r7 = VFILS
	@; DESPLAZAMIENTO DE FILAS  COLUMNAS
	mla r4, r6, r7, r5	@; r4 = (PCOLS * ( v / PPART) * VFILS)  ((v % ppart) * VCOLS)
		
	@; desplazamiento de fila act  despl. total
	mla r5, r1, r3, r4 @; r5 = (filaACt * PCOLS)  (PCOLS * ( v / PPART) * VFILS)  ((v % ppart) * VCOLS)
	lsl r5, #1				@; Baldosas son 2 bytes, halfword, mulitplicamos por dos la direcciÃ³n
	
	@; dir ini bg 2  despl. total
	ldr r4, =bg2MapDir		@; variable con la direcciÃ³n del fondo 2
	ldr r4, [r4]			@; valor de la variable a r4
	
	add r4, r5				@; r4 = DirIniBg2  Desplazamiento total
	
	@; cogemos vector _gd_wbfs
	ldr r5, =_gd_wbfs		@; r5 = @_gd_wbfs
	mov r6, #WBUFS_LEN		@; vector de 324 del buffer de v
	mul r3,r6, r0				@; r6 = WBUFS_LEN * v --> nos colocamos en el buffer correcto
	
	add r5, r3				@; r5 = @_dg_wbfs  (WBUFS_LEN * v)
	add r5, #4				@; primeros 4 bytes son p control, accedimos a pChars
	
	lsl r2, #1
	mov r6, #0				@; iterador para bucle (i)
.LWhile:
	ldrh r3, [r5, r6]		@; r3 = _gd_wbfs[v].pChars[i] --> son halfwords ahora
	sub r3, #32				@; restar a ASCII 32, obtenemos codigo baldosa
	strh r3, [r4]			@; Guardamos codigo baldosa al fondo (2 bytes, halfword)
	add r4, #2				@; Sumamos 2 bytes para la siguiente posiciÃ³n
	add r6, #2				@; i;
	cmp r6, r2				@; Comparar i < charCount
	blo .LWhile				@; Si cierto volvemos al bucle	

	pop {r3-r7, pc}
	
	
	
	.global _gg_desplazar
	@; Rutina para desplazar una posiciÃ³n hacia arriba todas las filas de la
	@; ventana (v), y borrar el contenido de la Ãºltima fila
	@;ParÃ¡metros:
	@;	R0: ventana a desplazar (int v)
_gg_desplazar:
	push {r1-r7, lr}
	
	@;COLUMNA --> (v % ppart) * VCOLS
	mov r3, #PPART		@; r4 = PPART
	sub r3, r3, #1		@; PPART-
	and r4, r0, r3		@; r4 = r0 and r4 (v and PPART-1)
	mov r3, #VCOLS		@; r3 = VCOLS
	mul r5, r3, r4		@; r5= (v % ppart) * VCOLS
	
	@;FILA --> (v / ppart) * PCOLS * VFILS
	mov r3, #L2_PPART	@; r3 = L2_PPART
	lsr r4, r0, r3		@; r6 = ( v / PPART), shif right de 1 o 2 bits, depende de fase
	mov r3, #PCOLS		@; r3 = PCOLS
	mul r6, r3, r4		@; r6 = PCOLS * ( v / PPART)
	
	mov r7, #VFILS		@; r7 = VFILS
	@; DESPLAZAMIENTO DE FILAS + COLUMNAS
	mla r3, r6, r7, r5	@; r4 = (PCOLS * ( v / PPART) * VFILS) + ((v % ppart) * VCOLS)
	lsl r3, #1			@; Baldosas son halfwords, multiplicamos por dos (bytes) el desplazamiento de mapa	
	
	@; dir ini bg 2  despl. total	
	ldr r1, =bg2MapDir		@; DirecciÃ³n que contiene @bg2MapDir
	ldr r1, [r1]			@; valor de bgMapDir
	add r1, r3				@; r1 = bg2MapDir  Desplaamiento de v
	
	@; desplazar cada fila una posiciÃ³n hacia arriba
	@; dos registros con la fila actual y uno con la siguiente
	@; bucle para recorrer la siguiente y colocar sus posiciones a la actual
	@; una vez VCOLS == 0, pasamos a la siguiente fila
	@; una vez VFILS == 0, borramos la ultima linea
	
	
	mov r2, r1				@; r2 = desplazamiento en mem.
	mov r3, #PCOLS			@; r3 = PCOLS
	lsl r3, #1				@; Baldosas son halfwords, 2 bytes, pcols * 2
	mov r4, #VFILS			@; r4 = VFILS
	add r2, r3				@; r2 = desplazamiento para obtener la siguiente fila
	
.LWhile1:					@; Primer bucle para todas las filas
	mov r5, #VCOLS			@; r5 = VCOLS, nos sirve como iterador del bucle
	mov r6, #0				@; r6 = desplazador para r1/r2
.LWhile2:					@; Segundo bucle para recorrer toda una fila y desplazar sus columnas una posiciÃ³n arriba
	ldrh r7, [r2, r6]		@; r7 = siguiente fila cogemos columna r6
	strh r7, [r1, r6]		@; store de r7 en la fila actual en su columna correspondiente
	add r6, #2				@; r6 = r6  2, ya que baldosa es halfword
	sub r5, #1				@; vcols--
	cmp r5, #0				@; comparamos vcols con 0
	bhi .LWhile2			@; mientras r5 > 0, saltamos
	
	sub r4, #1				@; vfils--
	add r1, r3				@; pasamos a la siguiente fila
	add r2, r3					
	cmp r4, #0				@; comparamos vfils con 0
	bhi .LWhile1			@; si r4 > 0, saltamos a .LWhile1 para nueva fila a desplazar
	
	sub r1, r3				@; hemos llegado a ultima fila, r1 = r1 - pcols ya que hemos avanzado 1 de mas
	mov r2, #0				@; r3 = baldosa 0, en negro
	mov r3, #0				@; desplazamiento para las baldosas
	mov r4, #VCOLS			@; r4 = VCOLS
	
.LWhile3:
	strh r2, [r1, r3]		@; store del halword
	add r3, #2				@; desplazador  2
	sub r4, #1				@; vcols--
	cmp r4, #0				@; comprar vcols con 0
	bhi .LWhile3			@; si vcols > 0, saltamos a Lwhile3

							@; si ascii < 32, no modificar 
	pop {r1-r7, pc}

	.global _gg_escribirLineaTabla
	@; escribe los campos bÃƒÂ¡sicos de una linea de la tabla correspondiente al
	@; zÃƒÂ³calo indicado por parÃƒÂ¡metro con el color especificado; los campos
	@; son: nÃƒÂºmero de zÃƒÂ³calo, PID, keyName y direcciÃƒÂ³n inicial
	@;ParÃƒÂ¡metros:
	@;	R0 (z)		->	nÃƒÂºmero de zÃƒÂ³calo
	@;	R1 (color)	->	nÃƒÂºmero de color (de 0 a 3)
_gg_escribirLineaTabla:
	push {r0-r6, lr}
	
	mov r4, r0 					@; mov del zocalo y color a r4 y r5 respectivamente
	mov r5, r1					@; necesitamos registros r0-r4 libres para funciÃ³n _gs_escribirStringSub
	
	ldr r0, =_gd_pcbs			@; obtenemos direcciÃ³n del vector con los PCBs
	mov r1, #24					@; Cada pos del vector es de 24 bytes (6 declaraciones * 4 bytes)
	mla r6, r4, r1, r0			@; r3 = num zocalo * 24 + dir ini vector
	
	ldr r2, [r6, #0]			@; Primer valor de la estrucutra, PID

	cmp r4, #0					@; Si estamos en el primer zocalo, escribimos su linea con PID 0
	beq .LescribirLinea
	
	cmp r2, #0					@; PID diferente de 0
	bne .LescribirLinea			@; Escribimos nueva linea
	
	ldr r0, =borrarLinea		@; string para vaciar linea			
	add r1, r4, #4				@; Fila zÃ³calo
	mov r2, #4					@; Columna PID
	mov r3, r5					@; Color
	bl _gs_escribirStringSub	@; Vaciamos PID
	
	mov r2, #9					@; Columna keyname
	bl _gs_escribirStringSub 	@; Vaciamos keyname
	b .LescribirZocalo			@; Color del zocalo sigue igual
	
.LescribirLinea:
	ldr r0, =str				@; string para guardar resultado de funciÃ³n
	mov r1, #3					@; lenght de la string
	bl _gs_num2str_dec			
	
	ldr r0, =str				@; pasamos resultado a r0
	add r1, r4, #4				@; Fila zÃ³calo
	mov r2, #5					@; Columna PDI
	mov r3, r5					@; Color
	bl _gs_escribirStringSub
	
	cmp r4, #0					@; Miramos si estamos en zocalo 0
	ldrne r0, [r6, #16]			@; si no lo estamos, keyname de los demas procesos
	ldreq r1, [r6, #16]			@; si lo estamos cargamos y guardamos en r0 GARL
	streq r1, [r0]		
	
	add r1, r4, #4				@; Fila zÃ³calo
	mov r2, #9					@; Columna keyname
	mov r3, #0					@; Color en blanco
	bl _gs_escribirStringSub
	
.LescribirZocalo:
	ldr r0, =str				@; string para guardar resultado de funcion
	mov r1, #3					@; lenght string
	mov r2, r4					@; pasamos numero de zocalo
	bl _gs_num2str_dec
	
	ldr r0, =str				@; guardamos resultado en r0
	add r1, r4, #4				@; Fila zÃ³calo
	mov r2, #1					@; Columna zÃ³calo
	mov r3, r5					@; Color
	bl _gs_escribirStringSub
	
	pop {r0-r6, pc}


	.global _gg_escribirCar
	@; escribe un carÃƒÂ¡cter (baldosa) en la posiciÃƒÂ³n de la ventana indicada,
	@; con un color concreto;
	@;ParÃƒÂ¡metros:
	@;	R0 (vx)		->	coordenada x de ventana (0..31)
	@;	R1 (vy)		->	coordenada y de ventana (0..23)
	@;	R2 (car)	->	cÃƒÂ³digo del carÃƒÂ cter, como nÃƒÂºmero de baldosa (0..127)
	@;	R3 (color)	->	nÃƒÂºmero de color del texto (de 0 a 3)
	@; pila (vent)	->	nÃƒÂºmero de ventana (de 0 a 15)
_gg_escribirCar:
	push {r4-r8, lr}

	ldr r4, [sp, #24]	@; 5 registros apilados + lr

	@;COLUMNA --> (v % ppart) * VCOLS
	mov r5, #PPART		@; r5 = PPART
	sub r5, r5, #1		@; PPART-
	and r6, r4, r5		@; r6 = r4 and r5 (v and PPART-1)
	mov r7, #VCOLS		@; r7 = VCOLS
	mul r5, r6, r7		@; r5= (v % ppart) * VCOLS
	
	@;FILA --> (v / ppart) * PCOLS * VFILS
	mov r6, #L2_PPART	@; r6 = L2_PPART
	lsr r7, r4, r6		@; r6 = ( v / PPART), shif right de 1 o 2 bits, depende de fase
	mov r8, #PCOLS		@; r3 = PCOLS
	mul r6, r8, r7		@; r6 = PCOLS * ( v / PPART)
	
	@; DESPLAZAMIENTO DE FILAS + COLUMNAS
	mov r7, #VFILS		@; r7 = VFILS
	mla r8, r6, r7, r5	@; r4 = (PCOLS * ( v / PPART) * VFILS) + ((v % ppart) * VCOLS)
	
	@; DESPLAZAMIENTO COORDENADA
	mov r4, #PCOLS		@; r4 = PCOLS
	mla r5, r4, r1, r8	@; r5 = PCOLS * vy + desplazamiento ventana --> nos colocamos en la fila correcta
	add r5, r0			@; r5 = r5 + vx --> coordenada correcta
	lsl r5, #1			@; cada baldosa 2 bytes, lsl de 1 para multiplicar por 2

	ldr r4, =bg2MapDir  @; variable que contiene direcciÃ³n mapa bg2
	ldr r4, [r4]		@; direcciÃ³n bg2
	add r4, r5			@; direcciÃ³n bg2 mÃ¡s desplazamiento de coordenada
	
	mov r5, r3, lsl #7	@; r5 = color * 128
	add r5, r2			@; r5 --> baldosa con el color correspondiente
	strh r5, [r4]		@; guardamos en pos r4 valor de r5
	
	pop {r4-r8, pc}


	.global _gg_escribirMat
	@; escribe una matriz de 8x8 carÃƒÂ¡cteres a partir de una posiciÃƒÂ³n de la
	@; ventana indicada, con un color concreto;
	@;ParÃƒÂ¡metros:
	@;	R0 (vx)		->	coordenada x inicial de ventana (0..31)
	@;	R1 (vy)		->	coordenada y inicial de ventana (0..23)
	@;	R2 (m)		->	puntero a matriz 8x8 de cÃƒÂ³digos ASCII (direcciÃƒÂ³n)
	@;	R3 (color)	->	nÃƒÂºmero de color del texto (de 0 a 3)
	@; pila	(vent)	->	nÃƒÂºmero de ventana (de 0 a 15)
_gg_escribirMat:
	push {r4-r8, lr}
	ldr r4, [sp, #24]	@; 5 registros apilados + lr

	@;COLUMNA --> (v % ppart) * VCOLS
	mov r5, #PPART		@; r5 = PPART
	sub r5, r5, #1		@; PPART-
	and r6, r4, r5		@; r6 = r4 and r5 (v and PPART-1)
	mov r7, #VCOLS		@; r7 = VCOLS
	mul r5, r6, r7		@; r5= (v % ppart) * VCOLS
	
	@;FILA --> (v / ppart) * PCOLS * VFILS
	mov r6, #L2_PPART	@; r6 = L2_PPART
	lsr r7, r4, r6		@; r6 = ( v / PPART), shif right de 1 o 2 bits, depende de fase
	mov r8, #PCOLS		@; r3 = PCOLS
	mul r6, r8, r7		@; r6 = PCOLS * ( v / PPART)
	
	@; DESPLAZAMIENTO DE FILAS + COLUMNAS
	mov r7, #VFILS		@; r7 = VFILS
	mla r8, r6, r7, r5	@; r4 = (PCOLS * ( v / PPART) * VFILS) + ((v % ppart) * VCOLS)
	
	@; DESPLAZAMIENTO COORDENADA
	mov r4, #PCOLS		@; r4 = PCOLS
	mla r5, r4, r1, r8	@; r5 = PCOLS * vy + desplazamiento ventana --> nos colocamos en la fila correcta
	add r5, r0			@; r5 = r5 + vx --> coordenada correcta
	lsl r5, #1			@; cada baldosa 2 bytes, lsl de 1 para multiplicar por 2

	ldr r4, =bg2MapDir  @; variable que contiene direcciÃ³n mapa bg2
	ldr r4, [r4]		@; direcciÃ³n bg2
	add r4, r5			@; direcciÃ³n bg2 mÃ¡s desplazamiento de coordenada
	
	mov r5, r3, lsl #7	@; r5 = color * 128
	
	mov r7, #0			@; i = 0, recorrer  matriz de chars
	mov r6, #0			@; contador de elementos puesto en una fila
	b .LescribirChar
	
.LnuevaFila:
	mov r6, #PCOLS		@; vuelta completa
	lsl r6, #1			@; cada pos halfword
	add r4, r6			@; sumamos a bg2 dir
	sub r4, #16			@; -16 ya que queremos escribir al principio, 8 pos (char) * 2 = 16
	mov r6, #0			@; contador columnas a colocar
	
.LescribirChar:	
	ldrb r8, [r2, r7]	@; obtenemos valor de matriz
	cmp r8, #0			@; comparamos si es transparente
	beq .LnuevoChar		@; si es asi, no se hace nada, cogemos siguiente char
	sub r8, #32			@; restamos ascii
	
	add r8, r5			@; sumamos color a la baldosa
	strh r8, [r4]		@; colocamos en bg2
	
.LnuevoChar:
	add r7, #1			@; mÃ¡s 1 elemento colocado
	cmp r7, #64			@; comparamos con los 64 a colocar
	beq .LFinish 		@; si es igual, acabamos bucle
	
	add r4, #2			@; siguiente pos mapa, halfword
	add r6, #1			@; -1 columna a colocar
	cmp r6, #8			@; comparamos con 0
	beq .LnuevaFila		@; si es igual, nueva fila
	
	b .LescribirChar
.LFinish:
	
	pop {r4-r8, pc}


	.global _gg_rsiTIMER2
	@; Rutina de Servicio de InterrupciÃƒÂ³n (RSI) para actualizar la representa-
	@; ciÃƒÂ³n del PC actual.
_gg_rsiTIMER2:
	push {r0-r5, lr}
								@; Comenzamos en r4 para dejar los primers registros para las funciones
	ldr r4, =_gd_pcbs			@; obtenemos direcciÃ³n del vector con los PCBs
	mov r5, #0					@; Primer zocalo

.LWhile4:
	ldr r2, [r4, #0]			@; Primer valor de la estrucutra, PID

	cmp r5, #0					@; Si estamos en el primer zocalo, escribimos su linea con PID 0
	beq .LescribirLinea2
	
	cmp r2, #0					@; PDI diferente de 0
	bne .LescribirLinea2		@; Escribimos nueva linea
	
	ldr r0, =borrarLineaRSI		@; string para vaciar linea			
	add r1, r5, #4				@; Fila zÃ³calo
	mov r2, #14					@; Columna PC
	mov r3, #0					@; Color
	bl _gs_escribirStringSub	@; Vaciamos PID
	b .LescribirZocalo2			@; Color del zocalo sigue igual
	
.LescribirLinea2:
	ldr r0, =str2				@; string para guardar resultado de funciÃ³n
	mov r1, #9					@; lenght de la string, 8 + centinela
	ldr r2, [r4, #4]			@; 	Accedemos al PC dentro de la estructura del PCB
	bl _gs_num2str_hex			
	
	ldr r0, =str2				@; pasamos resultado a r0
	add r1, r5, #4				@; Fila zÃ³calo
	mov r2, #14					@; Columna PC
	mov r3, #0					@; Color
	bl _gs_escribirStringSub
	
.LescribirZocalo2:
	add r4, #24					@; pasamos al siguiente PCB
	add r5, #1					@; contador de zocalos hechos
	cmp r5, #16					@; si es menor que 16, leemos los que quedan
	blo .LWhile4
	
	pop {r0-r5, pc}
.end