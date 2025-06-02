.global draw_barco
.global draw_mastil
.global draw_sol
.global draw_vela
.global dibujar_lineas_agua
.global odc_2025


//----------------- MASTIL DEL BARCO ------------------//
draw_mastil:   
    // 
    mov x3, 300            // fila inicial
    mov x6, 250             // alto (cantidad de filas a pintar)
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

//----------------------- SOL -----------------------//
 draw_sol:
     mov x4, 160  // columna inicial  --> centro x
     mov x2, 65  // fila inicial --> centro y
     mov x3, 40  // radio
   
    mov x5, x4         // centro x
    mov x6, x2         // centro y
    mov x7, x3         // radio

    movz x9, 0xFF, lsl 16   
    movk x9, 0xF700, lsl 0  // color amarillo

    // loop sobre y desde -radio hasta +radio
          mov x10, -1
          mul x10, x7, x10     // x10 = -radio
   loop_y:
          cmp x10, x7
          bgt fin_circulo

    // loop sobre x desde -radio hasta +radio
          mov x11, -1
          mul x11, x7, x11     // x11 = -radio
   loop_x:
          cmp x11, x7
          bgt siguiente_y

    // dx = x11, dy = x10
    mul x12, x11, x11    // dx^2
    mul x13, x10, x10    // dy^2
    add x14, x12, x13    // dx^2 + dy^2
    mul x15, x7, x7      // radio^2
    cmp x14, x15
    bgt skip_pixel       // si está fuera del círculo, no dibujar

    // calcular posición en framebuffer
    add x16, x5, x11     // x = centro_x + dx
    add x17, x6, x10     // y = centro_y + dy

    // offset = (y * SCREEN_WIDTH + x) * 4
    mov x18, x1 
    mul x19, x17, x18      // y * ancho
    add x19, x19, x16      // + x
    lsl x19, x19, 2        // *4
    add x21, x0, x19      // dirección final

    str w9, [x21]          // escribir pixel rojo

skip_pixel:
    add x11, x11, 1
    b loop_x

siguiente_y:
    add x10, x10, 1
    b loop_y

fin_circulo:
    ret                          

//------------------ VELAS BARCO ------------------//

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

//------------------- LINEAS DEL AGUA ---------------------//
tabla_Y_posiciones: .dword 250, 270, 250, 275, 280, 310, 290, 291, 310, 330, 350, 366, 378, 400, 394, 400, 415, 426, 458, 432, 467, 473
tabla_X_posiciones: .dword 40, 97, 470, 210, 578, 30, 500, 350, 459, 530, 145, 100, 540, 40, 299, 430, 320, 200, 366, 3, 574, 105

dibujar_lineas_agua:
    ldr x19, =tabla_Y_posiciones
    ldr x20, =tabla_X_posiciones
    mov x21, 22  // cantidad de líneas
    mov x22, 0   // índice

bucle_lineas: 
    cmp x22, x21
    beq exit

    // Leer X
    mov x24, x22
    lsl x24, x24, #3
    add x24, x20, x24
    ldr x3, [x24]

    // Leer Y
    mov x25, x22
    lsl x25, x25, #3
    add x25, x19, x25
    ldr x2, [x25]
    

    mov x5, x3         // x inicial
    mov x6, x2         // y inicial
    mov x7, 60         // ancho cuadrado
    mov x8, 3         // alto cuadrado

    movz x9, 0x43, lsl 16  // color celeste
    movk x9, 0xA8DB, lsl 0

    mov x10, 0         // contador y
alto_loop_y:
    cmp x10, x8
    bge fin_linea

    mov x11, 0         // contador x
ancho_loop_x:
    cmp x11, x7
    bge inc_y

    // offset = (y + x*width) * 4 bytes
    add x12, x5, x11      // x final
    add x13, x6, x10      // y final
 
    mul x14, x13, x1     // y * width
    add x14, x14, x12     // + x
    lsl x14, x14, 2       // *4 (bytes por pixel)
    add x15, x0, x14     // dir = base + offset

    str w9, [x15]         // escribir pixel rojo

    add x11, x11, 1
    b ancho_loop_x

inc_y:
    add x10, x10, 1
    b alto_loop_y

fin_linea:
    add x22, x22, 1
    b bucle_lineas
    
exit: ret


//------------- texto odc ---------//
letra_O:
    .byte 1, 1, 1, 1, 1
    .byte 1, 0, 0, 0, 1
    .byte 1, 0, 0, 0, 1
    .byte 1, 0, 0, 0, 1
    .byte 1, 1, 1, 1, 1

odc_2025:
ldr x24, =letra_O     // Dirección de la matriz
mov x6, 0             // fila = 0

bucle_filas:
    cmp x6, 5
    bge fin_letra

    mov x5, 0         // columna = 0
bucle_columnas:
    cmp x5, 5
    bge sig_fila

    // Calcular offset: fila * 5 + columna
    mov x10, x6
    mov x23, 5
    mul x10, x10, x23 
    add x10, x10, x5
    add x11, x24, x10     // dirección del byte
    ldrb w12, [x11]       // cargar byte (w12 = 0 o 1)

    cbz w12, no_dibujar

    // Calcular coordenadas en pantalla
    mov x19, x3      // x base
    mov x20, x2      // y base
    mov x21, x5
    lsl x21, x21, #2     // columna * 4
    add x21, x21, x19

    mov x22, x6
    lsl x22, x22, #2     // fila * 4
    add x22, x22, x20

    mov x3, x21          // x para dibujar
    mov x2, x22          // y para dibujar
    bl dibujar_cuadr5x5  // función que pinta un cuadrado 5x5

no_dibujar:
    add x5, x5, 1
    b bucle_columnas

sig_fila:
    add x6, x6, 1
    b bucle_filas

fin_letra:
    ret

//------ dibujar_cuadr5x5 --------//

dibujar_cuadr5x5:
    // x0 = dirección base framebuffer
    // x1 = SCREEN_WIDHT
    // x3 = posición x inicial
    // x2 = posición y inicial
    // x9 = color

    mov x5, x3         // x inicial
    mov x6, x2         // y inicial
    mov x7, 5         // ancho cuadrado
    mov x8, 5         // alto cuadrado

    mov x10, #0         // contador y
cuadr5x5_loop_y:
    cmp x10, x8
    bge fin_cuadr5x5

    mov x11, #0         // contador x
cuadr5x5_loop_x:
    cmp x11, x7
    bge sig_fila_y

    // offset = (x + y * width) * 4 bytes
    add x12, x5, x11      // x final
    add x13, x6, x10      // y final
    
    mul x14, x13, x1     // y * width
    add x14, x14, x12     // + x
    lsl x14, x14, 2       // *4 (bytes por pixel)
    add x15, x0, x14     // dir = base + offset

    str w9, [x15]         // escribir pixel rojo

    add x11, x11, #1
    b cuadr5x5_loop_x

sig_fila_y:
    add x10, x10, #1
    b cuadr5x5_loop_y

fin_cuadr5x5: ret

//-----------------------------BANDERA-----------------------------------//
draw_bandera:
    // x0: framebuffer
    // x1: ancho pantalla
    // x2: alto pantalla
    // x3: fila inicial
    // x4: columna inicial (el mástil)
    // x15: altura de la bandera
    // x6: 0 = izquierda, 1 = derecha
    // x12: color
      
    mov x7, 70          // ancho inicial (punta del triángulo)
    mov x8, x15         // altura (cantidad de filas)
    
bandera_loop:
    mov x9, x7         // ancho actual    
bandera_derecha:
    mov x10, x4        // Si es derecha: arranca desde mástil

seguir_bandera:
    // Pintar línea horizontal (ancho de la fila)
bandera_col_loop:
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
    
    

