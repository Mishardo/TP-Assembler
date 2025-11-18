.8086
.model small
.stack 100h
.data
    arch1		db 'frases.txt',0
    buf1		db 4096 dup(?)
    fraseSeleccionada db ?
    fraseInicial db 255 dup(24h)
    cartel db "error abrir archivo",0ah,0dh,24h
    archivoAbierto db 0  ; 0 = cerrado, 1 = abierto

.code
    PUBLIC frase    
    PUBLIC fraseInicial

frase proc
    push bp
    mov bp, sp

    call limpiarV
    
    ;-------- Abrir el archivo ----------
    mov ah, 3Dh
    mov al, 0           ; modo lectura
    mov dx, offset arch1
    int 21h
    jc errorAbrirArchivo

    ;------ Leer el archivo -------------
    mov bx, ax          ; handle
    mov ah, 3Fh
    mov cx, 4095
    mov dx, offset buf1 ; buffer donde guardar
    int 21h
    jc errorLeerArchivo

    ;------ Cerrar el archivo -------
    mov ah, 3Eh
    int 21h

    ;-------- Seleccionar aleatorio ------
    mov ah, 00h
    int 1Ah
    mov ax, dx
    mov bx, 50
    xor dx, dx
    div bx
    mov fraseSeleccionada, dl

    call seleccionarFrase
    mov bx, offset fraseInicial

    pop bp
    ret

errorLeerArchivo:
    ; Cerrar archivo si hubo error de lectura
    mov ah, 3Eh
    int 21h

errorAbrirArchivo:
    mov bx, offset cartel
    pop bp
    ret
frase endp

seleccionarFrase proc
    mov si, offset buf1
    mov di, offset fraseInicial

    mov cl, 1                    ; línea actual
    mov al, fraseSeleccionada    ; línea buscada

buscar_inicio:
    cmp cl, al
    je copiar_linea

    cmp byte ptr [si], 0
    je fin_archivo

avanzar_linea:
    cmp byte ptr [si], 0Ah       ; salto de línea
    je siguiente_linea
    cmp byte ptr [si], 0         ; fin de archivo
    je fin_archivo
    inc si
    jmp avanzar_linea

siguiente_linea:
    inc si
    inc cl
    jmp buscar_inicio

copiar_linea:
    cmp byte ptr [si], 0Ah
    je terminar
    cmp byte ptr [si], 0Dh       ; retorno de carro
    je terminar
    cmp byte ptr [si], 0         ; fin de archivo
    je terminar
    mov al, [si]
    mov [di], al
    inc si
    inc di
    jmp copiar_linea

terminar:
    mov byte ptr [di], '$'
    ret

fin_archivo:
    mov byte ptr [di], '$'
    ret
seleccionarFrase endp

limpiarV proc
    push bp
    push cx
    push di
    mov bp, sp

    mov cx, 255
    lea di, fraseInicial
limpiar_loop:
    mov byte ptr [di], 24h
    inc di
    loop limpiar_loop

    pop di
    pop cx
    pop bp
    ret
limpiarV endp

end