.8086
.model small
.stack 100h
.data
    arch1		db 'frases.txt',0
    buf1		db 4096 dup(?)
    fraseSeleccionada db ?

.code
    mov ax,@data
    mov ds,ax

    mov ah, 3Dh
    mov al, 0
    mov dx, offset arch1
    int 21h
    jc errorAbrirArchivo

    mov bx, ax        ; handle
    mov ah, 3Fh
    mov cx, 4095
    int 21h           ; lee hasta 255 bytes

    mov ah, 3Eh
    int 21h

    ;Seleccionar aleatorio entre 0 y 50
    mov ah, 00h
    int 1Ah
    mov ax, dx
    mov bx, 50
    xor dx, dx
    div bx
    mov fraseSeleccionada, dl


    call seleccionarFrase
    ;dx tengo el offset donde inicia la frase

    imprimir:

    mov ah,9
    int 21h

    errorAbrirArchivo:

    mov ax, 4c00h
    int 21h

    ; luego quiero agregarle un nro aleatorio y que ponga el offset al inicio de luego de un salto de linea y el signo pesos al final de esa linea
    seleccionarFrase proc

    mov si, offset buf1
    mov cl, 1                ; contador de líneas actuales
    mov al, fraseSeleccionada

    buscar_inicio:
        cmp cl, al
        je  linea_encontrada        ;cuenta los saltos de linea para encontrar la linea aleatoria que toca.
        cmp byte ptr [si], 0
        je  fin_archivo
        cmp byte ptr [si], 0Ah
        jne continuar
        inc cl
    continuar:
        inc si
        jmp buscar_inicio

    linea_encontrada:
        mov dx, si              ; guardar inicio de la línea seleccionada
    buscar_fin:
        cmp byte ptr [si], 0        ;recorre para encontrar el final
        je fin_linea
        cmp byte ptr [si], 0Ah
        je fin_linea
        inc si
        jmp buscar_fin

    fin_linea:
        mov byte ptr [si], '$'  ; poner fin de cadena
        ret

    fin_archivo:
        mov byte ptr [si], '$'
        ret

    seleccionarFrase endp


end

