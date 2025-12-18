# When a socket is created with socket(2), it exists in a name space
# (address family) but has no address assigned to it.  bind()
# assigns the address specified by addr to the socket referred to by
# the file descriptor sockfd.  addrlen specifies the size, in bytes,
# of the address structure pointed to by addr.

# int bind(int sockfd, const struct sockaddr *addr,
#                 socklen_t addrlen);

# bind(rax(49), rdi(int), rsi(&struct sockaddr_in), rdx(int));

.intel_syntax noprefix
.global _start

_start:
    call open_socket
    mov r12, rax              # save sockfd

    call bind_addr            # bind(r12, &sockaddr_in, 16)

    xor rdi, rdi              # exit code 0
    jmp exit

open_socket:
    mov rax, 41               # SYS_socket
    mov rdi, 2                # AF_INET
    mov rsi, 1                # SOCK_STREAM
    xor rdx, rdx              # IPPROTO_IP (0)
    syscall
    ret

bind_addr:
    # Build sockaddr_in on the stack (16 bytes)
    sub rsp, 16

    mov word ptr [rsp+0], 2       # sin_family = AF_INET

    # sin_port = htons(80).
    # 80 = 0x5000, network order bytes: 11 5c.
    mov word ptr [rsp+2], 0x5000  # sin_port
    mov dword ptr [rsp+4], 0      # sin_addr = INADDR_ANY (0.0.0.0)
    mov qword ptr [rsp+8], 0      # sin_zero padding

    mov rax, 49               # SYS_bind
    mov rdi, r12              # sockfd
    mov rsi, rsp              # addr = &sockaddr_in
    mov rdx, 16               # addrlen
    syscall

    add rsp, 16
    ret

exit:
    mov rax, 60               # SYS_exit
    syscall
