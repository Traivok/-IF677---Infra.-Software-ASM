org 0x7c00
jmp 0x0000:start

array_int db 150, 151, 122, 77, 0
array_string times 12 db 0 ;a quantidade de caracteres do array int mais o zero final
aux0 dw 0
aux1 dw 0
aux2 dw 0

start:
	xor ax, ax		; ax = 0
	mov ds, ax 		; ds = 0
	mov es, ax 		; es = 0

mov si, array_int
lodsb ; si -> al
to_string:

	.extract_transform: ; extrai o último algarismo de al
		; e transforma em caracter
		mov dh, 10
		div dh ; al/10 - o resto vai para ah 
		;(al é o source pois o número tem apenas um byte, se tivesse
		;mais, o source seria o ax)
		add ah, 48 ; ah += 48
		xchg ah, al ; ah <-> al
		mov di, array_string
		stosb ; al -> di

		; operação de print do caracter contido em al
		mov [aux0], ax ; para não perder na operação de print
		mov [aux1], si ; para não perder na operação de print
		mov [aux2], di ; para não perder na operação de print

		mov ah, 0xe ; número da chamada
		mov bh, 0 ; número da página
		mov bl, 0xf ; cor da letra, branco
		int 10h

		mov ax, [aux0] ; recuperando o valor
		mov si, [aux1] ; recuperando o valor
		mov di, [aux2] ; recuperando o valor
		; terminando a operação de print

		xchg ah, al ; ah <-> al
		cmp al, 0 ; al == 0?
		jne .extract_transform

	lodsb ; si -> al
	cmp al, 0 ; ver se chegou no fim do array_int
	jne to_string

done:
	jmp $

times 510 - ($ - $$) db 0
dw 0xaa55 ;assinatura de boot