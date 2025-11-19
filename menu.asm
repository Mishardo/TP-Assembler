.8086
.model small
.stack 100h
.data
	titulo db "ASM Typer",0dh,0ah,24h
	jugar db "Jugar",0dh,0ah,24h
	salir db "Salir",0dh,0ah,24h
	ayuda db "Ayuda",0dh,0ah,24h
	dificultad db "Seleccione dificultad:",0dh,0ah,24h
	facil db "Facil",0dh,0ah,24h
	normal db "Normal",0dh,0ah,24h
	dificil db "Dificil",0dh,0ah,24h
	pixel db 219d,0dh,0ah,24h
	flecha db "<",0dh,0ah,24h
	valorDific db 0,24h
	ayudaTxtTitulo db "Bienvenido a ASM Typer!",0dh,0ah,24h
	ayudaTxt2 db "ASM Typer es un juego de mecanografia",0dh,0ah,24h
	ayudaTxt2bis db "donde desafias tu velocidad de tipeado.",0dh,0ah,24h
	ayudaTxt3 db "Prueba tu velocidad en diferentes dificultades, ",0dh,0ah,24h
	ayudaTxt4 db "Facil: 30s para tipear 3 frases faciles, 10 errores permitidos",0dh,0ah,24h
	ayudaTxt5 db "Medio: 20s para tipear 3 frases de nivel intermedio, 5 errores permitidos",0dh,0ah,24h
	ayudaTxt6 db "Dificil: 15s para tipear 3 frases de nivel avanzado, SIN ERRORES",0dh,0ah,24h
	ayudaTxt7 db "Completa todos los modos y coronate como el amo de la mecanografia!",0dh,0ah,24h
	ayudaTxt8 db "SAL DE ESTE MENU CON LA TECLA ESC",0dh,0ah,24h
	mover db "Te moves con W, S, Enter y Esc",24h
	moverSalir db "Te moves con A, D, Enter y Esc",24h
	creditos db "Creadores: Tomas M, David V, Thiago G R, Aliz T",24h
	variableBuc db 25,24h
	valorDesplaz db 3,24h
	salirSeguro db "Estas seguro?",0dh,0ah,24h
	siSalir db "Si",0dh,0ah,24h
	noSalir db "No",0dh,0ah,24h
	flechaArriba db "^",0dh,0ah,24h
.code
	public menu
	proc menu
	mov ax,@data
	mov ds,ax
tituloPrinc:
	mov ax, 0dh
	mov bx, 0   ; disable blinking.
	int 10h
	int 69h 
	mov ax, 0dh
	mov bx, 0   ; disable blinking.
	int 10h

	mov ah,01h
	mov ch,0026h
	mov cl,0007h
	int 10h
	mov ax, 0dh
	mov bx, 0   ; disable blinking.
	int 10h
	call tituloTxt

	cmp dl, 1
	je selectorDific
	cmp dl, 2
	je ayudaPagina
	jmp tituloPrinc
ayudaPagina:
	mov ax, 0eh
	mov bx, 0   ; disable blinking.
	int 10h
	call ayudaPrint
	cmp dl, 1
	je tituloPrinc
	jmp ayudaPagina
selectorDific:
	int 69h 
	mov ah,01h
	mov ch,0026h
	mov cl,0007h
	int 10h
	mov ax, 0dh
	mov bx, 0   ; disable blinking.
	int 10h
	call dificPrint
	mov valorDific,dl ; almacenamos el valor de dificultad

	ret
fin:
	jmp seguro
seguro:
	call seguroPrint
finalReal:
	mov ax,4c00h
	int 21h
	ret
	menu endp

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

	proc tituloTxt

selectorJugar:
	int 69h 

	call tituloPixeles
	call textoColor

	mov ah,02h
	mov bh,0
	mov dh,13 ; fila
	mov dl,17 ; columna
	int 10h

	mov ah,9
	lea dx, jugar
	int 21h


	mov ah,02h
	mov bh,0
	mov dh,13 ; fila
	mov dl,25 ; columna
	int 10h
	mov ah, 09h
	mov al, '<'
	mov bl, 0Bh   ; atributo de color (amarillo claro, fondo negro)
	mov bh, 0     
	mov cx, 1     ; imprimir 1 vez
	int 10h

	mov ah,02h
	mov bh,0
	mov dh,15 ; fila
	mov dl,17 ; columna
	int 10h

	mov ah,9
	lea dx, ayuda
	int 21h

	mov ah,02h
	mov bh,0
	mov dh,17 ; fila
	mov dl,17 ; columna
	int 10h

	mov ah,9
	lea dx, salir
	int 21h

	mov ah,1
	int 21h
	call minusculizar

	cmp al,"s"
	je AyudaSelect
	cmp al,0dh
	je JugarSeleccionado
	jmp selectorJugar


JugarSeleccionado:
	mov dl,1
	jmp retorno
AyudaSelect:
	int 69h 

	call tituloPixeles
	call textoColor

	mov ah,02h
	mov bh,0
	mov dh,13 ; fila
	mov dl,17 ; columna
	int 10h

	mov ah,9
	lea dx, jugar
	int 21h

	mov ah,02h
	mov bh,0
	mov dh,15 ; fila
	mov dl,25 ; columna
	int 10h
	mov ah, 09h
	mov al, '<'
	mov bl, 0Bh   ; atributo de color (amarillo claro, fondo negro)
	mov bh, 0     
	mov cx, 1     ; imprimir 1 vez
	int 10h


	mov ah,02h
	mov bh,0
	mov dh,15 ; fila
	mov dl,17 ; columna
	int 10h

	mov ah,9
	lea dx, ayuda
	int 21h

	mov ah,02h
	mov bh,0
	mov dh,17 ; fila
	mov dl,17 ; columna
	int 10h

	mov ah,9
	lea dx, salir
	int 21h

	mov ah,1
	int 21h
		call minusculizar

	call minusculizar
	cmp al,"w"
	je selectorJugarJmp
	cmp al,"s"
	je SalirSelect
	cmp al,0dh
	je AyudaSeleccionada
	jmp AyudaSelect
AyudaSeleccionada:
	mov dl,2
	jmp retorno
selectorJugarJmp:
	jmp selectorJugar
SalirSelect:
	int 69h 
	call tituloPixeles
	call textoColor

	mov ah,02h
	mov bh,0
	mov dh,13 ; fila
	mov dl,17 ; columna
	int 10h

	mov ah,9
	lea dx, jugar
	int 21h

	mov ah,02h
	mov bh,0
	mov dh,17 ; fila
	mov dl,25 ; columna
	int 10h
	mov ah, 09h
	mov al, '<'
	mov bl, 0Bh   ; atributo de color
	mov bh, 0     
	mov cx, 1     ; imprimir 1 vez
	int 10h



	mov ah,02h
	mov bh,0
	mov dh,15 ; fila
	mov dl,17 ; columna
	int 10h

	mov ah,9
	lea dx, ayuda
	int 21h

	mov ah,02h
	mov bh,0
	mov dh,17 ; fila
	mov dl,17 ; columna
	int 10h

	mov ah,9
	lea dx, salir
	int 21h

	mov ah,1
	int 21h
	call minusculizar

	cmp al,"w"
	je AyudaSelectJmp
	cmp al,0dh
	je finJmpMenu
	jmp SalirSelect	
finJmpMenu:
	jmp fin
AyudaSelectJmp:
	jmp AyudaSelect
retorno:

	ret
	tituloTxt endp 

	proc dificPrint


facilSelect:
	call cls 

	mov ah,02h
	mov bh,0
	mov dh,9 ; fila
	mov dl,8 ; columna
	int 10h

	mov ah,9
	lea dx, dificultad
	int 21h

	mov ah,02h
	mov bh,0
	mov dh,11 ; fila
	mov dl,15 ; columna
	int 10h

	mov ah,9
	lea dx, facil
	int 21h
	mov ah,02h
	mov bh,0
	mov dh,11 ; fila
	mov dl,25 ; columna
	int 10h
	mov ah, 09h
	mov al, '<'
	mov bl, 0Bh   ; atributo de color
	mov bh, 0     
	mov cx, 1     ; imprimir 1 vez
	int 10h
	
	mov ah,02h
	mov bh,0
	mov dh,13 ; fila
	mov dl,15 ; columna
	int 10h

	mov ah,9
	lea dx, normal
	int 21h
	mov ah,02h
	mov bh,0
	mov dh,15 ; fila
	mov dl,14 ; columna
	int 10h

	mov ah,9
	lea dx, dificil
	int 21h
	mov ah,1
	int 21h
	call minusculizar

	cmp al,"s"
	je normalSelect
	cmp al,0dh
	je seleccionFacil
	cmp al,1bh
	je finJmp
	jmp facilSelect

seleccionFacil:
	mov dl, 1; indica que se selecciono el facil
	jmp final
finJmp:
	jmp tituloPrinc
normalSelect:
	call cls 
	mov ah,02h
	mov bh,0
	mov dh,9 ; fila
	mov dl,8 ; columna
	int 10h

	mov ah,9
	lea dx, dificultad
	int 21h
	mov ah,02h
	mov bh,0
	mov dh,11 ; fila
	mov dl,15 ; columna
	int 10h

	mov ah,9
	lea dx, facil
	int 21h

	mov ah,02h
	mov bh,0
	mov dh,13 ; fila
	mov dl,15 ; columna
	int 10h

	mov ah,9
	lea dx, normal
	int 21h
	mov ah,02h
	mov bh,0
	mov dh,15 ; fila
	mov dl,14 ; columna
	int 10h

	mov ah,9
	lea dx, dificil
	int 21h


	mov ah,02h
	mov bh,0
	mov dh,13 ; fila
	mov dl,25 ; columna
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

	cmp al,"s"
	je dificilSelect
	cmp al,"w"
	je facilSelectJmp
	cmp al,0dh
	je seleccionNormal
	cmp al,1bh
	je finJmp3
	jmp normalSelect

seleccionNormal:
	mov dl, 2; indica que se selecciono el medio
	jmp final
facilSelectJmp:
	jmp facilSelect
finJmp3:
	jmp tituloPrinc
dificilSelect:
	call cls 
	mov ah,02h
	mov bh,0
	mov dh,9 ; fila
	mov dl,8 ; columna
	int 10h

	mov ah,9
	lea dx, dificultad
	int 21h
	mov ah,02h
	mov bh,0
	mov dh,11 ; fila
	mov dl,15 ; columna
	int 10h

	mov ah,9
	lea dx, facil
	int 21h
	mov ah,02h
	mov bh,0
	mov dh,15 ; fila
	mov dl,25 ; columna
	int 10h
	mov ah, 09h
	mov al, '<'
	mov bl, 0Bh   ; atributo de color
	mov bh, 0     
	mov cx, 1     ; imprimir 1 vez
	int 10h
	mov ah,02h
	mov bh,0
	mov dh,13 ; fila
	mov dl,15 ; columna
	int 10h

	mov ah,9
	lea dx, normal
	int 21h
	mov ah,02h
	mov bh,0
	mov dh,15 ; fila
	mov dl,14 ; columna
	int 10h

	mov ah,9
	lea dx, dificil
	int 21h


	mov ah,1
	int 21h
	call minusculizar

	cmp al,"w"
	je normalSelectJmp
	cmp al,0dh
	je seleccionDificil
	cmp al,1bh
	je finJmp2
	jmp dificilSelect
normalSelectJmp:
	jmp normalSelect
seleccionDificil:
	mov dl, 3; indica que se selecciono el dificil
	jmp final
finJmp2:
	jmp tituloPrinc
final:
	ret
	dificPrint endp
	proc ayudaPrint
ayudaPrintBuc:
	call cls 
	call creditosTxt
	mov ah,02h
	mov bh,0
	mov dh,3 ; fila
	mov dl,30 ; columna
	int 10h

	mov ah,9
	lea dx, ayudaTxtTitulo
	int 21h
	mov ah,02h
	mov bh,0
	mov dh,8 ; fila
	mov dl,4 ; columna
	int 10h

	mov ah,9
	lea dx, ayudaTxt2
	int 21h
	mov ah,02h
	mov bh,0
	mov dh,10 ; fila
	mov dl,4 ; columna
	int 10h

	mov ah,9
	lea dx, ayudaTxt3
	int 21h
	mov ah,02h
	mov bh,0
	mov dh,12 ; fila
	mov dl,4 ; columna
	int 10h

	mov ah,9
	lea dx, ayudaTxt4
	int 21h

	mov ah,02h
	mov bh,0
	mov dh,14 ; fila
	mov dl,4 ; columna
	int 10h

	mov ah,9
	lea dx, ayudaTxt5
	int 21h

	mov ah,02h
	mov bh,0
	mov dh,16 ; fila
	mov dl,4 ; columna
	int 10h

	mov ah,9
	lea dx, ayudaTxt6
	int 21h

	mov ah,02h
	mov bh,0
	mov dh,18 ; fila
	mov dl,4 ; columna
	int 10h

	mov ah,9
	lea dx, ayudaTxt7
	int 21h

	mov ah,02h
	mov bh,0
	mov dh,20 ; fila
	mov dl,4 ; columna
	int 10h

	mov ah,9
	lea dx, ayudaTxt8
	int 21h
	mov ah,1
	int 21h
	call minusculizar

	cmp al,1bh
	je salirAyuda
	jmp ayudaPrintBuc
salirAyuda:
	mov dl,1
	ret
	ayudaPrint endp 
	proc tituloPixeles

	mov dh,1 ; fila
	mov dl,9 ; columna
	call pixelPoner

	mov dh,1 ; fila
	mov dl,10 ; columna
	call pixelPoner

	mov dh,1 ; fila
	mov dl,11 ; columna
	call pixelPoner
	mov dh,2 ; fila
	mov dl,12 ; columna
	call pixelPoner
	mov dh,3 ; fila
	mov dl,12 ; columna
	call pixelPoner
	mov dh,4 ; fila
	mov dl,12 ; columna
	call pixelPoner
	mov dh,5 ; fila
	mov dl,12 ; columna
	call pixelPoner
	mov dh,2 ; fila
	mov dl,8 ; columna
	call pixelPoner

	mov dh,3 ; fila
	mov dl,8 ; columna
	call pixelPoner
	mov dh,3 ; fila
	mov dl,9 ; columna
	call pixelPoner
	mov dh,3 ; fila
	mov dl,10 ; columna
	call pixelPoner
	mov dh,3 ; fila
	mov dl,11 ; columna
	call pixelPoner
	mov dh,4 ; fila
	mov dl,8 ; columna
	call pixelPoner
	mov dh,5 ; fila
	mov dl,8 ; columna
	call pixelPoner
	mov dh,5 ; fila
	mov dl,14 ; columna
	call pixelPoner
	mov dh,5 ; fila
	mov dl,15 ; columna
	call pixelPoner
	mov dh,5 ; fila
	mov dl,16 ; columna
	call pixelPoner
	mov dh,5 ; fila
	mov dl,17 ; columna
	call pixelPoner
	mov dh,4 ; fila
	mov dl,18 ; columna
	call pixelPoner

	mov dh,3 ; fila
	mov dl,17 ; columna
	call pixelPoner
	mov dh,3 ; fila
	mov dl,16 ; columna
	call pixelPoner
	mov dh,3 ; fila
	mov dl,15 ; columna
	call pixelPoner
	mov dh,2 ; fila
	mov dl,14 ; columna
	call pixelPoner

	mov dh,1 ; fila
	mov dl,15 ; columna
	call pixelPoner
	mov dh,1 ; fila
	mov dl,16 ; columna
	call pixelPoner
	mov dh,1 ; fila
	mov dl,17 ; columna
	call pixelPoner
	mov dh,1 ; fila
	mov dl,18 ; columna
	call pixelPoner

	mov dh,1 ; fila
	mov dl,20 ; columna
	call pixelPoner
	mov dh,2 ; fila
	mov dl,20 ; columna
	call pixelPoner
	mov dh,2 ; fila
	mov dl,21 ; columna
	call pixelPoner
	mov dh,2 ; fila
	mov dl,23 ; columna
	call pixelPoner
	mov dh,3 ; fila
	mov dl,20 ; columna
	call pixelPoner
	mov dh,3 ; fila
	mov dl,22 ; columna
	call pixelPoner	
	mov dh,4 ; fila
	mov dl,20 ; columna
	call pixelPoner
	mov dh,5 ; fila
	mov dl,20 ; columna
	call pixelPoner
	mov dh,5 ; fila
	mov dl,24 ; columna
	call pixelPoner
	mov dh,4 ; fila
	mov dl,24 ; columna
	call pixelPoner
	mov dh,3 ; fila
	mov dl,24 ; columna
	call pixelPoner
	mov dh,2 ; fila
	mov dl,24 ; columna
	call pixelPoner
	mov dh,1 ; fila
	mov dl,24 ; columna
	call pixelPoner


	mov dh,7 ; fila
	mov dl,8 ; columna
	call pixelPoner
	mov dh,7 ; fila
	mov dl,9 ; columna
	call pixelPoner
	mov dh,7 ; fila
	mov dl,10 ; columna
	call pixelPoner
	mov dh,8 ; fila
	mov dl,10 ; columna
	call pixelPoner
	mov dh,9 ; fila
	mov dl,10 ; columna
	call pixelPoner
	mov dh,10 ; fila
	mov dl,10 ; columna
	call pixelPoner
	mov dh,11 ; fila
	mov dl,10 ; columna
	call pixelPoner
	mov dh,7 ; fila
	mov dl,11 ; columna
	call pixelPoner
	mov dh,7 ; fila
	mov dl,12 ; columna
	call pixelPoner


	mov dh,7 ; fila
	mov dl,14 ; columna
	call pixelPoner
	mov dh,8 ; fila
	mov dl,15 ; columna
	call pixelPoner
	mov dh,9 ; fila
	mov dl,16 ; columna
	call pixelPoner
	mov dh,10 ; fila
	mov dl,16 ; columna
	call pixelPoner
	mov dh,11 ; fila
	mov dl,16 ; columna
	call pixelPoner
	mov dh,8 ; fila
	mov dl,17 ; columna
	call pixelPoner
	mov dh,7 ; fila
	mov dl,18 ; columna
	call pixelPoner

	mov dh,7 ; fila
	mov dl,20 ; columna
	call pixelPoner
	mov dh,7 ; fila
	mov dl,21 ; columna
	call pixelPoner
	mov dh,7 ; fila
	mov dl,22 ; columna
	call pixelPoner
	mov dh,7 ; fila
	mov dl,23 ; columna
	call pixelPoner
	mov dh,8 ; fila
	mov dl,24 ; columna
	call pixelPoner
	mov dh,9 ; fila
	mov dl,22 ; columna
	call pixelPoner
	mov dh,9 ; fila
	mov dl,21 ; columna
	call pixelPoner
	mov dh,9 ; fila
	mov dl,23 ; columna
	call pixelPoner
	mov dh,8 ; fila
	mov dl,20 ; columna
	call pixelPoner
	mov dh,9 ; fila
	mov dl,20 ; columna
	call pixelPoner
	mov dh,10 ; fila
	mov dl,20 ; columna
	call pixelPoner
	mov dh,11 ; fila
	mov dl,20 ; columna
	call pixelPoner

	mov dh,11 ; fila
	mov dl,26 ; columna
	call pixelPoner
	mov dh,10 ; fila
	mov dl,26 ; columna
	call pixelPoner
	mov dh,9 ; fila
	mov dl,26 ; columna
	call pixelPoner
	mov dh,8 ; fila
	mov dl,26 ; columna
	call pixelPoner
	mov dh,7 ; fila
	mov dl,26 ; columna
	call pixelPoner
	mov dh,7 ; fila
	mov dl,27 ; columna
	call pixelPoner
	mov dh,11 ; fila
	mov dl,27 ; columna
	call pixelPoner
	mov dh,11 ; fila
	mov dl,28 ; columna
	call pixelPoner
	mov dh,11 ; fila
	mov dl,29 ; columna
	call pixelPoner
	mov dh,11 ; fila
	mov dl,29 ; columna
	call pixelPoner
	mov dh,9 ; fila
	mov dl,28 ; columna
	call pixelPoner
	mov dh,9 ; fila
	mov dl,27 ; columna
	call pixelPoner
	mov dh,7 ; fila
	mov dl,28 ; columna
	call pixelPoner
	mov dh,7 ; fila
	mov dl,29 ; columna
	call pixelPoner


	mov dh,7 ; fila
	mov dl,31 ; columna
	call pixelPoner

	mov dh,7 ; fila
	mov dl,20 ; columna
	add dl,11
	call pixelPoner

	mov dh,7 ; fila
	mov dl,21 ; columna
	add dl,11
	call pixelPoner
	mov dh,7 ; fila
	mov dl,22 ; columna
	add dl,11
	call pixelPoner
	mov dh,7 ; fila
	mov dl,23 ; columna
	add dl,11
	call pixelPoner
	mov dh,8 ; fila
	mov dl,24 ; columna
	add dl,11
	call pixelPoner
	mov dh,9 ; fila
	mov dl,22 ; columna
	add dl,11
	call pixelPoner
	mov dh,9 ; fila
	mov dl,21 ; columna
	add dl,11
	call pixelPoner
	mov dh,9 ; fila
	mov dl,23 ; columna
	add dl,11
	call pixelPoner
	mov dh,8 ; fila
	mov dl,20 ; columna
	add dl,11
	call pixelPoner
	mov dh,9 ; fila
	mov dl,20 ; columna
	add dl,11
	call pixelPoner
	mov dh,10 ; fila
	mov dl,20 ; columna
	add dl,11
	call pixelPoner
	mov dh,11 ; fila
	mov dl,20 ; columna
	add dl,11
	call pixelPoner
	mov dh,11 ; fila
	mov dl,34 ; columna
	call pixelPoner
	mov dh,10 ; fila
	mov dl,33 ; columna
	call pixelPoner

	ret
	tituloPixeles endp

	proc pixelPoner
	inc dl
	mov ah,02h
	mov bh,0
	int 10h

	mov ah,9
	lea dx, pixel
	int 21h
	ret
	pixelPoner endp
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

	proc cantidadCaracteres
	xor cl,cl
cantidad:
	cmp byte ptr [bx],24h
	je terminarDeInc
	inc bx
	inc cl
	jmp cantidad
terminarDeInc:
	xor bx,bx
	ret
cantidadCaracteres endp
	proc textoColor ; Este estilo de funcion se repite a lo largo del codigo
	push ax ; porque cada funcion depende de la posicion, color, y el texto que se vayan a usar en el
	push bx ; momento
	push dx
	push cx
	xor si,si
	mov valorDesplaz,0
	mov variableBuc,30
	lea si,mover
bucleColor:

	cmp variableBuc,0
	je terminoColor
	mov ah,02h
	mov bh,0
	mov dh,23 ; fila
	mov dl,1 ; columna
	add dl,valorDesplaz
	int 10h
	mov ah, 09h

	mov al, [si]
	mov bl, 0Eh
	mov bh, 0     
	mov cx, 1
	int 10h
	inc si
	inc valorDesplaz
	dec variableBuc
	jmp bucleColor
terminoColor:
	pop cx
	pop dx
	pop bx
	pop ax
	ret
	textoColor endp
	proc creditosTxt
	push ax
	push bx
	push dx
	push cx
	xor si,si
	mov valorDesplaz,0
	mov variableBuc,47
	lea si,creditos
bucleCreditos:

	cmp variableBuc,0
	je terminoCreditos
	mov ah,02h
	mov bh,0
	mov dh,23 ; fila
	mov dl,4 ; columna
	add dl,valorDesplaz
	int 10h
	mov ah, 09h

	mov al, [si]
	mov bl, 7
	mov bh, 0     
	mov cx, 1
	int 10h
	inc si
	inc valorDesplaz
	dec variableBuc
	jmp bucleCreditos
terminoCreditos:
	pop cx
	pop dx
	pop bx
	pop ax
	ret
	creditosTxt endp	


	proc seguroPrint
siSalirSelect:
	int 69h 

	call cuadradoSalir
	call estasSeguroColor

	mov ah,02h
	mov bh,0
	mov dh,8; fila
	mov dl,14 ; columna
	int 10h

	mov ah,9
	lea dx, salirSeguro
	int 21h
	mov ah,02h
	mov bh,0
	mov dh,15; fila
	mov dl,14 ; columna
	int 10h

	mov ah,9
	lea dx, siSalir
	int 21h
	mov ah,02h
	mov bh,0
	mov dh,15; fila
	mov dl,24 ; columna
	int 10h

	mov ah,9
	lea dx, noSalir
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
	je noSalirSelect
	cmp al,0dh
	je finSaltar
	cmp al,1bh
	je volverMenu

	jmp siSalirSelect
noSalirSelect:
	int 69h 

	call cuadradoSalir
	call estasSeguroColor
	mov ah,02h
	mov bh,0
	mov dh,8; fila
	mov dl,14 ; columna
	int 10h

	mov ah,9
	lea dx, salirSeguro
	int 21h
	mov ah,02h
	mov bh,0
	mov dh,15; fila
	mov dl,14 ; columna
	int 10h

	mov ah,9
	lea dx, siSalir
	int 21h
	mov ah,02h
	mov bh,0
	mov dh,15; fila
	mov dl,24 ; columna
	int 10h

	mov ah,9
	lea dx, noSalir
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
	je siSalirSelectJmp
	cmp al,0dh
	je volverMenu
	cmp al,1bh
	je volverMenu
	jmp noSalirSelect
siSalirSelectJmp:
	jmp siSalirSelect
volverMenu:
	jmp tituloPrinc
finSaltar:
	int 69h 

	jmp finalReal
finalSeguro:
	ret
	seguroPrint endp

	proc estasSeguroColor
	push ax
	push bx
	push dx
	push cx
	xor si,si
	mov valorDesplaz,0
	mov variableBuc,30
	lea si,moverSalir
bucleSalir:

	cmp variableBuc,0
	je terminoSalir
	mov ah,02h
	mov bh,0
	mov dh,23 ; fila
	mov dl,4 ; columna
	add dl,valorDesplaz
	int 10h
	mov ah, 09h

	mov al, [si]
	mov bl, 0eh
	mov bh, 0     
	mov cx, 1
	int 10h
	inc si
	inc valorDesplaz
	dec variableBuc
	jmp bucleSalir
terminoSalir:
	pop cx
	pop dx
	pop bx
	pop ax
	ret

	estasSeguroColor endp


	proc cuadradoSalir
		mov dh,5 ; fila
	mov dl,2 ; columna
	add dl,3
	call pixelPoner
	mov dh,6 ; fila
	mov dl,2 ; columna
	add dl,3
	call pixelPoner
	mov dh,7 ; fila
	mov dl,2 ; columna
	add dl,3
	call pixelPoner
	mov dh,8 ; fila
	mov dl,2 ; columna
	add dl,3
	call pixelPoner
	mov dh,9 ; fila
	mov dl,2 ; columna
	add dl,3
	call pixelPoner
	mov dh,10 ; fila
	mov dl,2 ; columna
	add dl,3
	call pixelPoner
	mov dh,11 ; fila
	mov dl,2 ; columna
	add dl,3
	call pixelPoner
	mov dh,12 ; fila
	mov dl,2 ; columna
	add dl,3
	call pixelPoner
	mov dh,13 ; fila
	mov dl,2 ; columna
	add dl,3
	call pixelPoner
	mov dh,14 ; fila
	mov dl,2 ; columna
	add dl,3
	call pixelPoner
	mov dh,15 ; fila
	mov dl,2 ; columna
	add dl,3
	call pixelPoner
	mov dh,16 ; fila
	mov dl,2 ; columna
	add dl,3
	call pixelPoner
	mov dh,17 ; fila
	mov dl,2 ; columna
	add dl,3
	call pixelPoner
	mov dh,18 ; fila
	mov dl,2 ; columna
	add dl,3
	call pixelPoner
	mov dh,19 ; fila
	mov dl,2 ; columna
	add dl,3
	call pixelPoner
	mov dh,20 ; fila
	mov dl,2 ; columna
	add dl,3
	call pixelPoner
	mov dh,20 ; fila
	mov dl,3 ; columna
	add dl,3
	call pixelPoner
	mov dh,20 ; fila
	mov dl,4 ; columna
	add dl,3
	call pixelPoner
	mov dh,20 ; fila
	mov dl,5 ; columna
	add dl,3
	call pixelPoner
	mov dh,20 ; fila
	mov dl,6 ; columna
	add dl,3
	call pixelPoner
	mov dh,20 ; fila
	mov dl,7 ; columna
	add dl,3
	call pixelPoner
	mov dh,20 ; fila
	mov dl,8 ; columna
	add dl,3
	call pixelPoner
	mov dh,20 ; fila
	mov dl,9 ; columna
	add dl,3
	call pixelPoner
	mov dh,20 ; fila
	mov dl,10 ; columna
	add dl,3
	call pixelPoner
	mov dh,20 ; fila
	mov dl,11 ; columna
	add dl,3
	call pixelPoner
	mov dh,20 ; fila
	mov dl,12 ; columna
	add dl,3
	call pixelPoner
	mov dh,20 ; fila
	mov dl,13 ; columna
	add dl,3
	call pixelPoner
	mov dh,20 ; fila
	mov dl,14 ; columna
	add dl,3
	call pixelPoner
	mov dh,20 ; fila
	mov dl,15 ; columna
	add dl,3
	call pixelPoner
	mov dh,20 ; fila
	mov dl,16 ; columna
	add dl,3
	call pixelPoner
	mov dh,20 ; fila
	mov dl,17 ; columna
	add dl,3
	call pixelPoner
	mov dh,20 ; fila
	mov dl,18 ; columna
	add dl,3
	call pixelPoner
	mov dh,20 ; fila
	mov dl,19 ; columna
	add dl,3
	call pixelPoner
	mov dh,20 ; fila
	mov dl,20 ; columna
	add dl,3
	call pixelPoner
	mov dh,20 ; fila
	mov dl,21 ; columna
	add dl,3
	call pixelPoner
	mov dh,20 ; fila
	mov dl,22 ; columna
	add dl,3
	call pixelPoner
	mov dh,20 ; fila
	mov dl,23 ; columna
	add dl,3
	call pixelPoner
	mov dh,20 ; fila
	mov dl,24 ; columna
	add dl,3
	call pixelPoner
	mov dh,20 ; fila
	mov dl,25 ; columna
	add dl,3
	call pixelPoner
	mov dh,20 ; fila
	mov dl,26 ; columna
	add dl,3
	call pixelPoner
	mov dh,20 ; fila
	mov dl,27 ; columna
	add dl,3
	call pixelPoner
	mov dh,20 ; fila
	mov dl,28 ; columna
	add dl,3
	call pixelPoner	
	mov dh,20 ; fila
	mov dl,29 ; columna
	add dl,3
	call pixelPoner	
	mov dh,20 ; fila
	mov dl,30 ; columna
	add dl,3
	call pixelPoner	
	mov dh,19 ; fila
	mov dl,30 ; columna
	add dl,3
	call pixelPoner	
	mov dh,18 ; fila
	mov dl,30 ; columna
	add dl,3
	call pixelPoner	
	mov dh,17 ; fila
	mov dl,30 ; columna
	add dl,3
	call pixelPoner	
	mov dh,16 ; fila
	mov dl,30 ; columna
	add dl,3
	call pixelPoner	
	mov dh,15 ; fila
	mov dl,30 ; columna
	add dl,3
	call pixelPoner	
	mov dh,14 ; fila
	mov dl,30 ; columna
	add dl,3
	call pixelPoner	
	mov dh,13 ; fila
	mov dl,30 ; columna
	add dl,3
	call pixelPoner	
	mov dh,12 ; fila
	mov dl,30 ; columna
	add dl,3
	call pixelPoner	
	mov dh,11 ; fila
	mov dl,30 ; columna
	add dl,3
	call pixelPoner	
	mov dh,10 ; fila
	mov dl,30 ; columna
	add dl,3
	call pixelPoner	
	mov dh,9 ; fila
	mov dl,30 ; columna
	add dl,3
	call pixelPoner	
	mov dh,8 ; fila
	mov dl,30 ; columna
	add dl,3
	call pixelPoner	
	mov dh,7 ; fila
	mov dl,30 ; columna
	add dl,3
	call pixelPoner	
	mov dh,6 ; fila
	mov dl,30 ; columna
	add dl,3
	call pixelPoner	
	mov dh,5 ; fila
	mov dl,30 ; columna
	add dl,3
	call pixelPoner	
	mov dh,5 ; fila
	mov dl,30 ; columna
	add dl,3
	call pixelPoner
	mov dh,5 ; fila
	mov dl,29 ; columna
	add dl,3
	call pixelPoner
	mov dh,5 ; fila
	mov dl,28 ; columna
	add dl,3
	call pixelPoner
	mov dh,5 ; fila
	mov dl,27 ; columna
	add dl,3
	call pixelPoner
	mov dh,5 ; fila
	mov dl,26 ; columna
	add dl,3
	call pixelPoner
	mov dh,5 ; fila
	mov dl,25 ; columna
	add dl,3
	call pixelPoner
	mov dh,5 ; fila
	mov dl,24 ; columna
	add dl,3
	call pixelPoner
	mov dh,5 ; fila
	mov dl,23 ; columna
	add dl,3
	call pixelPoner
	mov dh,5 ; fila
	mov dl,22 ; columna
	add dl,3
	call pixelPoner
	mov dh,5 ; fila
	mov dl,21 ; columna
	add dl,3
	call pixelPoner
	mov dh,5 ; fila
	mov dl,20 ; columna
	add dl,3
	call pixelPoner
	mov dh,5 ; fila
	mov dl,19 ; columna
	add dl,3
	call pixelPoner
	mov dh,5 ; fila
	mov dl,18 ; columna
	add dl,3
	call pixelPoner
	mov dh,5 ; fila
	mov dl,17 ; columna
	add dl,3
	call pixelPoner
	mov dh,5 ; fila
	mov dl,16 ; columna
	add dl,3
	call pixelPoner
	mov dh,5 ; fila
	mov dl,15 ; columna
	add dl,3
	call pixelPoner
	mov dh,5 ; fila
	mov dl,14 ; columna
	add dl,3
	call pixelPoner
	mov dh,5 ; fila
	mov dl,13 ; columna
	add dl,3
	call pixelPoner
	mov dh,5 ; fila
	mov dl,12 ; columna
	add dl,3
	call pixelPoner
	mov dh,5 ; fila
	mov dl,11 ; columna
	add dl,3
	call pixelPoner
	mov dh,5 ; fila
	mov dl,10 ; columna
	add dl,3
	call pixelPoner
	mov dh,5 ; fila
	mov dl,9 ; columna
	add dl,3
	call pixelPoner
	mov dh,5 ; fila
	mov dl,8 ; columna
	add dl,3
	call pixelPoner
	mov dh,5 ; fila
	mov dl,7 ; columna
	add dl,3
	call pixelPoner
	mov dh,5 ; fila
	mov dl,6 ; columna
	add dl,3
	call pixelPoner
	mov dh,5 ; fila
	mov dl,5 ; columna
	add dl,3
	call pixelPoner
	mov dh,5 ; fila
	mov dl,4 ; columna
	add dl,3
	call pixelPoner
	mov dh,5 ; fila
	mov dl,3 ; columna
	add dl,3
	call pixelPoner
	mov dh,5 ; fila
	mov dl,2 ; columna
	add dl,3
	call pixelPoner
	ret
	cuadradoSalir endp
end
