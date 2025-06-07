Nombre y apellido 
Integrante 1: Lola Manrique
Integrante 2: Vittorio Monina 
Integrante 3: Lujan Boasso
Integrante 4: Sofia Medina


Descripción ejercicio 1: Un barco navegando en el mar en la hora exacta de un atardecer.


Descripción ejercicio 2: Sin realizar.


Justificación instrucciones ARMv8:
LSRV Xd, Xn, Xm
La usamos para hacer un right shift donde la cantidad de bits a desplazar esta en un determinado registro definido anteriormente. 
Se encuentra en la funcion draw_letra de figuras.s

LDR Xt, addr.
Usamos esta instruccion, en vez de LDUR, para cargar contenido de la memoria a un registro Xt a partir de una dirección addr, sin tener que calcular la dirección a partir de la dirección base como en LDUR. 
      
STR Xt, addr
Usamos esta instrucción, en vez de STUR, para almacenar contenido de la memoria, con el addr, a partir de un registro Xt, sin tener que calcular la dirección a partir de la dirección base.
