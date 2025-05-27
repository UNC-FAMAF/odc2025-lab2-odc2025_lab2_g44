	.equ SCREEN_WIDTH, 		640
	.equ SCREEN_HEIGH, 		480
	.equ BITS_PER_PIXEL,  	32

	.equ GPIO_BASE,      0x3f200000
	.equ GPIO_GPFSEL0,   0x00
	.equ GPIO_GPLEV0,    0x34

	.globl main

main:
	// x0 contiene la direccion base del framebuffer
 	mov x20, x0	// Guarda la dirección base del framebuffer en x20
	//---------------- CODE HERE ------------------------------------

	movz x10, 0xC7, lsl 16
	movk x10, 0x1585, lsl 00

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
	
 
 	movz x12, 0x00, lsl 16
	movk x12, 0x00FF, lsl 00  // Guardamos el color azul oscuro

	mov x1, SCREEN_WIDTH         // X Size 640
        mov x2, SCREEN_HEIGH         // Y size 480
        add x0, x20, XZR            // guarda la dirección de memoria del frame en X0

        add x4, XZR, 240    // x4 = 240

        mul x4, X4, x1     // X4 = 240 * 640
        lsl x4, X4, 2      // X4 = (240 * 640) * 4
        add x0, X0, X4    // Ahora la dirección base es la mitad del arreglo

iLoop:  mov x1, SCREEN_WIDTH         // X Size

oLoop : stur w12, [X0]   // Coloreo el pixel N
        add x0, x0, 4    // siguiente pixel
        sub x1, x1, 1    // Decrementa contador X
        cbnz x1, oLoop  // Si no termino la fila, salto
        subs x2, x2, 1  // Decrementar contador Y
        cmp  x2, 240    // Compara si llego a iterar 240 veces
        B.ne iLoop      // Si aun no llego, salto
 
	// Ejemplo de uso de gpios
	mov x9, GPIO_BASE

	// Atención: se utilizan registros w porque la documentación de broadcom
	// indica que los registros que estamos leyendo y escribiendo son de 32 bits

	// Setea gpios 0 - 9 como lectura
	str wzr, [x9, GPIO_GPFSEL0]

	// Lee el estado de los GPIO 0 - 31
	ldr w10, [x9, GPIO_GPLEV0]

	// And bit a bit mantiene el resultado del bit 2 en w10
	and w11, w10, 0b10

	// w11 será 1 si había un 1 en la posición 2 de w10, si no será 0
	// efectivamente, su valor representará si GPIO 2 está activo
	lsr w11, w11, 1

	//---------------------------------------------------------------
	// Infinite Loop

InfLoop:
	b InfLoop
