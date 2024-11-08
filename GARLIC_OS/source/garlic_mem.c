/*------------------------------------------------------------------------------

	"garlic_mem.c" : fase 2 / programador M

	Funciones de carga de un fichero ejecutable en formato ELF, para GARLIC 2.0

------------------------------------------------------------------------------*/
#include <nds.h>
#include <filesystem.h>
#include <dirent.h>			// para struct dirent, etc.
#include <stdio.h>			// para fopen(), fread(), etc.
#include <stdlib.h>			// para malloc(), etc.
#include <string.h>			// para strcat(), memcpy(), etc.

#include <garlic_system.h>	// definici�n de funciones y variables de sistema

#define INI_MEM 0x01002000		
#define EI_NIDENT 16

typedef struct{
	unsigned char e_ident[EI_NIDENT]; 	//0-15
	unsigned short e_type;				
	unsigned short e_machine;			//18-19
	unsigned long int e_version;
	unsigned long int e_entry;			//24-27	
	unsigned long int e_phoff;			
	unsigned long int e_shoff;			//32-35
	unsigned long int e_flags;			
	unsigned short e_ehsize;			//40-41
	unsigned short e_phentsize;			
	unsigned short e_phnum;				//44-45
	unsigned short e_shentsize;			
	unsigned short e_shnum;				//48-49
	unsigned short e_shstrndx;			
}Elf32_Ehdr;


typedef struct{
	unsigned long int p_type;
	unsigned long int p_offset;
	unsigned long int p_vaddr;
	unsigned long int p_paddr;
	unsigned long int p_filesz;
	unsigned long int p_memsz;
	unsigned long int p_flags;
	unsigned long int p_align;
}Elf32_Phdr;

/* _gm_initFS: inicializa el sistema de ficheros, devolviendo un valor booleano
					para indiciar si dicha inicializaci�n ha tenido �xito; */
int _gm_initFS()
{
	return nitroFSInit(NULL);	// inicializar sistema de ficheros NITRO
}


/* _gm_listaProgs: devuelve una lista con los nombres en clave de todos
			los programas que se encuentran en el directorio "Programas".
			 Se considera que un fichero es un programa si su nombre tiene
			8 caracteres y termina con ".elf"; se devuelven s�lo los
			4 primeros caracteres de los programas (nombre en clave).
			 El resultado es un vector de strings (paso por referencia) y
			el n�mero de programas detectados */
int _gm_listaProgs(char* progs[])
{
	DIR *pdir;
	struct dirent *dir;
	char *name;
	char *type;
	int nProg=0;
	pdir = opendir("/Programas/");
	
	if(pdir!=NULL){
		while((dir = readdir (pdir)) != NULL)
		{
			if((strcmp(dir->d_name, ".")!=0) && (strcmp(dir->d_name, "..")!=0)){
				if(strlen(dir->d_name)==8){
					strcat(dir->d_name, ".");
					name=strtok(dir->d_name, ".");
					type=strtok(NULL, ".");
					if(strcmp(type,"elf")==0){
						progs[nProg]=(char * ) malloc(5);
						strcpy(progs[nProg],name);
						strcat(progs[nProg],"\0");
						nProg+=1;
					}
				}
			
			}
		
		}
	
	}
	closedir(pdir);
	return nProg;
}


/* _gm_cargarPrograma: busca un fichero de nombre "(keyName).elf" dentro del
				directorio "/Programas/" del sistema de ficheros, y carga los
				segmentos de programa a partir de una posici�n de memoria libre,
				efectuando la reubicaci�n de las referencias a los s�mbolos del
				programa, seg�n el desplazamiento del c�digo y los datos en la
				memoria destino;
	Par�metros:
		zocalo	->	�ndice del z�calo que indexar� el proceso del programa
		keyName ->	vector de 4 caracteres con el nombre en clave del programa
	Resultado:
		!= 0	->	direcci�n de inicio del programa (intFunc)
		== 0	->	no se ha podido cargar el programa
*/
intFunc _gm_cargarPrograma(int zocalo, char *keyName)
{
	Elf32_Phdr *segment;
	int pos, offset,espacio=1,puntSegm[2],ph_type;
	int adresaFinal=0;
	
	char path[21]="/Programas/";
	strcat(path, keyName);
	strcat(path, ".elf");
	FILE* pdir = fopen(path, "rb"); //Buscar fichero "(Keyname).elf" en "nitrofiles/Programas"
	Elf32_Ehdr *cabecera = malloc(sizeof(Elf32_Ehdr));
	
	if (pdir) { //se encuentra fitx? si ->
		int tamFitx;
		fseek(pdir,0,SEEK_END);	
		tamFitx=ftell(pdir);
		fseek(pdir,0,SEEK_SET);  //indica el tamany del fitxer
		
		int *punter=malloc(tamFitx); 
		fread(punter,1,tamFitx,pdir); //puntero a memo dinam con el contenido del fichero;
		
		if(cabecera)
		{
			fseek(pdir,0,SEEK_SET);		//acceder a la cabecera para obtener pos (offset) y tam de la tabla de segm
			fread(cabecera,1,sizeof(Elf32_Ehdr),pdir);
			offset=cabecera->e_entry - 0x8000;
			segment= malloc(sizeof(Elf32_Phdr) * cabecera->e_phnum);	//tabla de segmentos
			if(segment)	
			{
				int nSegm = 0;
				while((nSegm<cabecera->e_phnum)&&(espacio))	//mientras haya segmentos
				{ 	 
					pos=cabecera->e_phoff+(nSegm*cabecera->e_phentsize);	// siguiente segmento
					fseek(pdir,pos,SEEK_SET);
					fread(&segment[nSegm],1,sizeof(Elf32_Phdr),pdir);
					
					if(segment[nSegm].p_type==1){	// si es segmento de tipo 1		
						if(segment[nSegm].p_flags == 5){
							ph_type=0;
						}else{
							ph_type=1;
						}
							//Reservamos memoria	
						puntSegm[nSegm]=(int) _gm_reservarMem(zocalo,segment[nSegm].p_memsz,ph_type);
						if(puntSegm[nSegm] != 0) //HAY ESPACIO
						{
							if(segment[nSegm].p_flags == 5){ 
								adresaFinal = (puntSegm[nSegm] + offset);
							} //si es de codig guardam a dir inicial
							segment[nSegm].p_offset +=(int) punter;	// guarda al offset la posicio de memo a on es troba el segment 
							_gs_copiaMem((const void *)segment[nSegm].p_offset,(void *) puntSegm[nSegm],segment[nSegm].p_filesz);
											//posicio del segment, adreça final, tamany del segment
						}else{
							espacio=0;
							adresaFinal=0;
							if(nSegm>0) {_gm_liberarMem(zocalo);}
						}
					}
					nSegm++; 
				}
				if(espacio!=0)
				{
					if(cabecera->e_phnum==1){
							_gm_reubicar((char*)punter,(unsigned int)segment[0].p_paddr,(unsigned int *) puntSegm[0],0,0);
					}else{
							_gm_reubicar((char*)punter,(unsigned int)segment[0].p_paddr,(unsigned int *) puntSegm[0],(unsigned int ) segment[1].p_paddr,(unsigned int *) puntSegm[1]);
					}
				}		
				free(segment);
			}
			free(cabecera);
		}
		free(punter);
		fclose(pdir);
	}
	
	
	
	return ((intFunc) adresaFinal);
}

