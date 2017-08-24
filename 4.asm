org 0x7c00        
jmp 0x0000:start
 

char times 2 db 0 
string times 100 db 0
 
start:
    xor ax, ax  
    mov ds, ax  
    mov es, ax
 
    mov di, string         
    call read_string

 
    mov di, char
    call read_character
    
    mov si, string
    call remove_character
    
    jmp done

read_character:
    .read:
        mov ah, 0
        int 16h  
   
        stosb
   
    .print:
        mov ah, 0xe
        mov bh, 0  
        mov bl, 0xf
        int 10h
 
    .done:
        call println  
        mov al, 0  
        stosb
   
        ret

 
remove_character:
    lodsb
   
    cmp al, 0
    je .done
 
    cmp al, [char]
    je remove_character
 
    mov ah, 0eh
    int 10h
 
    jmp remove_character
 
    .done:
        ret    
 
print_string:
    lodsb      
    cmp al, 0  
    je .done
 
    mov ah, 0eh
    int 10h    
    


    jmp print_string
 
    .done:
        ret    
 
read_string:      
    .read:
        mov ah, 0
        int 16h  
 
        cmp al, 0xd
        je .done
   
        stosb
        jmp .print
   
    .print:
        mov ah, 0xe
        mov bh, 0  
        mov bl, 0xf
        int 10h
 
        jmp .read
 
    .done:
        call println  
        mov al, 0  
        stosb
   
        ret
   
println:
    mov ah, 0xe
    mov bh, 0
    mov bl, 0xf
    mov al, 13
    int 10h
 
    mov ah, 0xe
    mov bh, 0
    mov bl, 0xf
    mov al, 10
    int 10h
 
    ret
   
 
done:
    jmp $      
 
times 510 - ($ - $$) db 0
dw 0xaa55