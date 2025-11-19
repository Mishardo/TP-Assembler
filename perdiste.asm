.8086
.model small
.stack 100h
.data
	perdisteTxt db "Perdiste! Queres reintentar?",0dh,0ah,24h
	siReint db "Si",0dh,0ah,24h
	noReint db "No",0dh,0ah,24h
.code
	extrn main:proc
	public perdiste
	proc perdiste
	mov ax,@data
	mov ds,ax
	call cls

	mov ax, 0dh
	mov bx, 0
	int 10h
	
	call reintentarPrint
	cmp dl,1
	je volverMenuOpcion
	cmp dl,2
	je terminarOpcion

terminarOpcion:
	call cls
	mov ax,4c00h
	int 21h 
volverMenuOpcion:
	call cls 
	call main

	ret
	
	perdiste endp

	proc reintentarPrint
siReintSelect:
	call cls
	mov ah,02h
	mov bh,0
	mov dh,8; fila
	mov dl,8 ; columna
	int 10h

	mov ah,9
	lea dx, perdisteTxt
	int 21h
	mov ah,02h
	mov bh,0
	mov dh,15; fila
	mov dl,14 ; columna
	int 10h

	mov ah,9
	lea dx, siReint
	int 21h
	mov ah,02h
	mov bh,0
	mov dh,15; fila
	mov dl,24 ; columna
	int 10h

	mov ah,9
	lea dx, noReint
	int 21h

	mov ah,02h
	mov bh,0
	mov dh,15 ; fila
	mov dl,18 ; columna
	int 10h
	mov ah, 09h
	mov al, '<'
	mov bl, 0Bh   ; atributo de color
	mov bh, 0     
	mov cx, 1     ; imprimir 1 vez
	int 10h
	mov ah,1
	int 21h
	call minusculizar
	cmp al,"d"
	je noReintSelect
	cmp al,0dh
	je volverMenu

	jmp siReintSelect
volverMenu:
	mov dl,1
	jmp finReint

noReintSelect:
	call cls
	mov ah,02h
	mov bh,0
	mov dh,8; fila
	mov dl,8 ; columna
	int 10h

	mov ah,9
	lea dx, perdisteTxt
	int 21h
	mov ah,02h
	mov bh,0
	mov dh,15; fila
	mov dl,14 ; columna
	int 10h

	mov ah,9
	lea dx, siReint
	int 21h
	mov ah,02h
	mov bh,0
	mov dh,15; fila
	mov dl,24 ; columna
	int 10h

	mov ah,9
	lea dx, noReint
	int 21h

	mov ah,02h
	mov bh,0
	mov dh,15 ; fila
	mov dl,28 ; columna
	int 10h
	mov ah, 09h
	mov al, '<'
	mov bl, 0Bh   ; atributo de color
	mov bh, 0     
	mov cx, 1     ; imprimir 1 vez
	int 10h
	mov ah,1
	int 21h
	call minusculizar
	cmp al,"a"
	je siReintSelectJmp
	cmp al,0dh
	je finalSelect

	jmp noReintSelect
siReintSelectJmp:
	jmp siReintSelect
finalSelect:
	mov dl,2
	jmp finReint
finReint:
	ret

	reintentarPrint endp
	proc cls
	push ax

	mov ah, 0fh
	int 10h
	mov ah, 0
	int 10h
	mov ah,02h

	pop ax
	ret
	cls endp
	proc minusculizar
	cmp al,41h ;A
	jae casiMayus
	jmp terminar
casiMayus:
	cmp al, 5Ah ;Z
	jbe esMayus
	jmp terminar
esMayus:
	add al,20h
terminar:
	ret
	endp minusculizar
end