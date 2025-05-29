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
//-----INTENTO PARTE DE ARRIBA------
// el circulo va a tener columna inicial=110 , fila inicial=65
// vamos a hacer el uso de la ecuación de la circunferencia x² + y² = r². 
// como queremos calcular la distancia a la que va a estar el pixel desde el centro del cielo para pintarlo la incógnita sera r = 2 * √(x² + y²)
 
               mov x3, 65         // fila inicial
               mov x4, 50          // radio  
               

   loop_1:
               sub x5, x3, 40      // centro vertical del círculo
               cbz x5, exit

               // calculamos el ancho de cada fila
               
               mul x11, x5, x5
               mul x9, x4, x4
               add x11, x9, x11
               ucvtf s11, x11                       // UCVTF Sd, Xn, #fbits. Convert unsigned 64-bit fixed-point in Xn to single-precision scalar in Sd, using FPCR rounding mode
               fsqrt s11, s11                          //FSQRT Sd, Sn.    Single-precision floating-point scalar square root: Sd = sqrt(Sn).
               fmov s2, 2.0                                     // FMOV Sd, #fpimm. Single-precision floating-point move immediate Sd = fpimm.
               fmul s11, s11, s2                                         // FMUL Sd, Sn, Sm .  Single-precision floating-point scalar multiply: Sd = Sn * Sm.
               fcvtzu x11, s11                         //FCVTZU Xd, Sn, #fbits. Convert single-precision scalar in Sn to unsigned 64-bit fixed-point in Xd, rounding towards zero.

               
               mov x6, 160                  // Esto ubica el inicio de la línea de forma que quede centrada horizontalmente respecto a la columna 160
               sub  x6, x6, x11, lsr #1     // x6 = centro - ancho/2
               mov x10, x11                 // copiamos el ancho de la fila a x10 para usarlo como contador


   loop_2:     mul x8, x3, x1
               add x8, x6, x8  
               lsl x8, x8, 2
               add x8, x0, x8
               stur w12, [x8]

               add x6, x6, 1
               sub x10, x10, 1
               cbnz x10, loop_2
               
               sub x3, x3, 1
               b loop_1
    exit : ret

.global draw_vela

draw_vela:
    // x0: framebuffer
    // x1: ancho pantalla
    // x2: alto pantalla
    // x3: fila inicial
    // x4: columna inicial (el mástil)
    // x5: altura de la vela
    // x6: 0 = izquierda, 1 = derecha
    // x12: color

    mov x7, 1          // ancho inicial (punta del triángulo)
    mov x8, x5         // altura (cantidad de filas)

vela_loop:
    mov x9, x7         // ancho actual

    // Determinar x10 
    cmp x6, 1
    beq usar_derecha

    // Si es izquierda: arranca desde (mástil - ancho)
    sub x10, x4, x7
    b seguir_dibujo

usar_derecha:
    mov x10, x4        // Si es derecha: arranca desde mástil

seguir_dibujo:
    // Pintar línea horizontal (ancho de la fila)
vela_col_loop:
    mul x11, x3, x1
    add x11, x10, x11
    lsl x11, x11, 2
    add x11, x0, x11
    stur w12, [x11]

    add x10, x10, 1
    sub x9, x9, 1
    cbnz x9, vela_col_loop

    // Ir a la siguiente fila
    add x3, x3, 1

    // Aumentar el ancho (triángulo crece en la base)
    add x7, x7, 1

    // Bajar altura
    sub x8, x8, 1
    cbnz x8, vela_loop

    ret

