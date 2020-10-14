
global _main
section .text
    
_main: 
    mov rax, 0x02000004
    mov rdi, 1
    mov rsi, msg
    mov rdi, msg_L
    syscall
    mov rax, 0x02000001
    xor rdi, rdi
    syscall
    
section .data
    msg: db "Hello world", 10
section .bss
    msg_L: equ $-msg


;;;;;;


eraseFirstElementLoop:
                        mov si, offset snakePosX
                        ;moving next element to the previous of x position array
                        mov ax, 2
                        mul cx
                        add si, ax

                        mov ax, [si]

                        sub si, 2
                        mov [si], ax

                        ;moving next nelement to the previous of y position array

                        mov si, offset snakePosY

                        mov ax, 2
                        mul cx
                        add si, ax
                        mov ax, [si]

                        sub si, 2
                        mov [si], ax

                        inc cx
                        cmp cx, snakeSize
                        jl eraseFirstElementLoop

addElementToEnd:
                        mov ax, 2 
                        mul cx

                        add dx, ax
                        mov si, dx
                        mov ax, currentX
                        mov [si], ax

                        mov ax, 2 
                        mul cx

                        add bx, ax
                        mov si, bx
                        mov ax, currentY
                        mov [si], ax



                        ;;;;;

rewriteArray:
        
                lea si, snakePosX
                ;moving next element to the previous of x position array
                mov ax, 2
                mul cx
                add si, ax
                mov ax, [si]

                sub si, 2
                mov [si], ax

                ;moving next nelement to the previous of y position array

                lea si,  snakePosY

                mov ax, 2
                mul cx
                add si, ax
                mov ax, [si]

                sub si, 2
                mov [si], ax

                inc cx

                dec bx

                cmp cx, bx    ;comparing counter to snake

                inc bx
                jl rewriteArray

                        lea si, snakePosY
                        mov ax, 2
                        mul arrayLength
                        add si, ax
                        mov ax, currentY
                        mov [si], ax
                        
                        lea si, snakePosX
                        mov ax, 2
                        mul arrayLength
                        add si, ax
                        mov ax, currentX
                        mov [si], ax
                        inc arrayLength
                        ret
    
        ret