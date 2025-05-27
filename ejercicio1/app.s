.equ SCREEN_WIDTH, 		640
.equ SCREEN_HEIGH, 		480
.equ BITS_PER_PIXEL,  	32

.equ GPIO_BASE,      0x3f200000
.equ GPIO_GPFSEL0,   0x00
.equ GPIO_GPLEV0,    0x34

.extern draw_submarino_up

.globl main

main:
	// x0 contiene la direccion base del framebuffer
	mov x20, x0	// Guarda la dirección base del framebuffer en x20

	// Pinta toda la pantalla con color inicial
	movz x10, 0x66, lsl 16
	movk x10, 0xB2FF, lsl 0

	mov x2, SCREEN_HEIGH         // Y Size
loop1:
	mov x1, SCREEN_WIDTH         // X Size
loop0:
	stur w10,[x0]  // Colorear el pixel N
	add x0,x0,4	   // Siguiente pixel
	sub x1,x1,1	   // Decrementar contador X
	cbnz x1,loop0  // Si no terminó la fila, salto
	sub x2,x2,1	   // Decrementar contador Y
	cbnz x2,loop1  // Si no es la última fila, salto
	
	// Ahora pinta una franja azul oscura en la mitad inferior
	movz x12, 0x00, lsl 16
	movk x12, 0x00FF, lsl 0  // Color azul oscuro

	mov x1, SCREEN_WIDTH         // X Size
	mov x2, SCREEN_HEIGH         // Y size
	mov x0, x20                 // Dirección base framebuffer

	mov x4, 240    // Altura mitad

	mul x4, x4, x1     // x4 = 240 * 640
	lsl x4, x4, 2      // x4 = (240 * 640) * 4 (bytes por pixel)
	add x0, x0, x4     // Dirección base de la mitad inferior

iLoop:
	mov x1, SCREEN_WIDTH         // X Size

oLoop:
	stur w12, [x0]   // Coloreo el pixel N
	add x0, x0, 4    // siguiente pixel
	sub x1, x1, 1    // decrementa contador X
	cbnz x1, oLoop   // si no termino fila, salto

	subs x2, x2, 1   // decrementa contador Y
	cmp  x2, 240     // comparo con 240 para pintar solo mitad inferior
	bne  iLoop       // si no llego a 240, salto al inicio del loop


// INTENTO DE UN SUBMARINO.  
        mov x0, x20                  // x0 direccion base del frame
	mov x1, SCREEN_WIDTH         // X Size
        mov x2, SCREEN_HEIGH         // Y Size
	mov x3, 360                  // Son posiciones de donde quiero el submarino
        mov x4, 200
	mov x5, 340                  // Este sera el contador
        bl draw_submarino_up         // me lleva a la funcion en otro archivo



 

	// Ejemplo de uso de gpios
	mov x9, GPIO_BASE

	// Setea gpios 0 - 9 como lectura (registros 32 bits)
	str wzr, [x9, GPIO_GPFSEL0]

	// Lee el estado de los GPIO 0 - 31
	ldr w10, [x9, GPIO_GPLEV0]

	// And bit a bit mantiene el resultado del bit 2 en w10
	and w11, w10, 0b10

	// w11 será 1 si había un 1 en la posición 2, sino 0
	lsr w11, w11, 1

	// Bucle infinito
InfLoop:
	b InfLoop
 
