/*------------------------------------------------------------------------------
	"ORDI.c"
	
	Imprime un array ordenado de (arg + 1) * 10 número aleatorios
	
------------------------------------------------------------------------------*/

#include <GARLIC_API.h>			/* definición de las funciones API de GARLIC */


int _start(int arg)				
{
	if (arg < 0) arg = 0;			// limitar valor máximo y 
	else if (arg > 3) arg = 3;		// valor mínimo del argumento
	
	GARLIC_printf("-- Programa ORDI --\n");
	
	unsigned int maxArray = (arg + 1) * 10;
	int arr[maxArray];
	int i;
	for (i = 0; i < maxArray; i++)
	{
		arr[i] = GARLIC_random();
	}
	
	GARLIC_printf("%3Array %2of %1size %d, %0random.\n", maxArray);
	for (i = 0; i < maxArray; i++)
	{
		if (i == maxArray - 1)
		{
			GARLIC_printf("%d.\n\n", arr[i]);
		}
		else
		{
			GARLIC_printf("%d, ", arr[i]);
		}
		
	}
	
	
    i = 0;
	int key, j;
    for (i = 1; i < maxArray; i++) {
        key = arr[i];
        j = i - 1;
        while (j >= 0 && arr[j] > key) {
            arr[j + 1] = arr[j];
            j = j - 1;
        }
        arr[j + 1] = key;
    }
	GARLIC_printf("Array of size %d, sorted.\n", maxArray);
	for (i = 0; i < maxArray; i++)
	{
		if (i == maxArray - 1)
		{
			GARLIC_printf("%d.\n", arr[i]);
		}
		else
		{
			GARLIC_printf("%d, ", arr[i]);
		}
	}

	return 0;
}