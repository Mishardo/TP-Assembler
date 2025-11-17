; contador.asm
.8086
.model small
.stack 100h

.data
    oldTick dw 0
    newTick dw 0
    tickCount dw 0
    counter dw 0
    buffer  db 6 dup(?)    ; buffer para el número convertido (max 5 digitos + '$')
    contadorCPS dw 0

    UltimoCPS db 0
    ultimoWPM db 0

.code
public contador

contador proc
    push ax
    push bx
    push cx
    push dx
    push di
    push si

    mov contadorCPS, bx

    ; === Leer reloj BIOS ===
    mov ah, 00h
    int 1Ah
    mov newTick, dx

    ; === Si no cambió el tick, salimos rápido ===
    mov ax, newTick
    cmp ax, oldTick
    je .cps
    mov oldTick, ax

    ; === Contamos ticks (cada tick ≈ 55 ms); 18 ticks ≈ 1 s ===
    inc tickCount
    cmp tickCount, 18
    jb .cps
    mov tickCount, 0
    inc counter

    ; === Mover cursor arriba a la derecha (fila 2, col 70) ===
    mov ah, 02h
    mov bh, 0
    mov dh, 2
    mov dl, 70
    int 10h

    ; === Convertir counter a ASCII en buffer ===
    mov ax, counter
    lea di, buffer
    call convertirNumero

    ; === Imprimir buffer con INT 10h AH=0Eh ===
    lea bx, buffer
.imprimir:
    cmp byte ptr [bx], '$'
    je .cps
    mov ah, 0Eh
    mov al, [bx]
    int 10h
    inc bx
    jmp .imprimir
.cps:
    ;-------------- MOSTRAR CPS -------------
    mov ax, contadorCPS
    cwd
    mov bx, counter
    cmp bx, 0
    je .skipCPS
    div bx
    lea di, buffer
    call convertirNumero

    ;Contar largo de nuevos CPS
    xor cx, cx
    lea si, buffer

.contarLargoCPS:
    cmp byte ptr [si], '$'
    je .finContarLargoCPS
    inc cx
    inc si
    jmp .contarLargoCPS
.finContarLargoCPS:


    ;Mover el cursor a la pos de los CPS
    mov ah, 02h
    mov bh, 0
    mov dh, 3
    mov dl, 70
    int 10h


    ;Borrar si el nro largo es menor
    mov al, ultimoCPS     ; al = largo anterior
    sub al, cl            ; AL = diferencia
    jle .noBorrarCPS      ; si no disminuyó, no borrar

    mov bl, al            ; BL = cuántos borrar

.borrarCPSExtra:
    add bl, 70

    mov ah, 02h
    mov bh, 0
    mov dh, 3
    mov dl, bl
    int 10h

    mov ah, 0Eh
    mov al, ' '
    int 10h
    sub bl, 70
    dec bl
    jnz .borrarCPSExtra

.noBorrarCPS:
    mov ultimoCPS, cl     ; guardar largo actual

    ;Volver a la pos para imprimir los CPS
    mov ah, 02h
    mov bh, 0
    mov dh, 3
    mov dl, 70
    int 10h


    ;IMPRIMIR CPS 
    lea si, buffer
.imprimirCPS:
    cmp byte ptr [si], '$'
    je .skipCPS
    mov ah, 0Eh
    mov al, [si]
    int 10h
    inc si
    jmp .imprimirCPS

.skipCPS:
;--------- MOSTRAR WMP ----------------
.wpm:
    ; AX = contador de caracteres
    mov ax, contadorCPS
    cwd
    mov bx, counter     ; BX = tiempo en segundos
    cmp bx, 0
    je .skipWPM        ; evitar división entre cero
    div bx              ; AX = CPS (caracteres por segundo)

    ; Convertir CPS → WPM
    mov bx, 12
    mul bx              ; AX = CPS * 12 = WPM

    ; Convertir resultado a cadena en "buffer"
    lea di, buffer
    call convertirNumero

    ;-------------- CONTAR LARGO DEL WPM -------------
    xor cx, cx          ; CX = largo
    lea si, buffer
.contarLargoWPM:
    cmp byte ptr [si], '$'
    je .finContarLargoWPM
    inc cx
    inc si
    jmp .contarLargoWPM
.finContarLargoWPM:
    ;-------------- BORRAR CARACTERES SOBRANTES -------------
    mov al, ultimoWPM
    sub al, cl
    jle .noBorrarWPM        ; si no bajó, no borrar

    mov bl, al              ; bl = cuántos borrar

    ; posicionar al final del número anterior:
    mov ah, 02h
    mov bh, 0
    mov dh, 4               ; fila WPM
    mov dl, 70
    add dl, ultimoWPM
    dec dl                  ; DL = última cifra
    int 10h

.borrarWPMExtra:
    mov ah, 0Eh
    mov al, ' '
    int 10h
    dec dl
    dec bl
    jnz .borrarWPMExtra
.noBorrarWPM:
    mov ultimoWPM, cl       ; guardar largo actual

    mov ah, 02h
    mov bh, 0
    mov dh, 4           ; fila
    mov dl, 70          ; columna
    int 10h

    lea bx, buffer

.imprimirWPM:
    cmp byte ptr [bx], 24h 
    je .skipWPM

    mov ah, 0Eh
    mov al, [bx]
    int 10h

    inc bx
    jmp .imprimirWPM

.skipWPM:
;---------------------------------
.salir:
    pop si
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret
contador endp


; convertirNumero: convierte AX -> cadena ASCII terminada en '$' en DI
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

end
