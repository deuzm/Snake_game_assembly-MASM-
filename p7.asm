        data segment
        dat db 10
        data ends

        display macro m1
        mov ah,09h
        lea dx,m1
        int 21h
        endm

        code segment
        assume cs:code, ds:data
start:  mov ax,data
        mov ds,ax

        lea dx,[dat]
        mov ah,0ah
        int 21h

        mov cx,000ah
        lea si,dat
up:     mov al,[si]
        sub al,20h
        mov [si],al
        inc si
        loop up

        display dat

        code ends
        end start

