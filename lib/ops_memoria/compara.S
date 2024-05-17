.syntax unified
.cpu cortex-m3
.thumb

.text

/**
 * @brief Compara dos regiones de memoria byte a byte como valores *sin signo*. 
 * Retorna 0 si son iguales, -1 si en la primera diferencia el valor de
 * izquierda es el menor y 1 si en la primera diferencia el valor de la
 * izquierda es mayor
 * 
 * @param izquierda Dirección base de la primera región
 * @param derecha Dirección base de la segunda región
 * @param tamano tamaño de las regiones
 * @return int 
 */

    .type comparaMemoria, %function
    .global comparaMemoria
comparaMemoria: // R0: base region izq., R1 : base region der., R2: nro. de bytes
    add r2,r0
0:
    cmp r0,r2
    bhs 3f
    ldrb r3,[r0],#1
    ldrb r12,[r1],#1
    cmp r3,r12
    beq 0b
    bge 2f
    mov r0,#-1
1:
    bx lr
2:
    mov r0,#1
    b 1b
3:
    mov r0,#0
    b 1b
    .size comparaMemoria, . - comparaMemoria
