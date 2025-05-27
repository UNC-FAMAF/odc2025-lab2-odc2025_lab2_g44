.global draw_submarino

draw_submarino:
    // Pinta la parte de arriba del submarino (de 360 a 400 en Y)
    mov x3, 360            // fila inicial
    mov x6, 40             // alto (cantidad de filas a pintar)
    mov x7, 40             // ancho (cantidad de columnas)

loop_filas_up:
    mov x4, 200            // columna inicial
    mov x5, x7             // contador columnas

loop_columnas_up:
    mul x11, x3, x1        // x11 = fila * 640
    add x11, x4, x11       // x11 += columna
    lsl x11, x11, 2        // offset en bytes
    add x11, x0, x11       // dirección de memoria final
    stur w12, [x11]        // pintar pixel

    add x4, x4, 1          // siguiente columna
    sub x5, x5, 1
    cbnz x5, loop_columnas_up

    sub x3, x3, 1          // fila anterior (hacia arriba)
    sub x6, x6, 1
    cbnz x6, loop_filas_up

    // Pinta la parte de abajo del submarino (de 361 a 400 en Y)
    mov x3, 361            // fila inicial parte de abajo
    mov x6, 40             // alto
    mov x7, 40             // ancho

loop_filas_down:
    mov x4, 200            // columna inicial
    mov x5, x7             // contador columnas

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
    sub x6, x6, 1
    cbnz x6, loop_filas_down

    ret

