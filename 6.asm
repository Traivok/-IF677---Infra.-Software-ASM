org 0x7c00
jmp 0x0000:start

strinp times 128 db 0 		; input string
strinv times 128 db 0		; inverted string
truemsg db "Palindroma", 0
falsemsg db "Nao e palindroma", 0	
	
start:
	xor ax, ax		; reg init
	mov ds, ax 		; reg init
	mov es, ax 		; reg init	
	mov ss, ax		; stack init
	mov sp, 0x7c00		; stack init
	
	mov di, strinp
	call readvstr

	mov si, strinp
	mov di, strinv
	call str_inverter
	
	mov si, strinv
	call printstr
	call println

	mov bx, strinv
	mov dx, strinp
	call streq

	cmp al, 1
	je .isequal
	jmp .isnotequal
	
.isequal:
	mov si, truemsg
	jmp .end
.isnotequal:
	mov si, falsemsg
	jmp .end
.end:
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

;;; check if two string are equal
;; @param use bx and dx as string input
;; @return if equal (al == 1); else (al == 0)
streq:
.addrcheck:
	cmp bx, dx
	je .equal		; if the address is the same, so the content will be too
	jmp .datacheck		; else, check the content of two strings
.datacheck:
	mov si, bx		; get content of first string
	lodsb			; the content will be at al
	mov bx, si		; update the string index
	
	mov cl, al		; store it

	mov si, dx		; get the content of second string
	lodsb			; getting it
	mov dx, si		; update the string index
	
	cmp al, cl		; compare them
	jne .nequal		; if not equal, then return false

	cmp al, 0		; elif equal and end o string, then return true
	je .equal

	cmp cl, 0		; elif equal and end o string, then return true
	je .equal
	
	jmp .datacheck		; else recursion
	
.equal:
	mov al, 1
	ret
.nequal:
	mov al, 0
	ret
	
done:
	jmp $ 			; infinity jump

times 510-($-$$) db 0   ; Pad remainder of boot sector with 0s
dw 0xAA55               ; The standard PC boot signature
