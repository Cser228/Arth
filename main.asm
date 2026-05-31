format ELF64 executable

segment readable executable

macro strcmp_const str_val {
    local ..str, ..end
    jmp ..end
    ..str db str_val
    ..end:
    mov rdi, ..str
    mov rdx, ..end - ..str
}

_start:
	;inic stack
	push rbp
	mov rbp, rsp

	;malloc 32 byte
	sub rsp, 32

	;inic stack my language
	mov r12, mlv_end

	;inic variables

	;char *a = src
	mov qword [rbp-8], src
	;uint16_t b = src_len
	mov dword [rbp-12], src_len
	;uint8_t word_len = 0
	mov byte [rbp-13], 0
	;char *a = src // it will point on the first character after space
	mov qword [rbp-21], src
	;uint16_t a = 1 // now we on line
	mov word [rbp-23], 1
	;if stack
	mov qword [rbp-31], if_stack_end

	;go to while
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

;uint8_t its_number(char* a, uint8_t len)
;a = rax
;len = rdi
;ret = rax
its_number:
	;inic own stack
	push rbp
	mov rbp, rsp

	;save rax
	mov r8, rax

	;save rdi
	mov r9, rdi

	jmp its_number_loop

its_number_loop:
	;if len == 0
	cmp r9, 0
	je its_number_true

	;if (*a >= '0' && *a <= '9')
	cmp byte [r8], 48
	jl its_number_false
	cmp byte [r8], 57
	jg its_number_false

	;continue loop
	inc r8
	dec r9

	jmp its_number_loop

its_number_false:
	;return false
	mov rax, 0

	;ret
	pop rbp
	ret

its_number_true:
	;return true
	mov rax, 1
	
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
	mov rax, qword [rbp-21]
	movzx rdi, byte [rbp-13]
	call string_to_int

	;add to my stack
	sub r12, 8
	mov [r12], rax

	jmp command_finish

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

	jmp command_finish

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

	jmp command_finish

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

	jmp command_finish

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

	jmp command_finish

equal_my_true:
	;put 1 in rax
	mov rax, 1

	;ret true
	sub r12, 8
	mov [r12], rax

	jmp command_finish

;bool strcmp(char *a, char *b, uint8_t a_len, uint8_t b_len)
;a = rax
;b = rdi
;a_len = rsi
;b_len = rdx
;ret = rax
strcmp:
	;inic own stack
	push rbp
	mov rbp, rsp

	;if a_len != b_len
	cmp rsi, rdx
	jne strcmp_false

	jmp strcmp_loop

strcmp_loop:
	;if a_len != 0 && b_len != 0
	cmp rsi, 0
	je strcmp_true

	cmp rdx, 0
	je strcmp_true

	;if a != b
	mov r8b, byte [rdi]
	cmp byte [rax], r8b
	jne strcmp_false

	;a++
	;b++
	;a_len--
	;b_len--
	inc rax
	inc rdi
	dec rsi
	dec rdx

	jmp strcmp_loop

strcmp_true:
	;ret true
	mov rax, 1
	
	mov rsp, rbp
	pop rbp
	ret

strcmp_false:
	;ret false
	mov rax, 0

	mov rsp, rbp
	pop rbp
	ret

if_my:
	;get from mlv stack last
	mov rax, [r12]
	add r12, 8

	;if if condition true, set if stack[] = 1
	cmp rax, 1
	je if_my_true

	;else
	mov rax, qword [rbp-31]
	sub rax, 8
	mov qword [rax], 2
	mov qword [rbp-31], rax

	jmp command_finish

if_my_false_set:
	;put on if stack false
	mov rax, qword [rbp-31]
	sub rax, 8
	mov qword [rax], 2
	mov qword [rbp-31], rax

	jmp command_finish

if_my_false:
	;if if stack [-1] == 2
	mov rax, qword [rbp-31]
	add rax, 8
	cmp qword [rax], 2
	je if_my_false_set

	;put on if stack true
	mov rax, qword [rbp-31]
	sub rax, 8
	mov qword [rax], 1
	mov qword [rbp-31], rax

	jmp command_finish

if_my_true:
	;if if stack [-1] exists
	mov rax, qword [rbp-31]
	add rax, 8
	cmp rax, if_stack_end
	jne if_my_false

	;put on if stack true
	mov rax, qword [rbp-31]
	sub rax, 8
	mov qword [rax], 1
	mov qword [rbp-31], rax

	jmp command_finish

else_my:
	;get from if stack last value
	mov rdi, qword [rbp-31]
	
	;if if stack empty, skip
	cmp rdi, if_stack_end
	je command_finish

	;check if we have parent if on stack
	mov rax, rdi
	add rax, 8
	cmp rax, if_stack_end
	je no_parent_skip      ;if next level is end, parent not exist

	;if parent if stack == 2, skip all change logic
	mov rax, [rdi+8]
	cmp rax, 2
	je command_finish      ;parent if says skip, so we do nothing

	;!if stack last value
	mov rax, qword [rbp-31]
	cmp qword [rax], 2
	je if_stack_set_one

	mov rax, qword [rbp-31]
	mov qword [rax], 2
	mov qword [rbp-31], rax

	jmp command_finish

if_stack_set_one:
	mov rax, qword [rbp-31]
	mov qword [rax], 1
	mov qword [rbp-31], rax

	jmp command_finish

no_parent_skip:
	;get last value again
	mov rax, [rdi]

	;if last value was 2
	cmp rax, 2
	je else_my_two

	;set last if stack 2
	mov qword [rdi], 2
	jmp command_finish

else_my_two:
	;set last if stack 1
	mov qword [rdi], 1
	jmp command_finish

end_my:
	;remove last if stack value
	add qword [rbp-31], 8

	jmp command_finish

do_command:
	;if word_len == 0
	cmp byte [rbp-13], 0
	je command_finish

	;if word == "if"
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "if"
	call strcmp
	;if true
	cmp rax, 1
	je if_my

	;if word == "else"
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "else"
	call strcmp
	;if true
	cmp rax, 1
	je else_my

	;if word == "end"
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "end"
	call strcmp
	;if true
	cmp rax, 1
	je end_my

	;if last if stack is 2, skip all
	mov rdi, qword [rbp-31]
	mov rax, [rdi]

	cmp rax, 2
	je command_finish

	;its_number(word_now, word_len)
	mov rax, qword [rbp-21]
	movzx rdi, byte [rbp-13]
	call its_number
	;if true
	cmp rax, 1
	je push_my

	;if else word_now[0] == '.'
	mov rax, qword [rbp-21]
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

	jmp command_finish

command_finish:
	;if src_len == 0
	cmp dword [rbp-12], 0
	je exit

	;src++
	;src_len--
	inc qword [rbp-8]
	dec dword [rbp-12]

	;word = src
	mov rax, qword [rbp-8]
	mov qword [rbp-21], rax

	;word_len = 0
	mov byte [rbp-13], 0

	jmp go_for_line

new_line:
	;if word_len != 0
	cmp byte [rbp-13], 0
	jne do_command

	;line_counter++
	inc word [rbp-23]

	;if src_len == 0
	cmp dword [rbp-12], 0
	je exit

	;src++
	;src_len--
	inc qword [rbp-8]
	dec dword [rbp-12]

	;word = src
	;word_len = 0
	mov rax, qword [rbp-8]
	mov qword [rbp-21], rax
	mov byte [rbp-13], 0

	jmp go_for_line

go_for_line_loop:
	mov rax, qword [rbp-8]

	;if its \n
	cmp byte [rax], 10
	je new_line

	;if its space
	cmp byte [rax], 32
	je do_command

	;if its \t
	cmp byte [rax], 9
	je do_command

	;next
	jmp go_for_line_loop_cont

go_for_line_loop_cont:
	;src++ src_len-- word_len++
	inc qword [rbp-8]
	dec dword [rbp-12]
	inc byte [rbp-13]

	jmp go_for_line

go_for_line:
	;if src_len != 0
	cmp dword [rbp-12], 0
	jne go_for_line_loop

	;if word_len != 0
	cmp byte [rbp-13], 0
	jne do_command

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
if_stack db 100 dup (0)
if_stack_end:
