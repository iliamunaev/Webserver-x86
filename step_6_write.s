# https://man7.org/linux/man-pages/man2/write.2.html

# write() writes up to count bytes from the buffer starting at buf
# to the file referred to by the file descriptor fd.

# ssize_t write(int fd,
#               const void buf[count],
#               size_t count);
# Args:
#       fd:     a file descriptor to write
#       buf:    a pointer to a buffer from bites should be written 
#       count:  the number of bites to write
# Returns:
#   rax = the number of bytes written is returned on success
#   rax = -errno (< 0) on failure

.intel_syntax noprefix
.global _start

_start:
    call open_socket                # rax = fd or -errno
    test rax, rax
    js   exit_fail

    mov r12, rax                    # save listen fd

    call bind_addr                  # bind(r12, &sockaddr_in, 16)
    test rax, rax
    js   exit_fail

    call listen                     # listen(r12, 0)
    test rax, rax
    js   exit_fail

    call accept_conn                # rax = conn fd
    test rax, rax
    js   exit_fail

    mov r13, rax                    # save accepted(conn) fd

    call read_request               # read(r13, buf, count)
    test rax, rax
    js   exit_fail

    call write_responce             # write(r13, "HTTP/1.0 200 OK\r\n\r\n", 19)
    test rax, rax
    js   exit_fail

    call close_conn                 # close(r13)
    test rax, rax
    js   exit_fail

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
    xor  rdx, rdx                   # IPPROTO_IP = 0
    syscall
    ret

bind_addr:
    sub rsp, 16                     # sockaddr_in (16 bytes)

    mov word ptr  [rsp+0], 0x02     # sin_family = AF_INET
    mov word ptr  [rsp+2], 0x5000   # sin_port = htons(80)  (port 80 required)
    mov dword ptr [rsp+4], 0        # sin_addr = INADDR_ANY (0.0.0.0)
    mov qword ptr [rsp+8], 0        # sin_zero padding

    mov rax, 49                     # SYS_bind
    mov rdi, r12                    # sockfd (listen fd)
    mov rsi, rsp                    # addr
    mov rdx, 16                     # addrlen
    syscall

    add rsp, 16
    ret

listen:
    mov rax, 50                     # SYS_listen
    mov rdi, r12                    # sockfd (listen fd)
    mov rsi, 0                      # backlog MUST be 0 for this challenge
    syscall
    ret

accept_conn:
    mov rax, 43                     # SYS_accept
    mov rdi, r12                    # listen fd
    xor rsi, rsi                    # addr = NULL
    xor rdx, rdx                    # addrlen = NULL
    syscall
    ret

read_request:
    sub rsp, 1024                   # request buffer on stack

    mov rax, 0                      # SYS_read
    mov rdi, r13                    # fd = accepted fd
    mov rsi, rsp                    # buf
    mov rdx, 1024                   # count
    syscall

    add rsp, 1024
    ret

write_responce:
    mov rax, 1                      # SYS_write
    mov rdi, r13                    # fd = accepted fd
    lea rsi, resp[rip]              # buf
    mov rdx, 19                     # count
    syscall
    ret

close_conn:
    mov rax, 3                      # SYS_close
    mov rdi, r13                    # fd = accepted fd
    syscall
    ret

.section .rodata
resp:
    .ascii "HTTP/1.0 200 OK\r\n\r\n"
