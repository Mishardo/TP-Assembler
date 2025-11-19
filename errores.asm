.8086
.model small
.stack 100h
.data
    datadiv db 100,10,1          
    Ascii db "000",0ah,0dh,24h
    cartelError db "ERRORES:",24h
    imprimiErrores db 0
.code

    public errores

    errores proc

    push bp
    push ax
    mov bp, sp
    xor ah,ah

    conviertoAscii:
    call r2a

    mov al, imprimiErrores

    imprimoErroresStr:

    mov ah, 02h
    mov bh, 0
    mov dh, 2
    mov dl, 10
    int 10h

    lea bx, cartelError
    imprimo:
    cmp byte ptr [bx], '$' ; Errores
    je salir
    mov ah, 0Eh
    mov al, [bx]
    int 10h
    inc bx
    jmp imprimo

    salir:
    inc imprimiErrores

    yaImprimiErrores:

    mov ah, 02h
    mov bh, 0
    mov dh, 2
    mov dl, 18
    int 10h

    lea bx, Ascii

    imprimoErroresNum:
    cmp byte ptr [bx], '$'
    je limpioVariable
    mov ah, 0Eh
    mov al, [bx]
    int 10h
    inc bx
    jmp imprimoErroresNum 

    limpioVariable:
    call limpiarAScii

    fin:
    pop ax
    pop bp  
    ret

    errores endp

    r2a proc

    push bx
    push cx
    push dx

    mov bx, 0            ; índice para datadiv y Ascii
    mov cx, 3            ; tres divisiones: /100, /10, /1

    convertir:
        mov dl, datadiv[bx]  ; cargar divisor (100, 10, 1)
        xor ah, ah           ; limpiar AH antes de dividir
        div dl               ; dividir AX (AL) entre DL
                            ; cociente -> AL, resto -> AH
        add al, '0'          ; convertir dígito a ASCII
        mov Ascii[bx], al    ; guardar dígito en la posición correspondiente
        mov al, ah           ; pasar resto a AL para la próxima división
        inc bx               ; siguiente posición/divisor
        loop convertir        ; repetir hasta que CX=0

    pop dx
    pop cx
    pop bx

    ret

    r2a endp

    limpiarAscii proc

    push cx
    push bx

    mov bx, 0
    mov cx, 3
limpiar:
    mov Ascii[bx], '0'
    inc bx
    loop limpiar


    pop bx
    pop cx

    ret
    limpiarAscii endp
    
    end
