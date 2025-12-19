# https://man7.org/linux/man-pages/man2/bind.2.html

# When a socket is created with socket(2), it exists in a name space
# (address family) but has no address assigned to it.  bind()
# assigns the address specified by addr to the socket referred to by
# the file descriptor sockfd.  addrlen specifies the size, in bytes,
# of the address structure pointed to by addr.

# int bind(int sockfd,
#          const struct sockaddr *addr,
#          socklen_t addrlen);
# Args:
#       sockfd:     the file descriptor, returned by socket()
#       addr:       pointer to the assigned address
#       addrlen:    the size, in bytes, of the address structure pointed to by addr
# Returns:
#   rax = fd (>= 0) on success
#   rax = -errno (< 0) on failure

# struct sockaddr_in {
#    sa_family_t     sin_family;     /* AF_INET */
#    in_port_t       sin_port;       /* Port number */
#    struct in_addr  sin_addr;       /* IPv4 address */
# };

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

    mov word ptr [rsp+0], 0x02      # sin_family = AF_INET
    mov word ptr [rsp+2], 0x5000    # sin_port = htons(80), 80 = 0x5000
    mov dword ptr [rsp+4], 0        # sin_addr = INADDR_ANY (0.0.0.0)
    mov qword ptr [rsp+8], 0        # sin_zero padding

    mov rax, 49                     # SYS_bind
    mov rdi, r12                    # sockfd
    mov rsi, rsp                    # addr = &sockaddr_in
    mov rdx, 16                     # addrlen
    syscall

    add rsp, 16
    ret