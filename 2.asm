org 0x7c00
jmp 0x0000:start

notmsg db "Nao forma triangulo", 0
eqmsg db "Equilatero", 0
isomsg db "Isosceles", 0
scamsg db "Escaleno", 0	
strinput db "000", 0
X times 1 db 0
Y times 1 db 0
Z times 1 db 0

start:	
	xor ax, ax		; reg init
	mov ds, ax 		; reg init
	mov es, ax 		; reg init	
	mov ss, ax		; stack init
	mov sp, 0x7c00		; stack init

	mov di, strinput
	call readvstr
	
	mov si, strinput
	call atoi
	mov byte [X], dl	; and store the output conversion

	mov di, strinput
	call readvstr
	
	mov si, strinput
	call atoi
	mov byte [Y], dl	; and store the output conversion

	mov di, strinput
	call readvstr
	
	mov si, strinput
	call atoi
	mov byte [Z], dl	; and store the output conversion

;;; [Checking if the vertices form a triangle] ;;;
;; X < (Y + Z) ;;
	mov bl, byte [X]	; check if X < Y + Z
	mov al, byte [Y]
	mov ah, byte [Z]
	add al, ah		; (Y + Z)
	cmp bl, al		; X ? (Y + Z)
	jae .nottriangle	; if (X >= Y + Z), then its not a triangle
;; Y < (X + Z) ;;
	mov bl, byte [Y]
	mov al, byte [X]
	mov ah, byte [Z]
	add al, ah		; (X + Z)
	cmp bl, al		; Y ? (X + Z)
	jae .nottriangle	; if (Y >= X + Z), then its not a triangle
;; Z < (X + Y) ;;
	mov bl, byte [Z]
	mov al, byte [X]
	mov ah, byte [Y]
	add al, ah		; (X + Y)
	cmp bl, al		; Z ? (X + Y)
	jae .nottriangle	; if (Z >= X + Y), then its not a triangle
;;; [Done] ;;;

;;; [Check the type of triangle] ;;;
	mov al, byte[X]
	mov ah, byte[Y]
	mov bl, byte[Z]
	
	cmp al, ah
	jne .notequilateral
	cmp al, bl
	jne .isosceles
	jmp .equilateral

.notequilateral:
	cmp al, bl
	je .isosceles
	cmp ah, bl
	je .isosceles
	jmp .scalene
	
.equilateral:
	mov si, eqmsg
	jmp .done

.isosceles:
	mov si, isomsg
	jmp .done

.scalene:
	mov si, scamsg
	jmp .done
	
.nottriangle:
	mov si, notmsg
	jmp .done

.done:
	call printstr
	call println
	jmp done

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

;;; string to integer -- int atoi(string*) 
;; @param use si as string
;; @return dl as int result
;; @reg: ax, dx, bl, si
atoi:
	xor ax, ax 		; init
	mov dx, ax
.convert:	
	lodsb

	cmp al, '0'
	jb .done 		; character below '0'
	
	cmp al, '9'
	ja .done		; character above '9'

	sub al, '0'		; convert ascii to (0-9) int

	xchg dl, al 		; this swap is needed because mul

	mov bl, 10		; supose 12 from 123 string was computed, then 123 = (12*10) + 3
	mul bl			; prepare data for next unit digit
	add dl, al		; insert new digit into data
	
	jmp .convert
	
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

;;; integer to string -- string	to_string(int*)
;; @param use ax as number input
;; @return di as string output
;; @reg: ax, bl, sp, di
tostring:
	
	push 0 			; push '\0' end of string

.convert:			; convert every digit of integer input into characters
	
	mov bl, 10		; let number = 123, then, after div, 12 will be al, and 3 will be ah
	div bl			; so, we need to push 3 onto stack and recursively convert (number/10) until the result be zero 
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


	
done:
	jmp $ 			; infinity jump

times 510-($-$$) db 0   ; Pad remainder of boot sector with 0s
dw 0xAA55               ; The standard PC boot signature
