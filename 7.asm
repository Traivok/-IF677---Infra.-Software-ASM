org 0x7c00
jmp 0x0000:start

string1 times 98 db 0 
string2 times 97 db 0
aux dw 0
alph dw 0
str1 dw 0
str2 dw 0
alphabet db 'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z', 0
output times 5 db 0
nonsense db ':', 0

start:

	xor ax, ax		; reg init
	mov ds, ax 		; reg init
	mov es, ax 		; reg init	
	mov bx, ax
	mov ss, ax		; stack init
	mov sp, 0x7c00		; stack init
	
	mov di, string1
	call readvstr
	mov di, string2
	call readvstr

	mov dx, alphabet
	mov [alph], dx
	mov dx, string1
	mov [str1], dx
	mov dx, string2
	mov [str2], dx
	call commonletter
	
	jmp done

;;; Common letters
;; @function: prints the common letters between two strings, in alphabetic order,
;; and prints the difference, in absolute value, of the occurrences of these letters.
;; @parameter: use alph as the alphabet, str1 as the first string, str2 as the 
;; second string and output as the output number of each common letter.
;; @return: void
;; @reg: bx, cx, dx, si, di, ax 
commonletter:

	xor cx, cx ; counter = 0
	mov si, [alph]
	lodsb
	mov [alph], si ; update the position

	cmp al, 0
	je .done

	mov bl, al ; to keep the value of al 

	mov si, [str1]
	call stringSum

	cmp cx, 0 ; if it equals zero, there's no such letter in the first string 
	je commonletter

	mov [aux], cx ; to keep the value of cx before stringSub
	mov si, [str2] ; else search in the second string
	call stringSub

	cmp cx, [aux] ; if it's equal, there's no such letter in the second string
	je commonletter

	;else print char
	mov al, bl
	mov ah, 0xe 	; print char and move cursor foward
	mov bh, 0 	; page number
	mov bl, 0xf 	; white color
	int 10h 	; video interrupt

.negativeDealing:
	
	mov ax, -1
	imul cx ; cx*al == cx*(-1)
	mov cx, ax ; the multiplication result goes to ax
	cmp cx, 0 
	jl .negativeDealing

	;ax has the last value of cx
	;turns cx into a string and prints
	mov di, output
	call tostring

	mov si, nonsense
	call printstr

	mov si, output
	call printstr
	call println

	jmp commonletter

.done:

	ret

;;; Counts how many times the letter (in bl) shows up in the string 
;; @param bl as the searched letter, cx as the counter
;; @return cx as the number of times the letter showed up in the string 
;; @reg: ax, cx, bl
stringSum:
	
	lodsb

	cmp al, 0 ; (al == 0) -> end of string
	je .done

	cmp al, bl
	jne stringSum ; if it's not equal, search in another letter 

	inc cx ; counter++

	jmp stringSum

.done:

	ret

;;; Subtracts from cx the times the letter (in bl) shows up in the string 
;; @param bl as the searched letter, cx as the counter
;; @return cx as the difference, in absolute value, of the occurrences of a letter.
;; @reg: ax, cx, bl
stringSub:
	
	lodsb

	cmp al, 0 ; (al == 0) -> end of string
	je .done

	cmp al, bl
	jne stringSub ; if it's not equal, search in another letter 

	dec cx ; counter++

	jmp stringSub

.done:

	ret

;;; integer to string -- string	to_string(int*)
;; @param use ax as number input
;; @return di as string output
;; @reg: ax, bh, sp, di
tostring:
	
	push 0 			; push '\0' end of string

.convert:			; convert every digit of integer input into characters
	
	mov bh, 10		; let number = 123, then, after div, 12 will be al, and 3 will be ah
	div bh			; so, we need to push 3 onto stack and recursively convert (number/10) until the result be zero 
	add ah, '0'		; convert remainder to ascii...

	mov dl, ah		; (although the remainder is stored to ah, the stosb works with al)
	push dx			; ...and push it	

	cmp al, 0		; base case condition
	je .concat
	
	mov ah, 0		; the remainder was pushed onto stack, we dont need it anymore so AX = [3, 12] -> [0, 12]
	jmp .convert
	
.concat:			; concat every char of stack into a string
	
	pop ax			; get top of stack and pop it
	
	stosb			; store al at di
	
	cmp al, 0 		; if end of string
	je .done		; goto done
	jmp .concat
	
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
dw 0xAA55               ; The standard PC boot signature