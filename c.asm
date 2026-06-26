format ELF64
public _start

section '.text' executable

int_to_string:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    mov rcx, 10
    mov rdi, rsp
    add rdi, 31
    mov byte [rdi], 0
    dec rdi
    test rax, rax
    jnz .convert
    mov byte [rdi], '0'
    dec rdi
    jmp .done
.convert:
    xor rdx, rdx
    div rcx
    add dl, '0'
    mov [rdi], dl
    dec rdi
    test rax, rax
    jnz .convert
.done:
    inc rdi
    mov rax, rdi
    mov rsi, rsp
    add rsi, 31
    sub rsi, rdi
    mov rdi, rsi
    mov rsp, rbp
    pop rbp
    ret

write:
    mov rax, 1
    mov rdi, 1
    syscall
    ret

syscall_one:
	pop rdi
	syscall

syscall_two:
	pop rsi
	je syscall_one

syscall_three:
	pop rdx
	je syscall_two

syscall_four:
	pop r10
	je syscall_three

syscall_five:
	pop r8
	je syscall_four

_start:
    mov r14, mems_my

block_1:
    ;===push_int===
    push 1

block_2:
    ;===push_int===
    push 1

block_3:
    ;===equal===
    pop rax
    pop rdi
    mov rsi, 0
    mov rdx, 1
    cmp rax, rdi
    cmove rsi, rdx
    push rsi

block_4:
    ;===if===
    pop rax
    test rax, rax
    jz end_1

block_5:
    ;===push_int===
    push 1

block_6:
    ;===dump===
    pop rax
    call int_to_string
    mov rsi, rax
    mov rdx, rdi
    call write
    mov rsi, newline_character
    mov rdx, 1
    call write

end_1:
block_7:
    ;===push_int===
    push 2

block_8:
    ;===dump===
    pop rax
    call int_to_string
    mov rsi, rax
    mov rdx, rdi
    call write
    mov rsi, newline_character
    mov rdx, 1
    call write

block_9:
    ;===push_int===
    push 3

block_10:
    ;===dump===
    pop rax
    call int_to_string
    mov rsi, rax
    mov rdx, rdi
    call write
    mov rsi, newline_character
    mov rdx, 1
    call write

    ;===exit===
    mov rax, 60
    mov rdi, 0
    syscall

section '.bss' writable
mem_my rb 5000
mems_my rb 5000

section '.data' writable
newline_character db 10
