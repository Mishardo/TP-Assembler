.8086
.model tiny
.code 
	org 100h
start:
	jmp main


limpiar proc far
	push ax

	mov ah, 0fh
	int 10h
	mov ah, 0
	int 10h
	mov ah,02h

	pop ax
    iret
endp

DespIntXX dw 0
SegIntXX dw 0
FinResidente label byte
Cartel db "Se instalo correctamente",0dh,0ah,24h
main:
	mov ax,cs
	mov ds,ax
	mov es,ax
InstalarInt:
	mov ax,3569h ; la interrupción es la 69
	int 21h

	mov DespIntXX,bx
	mov SegIntXX,es

	mov ax,2569h ; coloca la isr 69 en el vector de interrupciones
	lea dx, limpiar
	int 21h
printCartel:
	mov ah,9
	lea dx,Cartel
	int 21h
DejarResidente:
	mov ax,(15+ offset FinResidente)
	shr ax,1
	shr ax,1
	shr ax,1
	shr ax,1
	mov dx,ax
	mov ax,3100h
	int 21h
end start