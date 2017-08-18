org 0x7c00
jmp 0x0000:start

num1 db '000', 0
num2 db '000', 0

start:
	xor ax, ax ;zera ax
	mov ds, ax
	mov es, ax

	mov si, num1 ;; pass num1 as arg to read
	call read_to_si ;; call read(num1)
	mov [num1], si
	call print_from_si

	jmp done

read_to_si: ;;; ERROR - input not stored - ERROR ;;; 

	.start:
		mov ah, 0 ;; read keyboard
		int 16h ;; keyboard interrupt
			
		cmp al, 0xd
		je .done ;; if (al == 'enter') return
		jmp .output ;; else print last input 

		lodsb ;; store al (key stroke) to si (arg passed)

	.output:
		mov ah, 0xe ;; char print
		mov bh, 0 ;; page number
		mov bl, 0xf ;; white color
		int 10h ;; visual output

		jmp .start

	.done:
		
		call print_new_line

		mov al, 0 ;; end of string
		lodsb ;; store '\0'

		ret

print_from_si:	
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
			call print_new_line
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