/*------------------------------------------------------------------------------

	"MDET.c" : primer programa de prueba para el sistema operativo GARLIC 1.0;
	
	Determinante de una matriz NxN (N=arg+2) de numeros aleatorios [-10..10]

------------------------------------------------------------------------------*/

#include <GARLIC_API.h>			/* definici�n de las funciones API de GARLIC */

int _start(int arg)				/* funci�n de inicio : no se usa 'main' */
{
	int i, j, rand, aux_rand, det = 0, N = arg+2;
	int matrix[N][N];

	if (arg < 0) arg = 0;			// limitar valor m�ximo y 
	else if (arg > 3) arg = 3;		// valor m�nimo del argumento
	
									// esccribir mensaje inicial
	GARLIC_printf("-- Programa MDET  -  PID (%d) --\n", GARLIC_pid());
	
	for (i = 0; i < N; i++) 
	{
		for (j = 0; j < N; j++)
		{
			rand = GARLIC_random();
			aux_rand = GARLIC_random();
			
			rand = rand % 11;
			if (aux_rand % 2) 
			{
				rand = -rand;
			}
			
			matrix[i][j] = rand;
		}
	}
	
	for (i = 0; i < N; i++){
		for (j = 0; j < N; j++){
			GARLIC_delay(arg);
			if (matrix[i][j] < 0)
			{
				matrix[i][j] = -matrix[i][j];
				GARLIC_printf("%3-%d\t", matrix[i][j]);
				matrix[i][j] = -matrix[i][j];
			}
			else
			{
				GARLIC_printf("%2%d\t", matrix[i][j]);
			}
		}
		GARLIC_printf("\n");
	}
	
	if (N == 2)
	{
		det = matrix[0][0] * matrix[1][1] - matrix[0][1] * matrix[1][0];
	}
	else
	{
		if(N == 3) 
		{
			det = matrix[0][0] * matrix[1][1] * matrix[2][2];
			det -= matrix[0][2] * matrix[1][1] * matrix[2][0];
			det += matrix[0][1] * matrix[1][2] * matrix[2][0];
			det -= matrix[0][1] * matrix[1][0] * matrix[2][2];
			det += matrix[1][0] * matrix[2][1] * matrix[0][2];
			det -= matrix[1][2] * matrix[2][1] * matrix[0][0];
		}
		else
		{
			if(N == 4) 
			{
				int i, j, k, signo = 1, aux_det = 0, aux_matrix[N-1][N-1];
	
				for (i = 0; i < N; i++)
				{
					for (j = 0; j < N; j++)
					{
						for (k = 0; k < N; k++)
						{
							if (k < i)
							{
								aux_matrix[j][k] = matrix[j+1][k];
							}
							else
							{
								aux_matrix[j][k] = matrix[j+1][k+1];
							}
						}
					}
					aux_det = aux_matrix[0][0] * aux_matrix[1][1] * aux_matrix[2][2];
					aux_det-= aux_matrix[0][2] * aux_matrix[1][1] * aux_matrix[2][0];
					aux_det += aux_matrix[0][1] * aux_matrix[1][2] * aux_matrix[2][0];
					aux_det -= aux_matrix[0][1] * aux_matrix[1][0] * aux_matrix[2][2];
					aux_det += aux_matrix[1][0] * aux_matrix[2][1] * aux_matrix[0][2];
					aux_det -= aux_matrix[1][2] * aux_matrix[2][1] * aux_matrix[0][0];
					
					det += signo * matrix[0][i] * aux_det;
					signo = signo * -1;
				}
			} 
			else
			{
				GARLIC_delay(arg);
				//det = det5(matrix);
			}
		}
	}
	
	if(N == 5) 
	{
		GARLIC_printf("(%d)\tERROR MATRIZ 5X5\n", GARLIC_pid());
	}
	else 
	{
		GARLIC_delay(arg);
		if (det < 0)
		{
			det = -det;
			GARLIC_printf("%0(%d)\tDETERMINANTE = -%d\n", GARLIC_pid(), det);
		}
		else
		{
			GARLIC_printf("%0(%d)\tDETERMINANTE = %d\n", GARLIC_pid(), det);
		}
	}
	
	return 0;
}