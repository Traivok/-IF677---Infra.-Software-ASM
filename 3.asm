org 0x7c00
jmp 0x0000:start

msg1 db "String Inverter", 13, 10, 0
msg2 db "Put the string you want to invert: ", 0
string times 100 db 0
inverted_string times 100 db 0 
	
start:
	xor ax, ax		; ax = 0
	mov ds, ax 		; ds = 0
	mov es, ax 		; es = 0
	mov ss, ax		; stack init
	mov sp, 0x7c00		; stack init
	
	mov si, msg1
	call printstr
	mov si, msg2
	call printstr

	; reading the string from the user
	mov di, string
	call readvstr
	;;

	mov si, string
	mov di, inverted_string
	call str_inverter

	mov si, inverted_string
	call printstr

;;; inverts the string 
;; @param use si as the string input
;; @return di as the inverted string output
;; @reg: ax, si, di
str_inverter:

	push 0 ; '\0' end of string

.stack:

	xor ax, ax ; ax = 0
	lodsb ; si -> al
	cmp al, 0
	je .inverter ; can't put the 0 into the stack
	push ax ; else put ax into the stack
	jmp .stack 

.inverter: 

	pop ax
	stosb ; al -> di
	cmp al, 0 ; end of the string
	je .done
	jmp .inverter

.done:

	ret
	
;;; print string
;; @param: use si to print
;; @reg: ax, bx
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

;;; read (verbosely) string from di and print char by char
;; @param: use di to read 	
;; @reg: ax, bx
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
;; @reg: ax, bx
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
dw 0xaa55               ; The standard PC boot signature
