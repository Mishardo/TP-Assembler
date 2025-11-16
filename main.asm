; main.asm
.8086
.model small
.stack 100h
.data
    fraseInicial db 255 dup(24h)
    letraUsuario db ?         ; donde guardo la tecla apretada
    posAcierto   db 0         ; cuántos aciertos llevo (para saber dónde poner los *)
    contadorErrores db 0
    columna db 0
    fila db 0
    contadorCPS dw 0
    contadorWPS dw 0

.code
    extrn errores:proc
    extrn contador:proc
    extrn frase:proc

main proc
    mov ax,@data
    mov ds,ax

;---------------------- IMPRESION DE LA FRASE ---------------------------
    ; poner modo texto o limpiar pantalla si querés
    mov ah, 0
    mov al, 03h
    int 10h
    
    call imprimirFrase ; imprime la frase inicial
    lea si, fraseInicial
;-------------------------------------------------------------------------

;---------------------- CONTADOR DE ERRORES Y DE ACIERTOS------------------------------
bucleJuego:
    push bx
    mov bx, contadorCPS
    push si
    mov si, contadorWPS
    call contador       ; actualiza contador si corresponde (no bloqueante)
    pop si
    pop bx
    
    llamoErrores:
    mov al, contadorErrores
    guardoPuntero:
    mov [fila],dh       ;guardo la columna y la fila, porque errores la modifica. asi la restauro luego
    mov [columna], dl
    call errores

    restauroPuntero:
    mov dh, [fila]
    mov dl, [columna]
    mov ah, 02h
    mov bh, 0
    int 10h

    ; Chequear teclado (sin bloquear): INT16 AH=01
    mov ah, 01h
    int 16h
    jz bucleJuego       ; si no hay tecla, volvemos al bucle

    ; si hay tecla AH=00 y la imprimimos
    mov ah, 00h
    int 16h             ; AX = key (AH = scancode, AL = ascii)

    comparoConLaLetraActual:
    cmp al, [si] 
    jne error ;si no le pegue a la tecla sumo errores
    jmp acierto

    error:
    inc contadorErrores
    jmp bucleJuego

    acierto:
    inc si

    inc contadorCPS

    cmp al, ' '
    je EsPalabra
    cmp al, 0dh
    je esPalabra
    jmp noEsPalabra
    esPalabra:
    inc contadorWPS
    ; Aún no lo codee para imprimirlo
    
    noEsPalabra:
    mov bl, al
    ; calcular posición del * abajo de la frase
    mov dh, 12           ; fila debajo de la frase
    mov dl, 10
    add dl, posAcierto   ; desplazamiento horizontal porque sino es un quilombo tengo un contador para saber en q letra voy
    mov ah, 2
    int 10h              
 
    mov al, bl
    ; imprimir el caracter en AL
    mov ah, 0Eh
    int 10h

    inc posAcierto
;;-----------------------------------------------------------

;---------------------- FIN DEL JUEGO ----------------------
    cmp byte ptr[si], "$"
    je finPrograma

    jmp bucleJuego

finPrograma:
    mov ax,4C00h
    int 21h
main endp
;------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;; FUNCIONES INTERNAS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
imprimirFrase proc

    push bp
    mov bp, sp
    push bx
    push ax
    push dx

    call frase
    mov si, bx

        mov dh, 11; FILA (0 25)
        mov dl, 10 ; COLUMNA (0 80)
        mov bh, 0
        mov ah, 2
        int 10h 

    lea bx, fraseInicial
bucleImprimirFrase:             ;copia la frase tmb en la variable local para comparar luego en el juego
        cmp byte ptr [si], 24h
        je termineDeImprimir
        mov ah, 0eh
        mov al, [si]
        mov byte ptr[bx], al
        int 10h
        inc si
        inc bx
        jmp bucleImprimirFrase

termineDeImprimir:
    pop dx
    pop ax
    pop bx
    pop bp

    ret 
imprimirFrase endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
end
