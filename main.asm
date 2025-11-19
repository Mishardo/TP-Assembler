; main.asm
.8086
.model small
.stack 100h
.data
    textoTiempo db "Tiempo: ",24h
    textoTiempo2 db " segundos",24h
    textoCPS db "CPS: ",24h
    textoWPM db "WPM: ",24h
    textoErrores db "Errores: ",24h
    textoDificultad db "Dificultad: ",24h

    textoErrores2 db "ERROR:",24h

    dif_facil db "facil",24h
    dif_medio db "normal",24h
    dif_dificil db "dificil",24h

    fraseInicial db 255 dup(24h)
    letraUsuario db ?         ; donde guardo la tecla apretada
    posAcierto   db 0         ; cuántos aciertos llevo (para saber dónde poner los *)
    contadorErrores db 0

    columna db 0
    fila db 0

    frasesCompletadas db 0 ;cuantas palabras voy completando

    buffer  db 6 dup(?)

    contadorCPS dw 0
    contadorWPM dw 0
    tiempo dw 0
    nivel db 0

    limiteTiempo dw 0

    limiteErrores db 0
    resultadoTexto db "RESULTADOS",24h

.code
    extrn errores:proc
    extrn contador:proc
    extrn frase:proc
    extrn menu:proc
    extrn perdiste:proc
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
seguir:
mov tiempo, 0
mov frasesCompletadas, 0
mov dl, 2
call contador

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
    cmp al, 24h
    je finImprimirTiempo
    int 10h
    inc si
    jmp imprimirTiempo

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
    cmp al, 24h
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
    cmp al, 24h
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
    push si
    lea si, contadorWPM
    push di
    lea di, tiempo
    push dx 

    
    mov dl, 1
    call contador       ; actualiza contador si corresponde (no bloqueante)
    mov ax, tiempo
    pop dx
    pop di
    pop si
    pop bx

    cmp ax, limiteTiempo
    je perdisteJmp

    xor ax, ax
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


    ; Chequear si se completó la frase
    mov al, [si]
    cmp al, 24h        ; carácter '$'
    je completeFrase
    cmp al, 0          ; carácter nulo
    je completeFrase
    jmp noCompleteFrase
perdisteJmp:
    mov posAcierto, 0
    
    call perdiste
completeFrase:

cargoNuevaFrase:
    inc frasesCompletadas
    call limpiarV           ; limpia fraseInicial local
    call imprimirFrase      ; obtiene nueva frase y la copia a fraseInicial
    lea si, fraseInicial    ; SI apunta al inicio de la nueva frase
    mov posAcierto, 0
    cmp frasesCompletadas, 3
    je finPrograma
    jmp continuarJuego

noCompleteFrase:

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

continuarJuego:
    jmp bucleJuego

finPrograma:
    ;Mostrar resutados finales.
    mov ah, 0
    mov al, 03h
    int 10h

    call imprimirResultados
    
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
    push si
    push di
    push cx

    ; LIMPIAR la línea de la frase original (blanco)
    mov ah, 02h         ; posicionar cursor
    mov bh, 0
    mov dh, 11          ; fila de la frase
    mov dl, 10          ; columna inicial
    int 10h
    
    mov cx, 100         ;número de espacios a limpiar
    mov ah, 0Ah         ;escribir carácter
    mov al, ' '         ; espacio
    mov bh, 0
limpiarLineaFrase:
    int 10h
    inc dl
    mov ah, 02h
    int 10h
    mov ah, 0Ah
    loop limpiarLineaFrase

    ; LIMPIAR la línea de aciertos (caracteres en color)
    mov ah, 02h         ; posicionar cursor
    mov bh, 0
    mov dh, 11          ; misma fila
    mov dl, 10          ; misma columna inicial
    int 10h
    
    mov cx, 100          ; número de espacios a limpiar
    mov ah, 09h         ; usar función de escribir con atributo
    mov al, ' '         ; espacio
    mov bh, 0
    mov bl, 07h         ; color blanco normal
    mov cx, 100          ; limpiar 50 caracteres de una vez
    int 10h

    ; AHORA imprimir la nueva frase
    mov ah, 02h         ; reposicionar cursor al inicio
    mov bh, 0
    mov dh, 11
    mov dl, 10
    int 10h

    mov dl, nivel
    call frase
    mov si, bx
    lea di, fraseInicial

bucleImprimirFrase:
    cmp byte ptr [si], 24h
    je termineDeImprimir
    mov ah, 0eh
    mov al, [si]
    mov byte ptr [di], al
    int 10h
    inc si
    inc di
    jmp bucleImprimirFrase

termineDeImprimir:
    mov byte ptr [di], 24h
    
    pop cx
    pop di
    pop si
    pop dx
    pop ax
    pop bx
    pop bp
    ret 
imprimirFrase endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;80x25
imprimirResultados proc
    ;Impresion texto 'Resultado'
    mov ah, 02h
    mov bh, 0
    mov dl, 10 ; columna
    mov dh, 4   ; fila
    int 10h 

    mov ah, 9
    lea dx, resultadoTexto
    int 21h


    ;impresion 'Dificultad'
    mov ah, 02h
    mov bh, 0
    mov dl, 0 ; columna
    mov dh, 6   ; fila
    int 10h

    mov ah, 9
    lea dx, textoDificultad
    int 21h

    cmp nivel, 1
    je mostrarFacil
    cmp nivel, 2
    je mostrarMedio
    cmp nivel, 3
    je mostrarDificil

mostrarFacil:
    mov ah, 9
    lea dx, dif_facil
    int 21h
    jmp seguirImprimiendo

mostrarMedio:
    mov ah, 9
    lea dx, dif_medio
    int 21h
    jmp seguirImprimiendo

mostrarDificil:
    mov ah, 9
    lea dx, dif_dificil
    int 21h
seguirImprimiendo:
    ;impresión texto 'WPM'
    mov ah, 02h
    mov bh, 0
    mov dl, 0 ; columna
    mov dh, 7   ; fila
    int 10h

    mov ah, 9
    lea dx, textoWPM
    int 21h

    mov ax, contadorWPM
    lea di, buffer
    call convertirNumero

    mov ah, 9
    lea dx, buffer
    int 21h
    ;impresión 'Tiempo'
    mov ah, 02h
    mov bh, 0
    mov dl, 0 ; columna
    mov dh, 8   ; fila
    int 10h

    mov ah, 9
    lea dx, textoTiempo
    int 21h

    mov ax, tiempo
    lea di, buffer
    call convertirNumero

    mov ah, 9
    lea dx, buffer
    int 21h

    lea dx, textoTiempo2
    int 21h

    ;impresion 'Errores'
    mov ah, 02h
    mov bh, 0
    mov dl, 0 ; columna
    mov dh, 9   ; fila
    int 10h

    mov ah, 9
    lea dx, textoErrores
    int 21h

    xor ax, ax
    mov al, contadorErrores
    lea di, buffer
    call convertirNumero


    mov ah, 9
    lea dx, buffer
    int 21h


    ;Colocar colocar cursor debajo del texto así no molesta el 'C:\Tasm:>'
    mov ah, 02h
    mov bh, 0
    mov dl, 0 ; columna
    mov dh, 10   ; fila
    int 10h
    
    ret
imprimirResultados endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
convertirNumero proc
    push ax
    push bx
    push cx
    push dx
    mov bx, 10
    xor cx, cx

.convLoop:
    xor dx, dx
    div bx           ; AX / 10 ; remainder in DX
    push dx
    inc cx
    cmp ax, 0
    jne .convLoop

.writeLoop:
    pop dx
    add dl,'0'
    mov [di],dl
    inc di
    dec cx
    jnz .writeLoop
    mov byte ptr [di],'$'

    pop dx
    pop cx
    pop bx
    pop ax
    ret
convertirNumero endp

limpiarV proc
    push bp
    push dx
    mov bp, sp

    mov cx, 255
    lea di, fraseInicial  
    limpiar_loop:
        mov byte ptr [di], 24h
        inc di
        loop limpiar_loop

    pop dx
    pop bp
    ret

limpiarV endp



end