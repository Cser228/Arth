format ELF64 executable

segment readable executable

_start:
	;inic stack
	push rbp
	mov rbp, rsp

	;malloc 16 byte
	sub rsp, 16

	;inic stack my language
	mov r12, mlv_end

	;inic variables

	;char *a = src
	mov qword [rbp-8], src
	;uint16_t b = src_len
	mov dword [rbp-12], src_len

	;go to while (src_len != 0)
	jmp go_for_line

write:
	;print
    mov rax, 1
    mov rdi, 1
    syscall

	;ret, because call
    ret

;char *int_to_string(uint64_t n)
;n = rax
;ret string = rax
;ret string_len = rdi
int_to_string:
        push    rbp
        mov     rbp, rsp
        sub     rsp, 48
        mov     qword [rbp-8], rax
        mov     qword [rbp-16], 1
        mov     eax, 32
        sub     rax, qword [rbp-16]
        mov     byte [rbp-48+rax], 10

		jmp int_to_string_loop

int_to_string_loop:
        mov     rcx, qword [rbp-8]
		mov     rdx, 0xCCCDCCCDCCCDCCC5
        mov     rax, rcx
        mul     rdx
        shr     rdx, 3
        mov     rax, rdx
        sal     rax, 2
        add     rax, rdx
        add     rax, rax
        sub     rcx, rax
        mov     rdx, rcx
        mov     eax, edx
        lea     edx, [rax+48]
        mov     eax, 31
        sub     rax, qword [rbp-16]
        mov     byte [rbp-48+rax], dl
        add     qword [rbp-16], 1
        mov     rax, qword [rbp-8]
		mov     rdx, 0xCCCDCCCDCCCDCCC5
        mul     rdx
        mov     rax, rdx
        shr     rax, 3
        mov     qword [rbp-8], rax
        cmp     qword [rbp-8], 0
        jne     int_to_string_loop
        mov     eax, 32
        sub     rax, qword [rbp-16]
        lea     rdx, [rbp-48]
        lea     rcx, [rdx+rax]
        mov     rax, qword [rbp-16]
        mov     rdx, rax
        mov     rsi, rcx

		;rsi = string
		;rdx = string_len

		mov rax, rsi
		mov rdi, rdx
	
		mov rsp, rbp
		pop rbp
        ret

;uint8_t its_number(char* a)
;a = rax
;ret = rax
its_number:
	;inic own stack
	push rbp
	mov rbp, rsp

	;save rax
	mov r8, rax

	;if (*a >= '0' && *a <= '9')
	cmp byte [r8], 48
	jl its_number_false
	cmp byte [r8], 57
	jg its_number_false

	;return true
	mov rax, 1

	;ret
	pop rbp
	ret

its_number_false:
	;return false
	mov rax, 0

	;ret
	pop rbp
	ret

;uint64_t string_to_int(char *a, uint8_t a_len)
;ret = rax
;a = rax
;a_len = rdi
string_to_int:
	;inic own stack
	push rbp
	mov rbp, rsp

	mov r8, rax
	mov r9, rdi
	mov rax, 0

	jmp string_to_int_loop

string_to_int_loop:
	cmp r9, 0
	je string_to_int_loop_false

	imul rax, rax, 10

	movzx r10, byte [r8]
	sub r10, 48
	add rax, r10

	inc r8
	dec r9

	jmp string_to_int_loop

string_to_int_loop_false:
	pop rbp
	ret

push_my:
	;string_to_int
	mov rax, qword [rbp-8]
	mov rdi, 1
	call string_to_int

	;add to my stack
	sub r12, 8
	mov [r12], rax

	jmp go_for_line_loop_cont

dump_my:
	;get from my stack
	mov rax, [r12]
	add r12, 8

	;call int_to_string
	call int_to_string

	;print value
	mov rsi, rax
	mov rdx, rdi

	call write

	jmp go_for_line_loop_cont

plus_my:
	;get first from stack
	mov rax, [r12]
	add r12, 8

	;get second from stack
	mov rdi, [r12]
	add r12, 8

	;sum
	add rax, rdi

	;put in stack
	sub r12, 8
	mov [r12], rax

	jmp go_for_line_loop_cont

minus_my:
	;get first from stack
	mov rax, [r12]
	add r12, 8

	;get second from stack
	mov rdi, [r12]
	add r12, 8

	;minus
	sub rdi, rax

	;put in stack
	sub r12, 8
	mov [r12], rdi

	jmp go_for_line_loop_cont

equal_my:
	;save first stack
	mov rax, [r12]
	add r12, 8

	;save second stack
	mov rdi, [r12]
	add r12, 8

	;if a == b
	cmp rax, rdi
	je equal_my_true

	;put 0 in rax
	mov rax, 0

	;ret false
	sub r12, 8
	mov [r12], rax

	jmp go_for_line_loop_cont

equal_my_true:
	;put 1 in rax
	mov rax, 1

	;ret true
	sub r12, 8
	mov [r12], rax

	jmp go_for_line_loop_cont

go_for_line_loop:
	;its_number(src)
	mov rax, qword [rbp-8]
	call its_number

	;if true
	cmp rax, 1
	je push_my

	;if else *src == '.'
	mov rax, qword [rbp-8]
	cmp byte [rax], 46
	je dump_my

	;if else *src == '+'
	cmp byte [rax], 43
	je plus_my

	;if else *src == '-'
	cmp byte [rax], 45
	je minus_my

	;if else *src == '='
	cmp byte [rax], 61
	je equal_my

	;next
	jmp go_for_line_loop_cont

go_for_line_loop_cont:
	;src++ src_len--
	add qword [rbp-8], 1
	sub dword [rbp-12], 1
	jmp go_for_line

go_for_line:
	;if src_len != 0
	cmp dword [rbp-12], 0
	jne go_for_line_loop

	;exit
	jmp exit

exit:
	;free stack
	mov rsp, rbp
	pop rbp

	;exit
    mov rax, 60
    mov rdi, 0
    syscall

segment readable writable

src file "src.sb"
src_len = $ - src
mlv rb 800
mlv_end: 
