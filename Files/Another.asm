
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
