## Webserver-x86

Building a tiny web server from scratch in **x86-64 Linux assembly**, step by step (socket → bind → listen/accept → HTTP GET/POST).

### Files
- `step_1_create_exit.s`: minimal program / syscalls warmup
- `step_2_open_socket.s`: create a TCP socket
- `step_3_bind_address.s`: bind socket to an address/port

### Prereqs
- Linux x86-64
- `as` + `ld` (binutils), optional: `gdb`, `strace`

### Build & run (template)
Replace `step_1_create_exit` with the step you want.

Option 1:

```bash
as -o step_1_create_exit.o step_1_create_exit.s
ld -o step_1_create_exit step_1_create_exit.o
./step_1_create_exit
```
Option 2:

```bash
gcc -nostdlib -o step_1_create_exit step_1_create_exit.s
./step_1_create_exit
```

### Debug quick hits

```bash

```


