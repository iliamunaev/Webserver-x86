.intel_syntax noprefix
.global _start

_start:
    mov rax, 60     # syscall: exit
    mov rdi, 0      # exit status
    syscall