; main.asm
.8086
.model small
.stack 100h
.data
    textoTiempo db "Tiempo: ",0
    textoCPS db "CPS: ",0
    textoWPM db "WPM: ",0

    fraseInicial db 255 dup(24h)
    letraUsuario db ?         ; donde guardo la tecla apretada
    posAcierto   db 0         ; cuántos aciertos llevo (para saber dónde poner los *)
    contadorErrores db 0
    columna db 0
    fila db 0
    
    contadorCPS dw 0
    nivel db 0
    limiteTiempo db 0
    limiteErrores db 0

.code
    extrn errores:proc
    extrn contador:proc
    extrn frase:proc
    extrn menu:proc
    extrn perdiste:proc
    extrn puntajes:proc
    public main
main proc
    mov ax,@data
    mov ds,ax
    mov contadorErrores,0
    call menu
    mov nivel,dl ; menu me devuelve por dl el nivel
    cmp nivel,1; comparo para saber que nivel me devolvio y en base a eso setear las variables
    je facilSet
    cmp nivel,2
    je medioSet
    cmp nivel,3
    je dificilSet
    jmp seguir
facilSet:
    mov limiteTiempo,30
    mov limiteErrores,10
    jmp seguir
medioSet:
    mov limiteTiempo,20
    mov limiteErrores,5
    jmp seguir
dificilSet:
    mov limiteTiempo,15
    mov limiteErrores,1
    jmp seguir
seguir: ; Seguir es una funcion auxiliar para indicar que termino de setear

;---------------------- IMPRESION DE LA FRASE ---------------------------
    ; poner modo texto o limpiar pantalla si querés
    mov ah, 0
    mov al, 03h
    int 10h
    
    call imprimirFrase ; imprime la frase inicial
;-------------------------------------------------------------------------
    mov ah, 02h 
    mov bh, 0
    mov dh, 2
    mov dl, 60
    int 10h

    mov ah, 0Eh 
    lea si, textoTiempo
imprimirTiempo:
    mov al, [si]
    cmp al, 0
    je finImprimirTiempo
    cmp al,limiteTiempo
    je terminoRonda
    int 10h
    inc si
    jmp imprimirTiempo
terminoRonda:
    mov dl,contadorErrores
    mov dh,contadorCPS
    call puntajes
finImprimirTiempo:

    mov ah, 02h 
    mov bh, 0
    mov dh, 3
    mov dl, 60
    int 10h

    mov ah, 0Eh 
    lea si, textoCPS

imprimirCPS:
    mov al, [si]
    cmp al, 0
    je finImprimirCPS
    int 10h
    inc si
    jmp imprimirCPS

finImprimirCPS:

    mov ah, 02h 
    mov bh, 0
    mov dh, 4
    mov dl, 60
    int 10h

    mov ah, 0Eh 
    lea si, textoWPM

imprimirWPM:
    mov al, [si]
    cmp al, 0
    je finImprimirWPM
    int 10h
    inc si
    jmp imprimirWPM

finImprimirWPM:
lea si, fraseInicial
;---------------------- CONTADOR DE ERRORES Y DE ACIERTOS------------------------------
bucleJuego:
    push bx
    mov bx, contadorCPS
    call contador       ; actualiza contador si corresponde (no bloqueante)
    pop bx
    
    llamoErrores:
    mov al, contadorErrores

    guardoPuntero:
    mov [fila],dh       ;guardo la columna y la fila, porque errores la modifica. asi la restauro luego
    mov [columna], dl
    call errores

    jmp restauroPuntero
perdisteJmp:
    call perdiste
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
    xor al,al
    mov al,contadorErrores
    cmp al,limiteErrores
    je perdisteJmp
    jmp bucleJuego

    acierto:
    inc si
    inc contadorCPS
    mov bl, al          ; guardar carácter a imprimir

    ; Mover cursor a fila/col deseada
    mov ah, 02h         ; set cursor position
    mov bh, 0           ; página
    mov dh, 11          ; fila
    mov dl, 10
    add dl, posAcierto  ; desplazamiento horizontal
    int 10h

    ; Imprimir carácter con color
    mov ah, 09h         ; write char + attr
    mov al, bl          ; carácter
    mov bh, 0           ; página
    mov bl, 0Bh         ; color (mirar colores.txt)
    mov cx, 1           ; imprimir una vez
    int 10h

    inc posAcierto
;;----------------------------------------------------------

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