# GarlicOS: Sistema Operativo Educativo para Nintendo DS

**GarlicOS** es un sistema operativo pedagógico diseñado para la consola Nintendo DS (NDS), desarrollado como parte de una práctica académica en **Estructura de Sistemas Operativos**. Este proyecto combina conceptos fundamentales de sistemas operativos con programación de bajo nivel en C y ensamblador para ARM. 

El objetivo es implementar un microkernel funcional que gestione múltiples procesos de usuario y ofrezca características avanzadas de entrada/salida y gráficos.

---

## Funcionalidades principales

### Gestión de procesos:
- **Ejecución concurrente**:
  - Permite hasta 15 procesos de usuario más un proceso de control del sistema operativo.
- **Multiplexación**:
  - Implementa un sistema de cambio de contexto y colas para procesos listos y bloqueados.
- **Control avanzado**:
  - Retardo de procesos, terminación, y cálculo del porcentaje de uso de CPU.

### Gestión de memoria:
- **Carga dinámica**:
  - Soporte para leer y cargar programas en formato ELF, con reubicación de direcciones.
- **Visualización gráfica**:
  - Representación gráfica del estado de memoria y uso de pilas.

### Gráficos y ventanas:
- **Entorno gráfico**:
  - Gestión de ventanas para cada proceso (hasta 16 ventanas simultáneas).
  - Soporte para texto con formato y gráficos avanzados.
- **Interfaz visual**:
  - Representación de una tabla de procesos en la pantalla inferior, mostrando información como ID, estado, y uso de CPU.

### Interacción con el teclado:
- **Entrada personalizada**:
  - Teclado virtual para capturar entrada de texto desde el usuario.
  - Funciones API específicas para manejar eventos de entrada.

---

## Implementación técnica

- **Lenguajes y herramientas**:
  - Código desarrollado en C y ensamblador para ARM.
  - Uso del entorno de desarrollo DevkitPro y emuladores como DeSmuME.
- **Arquitectura**:
  - Microkernel que gestiona procesos, memoria, gráficos, y dispositivos de entrada.
- **Extensible**:
  - Diseñado para agregar nuevas funcionalidades mediante un API bien estructurado.

---

## Organización del proyecto

El repositorio está estructurado por roles específicos que cada integrante del equipo puede asumir:
- **Gestión del procesador (progP)**:
  - Rutinas para manejo de interrupciones, cambio de contexto y gestión de procesos.
- **Gestión de la memoria (progM)**:
  - Carga de programas, reubicación de direcciones y control de la memoria.
- **Gestión de los gráficos (progG)**:
  - Inicialización del entorno gráfico y funciones para manejo de ventanas.
- **Gestión del teclado (progT)**:
  - Captura y procesamiento de entrada desde un teclado virtual.

---

## API y compatibilidad

GarlicOS ofrece un API que permite a los programas interactuar con el sistema operativo:
- Funciones como `GARLIC_printf`, `GARLIC_delay`, y `GARLIC_clear` facilitan la programación de aplicaciones en el entorno.
- Total compatibilidad binaria entre las versiones 1.0 y 2.0 del sistema.

---

## Objetivo

GarlicOS sirve como herramienta educativa para aplicar conceptos de sistemas operativos, trabajar con hardware embebido, y desarrollar habilidades de programación en equipo usando control de versiones.

--- 
