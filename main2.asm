format ELF64 executable

segment readable executable

_start:
	mov [args_ptr], rsp

	mov rax, qword [args_ptr]
	add rax, 8

	mov rax, qword [rax]
	call strlen_C
	mov rsi, rax
	mov rdx, rdi
	call write

	mov rax, 60
	mov rdi, 0
	syscall

;char *int_to_string(uint64_t n)
;n = rax
;ret string = rax
;ret string_len = rdi
int_to_string:
	;inic stack
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

;GET
;rax = c string
;RETURN
;rax = string
;rdi = string len
strlen_C:
	;save registers
	push r8
	push r9
	push r10

	;r8 - string len
	;r9 - c string
	;r10 - string
	mov r8, 0
	mov r9, rax
	mov r10, rax

.cond:
	;check if \0
	cmp byte [r9], 0
	je .exit

	;c string++
	;string len++
	inc r8
	inc r9

	jmp .cond

.exit:
	mov rax, r10
	mov rdi, r8

	pop r10
	pop r9
	pop r8

	ret

write:
	mov rax, 1
	mov rdi, 1
	syscall
	ret

;GET
;rax = string
;rdi = string len
;RETURN
;rax = C string
string_to_C:
	push rbx
	push r12
	push r13
	push r8
	push r9
	push r10
	push rcx
	push r11

	mov r12, rax
	mov r13, rdi

	mov rsi, r13
	inc rsi
	mov rax, 9
	xor rdi, rdi
	mov rdx, 3
	mov r10, 34
	mov r8, -1
	xor r9, r9
	syscall

	mov rbx, rax

	cmp rbx, -1
	je .error

	mov rsi, r12
	mov rcx, r13
	mov rdi, rbx
	rep movsb

	mov byte [rdi], 0

	mov rax, rbx

	jmp .end

.error:
	;DEBUG
	mov rax, 1
	mov rdi, 1
	mov rsi, newline_character
	mov rdx, 1
	;DEBUG

	jmp .end

.end:
	pop	r11
	pop rcx
	pop r10
	pop r9
	pop r8
	pop r13
	pop r12
	pop rbx
	ret

segment readable writable

msg db "hello"
msg_len = $ - msg

newline_character db 10

args_ptr rq 1
