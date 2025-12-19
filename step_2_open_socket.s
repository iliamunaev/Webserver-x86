# https://man7.org/linux/man-pages/man2/socket.2.html

# socket() creates an endpoint for communication and returns a file
#       descriptor that refers to that endpoint.  The file descriptor
#       returned by a successful call will be the lowest-numbered file
#       descriptor not currently open for the process.

# int socket(int domain, int type, int protocol);
# Args:
#       domain:     specifies a communication domain
#       type:       specifies the communication semantics
#       protocol:   specifies a particular protocol to be used with the socket
# Returns:
#   rax = fd (>= 0) on success
#   rax = -errno (< 0) on failure

.intel_syntax noprefix
.global _start

_start:
    call open_socket          # socket(AF_INET, AF_INET, IPPROTO_IP)
    test rax, rax             # cmp rax, 0
    js   exit_fail            # rax < 0 → error

    # mov r12, rax            # example: save fd

    # exit on success
    xor  rdi, rdi             # exit(0)
    jmp  exit

exit_fail:
    mov  rdi, 1               # exit(1)

exit:
    mov  rax, 60              # SYS_exit
    syscall

open_socket:
    mov  rax, 41              # SYS_socket
    mov  rdi, 2               # AF_INET
    mov  rsi, 1               # SOCK_STREAM
    xor  rdx, rdx             # PPROTO_IP
    syscall
    ret

