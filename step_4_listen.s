# https://man7.org/linux/man-pages/man2/listen.2.html

# listen() marks the socket referred to by sockfd as a passive
# socket, that is, as a socket that will be used to accept incoming
# connection requests using accept(2).

# int listen(int sockfd, int backlog);
# Args:
#       sockfd:     the file descriptor, returned by socket()
#       backlog:    the maximum length to which the queue
#                   of pending connections for sockfd may grow
# Returns:
#   rax = fd (>= 0) on success
#   rax = -errno (< 0) on failure

.intel_syntax noprefix
.global _start

_start:
    call open_socket                # rax = fd or -errno
    test rax, rax                   # cmp rax, 0
    js   exit_fail                  # rax < 0 → error

    mov r12, rax                    # save fd

    call bind_addr                  # bind(r12, &sockaddr_in, 16)
    test rax, rax                   # cmp rax, 0
    js   exit_fail                  # rax < 0 → error

    call listen
    test rax, rax
    js   exit_fail

    # exit on success
    xor  rdi, rdi                   # exit(0)
    jmp  exit

exit_fail:
    mov  rdi, 1                     # exit(1)

exit:
    mov  rax, 60                    # SYS_exit
    syscall

open_socket:
    mov  rax, 41                    # SYS_socket
    mov  rdi, 2                     # AF_INET
    mov  rsi, 1                     # SOCK_STREAM
    xor  rdx, rdx                   # PPROTO_IP
    syscall
    ret

bind_addr:    
    sub rsp, 16                     # Build sockaddr_in on the stack (16 bytes)

    mov word ptr  [rsp+0], 0x02     # sin_family = AF_INET
    mov word ptr  [rsp+2], 0x5000   # sin_port = htons(80), 80 = 0x5000
    mov dword ptr [rsp+4], 0        # sin_addr = INADDR_ANY (0.0.0.0)
    mov qword ptr [rsp+8], 0        # sin_zero padding

    mov rax, 49                     # SYS_bind
    mov rdi, r12                    # sockfd
    mov rsi, rsp                    # addr = &sockaddr_in
    mov rdx, 16                     # addrlen in bytes
    syscall

    add rsp, 16
    ret

listen:
    mov rax, 50
    mov rdi, r12
    mov rsi, 0
    syscall
    ret