/*------------------------------------------------------------------------------

	"garlic_graf.c" : fase 2 / programador G

	Funciones de gestión de las ventanas de texto (gráficas), para GARLIC 2.0

------------------------------------------------------------------------------*/
#include <nds.h>

#include <garlic_system.h>	// definición de funciones y variables de sistema
#include <garlic_font.h>	// definición gráfica de caracteres

/* definiciones para realizar cálculos relativos a la posición de los caracteres
	dentro de las ventanas gráficas, que pueden ser 4 o 16 */
#define NVENT	16				// número de ventanas totales
#define PPART	4				// número de ventanas horizontales o verticales
								// (particiones de pantalla)
#define VCOLS	32				// columnas y filas de cualquier ventana
#define VFILS	24
#define PCOLS	VCOLS * PPART	// número de columnas totales (en pantalla)
#define PFILS	VFILS * PPART	// número de filas totales (en pantalla)

const unsigned int char_colors[] = {240, 96, 64};	// amarillo, verde, rojo

// Variables globales para utilizar en todas las funciones
int bg2, bg3, bg2MapDir;
char str, str2, borrarLinea[] = "    ", borrarLineaRSI[] = "        ";

/* _gg_generarMarco: dibuja el marco de la ventana que se indica por parámetro*/
void _gg_generarMarco(int v, int color)
{
	//direccion inicial mapa del fondo, necesitamos dir map 3
	// bgGetMapPtr returns a u16 pointer to map
	
	u16 * mapPointer = bgGetMapPtr(bg3);
	
	// desplazamiento parametrizado con PPART
	// desplazamos las filas, nos movemos por la primera columna
	mapPointer = (u16 *)mapPointer + ((v / PPART) * VFILS * PCOLS);
	
	// desplazamiento de columnas si ventana impar
	// sumamos la cantidad de columnas a a la fila correspondiente
	if (v % PPART != 0)
	{
		mapPointer = (u16 *)mapPointer + ((v % PPART) * VCOLS);
	}
	// Recorremos las filas
	for (int i = 0; i  < VFILS; i++)
	{
		// Recorremos las columnas
		for (int j = 0; j < VCOLS; j++)
		{
			// Si estamos en la primera fila, comprovamos si es la primera, ultima o otra colum
			if (i == 0)
			{	
				if (j == 0)
				{
					mapPointer[j] = 103 + color * 128; // primera fila, podemos poner j solo
				}
				else if (j == VCOLS - 1)
				{
					mapPointer[j] = 102 + color * 128;
				}
				else
				{
					mapPointer[j] = 99 + color * 128;
				}
			}
			// Si estamos en la ultima fila, comprovamos si es la primera, ultima o otra colum
			else if (i == VFILS - 1)
			{
				if (j == 0)
				{
					mapPointer[i * PCOLS + j] = 100 + color * 128;	// fila * col totales + col  
				}
				else if (j == VCOLS - 1)
				{
					mapPointer[i * PCOLS + j] = 101 + color * 128;
				}
				else
				{
					mapPointer[i * PCOLS + j] = 97 + color * 128;
				}
			}
			// Si es otra fila, comprovamos si estamos en la primera o ultima fila.
			else
			{
				if (j == 0)
				{
					mapPointer[i * PCOLS + j] = 96 + color * 128;
				}
				else if(j == VCOLS - 1)
				{
					mapPointer[i * PCOLS + j] = 98 + color * 128;
				}
			}			
		}
	}
	
}


/* _gg_iniGraf: inicializa el procesador gráfico A para GARLIC 1.0 */
void _gg_iniGrafA()
{
	// Procesador gráfico en modo 5, con display en la parte superior.
	videoSetMode(MODE_5_2D);
	lcdMainOnTop();
	
	// Reservar banco de memoria de vídeo A
	vramSetBankA(VRAM_A_MAIN_BG_0x06000000);
	
	// Inicializar gráficos en Extended rotation, tamaño total de 512*512 pixeles

	// Tipo extended rotation, cada índice de baldosa es de 2 bytes.
	
	// Tamaño mapa =  posiciones * bytes/posición
	// Tamaño mapa = 64x64 posiciones * 2 bytes/posición = 8192 bytes (8 Kbytes) (Separación de 5).
	// Hay una diferencia de 2kb entre los mapBase de ambos mapas.
	

	
	// mapBase bg1 = donde comienza el contenidpo del mapa 1 --> virtA + 0 * 2kb = 0x0600 0000
	// mapBase bg2 = donde comienza el contenidpo del mapa 2 --> virtA + 5 * 2kb = 0x0600 2800
	// tileBase = donde comienza el contenido de las baldosas --> virtA + 4 * 16kb = 0x0601 0000
	
	bg2 = bgInit(2, BgType_ExRotation, BgSize_ER_1024x1024, 0, 4);
	bg3 = bgInit(3, BgType_ExRotation, BgSize_ER_1024x1024, 16, 4);
	
	// Dirección inicial del fondo 2 para funcion arm
	bg2MapDir = (int)bgGetMapPtr(bg2);
	
	// Prioridad del fondo 3 más que 2
	bgSetPriority(bg2, 1);
	bgSetPriority(bg3, 0);
	
	int base = 4096;
	
	// Decomprimir el contenido de la fuente de letras, dirección inicial de baldosas 
	decompress(garlic_fontTiles, bgGetGfxPtr(bg3), LZ77Vram);
	// amarillo
	decompress(garlic_fontTiles, bgGetGfxPtr(bg3) + base, LZ77Vram);
	// verde
	decompress(garlic_fontTiles, bgGetGfxPtr(bg3) + base * 2, LZ77Vram);
	// rojo
	decompress(garlic_fontTiles, bgGetGfxPtr(bg3) + base * 3, LZ77Vram);
	
	
	// Copiar la paleta de la fuente de letras, dirección inicial paleta principal
	dmaCopy(garlic_fontPal, BG_PALETTE, sizeof(garlic_fontPal));
	
	// Tamaño mapa baldosas = 128 baldosas * 8x8 píxeles/baldosa * 1 byte/píxel = 8.192 bytes 
	// Tamaño de baldosas = 8x8 pixeles/baldosa * 1 byte/pixel = 64 bytes
	// Por cada posición del mapa de baldosas se guarda un halfword --> 8192 / 2 = 4096 bytes en memoria
	
	// dirección inicial de las baldosas
	u16* dirBaldosas = bgGetGfxPtr(bg3);
	// primer bucle para cambiar el color, segundo bucle recorre las baldosas
	
	for (int i = 0; i < 3; i++)
	{
		for (int j = 0; j < base; j++)
		{
			if (dirBaldosas[(i+1) * base + j] == 0xFFFF)	// si todos los pixeles blancos, cambiamos todo
				dirBaldosas[(i+1) * base + j] = char_colors[i] + (char_colors[i] << 8);
				
			else if ((dirBaldosas[(i+1) * base + j] & 0xFF00) == 0XFF00)	// si primer byte blanco solo, cambiamos ese
				dirBaldosas[(i+1) * base + j] =  ((char_colors[i] << 8 ) + 0x00FF) & dirBaldosas[(i+1) * base + j];
		
			else if ((dirBaldosas[(i+1) * base + j] & 0x00FF) == 0X00FF)	// si segundo byte blanco, cambiamos ese
				dirBaldosas[(i+1) * base + j] = (char_colors[i] + 0xFF00) & dirBaldosas[(i+1) * base + j];
		}
	}

	// generar los marcos
	// _gg_generarMarco()
	
	for (int i = 0; i < NVENT; i++)
	{
		_gg_generarMarco(i, 3);
	}
	
	// escalar fondos 2 y 3, reduccion 50%
	
	bgSetScale(bg2, 1024, 1024);
	bgSetScale(bg3, 1024, 1024);
	bgUpdate();	
}



/* _gg_procesarFormato: copia los caracteres del string de formato sobre el
					  string resultante, pero identifica los códigos de formato
					  precedidos por '%' e inserta la representación ASCII de
					  los valores indicados por parámetro.
	Parámetros:
		formato	->	string con códigos de formato (ver descripción _gg_escribir);
		val1, val2	->	valores a transcribir, sean número de código ASCII (%c),
					un número natural (%d, %x) o un puntero a string (%s);
		resultado	->	mensaje resultante.
	Observación:
		Se supone que el string resultante tiene reservado espacio de memoria
		suficiente para albergar todo el mensaje, incluyendo los caracteres
		literales del formato y la transcripción a código ASCII de los valores.
*/
void _gg_procesarFormato(char *formato, unsigned int val1, unsigned int val2,
																char *resultado)
{
	// formatos --> c   d, x   s
	// solo dos formatos por cadena
	// si formato s, recorrer string y guardar en resultado (necesitamos puntero a la string)
	// si d o x, funciones ensamblador
	// si c, resultado directamente, todos estsos dependiendo de val1 y val2 (max 2)
	// caracteres literales de formato (%)
	
	//sabemos que la conversión es de un número de 32 bits, es decir, 2^32 posibles valores (10 numeros)
	// además tenemos que añadir el centina --> char[11]
	
	char numString[11], valor;
	
	int i = 0, j = 0; // iterador para la string de formato y para resultado
	int contFormato = 2;
	
	valor = formato[i];
	// bucle para navegar toda la string de formato
	while (formato[i] != '\0')
	{
		if (valor == '%') // si x posición de la string tiene % y aún quedan valores para transcribir
		{
			i++; valor = formato[i];
			if ((valor == 'c') && (contFormato > 0))// si formato 'c', comprovar cantidad del contador y cast de int a char (ya es ascii)
			{
				if (contFormato == 2)
				{
					resultado[j] = (char) val1;
				}
				else
				{
					resultado[j] = (char) val2;
				}
				j++;
				contFormato--;
				i++;
			
			}
			
			else if ((valor == 'd') && (contFormato > 0))		// si formato 'd', convertir valor en representación decimal dentro de string acabada en '\0'
			{
				if (contFormato == 2)	// sizeof devuelve lenght del array
				{				
					_gs_num2str_dec(numString, sizeof(numString), val1); // devuelve vector de chars con cod ascii
				}
				else
				{
					_gs_num2str_dec(numString, sizeof(numString), val2);
				}
				// hay que recorrer el vector de chars y ponerlo en resultado
				int k = 0;
				while (numString[k] != '\0')
				{
					if (numString[k] != ' ')// puede que el vector no se llene, centinela siempre al final del vec
					{
						resultado[j] = numString[k];
						j++;
					}
					k++;
				}
				contFormato--; 
				i++;
			}

			else if ((valor == 'x') && (contFormato > 0))		// si formato 'x', convertir valor en representación hexadecimal dentro de string acabada en '\0'
			{
				if (contFormato == 2)
				{
					_gs_num2str_hex(numString, sizeof(numString), val1); // devuelve vector de chars con cod ascii
				}
				else
				{
					_gs_num2str_hex(numString, sizeof(numString), val2);
				}
				// hay que recorrer el vector de chars y ponerlo en resultado
				int k = 0;
				while (numString[k] != '\0')
				{
					if (numString[k] != '0') // no se puede visualizar el numero sino
					{
						resultado[j] = numString[k];
						j++;
					}				
					k++;
				}			
				contFormato--; 
				i++;
			}
			
			else if ((valor == 's') && (contFormato > 0))//  si formato 's', necesitamos puntero a cadena de chars a partir del valor parametrizado 
			{
				char * p;
				if (contFormato == 2)
				{
					p = (char *) val1;
				}
				else
				{
					p = (char *) val2;
				}
				// bucle para escribir la string en resultado
				int k = 0;
				while (p[k] != '\0')
				{
					resultado[j] = p[k];
					j++;
					k++;
				}	
				contFormato--; 
				i++;
			}
			
			// si el siguiente char es un % o tenemos char % pero contformato 0
			else if ((valor == '%') || (contFormato == 0) || (valor >= 48 && valor <= 51))
			{
				if (valor == '%')
				{
					resultado[j] = valor;
					
				}
				else 
				{
					resultado[j] = '%';
					j++;
					resultado[j] = valor;
					
				}
				i++;
				j++; 
			}
		}
		// valor ascii literal
		else
		{
			resultado[j] = formato[i];
			i++;
			j++;
		}
		valor = formato[i];
	}
}


/* _gg_escribir: escribe una cadena de caracteres en la ventana indicada;
	Parámetros:
		formato	->	cadena de formato, terminada con centinela '\0';
					admite '\n' (salto de línea), '\t' (tabulador, 4 espacios)
					y códigos entre 32 y 159 (los 32 últimos son caracteres
					gráficos), además de códigos de formato %c, %d, %x y %s
					(max. 2 códigos por cadena)
		val1	->	valor a sustituir en primer código de formato, si existe
		val2	->	valor a sustituir en segundo código de formato, si existe
					- los valores pueden ser un código ASCII (%c), un valor
					  natural de 32 bits (%d, %x) o un puntero a string (%s)
		ventana	->	número de ventana (de 0 a 3)
*/
void _gg_escribir(char *formato, unsigned int val1, unsigned int val2, int ventana)
{	
	// pControl --> 16 bits altos: número de línea (0-23)
				//16 bits bajos: caracteres pendientes (0-32) (num de cols)
	
	// pChars	--> vector de 32 caracteres pendientes --> se añaden los caracteres de la string final despues de analizarlos
				 // indicando el código ASCII de cada posición
	int colorAct = _gd_wbfs[ventana].pControl >> 28; // shift right de 28 bits para quedarnos con los 4 altos
	int filaAct  = (_gd_wbfs[ventana].pControl >> 16) & 0x00000FFF;		// shift right de 16 bits y and para quedarnos con los 12 bits	
	int charCount = _gd_wbfs[ventana].pControl & 0xFFFF;  	// and de 16 bits a todo 1, nos quedamos con los bits bajos
	
	char resultado[3*VCOLS]="";		// Reservar string de texto def, tres lineas max.
	_gg_procesarFormato(formato, val1, val2, resultado); // nos pasa por referencia la string en resultado
	
	int i = 0; // iterador para la string de resultado
	
	// bucle hasta centinela de la string
	while (resultado[i] != '\0')
	{	// si resultado es una marca de color, entre 48 y 51 por ascii
		if (resultado[i] == '%' && (resultado[i + 1] >= 48 && resultado[i + 1] <= 51))
		{
			switch (resultado[i + 1])
			{
				case '0':
						colorAct = 0;
						break;
				case '1':
						colorAct = 1;
						break;
				case '2':
						colorAct = 2;
						break;
				case '3':
						colorAct = 3;
						break;
				
			}
			i+=2;
		}
		
	// si se trata de un tabulador ('\t'), añadir espacios en blanco hasta la próxima columna (posición del buffer) con índice múltiplo de 4
		if (resultado[i]  == '\t')
		{
			// Comparamos si el índice actual es múltiplo de 4 y no hay salto de linea 
			if ((charCount % 4 == 0) && (charCount < VCOLS))
			{
				_gd_wbfs[ventana].pChars[charCount] = ' ';
				charCount++;
			}			
			while ((charCount % 4 != 0) && (charCount < VCOLS))
				{
					_gd_wbfs[ventana].pChars[charCount] = ' ';
					charCount++; 
				}
			
			
		}
		// si se trata de un carácter literal, se añade el codigo ASCII
		else if (charCount < VCOLS && resultado[i] != '\n')
		{
			_gd_wbfs[ventana].pChars[charCount] = resultado[i] + (colorAct * 128);
			charCount++;
		}
		
		// si se trata de un salto de línea ('\n') o se ha llenado el buffer de línea de la ventana, esperar el siguiente período de retroceso vertical,
		if ((resultado[i] == '\n') || (charCount == VCOLS))
		{
			_gp_WaitForVBlank(); 	//esperar siguiente retroceso vertical
			
			// ultima linea actual == vfils, desplazamos
			if (filaAct == VFILS)
			{
				_gg_desplazar(ventana); 
				filaAct--;		// decrementamos fila actual
			}
			
			_gg_escribirLinea(ventana, filaAct, charCount); 
			charCount = 0;				// reset del contador de caracteres
			filaAct++;			// incrementar la linea de escritura
		}
		
		// en cada iteración se acutaliza el pcontrol, shift left de la fila actual para devolverlos a los bits altos + los charCount, q eran los bits bajos
		_gd_wbfs[ventana].pControl= (colorAct << 28) +  (filaAct << 16) + charCount;
		i++;
	}

}