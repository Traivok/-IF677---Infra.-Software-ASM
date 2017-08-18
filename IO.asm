org 0x7c00
jmp 0x0000:start

num1 db '000', 0
num2 db '000', 0

start:
	xor ax, ax ;zera ax
	mov ds, ax
	mov es, ax

	mov di, num1 ;; pass num1 as arg to read
	call readstr ;; call read(num1)
	
	mov si, num1
	call printstr

	jmp done

printstr:	
	.start:

		lodsb ;; si -> al
		cmp al, 0
		je .done ;; if (end of string) return
		jmp .print ;; else print current char

		.print:
			mov ah, 0xe ;; print char and move cursor foward
			mov bh, 0 ;; page number
			mov bl, 0xf ;; white color
			int 10h ;; video interrupt

			jmp .start

		.done:
			ret

print_new_line:
	mov ah, 0xe ;; char print
	mov bh, 0 ;; page number
	mov bl, 0xf ;; white color
	mov al, 13 ;; vertical tab
	int 10h ;; visual interrupt
	
	mov ah, 0xe ;; char print
	mov bh, 0 ;; page number
	mov bl, 0xf ;; white color
	mov al, 10 ;; backspace
	int 10h ;; visual interrupt	

	ret

done:
	jmp $

times 510-($-$$) db 0   ; Pad remainder of boot sector with 0s
dw 0xAA55               ; The standard PC boot signature
