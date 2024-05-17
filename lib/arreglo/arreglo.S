.syntax unified
.cpu cortex-m3
.fpu softvfp
.thumb

.macro defun nombre
    .section .text.\nombre
    .global \nombre
    .type \nombre, %function
\nombre:
.endm

.macro endfun nombre
    .size \nombre, . - \nombre
.endm

.equ Arreglo_base,0
.equ Arreglo_tamanoElemento,4
.equ Arreglo_numeroElementos,8

/**
 * @brief Inicializa un descriptor que describe un arreglo con una direccion de
 * memoria base, tamaño de elemento y número de elementos dados
 * 
 * @param descriptor Puntero al descriptor a inicializar 
 * @param base Dirección base del arreglo
 * @param tamanoElemento Tamaño del elemento
 * @param numElementos Número de elementos
 */
defun Arreglo_init // R0: desc., R1: base arreglo, R2: tamElem, R3: numElem
    str R1,[R0,#Arreglo_base]
    str R2,[R0,#Arreglo_tamanoElemento]
    str R3,[R0,#Arreglo_numeroElementos]
    bx lr
endfun Arreglo_init

/**
 * @brief Retorna un puntero a un elemento del arreglo descrito
 * 
 * @param descriptor Descriptor de arreglo inicializado con Arreglo_init
 * @param indice
 * @return void* Puntero al elemento indicado por indice, NULL si no existe el
 * elemento (NULL es la dirección 0)
 */
defun Arreglo_apunta // R0: desc., R1: indice
    ldr r2,[r0,#Arreglo_numeroElementos]
    cmp r1,r2
    bhs 1f
    ldr r2,[r0,#Arreglo_tamanoElemento]
    ldr r0,[r0,#Arreglo_base]
    mla r0,r2,r1,r0
0:
    bx lr
1:
    mov r0,#0
    b 0b
endfun Arreglo_apunta

/**
 * @brief Lee el valor de un elemento del arreglo descrito, copiándolo en el
 * espacio de memoria proporcionado. Supone que la región de memoria tiene
 * tamaño suficiente
 * 
 * @param descriptor Descriptor del arreglo
 * @param indice Índice del elemento a leer
 * @param destino Puntero a la regió de memoria donde copiar el valor
 * @return int 0 si la operación pudo realizarse, -1 si el elemento no existe
 */
defun Arreglo_lee // R0: desc., R1: ind., R2: dest.
    ldr r3,[r0,#Arreglo_numeroElementos]
    cmp r1,r3
    bhs 3f
    ldr r3,[r0,#Arreglo_tamanoElemento]
    ldr r0,[r0,#Arreglo_base]
    mla r0,r3,r1,r0
    add r3,r0
0:
    cmp r0,r3
    bhs 1f
    ldrb r1,[r0],#1
    strb r1,[r2],#1
    b 0b
1:
    mov r0,#0
2:
    bx lr
3:
    mov r0,#-1
    b 2b
endfun Arreglo_lee

/**
 * @brief Escribe el valor proporcionado en el arreglo descrito
 * 
 * @param descriptor Descriptor de arreglo
 * @param indice Índice del elemento a escribir
 * @param origen Puntero a región conteniendo los datos a escribir
 * @return int 0 si efectuó la operación, -1 si no existe el elemento en el
 * arreglo
 */
defun Arreglo_escribe
    ldr r3,[r0,#Arreglo_numeroElementos]
    cmp r1,r3
    bhs 3f
    ldr r3,[r0,#Arreglo_tamanoElemento]
    ldr r0,[r0,#Arreglo_base]
    mla r0,r3,r1,r0
    add r3,r0
0:
    cmp r0,r3
    bhs 1f
    ldrb r1,[r2],#1
    strb r1,[r0],#1
    b 0b
1:
    mov r0,#0
2:
    bx lr
3:
    mov r0,#-1
    b 2b
endfun Arreglo_escribe

/**
 * @brief Intercambia los valores de dos elementos del arreglo
 * 
 * @param descriptor Descriptor de arreglo
 * @param indice_1 Primer índice
 * @param indice_2 Segundo índice
 * @return int 0 si tuvo exito, -1 si algún elemento no existe
 */
defun Arreglo_intercambia // r0: desc., r1: i, r2: j
    push {r4-r6,lr}
    mov r4,r0
    mov r5,r1
    mov r6,r2
    bl Arreglo_apunta
    mov r5,r0 // r5 : p_i
    mov r0,r4
    mov r1,r6
    bl Arreglo_apunta
    mov r6,r0 // r6 : p_j
    ldr r0,[r4,#Arreglo_tamanoElemento]
    add r0,r5 // r0 : p_if
    cbz r5,3f
    cbz r6,3f
0:
    cmp r5,r0
    bhs 1f
    ldrb r1,[r5]
    ldrb r2,[r6]
    strb r2,[r5],#1
    strb r1,[r6],#1
    b 0b
1:
    mov r0,#0
2:
    pop {r4-r6,pc}
3:
    mov r0,#-1
    b 2b
endfun Arreglo_intercambia
