org 0x7c00
jmp 0x0000:start

array_int db 120, 0
array_string times 12 db 0 ;a quantidade de caracteres do array int

start:
	xor ax, ax		; ax = 0
	mov ds, ax 		; ds = 0
	mov es, ax 		; es = 0
	mov si, array_int
	mov di, array_string
	lodsb ; si -> al

to_string:

	.extract_transform: ; extrai o último algarismo de ax
		; e transforma em character
		mov dh, 10
		div dh ; al = ax/10 - o resto vai para ah
		add ah, '0'; ah += '0'
		xchg ah, al; ah <-> al
		stosb ; al -> di

		mov dh, ah ; guarda o valor de ah
		xor ax, ax ; ax = 0
		mov al, dh ; al recebe o antigo valor de ah
		cmp al, 0 ; (al == 0) -> número todo transformado
		jne .extract_transform

	xor ax, ax ; ax = 0
	lodsb ; si -> al
	cmp al, 0 ; checa se chegou no fim do array_int
	jne to_string

	mov si, array_string ; para ser usado na print_string

print_string:
	lodsb ; si -> al
	mov ah, 0xe ; número da chamada
	mov bh, 0 ; número da página
	mov bl, 0xf ; cor da letra, branco
	int 10h
	cmp al, 0
	jne print_string

done:
	jmp $

times 510 - ($ - $$) db 0
dw 0xaa55 ;assinatura de boot
