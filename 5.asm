org 0x7c00
jmp 0x0000:start

cxL1 times 16 db 0
cxL2 times 16 db 0

start:

mov ax, 0
mov ds, ax
mov es, ax

mov ah, 0
mov al, 12h
int 10h

mov ah, 0xb
mov bh, 0
mov bl, 15
int 10h

redSquare:
	mov cx, 230			;repetir o L1 230x ate 1x vezes

	L1:;muda as colunas
		mov [cxL1], cx
		mov cx, 230 ;repetir o L2 230y ate 1y vezes
		L2:;muda as linhas
			mov [cxL2], cx			
			mov ah, 0ch ;pixel na coordenada [dx, cx]
			mov bh, 0
			mov cx, [cxL1]
			mov dx, [cxL2]
			mov al, 4 ;cor do pixel (VERMELHO)
			int 10h			
			mov cx, [cxL2]
		loop L2
		mov cx, [cxL1]
	loop L1


yellowSquare:	
	mov cx, 400;repetir o L3 do 300x ao 400x

	L3:;muda as colunas
		cmp cx, 300
		jle fim3 
		mov [cxL1], cx
		mov cx, 450 
		L4:;repetir L4 de 450y ate 300y 
			cmp cx, 300
			jle fim4
			mov [cxL2], cx			
			mov ah, 0ch ;pixel na coordenada [dx, cx]
			mov bh, 0
			mov cx, [cxL1]
			mov dx, [cxL2]
			mov al, 14 ;cor do pixel (AMARELO)
			int 10h			
			mov cx, [cxL2]
			fim4:
		loop L4
		mov cx, [cxL1]
		fim3:
	loop L3

blueSquare:
	mov cx, 600;repetir o L5 do 400x ate 600x

	L5:;muda as colunas
		cmp cx, 400
		jle fim5;a figura tem largura 75
		mov [cxL1], cx
		mov cx, 300 ;repetir o L5 do 100y ate 300y
		L6:;muda as linhas
			cmp cx, 100
			jle fim6
			mov [cxL2], cx			
			mov ah, 0ch ;pixel na coordenada [dx, cx]
			mov bh, 0
			mov cx, [cxL1]
			mov dx, [cxL2]
			mov al, 1 ;cor do pixel (AZUL)
			int 10h			
			mov cx, [cxL2]
			fim6:
		loop L6
		mov cx, [cxL1]
		fim5:
	loop L5

jmp $
times 510-($-$$) db 0
dw 0xaa55
