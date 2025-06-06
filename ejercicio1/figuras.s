.global draw_barco
.global draw_mastil
.global draw_sol
.global draw_vela
.global dibujar_lineas_agua
.global draw_bandera
.global draw_letra


//----------------- MASTIL DEL BARCO ------------------//
draw_mastil:   
    // 
    mov x3, 300            // fila inicial
    mov x6, 250             // alto (cantidad de filas a pintar)
    mov x7, 5             // ancho (cantidad de columnas)

loop_filas_mastil:
    mov x4, 150            // columna inicial
    mov x5, x7             // contador columnas

loop_columnas_mastil:
    mul x11, x3, x1        // x11 = fila * 640
    add x11, x4, x11       // x11 += columna
    lsl x11, x11, 2        // offset en bytes
    add x11, x0, x11       // dirección de memoria final
    str w12, [x11]        // pintar pixel

    add x4, x4, 1          // siguiente columna
    sub x5, x5, 1
    cbnz x5, loop_columnas_mastil

    sub x3, x3, 1          // fila anterior (hacia arriba)
    sub x6, x6, 1
    cbnz x6, loop_filas_mastil

//----------------- BARCO ------------------//
draw_barco:
    mov x3, 300            // fila inicial
    mov x6, 45             // alto de la base total
    mov x8, 0              // ensanchamiento horizontal
    mov x9, x6             // guardamos el alto original
    lsr x10, x9, 1         // x10 = x9 / 2 = mitad de las filas

loop_filas_down:
    mov x7, 200           // inicilizacion del ancho
    add x7, x7, x8        // sumamos el ancho

    mov x4, 150
    lsr x19, x7, 1     // dividir el ancho por la mitad
    sub x4, x4, x19    // restarselo al centro donde se ubica el barco
    mov x5, x7

    // Elegir color según fila
    cmp x6, x10            // ¿estamos en la mitad superior?
    b.gt usar_color_claro

    // Parte inferior - sombra
    movz x12, 0x44, lsl 16     // color marrón oscuro
    movk x12, 0x2200, lsl 0
    b seguir_barco

usar_color_claro:
    movz x12, 0x88, lsl 16     // color marrón claro
    movk x12, 0x4400, lsl 0

seguir_barco:
loop_columnas_down:
    mul x11, x3, x1    // x11 = fila * 640
    add x11, x4, x11   // x11 += columna
    lsl x11, x11, 2    // offset en bytes
    add x11, x0, x11   // sumo direcc base del frame
    str w12, [x11]    // pintar pixel

    add x4, x4, 1     // siguente columna
    sub x5, x5, 1      // vamos achicando el ancho
    cbnz x5, loop_columnas_down

    add x3, x3, 1     // sig fila
    sub x8, x8, 1     
    sub x6, x6, 1
    cbnz x6, loop_filas_down

    ret

//----------------------- SOL -----------------------//
 draw_sol:
     mov x4, 320  // columna inicial  --> centro x
     mov x2, 150 // fila inicial --> centro y
     mov x3, 80  // radio
   
    mov x5, x4         // centro x
    mov x6, x2         // centro y
    mov x7, x3         // radio

    movz x9, 0xFD, lsl 16   
    movk x9, 0x9A04, lsl 0  // color naranjita

    // loop sobre y desde -radio hasta +radio
          mov x10, -1
          mul x10, x7, x10     // x10 = -radio
   loop_y:
          cmp x10, x7    // verifica si esta dentro del diametro vertical
          bgt fin_circulo

    // loop sobre x desde -radio hasta +radio
          mov x11, -1
          mul x11, x7, x11     // x11 = -radio
   loop_x:
          cmp x11, x7    // verifica si esta dentro del diametro horizontal
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

    str w9, [x21]          // pintar pixel rojo

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
    // x1: ancho frame
    // x2: alto frame
    // x3: fila inicial
    // x4: columna inicial (el mástil)
    // x5: altura de la vela
    // x6: 0 = izquierda, 1 = derecha
    // x12: color

    mov x7, 1          // ancho inicial (punta del triángulo)
    mov x8, x5         // altura (cantidad de filas)

vela_loop:
    mov x9, x7         // ancho actual

    // Determinar x10: columna
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
    mul x11, x3, x1     //x11 = fila * 640
    add x11, x10, x11    // x11 += columna
    lsl x11, x11, 2     // *4
    add x11, x0, x11    // le sumo la direcc base del frame
    str w12, [x11]     // pintar pixel

    add x10, x10, 1      // sig columna
    sub x9, x9, 1        // contador ancho
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

dibujar_lineas_agua:
    // x19 : puntero de la tabla de las posiciones Y
    // x20 : puntero de la tabla de las posiciones X
    // x21 : cantidad de lineas a pintar
    // x9 : color 
    
    mov x22, 0   // índice de la tabla de numeros

bucle_lineas: 
    cmp x22, x21  // si son iguales, pinte todas las lineas
    beq exit

    // Leer X 
    mov x24, x22        // x24 = indice actual de la tabla
    lsl x24, x24, #3    // * 8 bytes
    add x24, x20, x24   // le sumo direccion base de la tabla X
    ldr x3, [x24]       // el contenido de la dirección x24 lo guardo en x3

    // Leer Y
    mov x25, x22          // x25 = indice actual de la tabla
    lsl x25, x25, #3       // * 8 bytes
    add x25, x19, x25     // le sumo direccion base de la tabla Y
    ldr x2, [x25]         // guardo en x2 el contenido de la dirección x25
    

    mov x5, x3         // x inicial
    mov x6, x2         // y inicial
    mov x7, 60         // ancho total
    mov x8, 3         // alto total

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

    str w9, [x15]         // pintar pixel rojo

    add x11, x11, 1      // incremento contador ancho
    b ancho_loop_x

inc_y:
    add x10, x10, 1     // incremento contador alto
    b alto_loop_y

fin_linea:
    add x22, x22, 1
    b bucle_lineas
    
exit: ret

//-----------------------------BANDERA-----------------------------------//
draw_bandera:
    // x0: framebuffer
    // x1: ancho pantalla
    // x2: alto pantalla
    // x3: fila inicial
    // x4: columna inicial (mástil)
    // x15: altura de la bandera
    // x6: 0 = izquierda, 1 = derecha
    // x12: color

    mov x7, 1              // ancho inicial (punta)
    mov x8, x15            // altura restante (filas a dibujar)

bandera_loop:
    mov x9, x7             // ancho de la fila actual

    // Calcular columna inicial dependiendo de la dirección
    cmp x6, 0
    b.eq bandera_izquierda

bandera_derecha:
    mov x10, x4            // comienza desde mástil hacia la derecha
    b seguir_bandera

bandera_izquierda:
    sub x10, x4, x7        // comienza desde (mástil - ancho)
    add x10, x10, 1        // +1 porque queremos que la base empiece justo a la izquierda

seguir_bandera:
    // Pintar línea horizontal (ancho de la fila)
bandera_col_loop:
    // Calcular dirección framebuffer
    mul x11, x3, x1        // x3 * ancho pantalla = offset de fila
    add x11, x11, x10      // columna actual
    lsl x11, x11, 2        // cada pixel = 4 bytes
    add x11, x0, x11       // dirección en framebuffer

    str w12, [x11]        // pintar pixel

    add x10, x10, 1        // avanzar columna
    sub x9, x9, 1           // decremento contador del ancho
    cbnz x9, bandera_col_loop

    // Siguiente fila
    add x3, x3, 1
    add x7, x7, 3          // aumentar ancho (para forma triangular)
    sub x8, x8, 1
    cbnz x8, bandera_loop

    ret
    
//---------------------TEXTO----------------------------//
.section .data
// Cada carácter ocupa 7 bytes (una fila por byte, 5 bits usados)
letras:
    // "O"
    .byte 0b01110
    .byte 0b10001
    .byte 0b10001
    .byte 0b10001
    .byte 0b10001
    .byte 0b10001
    .byte 0b01110
    .skip 1

    // "d"
    .byte 0b00001
    .byte 0b00001
    .byte 0b01111
    .byte 0b10001
    .byte 0b10001
    .byte 0b10001
    .byte 0b01111
    .skip 1

    // "c"
    .byte 0b01110
    .byte 0b10001
    .byte 0b10000
    .byte 0b10000
    .byte 0b10000
    .byte 0b10001
    .byte 0b01110
    .skip 1

    // espacio
    .byte 0b00000
    .byte 0b00000
    .byte 0b00000
    .byte 0b00000
    .byte 0b00000
    .byte 0b00000
    .byte 0b00000
    .skip 1

    // "2"
    .byte 0b01110
    .byte 0b10001
    .byte 0b00001
    .byte 0b00110
    .byte 0b01000
    .byte 0b10000
    .byte 0b11111
    .skip 1

    // "0"
    .byte 0b01110
    .byte 0b10001
    .byte 0b10011
    .byte 0b10101
    .byte 0b11001
    .byte 0b10001
    .byte 0b01110
    .skip 1

    // "5"
    .byte 0b11111
    .byte 0b10000
    .byte 0b11110
    .byte 0b00001
    .byte 0b00001
    .byte 0b10001
    .byte 0b01110
    .skip 1

 
// x0: framebuffer
// x1: ancho pantalla
// x2: columna destino
// x3: fila destino
// x4: índice de la letra (0 para 'O', 1 para 'd', etc.)

draw_letra:
    lsl x5, x4, 3           // 7 bytes por letra (7 * 1 = 7, pero alineamos a 8)
    ldr x6, =letras         // x6 = direcc base de letras
    add x6, x6, x5          // puntero al bitmap de la letra
    movz x7, 0xFFFF, lsl 0  // color blanco
    movk x7, 0xFFFF, lsl 16

    mov x8, 0      // fila
draw_letra_fila:
    cmp x8, 7     
    bge fin_draw_letra

    ldrb w9, [x6, x8] // cargar fila del bitmap

    mov x10, 0     // columna
draw_letra_columna:
    cmp x10, 5
    bge sig_fila_letra

    
    mov x11, x9     // x11 = fila del bitmap
    mov x12, 4      
    sub x12, x12, x10  // x12 = 4 - columna actual (del 0 al 4 son los indices de las columnas)
    lsrv x11, x11, x12  // desplaza el bit correspondiente a la derecha

    and x11, x11, 1   // nos quedamos solo con ese bit (0 o 1)
    cbz x11, no_pixel // si 0, no se dibuja el pixel

    // dibujar píxel
    add x12, x2, x10     // columna actual
    add x13, x3, x8      // fila actual

    mul x14, x13, x1   // x14 = fila * 640
    add x14, x14, x12  // x14 += columna
    lsl x14, x14, 2    // *4
    add x15, x0, x14   // sumar direccional base del fram
    str w7, [x15]       // pintar pixel

no_pixel:
    add x10, x10, 1
    b draw_letra_columna

sig_fila_letra:
    add x8, x8, 1
    b draw_letra_fila

fin_draw_letra:
    ret
  

