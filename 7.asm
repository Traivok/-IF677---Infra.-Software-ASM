org 0x7c00
jmp 0x0000:start

string1 times 100 db 0
string2 times 100 db 0
aux dw 0
alph dw 0
alphabeto db 'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z', 0
output times 10 db 0

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

	mov dx, alphabeto
	mov [alph], dx
	call commonletter
	
	jmp done

; @reg: bl, cx
;;;;;;;;;;;;;;;;
commonletter:

	xor cx, cx ; contador = 0
	mov si, [alph]
	lodsb
	mov [alph], si ; atualiza a pos

	cmp al, 0
	je .done

	mov bl, al ; para guardar o valor

	mov si, string1
	call stringSum

	cmp cx, 0 ; se for zero é pq a letra não está na string1
	je commonletter

	mov [aux], cx
	mov si, string2 ; else eu procuro da string2
	call stringSub

	cmp cx, [aux] ; se for igual, é pq não tem na string2
	je commonletter

	;else print char
	mov al, bl
	mov ah, 0xe 	; print char and move cursor foward
	mov bh, 0 	; page number
	mov bl, 0xf 	; white color
	int 10h 	; video interrupt

	xor ax, ax ; ax = 0

.negativeDealing:
	
	mov ax, -1
	imul cx ; multiplica cx por -1
	mov cx, ax ; o resultado da multiplicação vai para ax
	cmp cx, 0 
	jl .negativeDealing

	;transformar o q tem em cx para string e printar
	mov ax, cx
	mov di, output
	call tostring

	mov si, output
	call printstr

	jmp commonletter

.done:

	ret

;; bl tem a letra que eu estou procurando
;; percorre a string e aumenta o contador a cada letra achada
stringSum:
	
	lodsb

	cmp al, 0 ; vê se chegou no fim
	je .done

	cmp al, bl
	jne stringSum ; se não for igual, procuro na próxima letra

	inc cx ; contador++

	jmp stringSum

.done:

	ret

;; bl tem a letra que eu estou procurando
;; percorre a string e subtrai o contador
stringSub:
	
	lodsb

	cmp al, 0 ; vê se chegou no fim
	je .done

	cmp al, bl
	jne stringSub ; se não for igual, procuro na próxima letra

	dec cx ; contador++

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