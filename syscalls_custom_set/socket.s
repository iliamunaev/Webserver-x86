#   https://man7.org/linux/man-pages/man7/ip.7.html

#   tcp_socket = socket(AF_INET, SOCK_STREAM, 0);
#   socket (rax(41), rdi(int), rsi(int), rdx(int));
#   AF_INET = 2;
#   SOCK_STREAM = 1;
#   IPPROTO_IP = 0;

.intel_syntax noprefix
.global _start

_start:
    call open_socket
    mov rdi, 0        # exit code
    jmp exit

open_socket:
    mov rax, 41       # SYS_socket
    mov rdi, 2        # AF_INET
    mov rsi, 1        # SOCK_STREAM
    mov rdx, 0        # IPPROTO_IP
    syscall
    ret

exit:
    mov rax, 60       # SYS_exit
    syscall

