.equ SCREEN_WIDTH,  640
.equ SCREEN_HEIGHT,  480
.equ BITS_PER_PIXEL, 32


.extern draw_barco
.extern draw_sol


.globl main

main:
                               // x0 = dirección base del framebuffer
    mov x20, x0               // guardamos base framebuffer

   // ---------------- MITAD SUPERIOR: DEGRADADO ATARDECER  ----------------
mov w2, SCREEN_HEIGHT
lsr w2, w2, 1             // w2 = 240 (alto de cada mitad)

mov w3, SCREEN_WIDTH
mov w4, 0                 // contador de líneas
superior_y:
    mov w1, w3            // columnas (ancho)

    // Colores invertidos
    // Arriba: púrpura (128, 0, 128)
    // Abajo: naranja (255, 140, 0)
    // Interpolación invertida:
    // R: 128 -> 255 (delta +127)
    // G: 0   -> 140 (delta +140)
    // B: 128 -> 0   (delta -128)

    // R
    mov w5, #127
    mul w6, w4, w5
    mov w7, #240
    udiv w6, w6, w7
    mov w8, #128
    add w14, w8, w6        // R = 128 + step

    // G
    mov w5, #140
    mul w6, w4, w5
    udiv w6, w6, w7
    mov w8, #0
    add w15, w8, w6        // G = 0 + step

    // B
    mov w5, #128
    mul w6, w4, w5
    udiv w6, w6, w7
    mov w8, #128
    sub w16, w8, w6        // B = 128 - step

    // Componer color
    lsl w14, w14, #16         // R << 16
    lsl w15, w15, #8          // G << 8
    orr w14, w14, w15         // R | G
    orr w14, w14, w16         // R | G | B
    mov w17, #0xFF            // Alpha (opcional)
    lsl w17, w17, #24
    orr w15, w17, w14         // ARGB

superior_x:
    str w15, [x0]
    add x0, x0, 4
    subs w1, w1, 1
    b.ne superior_x

    add w4, w4, 1
    subs w2, w2, 1
    b.ne superior_y


// ---------------- MITAD INFERIOR: DEGRADADO AZUL MARINO A NEGRO ----------------
mov w2, SCREEN_HEIGHT
lsr w2, w2, 1             // 240
mov w3, SCREEN_WIDTH
mov w4, 0                 // línea

degradado_y:
    mov w1, w3
    mov w5, w4            // y actual

    // Calcular R (255 → 0)
    mov w6, #255
    mul w7, w5, w6
    mov w8, #240
    udiv w9, w7, w8
    sub w10, w6, w9       // R = 255 - step

    // Calcular G (165 → 0)
    mov w11, #165
    mul w12, w5, w11
    udiv w13, w12, w8
    sub w14, w11, w13     // G = 165 - step

    // Calcular B (0 → 255)
    mov w15, #255
    mul w16, w5, w15
    udiv w17, w16, w8     // B = step

    // Componer color ARGB
    lsl w10, w10, #16     // R << 16
    lsl w14, w14, #8      // G << 8
    orr w18, w10, w14     // R | G
    orr w18, w18, w17     // RGB
    mov w19, #0xFF
    lsl w19, w19, #24
    orr w13, w19, w18     // ARGB

degradado_x:
    str w13, [x0]
    add x0, x0, 4
    subs w1, w1, 1
    b.ne degradado_x

    add w4, w4, 1
    subs w2, w2, 1
    b.ne degradado_y




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
    stur w12, [x11]

    add x4, x4, 1
    sub x5, x5, 1
    cbnz x5, loop_sombra_barco

bl draw_barco


    //--------- Sol -------------------//
mov x1, SCREEN_WIDTH
mov x0, x20                 // inicializamos el x0 con la direcc base del frame

bl draw_sol


 // --------- Lineas del agua ---------//
.section .data
tabla_Y_posiciones_naranja: .dword 260, 280, 250, 275, 280, 290, 291, 310
tabla_X_posiciones_naranja: .dword 40, 87, 470, 210, 578, 500, 350, 459   

tabla_Y_posiciones_violeta :  .dword 330, 290, 366, 378
tabla_X_posiciones_violeta : .dword 530, 160, 100, 540

tabla_Y_posiciones_azul: .dword 390, 394, 400, 400, 415, 426, 458, 432, 467, 473
tabla_X_posiciones_azul : .dword 30, 299, 40, 430, 320, 200, 366, 3, 574, 105


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
movz x9, 0x9C, lsl 16   
movk x9, 0x7FC7, lsl 0  // color violeta
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


//----------------------------------------------TEXTO---------------------------------------------------------------------------------------//

bl Odc_2025

  // ---------------- Bucle infinito ----------------
InfLoop:
    b InfLoop

 
