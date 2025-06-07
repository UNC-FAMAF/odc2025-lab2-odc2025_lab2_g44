.equ SCREEN_WIDTH,  640
.equ SCREEN_HEIGHT,  480
.equ BITS_PER_PIXEL, 32



// Tablas definidas para dibujar las lineas del agua. Las llamadas a estas tablas estan a partir de la linea 204 //

tabla_Y_posiciones_naranja: .dword 260, 280, 250, 275, 280, 290, 291, 310, 290, 318 
tabla_X_posiciones_naranja: .dword 40, 87, 470, 210, 578, 500, 350, 459, 160, 545

tabla_Y_posiciones_violeta:  .dword 347, 366, 378, 352
tabla_X_posiciones_violeta: .dword 330, 100, 540, 461

tabla_Y_posiciones_azul: .dword 390, 394, 400, 400, 415, 426, 458, 432, 467, 473
tabla_X_posiciones_azul: .dword 30, 299, 40, 430, 320, 200, 366, 3, 574, 105


.globl main

main:
                               // x0 = dirección base del framebuffer
    mov x20, x0               // guardamos base framebuffer

  // ---------------- MITAD DE ARRIBA: DEGRADADO DEL CIELO AL ATARDECER ----------------

mov w2, SCREEN_HEIGHT     // Guardamos la altura total de la pantalla
lsr w2, w2, 1             // Dividimos la altura a la mitad (usaremos solo la parte de arriba)

mov w3, SCREEN_WIDTH      // Guardamos el ancho de la pantalla
mov w4, 0                 // Empezamos desde la primera línea (fila 0)

superior_y:
    mov w1, w3            // Empezamos desde la primera columna en esta línea

    // Queremos hacer un cambio de color desde púrpura hasta naranja
    // Cambiaremos los valores de rojo, verde y azul poco a poco por cada línea

    // ROJO va de 128 a 255 (sube)
    mov w5, #127
    mul w6, w4, w5        // Calculamos cuánto subir el rojo en esta línea
    mov w7, #240
    udiv w6, w6, w7
    mov w8, #128
    add w14, w8, w6       // Color rojo para esta línea

    // VERDE va de 0 a 140 (sube)
    mov w5, #140
    mul w6, w4, w5
    udiv w6, w6, w7
    mov w8, #0
    add w15, w8, w6       // Color verde para esta línea

    // AZUL va de 128 a 0 (baja)
    mov w5, #128
    mul w6, w4, w5
    udiv w6, w6, w7
    mov w8, #128
    sub w16, w8, w6       // Color azul para esta línea

    // Juntamos los colores para formar el color final
    lsl w14, w14, #16     // Rojo se coloca en su lugar
    lsl w15, w15, #8      // Verde se coloca en su lugar
    orr w14, w14, w15     // Rojo + Verde
    orr w14, w14, w16     // Rojo + Verde + Azul
    mov w17, #0xFF
    lsl w17, w17, #24     // Usamos 0xFF para que el color se vea bien
    orr w15, w17, w14     // Color final listo

// Dibuja la línea horizontal completa con ese color
superior_x:
    str w15, [x0]         // Escribimos un píxel
    add x0, x0, 4         // Avanzamos al siguiente píxel
    subs w1, w1, 1        // Restamos una columna
    b.ne superior_x       // Si no llegamos al final, seguimos

    add w4, w4, 1         // Pasamos a la siguiente línea
    subs w2, w2, 1        // Restamos una línea
    b.ne superior_y       // Si no llegamos al final, seguimos

// ---------------- MITAD DE ABAJO: DEGRADADO DEL MAR AL ANOCHECER ----------------

mov w2, SCREEN_HEIGHT
lsr w2, w2, 1             // Otra vez 240 líneas (la mitad de la pantalla)
mov w3, SCREEN_WIDTH
mov w4, 0                 // Empezamos desde la primera línea de la parte de abajo

degradado_y:
    mov w1, w3            // Empezamos desde la primera columna
    mov w5, w4            // Línea actual

    // Cambiamos el color desde azul marino hasta negro

    // ROJO va de 255 a 0 (baja)
    mov w6, #255
    mul w7, w5, w6
    mov w8, #240
    udiv w9, w7, w8
    sub w10, w6, w9       // Color rojo para esta línea

    // VERDE va de 165 a 0 (baja)
    mov w11, #165
    mul w12, w5, w11
    udiv w13, w12, w8
    sub w14, w11, w13     // Color verde para esta línea

    // AZUL va de 0 a 255 (sube)
    mov w15, #255
    mul w16, w5, w15
    udiv w17, w16, w8     // Color azul para esta línea

    // Juntamos los colores para esta línea
    lsl w10, w10, #16     // Rojo en su lugar
    lsl w14, w14, #8      // Verde en su lugar
    orr w18, w10, w14     // Rojo + Verde
    orr w18, w18, w17     // Rojo + Verde + Azul
    mov w19, #0xFF
    lsl w19, w19, #24     // Agregamos transparencia fuerte (para que se vea)
    orr w13, w19, w18     // Color final listo

// Dibuja la línea completa
degradado_x:
    str w13, [x0]         // Escribimos un píxel
    add x0, x0, 4         // Avanzamos al siguiente píxel
    subs w1, w1, 1        // Restamos una columna
    b.ne degradado_x      // Si no terminamos, seguimos

    add w4, w4, 1         // Pasamos a la siguiente línea
    subs w2, w2, 1        // Restamos una línea
    b.ne degradado_y      // Si no terminamos, seguimos


//------------------- Mastil ------------------- //  

mov x0, x20                  // Dirección base del framebuffer
mov x1, SCREEN_WIDTH         // Ancho de la pantalla
mov x2, SCREEN_HEIGHT         // Alto de la pantalla


// Mástil (negro)
movz x12, 0x66, lsl 16
movk x12, 0x3300, lsl 0      // Color marrón

bl draw_mastil


// ------------ Vela izquierda ----------- //
movz x12, 0xFE, lsl 16
movk x12, 0xFFE4, lsl 0       // Color crema

mov x3, 130         // fila inicial 
mov x4, 145         // columna justo a la izquierda del mástil
mov x5, 120          // altura de la vela
mov x6, 0           // dirección izquierda
bl draw_vela

// -------- Vela derecha ------------//
mov x3, 130
mov x4, 160         // columna justo a la derecha del mástil
mov x5, 120
mov x6, 1           // dirección derecha
bl draw_vela


//----------- Barco ---------------//
movz x12, 0x66, lsl 16
movk x12, 0x3300, lsl 0      // Color marrón

mov x3, 360                  // Fila inicial
mov x4, 190                  // Columna inicial
mov x5, 340                   // Ancho del submarino

// Línea negra debajo del barco (sombra)
mov x3, 345           // fila justo debajo
mov x4, 50            // columna inicial
mov x5, 200           // ancho
movz x12, 0x00, lsl 16
movk x12, 0x0000, lsl 0   // color negro

loop_sombra_barco:
    mul x11, x3, x1
    add x11, x4, x11
    lsl x11, x11, 2
    add x11, x0, x11
    str w12, [x11]

    add x4, x4, 1
    sub x5, x5, 1
    cbnz x5, loop_sombra_barco

bl draw_barco


    //--------- Sol -------------------//
mov x1, SCREEN_WIDTH
mov x0, x20                 // inicializamos el x0 con la direcc base del frame

bl draw_sol


 // --------- Lineas del agua ---------//

   // Primeras lineas mas cercanas al sol
ldr x19, =tabla_Y_posiciones_naranja
ldr x20, =tabla_X_posiciones_naranja
movz x9, 0xFD, lsl 16   
movk x9, 0x9A04, lsl 0  // color naranja
mov x21, 8

bl dibujar_lineas_agua

    // Lineas a mitad del mar
ldr x19, =tabla_Y_posiciones_violeta
ldr x20, =tabla_X_posiciones_violeta
movz x9, 0x77, lsl 16   
movk x9, 0x6EB3, lsl 0  // color violeta
mov x21, 4

bl dibujar_lineas_agua

     // Lineas mas alejadas del sol
ldr x19, =tabla_Y_posiciones_azul
ldr x20, =tabla_X_posiciones_azul
movz x9, 0x44, lsl 16   
movk x9, 0x59C3, lsl 0  // color azul
mov x21, 10

bl dibujar_lineas_agua


//-------------Bandera----------------//
movz x12, 0xFA, lsl 16
movk x12, 0x462A, lsl 0       // Color marrón

mov x3, 55         // fila inicial
mov x4, 150        // columna inicial (mástil)
mov x15, 50        // altura
mov x6, 1          // dirección derecha

bl draw_bandera


//---------------------TEXTO---------------------//

Odc_2025:
    mov x2, 160       // columna inicial
    mov x3, 85      // fila
    mov x4, 0        // índice "O"
    bl draw_letra

    add x2, x2, 6
    mov x4, 1        // "d"
    bl draw_letra

    add x2, x2, 6
    mov x4, 2        // "c"
    bl draw_letra

    add x2, x2, 6
    mov x4, 3        // espacio
    bl draw_letra

    add x2, x2, 6
    mov x4, 4        // "2"
    bl draw_letra

    add x2, x2, 6
    mov x4, 5        // "0"
    bl draw_letra

    add x2, x2, 6
    mov x4, 4        // "2"
    bl draw_letra

    add x2, x2, 6
    mov x4, 6        // "5"
    bl draw_letra


  // ---------------- Bucle infinito ----------------
InfLoop:
    b InfLoop

 
