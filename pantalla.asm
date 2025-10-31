.8086
.model small
.stack 100h
.data

mensaje db "Texto centrado con INT 10h",0
longitud equ $ - mensaje   ; calcula automáticamente la longitud

.code
main proc
    mov ax, @data
    mov ds, ax

    ; --- MODO TEXTO 80x25 ---
    mov ah, 0
    mov al, 03h
    int 10h

    cursor:

    mov dh, 13; FILA (0 25)
    mov dl, 20 ; COLUMNA (0 80)
    mov bh, 0
    mov ah, 2
    int 10h 

    mov bx, offset mensaje

    mov cx, 26
    imprimirCaracter:

    mov ah, 0eh
    mov al, [bx]
    int 10h
    inc bx
    loop imprimirCaracter

    termine:
    jmp cursor

    fuera:
    ; --- Salir a DOS ---
    mov ax, 4C00h
    int 21h
main endp
end