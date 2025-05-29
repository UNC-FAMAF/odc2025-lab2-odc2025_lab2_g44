.global draw_barco
.global draw_mastil
.global draw_sol



draw_mastil:   
    // 
    mov x3, 300            // fila inicial
    mov x6, 200             // alto (cantidad de filas a pintar)
    mov x7, 5             // ancho (cantidad de columnas)

loop_filas_mastil:
    mov x4, 320            // columna inicial
    mov x5, x7             // contador columnas

loop_columnas_mastil:
    mul x11, x3, x1        // x11 = fila * 640
    add x11, x4, x11       // x11 += columna
    lsl x11, x11, 2        // offset en bytes
    add x11, x0, x11       // dirección de memoria final
    stur w12, [x11]        // pintar pixel

    add x4, x4, 1          // siguiente columna
    sub x5, x5, 1
    cbnz x5, loop_columnas_mastil

    sub x3, x3, 1          // fila anterior (hacia arriba)
    sub x6, x6, 1
    cbnz x6, loop_filas_mastil

    draw_barco:
    // Pinta base del barquito
    mov x3, 300            // fila inicial parte de abajo
    mov x6, 60             // alto de la base
    mov x8, 0             // variable auxiliar que va a ensanchar

loop_filas_down:
    mov x7, 250            // 
    add x7, x7,x8            // ancho crece con cada fila
    
     // columna inicial se corre hacia la izquierda para centrar
    mov x4, 320         // centro horizontal (aprox)
    sub x4, x4, x7, LSR #1   // x4 = centro - ancho/2

     mov x5, x7          // contador de columnas

loop_columnas_down:
    mul x11, x3, x1
    add x11, x4, x11
    lsl x11, x11, 2
    add x11, x0, x11
    stur w12, [x11]

    add x4, x4, 1
    sub x5, x5, 1
    cbnz x5, loop_columnas_down

    add x3, x3, 1          // siguiente fila hacia abajo
    sub x8, x8, 1
    sub x6, x6,1
    cbnz x6, loop_filas_down

    ret


 draw_sol:

//------------------- Parte Inferior (DOWN) -------------------//
draw_circulo_down:
    mov x3, 110        // fila inicial
    mov x6, 20         // cantidad de filas
    mov x8, 0          // ancho adicional

loop_down:
    mov x7, 100
    add x7, x7, x8     // ancho actual

    mov x4, 160
    sub x4, x4, x7, lsr #1  // centro - ancho/2
    mov x5, x7              // contador de columnas

loop_down1:
    mul x11, x3, x1
    add x11, x4, x11
    lsl x11, x11, 2
    add x11, x0, x11
    stur w12, [x11]

    add x4, x4, 1
    sub x5, x5, 1
    cbnz x5, loop_down1

    sub x3, x3, 1
    add x8, x8, 2      // ensanchar de a 2 pixeles
    sub x6, x6, 1
    cbnz x6, loop_down

//------------------- Parte Media -------------------//
draw_circulo_medio:
    mov x3, 90         // fila inicial
    mov x6, 10         // cantidad de filas
    mov x7, 140        // ancho fijo

loop_medio:
    mov x4, 160
    sub x4, x4, x7, lsr #1
    mov x5, x7

loop_medio1:
    mul x11, x3, x1
    add x11, x4, x11
    lsl x11, x11, 2
    add x11, x0, x11
    stur w12, [x11]

    add x4, x4, 1
    sub x5, x5, 1
    cbnz x5, loop_medio1

    sub x3, x3, 1
    sub x6, x6, 1
    cbnz x6, loop_medio

//------------------- Parte Superior (UP) -------------------//
draw_circulo_up:
    mov x3, 80         // fila inicial
    mov x6, 20         // cantidad de filas
    mov x8, 0          // estrechamiento

loop_up:
    mov x7, 140
    sub x7, x7, x8     // achicar de a poco

    mov x4, 160
    sub x4, x4, x7, lsr #1
    mov x5, x7

loop_up1:
    mul x11, x3, x1
    add x11, x4, x11
    lsl x11, x11, 2
    add x11, x0, x11
    stur w12, [x11]

    add x4, x4, 1
    sub x5, x5, 1
    cbnz x5, loop_up1

    sub x3, x3, 1
    add x8, x8, 2      // se achica de a 2 pixeles
    sub x6, x6, 1
    cbnz x6, loop_up

    ret

