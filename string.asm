org 0x7c00
jmp 0x0000:start

input_msg db "Your Text: ", 0
num times 8 db 0
var times 8 db 0
	
start:
	xor ax, ax		; init
	mov ds, ax 		; init
	mov es, ax 		; init

;;; <READ AND PRINT TEST> ;;;
	mov si, input_msg	; print input msg
	call printstr
	
	mov di, var		; pass var as arg to readstr
	call readstr

	mov si, var		; pass var as arg to printstr
	call printstr
	call println
;;; <READ AND PRINT TEST> ;;;
	
;;; <READ VERBOSELY TEST> ;;;
	mov di, num		; pass num as arg to readvstr	
	call readvstr 		; call read(num1)
	
	mov si, num
	call printstr
	call println
;;; <\READ VERBOSELY TEST> ;;;

;;; <VARIABLE CONTENT TEST> ;;;
	mov si, var
	call printstr
	call println
;;; <\VARIABLE CONTENT TEST> ;;;
	
	jmp done

;;; print string from si
printstr:
	.start:

		lodsb 		; si -> al
		cmp al, 0
		je .done 	; if (end of string) return
		jmp .print 	; else print current char

		.print:
			mov ah, 0xe 	; print char and move cursor foward
			mov bh, 0 	; page number
			mov bl, 0xf 	; white color
			int 10h 	; video interrupt

			jmp .start 
		.done:
			ret

;;; read string from di
readstr:
	.read:
		mov ah, 0 	; read keystroke
		int 16h		; keyboard interrupt

		cmp al, 0xd 	; compare al with 'enter'
		je .done
	
		stosb
		jmp .read	
	
	.done:
		mov al, 0 	; insert '\0'
		stosb
		ret

;;; read (verbosely) string from di and print char by char
readvstr:		
	.read:
		mov ah, 0 	; read keystroke
		int 16h		; keyboard interrupt

		cmp al, 0xd 	; compare al with 'enter'
		je .done
	
		stosb
		jmp .print
	
	.print:
		mov ah, 0xe 	; call number
		mov bh, 0	; page number
		mov bl, 0xf	; white color
		int 10h

		jmp .read

	.done:
		call println 	; print line
		mov al, 0 	; insert '\0'
		stosb
	
		ret 		; return
	
;;; print line (\n)
println:
	mov ah, 0xe ; char print
	mov bh, 0 ; page number
	mov bl, 0xf ; white color
	mov al, 13 ; vertical tab
	int 10h ; visual interrupt
	
	mov ah, 0xe ; char print
	mov bh, 0 ; page number
	mov bl, 0xf ; white color
	mov al, 10 ; backspace
	int 10h ; visual interrupt	

	ret

done:
	jmp $ 			; infinity jump

times 510-($-$$) db 0   ; Pad remainder of boot sector with 0s
dw 0xAA55               ; The standard PC boot signature
