#include <GARLIC_API.h>	



/** successio de Faraday: successio de fraccions irreductibles entre el 0 i l'1
* cada terme de la succesio es el cocient de la suma dels numeradors 
* i la suma dels denominadors dels seus termes veins
**/
unsigned int lim(int arg){
	unsigned int limite, max;
    limite = GARLIC_random();
    max=(arg+1)*3;
	if (limite < 2) limite = 2;			    // limitar valor maximo y 
	else while (limite > max) limite = GARLIC_random();    // valor minimo del limite
	return limite;
}
unsigned int div(int lim, int nume, int deno){
	unsigned int quo, num, den, rest;
	num=lim+nume;
	den=deno;
	GARLIC_divmod(num,den,&quo,&rest);
	return quo;
}

int _start(int arg)				/* funcion de inicio : no se usa 'main' */
{
	unsigned int limite=lim(arg);
									// escribir mensaje inicial
	GARLIC_printf("-- Programa FARE V2 -  PID (%d) --\n", GARLIC_pid());
    GARLIC_printf("Serie de farey amb el numero %d: \n",limite);
	GARLIC_printf("\n");
	typedef struct { int n, d; } frac; //estructura de les fraccions n-> numerador, d->denominador
	frac f1 = {0, 1}, f2 = {1, limite}, t; 

	GARLIC_printf("0/1, 1/"); // els primers nombres sempre seran 0/1 y 1/limit
	GARLIC_printf("%d, ", limite);
	unsigned int quoc;
	while (f2.d > 1) {  //es fa un recorregut sumant les fraccions per obtenir fraccions noves
        quoc=div(limite, f1.d, f2.d);
		t = f1; 
        f1 = f2; 
        f2 = (frac) { f2.n * quoc - t.n, f2.d * quoc - t.d }; // es modifica la fraccio per que sigui irreductible
		GARLIC_printf(" %d/%d,", f2.n, f2.d);
	}
	GARLIC_printf("\n");
	return 0;
}