.global draw_submarino_up

draw_submarino_up : mul x11, x3, x1     // x11 = 360 * 640
                    add x11, x4, x11    // x11 = 200 +  360 * 640
                    lsl x11, x11, 2    // x11 = [200 + (360 * 640)] * 4
                    add x11, x0, x11    // x11 = x0 + [200 + (360 * 640)] * 4
                    stur w12,[x11]     // pintar el pixel N
                    add x11, x11, 4    // siguiente pixel
                    sub x1, x1, 1       // decrementar contador
                    cmp x1, x5
                    bne draw_submarino_up

                    sub x3, x3, 1        // subir sobre las filas
                    add x4, x4, 1         // avanzar sobre las columnas
                    sub x5, x5, 1         //decrementar contador
                    cmp x5, 200
                    bne draw_submarino_up
              
                    mov x3, 361           //inicializo para empezar a pintar la parte inferior del submarino
                    mov x4, 201
                    mov x5, 339
                    mov x1, SCREEN_WIDTH

draw_submarino_down : mul x11, x3, x1  // x11 = 361 * 640
                      add x11, x4, x11 //x11 = 201 +  361 * 640
                      lsl x11, x11, 2  // x11 = [201 + (361 * 640)] * 4
                      add x11, x0, x11 // x11 = x0 + [201 + (361 * 640)] * 4
                      stur w12,[x11]
                      add x11, x11, 4
                      sub x1, x1, 1
                      cmp x1, x5
                      bne draw_submarino_down

                      add x3, x3, 1
                      add x4, x4, 1
                      sub x5, x5, 1
                      cmp x5, 200 
                      bne draw_submarino_down 
                      ret
