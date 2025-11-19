.8086
.model small
.stack 100h
.data
    arch1		db 'frases.txt',0
    arch2       db 'frasemed.txt',0
    arch3       db 'frasedif.txt',0

    buf1		db 4096 dup(?)

    fraseSeleccionada db ?
    fraseInicial db 255 dup(24h)
    cartel db "error abrir archivo",0ah,0dh,24h

.code

    PUBLIC frase 
    PUBLIC fraseInicial

frase proc
    ; RECIBE POR PARAMETRO:
    ;                        DL: elige el archivo
    ; Devuelve en: ??
    
    push bp
    mov bp, sp

    cmp dl,1
    je frasefacil
    cmp dl,2
    je frasemed 
    cmp dl,3
    je frasedifi

    frasefacil: 
    lea dx, arch1
    jmp abrirarchivo

    frasemed:
    lea dx, arch2
    jmp abrirarchivo

    frasedifi:
    lea dx, arch3
    jmp abrirarchivo

    abrirarchivo:
    ;-------- Abrir el archivo ----------
    mov ah, 3Dh
    mov al, 0
    int 21h
    jc errorAbrirArchivo

    ;------ Leer el archivo -------------
    mov bx, ax        ; handle
    mov ah, 3Fh
    mov cx, 4095
    mov dx, offset buf1
    int 21h           ; lee hasta 255 bytes
    jc errorLeerArchivo

    ;------ Cerrar el archivo -------
    mov ah, 3Eh
    int 21h

    ;-------- Seleccionar aleatorio entre 0 y 20 ------
    mov ah, 00h
    int 1Ah
    mov ax, dx
    mov bx, 20
    xor dx, dx
    div bx
    mov fraseSeleccionada, dl
    ;---------------------------------------------------

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; FUNCION INTERNA ;;;;;;;;;;;;;;;;;;;;;;;;
    ; luego quiero agregarle un nro aleatorio y que ponga el offset al inicio de luego de un salto de linea y el signo pesos al final de esa linea
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;