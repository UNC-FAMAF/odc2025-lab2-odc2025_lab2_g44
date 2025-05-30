.equ SCREEN_WIDTH,  640
.equ SCREEN_HEIGH,  480
.equ BITS_PER_PIXEL, 32


.extern draw_barco

.globl main

main:
    // x0 = dirección base del framebuffer
    mov x20, x0               // guardamos base framebuffer

    // ---------------- MITAD SUPERIOR: CELESTE ----------------
    mov w2, SCREEN_HEIGH
    lsr w2, w2, 1             // w2 = 240 (alto de cada mitad)

    mov w3, SCREEN_WIDTH
    mov w4, 0                 // contador de líneas

superior_y:
    mov w1, w3                // columnas (ancho)

    //color celeste combino rojo verde y azul
    //azul en los bits mas altos , verde en el medio y rojo en los bits mas bajos  
superior_x:
    // Color celeste: 0x00FFCC00 (R=0, V=204, A=255)
    superior_x:
    // Color celeste más claro: (R=100, G=255, B=255)
    mov w10, 255   // verde
    mov w11, 100   // rojo
    mov w12, w11
    orr w12, w12, w10, lsl #8
    mov w13, 255   // azul
    orr w12, w12, w13, lsl #0

    str w12, [x0]
    add x0, x0, 4
    subs w1, w1, 1
    b.ne superior_x


    add w4, w4, 1
    subs w2, w2, 1
    b.ne superior_y //si uedan filas, repito

    // ---------------- MITAD INFERIOR: DEGRADADO AZUL ----------------
    mov w2, SCREEN_HEIGH
    lsr w2, w2, 1             // 240 (la otra mitad)
    mov w3, SCREEN_WIDTH
    mov w4, 0                 // reinicio línea

degradado_y:
    mov w1, w3
    mov w5, w4                // y actual

    // verde=200 pasa a verde=0 y el azul siempre es 255
degradado_x:
    mov w6, 200               // verde base 
    mul w7, w5, w6            // y * 200
    mov w8, 240
    udiv w9, w7, w8           // división entera (w7 / 240)
    sub w10, w6, w9           // verde resultado

    // azul fijo
    mov w11, w10              // V (verde calculado)
    mov w12, 0                // R
    mov w13, w12
    orr w13, w13, w11, lsl #8     // V << 8 | R
    mov w14, 255              // B
    orr w13, w13, w14, lsl #0    // A << 16 | V << 8 | R

    str w13, [x0]
    add x0, x0, 4
    subs w1, w1, 1
    b.ne degradado_x
    
    add w4, w4, 1
    subs w2, w2, 1
    b.ne degradado_y




    // BARQUITO  
    mov x0, x20                  // Dirección base del framebuffer
mov x1, SCREEN_WIDTH         // Ancho de la pantalla
mov x2, SCREEN_HEIGH         // Alto de la pantalla


// Mástil (negro)
movz x12, 0x0000, lsl 16
movk x12, 0x0000, lsl 0      // Color negro
bl draw_mastil

// -------- Vela izquierda (blanca) ----------
movz x12, 0xFF, lsl 16
movk x12, 0xB266, lsl 0       // Color blanco

mov x3, 100         // fila inicial (un poco más arriba del barco)
mov x4, 315         // columna justo a la izquierda del mástil
mov x5, 100          // altura de la vela
mov x6, 0           // dirección izquierda
bl draw_vela

// -------- Vela derecha (blanca) ----------
mov x3, 100
mov x4, 330         // columna justo a la derecha del mástil
mov x5, 100
mov x6, 1           // dirección derecha
bl draw_vela


movz x12, 0xE9, lsl 16
movk x12, 0x0E0E, lsl 0      // Color ROJO

mov x3, 360                  // Fila inicial
mov x4, 200                  // Columna inicial
mov x5, 340                   // Ancho del submarino
bl draw_barco

    //---------Circulo Sol-------------------//

movz x12, 0xF7, lsl 16
movk x12, 0xE80C, lsl 0     // color amarillo

mov x1, SCREEN_WIDTH       // inicializamos ancho del frame
mov x0, x20                 // inicializamos el x0 con la direcc base del frame

bl draw_sol


    // ---------------- Bucle infinito ----------------
InfLoop:
    b InfLoop


 
