# https://man7.org/linux/man-pages/man2/accept.2.html

# The accept() system call is used with connection-based socket
# types (SOCK_STREAM, SOCK_SEQPACKET).  It extracts the first
# connection request on the queue of pending connections for the
# listening socket, sockfd, creates a new connected socket, and
# returns a new file descriptor referring to that socket.  The newly
# created socket is not in the listening state.  The original socket
# sockfd is unaffected by this call.

# int accept(int sockfd,
#            struct sockaddr *_Nullable restrict addr,
#            socklen_t *_Nullable restrict addrlen);
# Args:
#       sockfd:     the file descriptor, returned by socket()
#       addr:       a pointer to a sockaddr structure
#       addrlen:    a pointer to the size (in bytes) of the structure pointed to by addr
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

    call accept_conn
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
    mov rax, 50                     # SYS_listen
    mov rdi, r12                    # sockfd
    mov rsi, 0                      # backlog (not 0)
    syscall
    ret

accept_conn:
    mov  rax, 43                    # SYS_accept
    mov  rdi, r12                   # sockfd
    xor  rsi, rsi                   # addr = NULL
    xor  rdx, rdx                   # addrlen = NULL
    syscall
    ret