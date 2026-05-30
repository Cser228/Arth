format ELF64 executable

segment readable executable

_start:
	push rbp
	mov rbp, rsp
	sub rsp, 16

	jmp exit

write:
	push rbp
	mov rbp, rsp

	mov rax, 1
	mov rdi, 1
	syscall

	mov rsp, rbp
	pop rbp
	ret

exit:
	mov rsp, rbp
	pop rbp
	
	mov rax, 60
	mov rdi, 0
	syscall


segment readable writable

src db "123"
