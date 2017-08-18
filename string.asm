org 0x7c00
jmp 0x0000:start

num times 8 db 0
	
start:
	xor ax, ax		; init
	mov ds, ax 		; init
	mov es, ax 		; init	

	mov si, num	
	call readvstr
	
	mov edx, num
	add eax, '0'
	mov [si], eax
	
	call printstr
	call println
	
	jmp done


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

;;; read string
;; @param: use di to read
;; @reg: ax
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
;;; @reg: ax, bx
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

;;; string to integer -- int atoi(string*) 
;;; @param use dx as string pointer
;;; @return ax as int result
;;; @reg: eax, ecx, edx
atoi:
	xor eax, eax 		; zero a "result so far"
.top:
	movzx ecx, byte [edx] 	; get a character
	inc edx 		; ready for next one
	
	cmp ecx, '0'
	jb .done 		; if unsigned (ecx < '0') then, invalid

	cmp ecx, '9'		; if unsigned (ecx > '9') then, invalid
	ja .done
	
	sub ecx, '0'		; "convert" character to number
	imul eax, 10		; multiply "result so far" by ten
	add eax, ecx		; add in current digit

	jmp .top		; until done
	
.done:
	ret
	
done:
	jmp $ 			; infinity jump

times 510-($-$$) db 0   ; Pad remainder of boot sector with 0s
dw 0xAA55               ; The standard PC boot signature
