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
    contadorWPS dw 0

.code
public contador

contador proc
    push ax
    push bx
    push cx
    push dx
    push di

    mov contadorCPS, bx
    mov contadorWPS, si

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

    mov ah, 02h
    mov bh, 0
    mov dh, 3
    mov dl, 70
    int 10h

    lea bx, buffer
.imprimirCPS:
    cmp byte ptr [bx], 24h
    je .skipCPS
    mov ah, 0Eh
    mov al, [bx]
    int 10h
    inc bx
    jmp .imprimirCPS
.skipCPS:
;---------------------------------
.salir:
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
