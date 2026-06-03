;RAX (8 bytes)
;EAX (4 bytes)
;AX (2 bytes)
;AL (1 byte)

;RDI (8 bytes)
;EDI (4 bytes)
;DI (2 bytes)
;DIL (1 byte)

;RSI (8 bytes)
;ESI (4 bytes)
;SI (2 bytes)
;SIL (1 byte)

;RDX (8 bytes)
;EDX (4 bytes)
;DX (2 bytes)
;DL (1 byte)

format ELF64 executable

segment readable executable
entry _start

macro strcmp_const str_val {
    local ..str, ..end
    jmp ..end
    ..str db str_val
    ..end:
    mov rdi, ..str
    mov rdx, ..end - ..str
}

_start:
	;get argc
    pop rax
    
    ;if argc != 2
    cmp rax, 2
    jne .error_file
    
    ;program name
    pop rax
    
    ;file name
    pop rax

	call read_file_C

	;if rax == 0
	cmp rax, 0
	je .error_file

	;inic stack
	push rbp
	mov rbp, rsp

	;malloc 128 byte
	sub rsp, 128

	;inic stack my language
	mov r12, mlv_end

	;inic memory for user string
	mov r13, mfus

	;inic variables

	;char *a = src
	mov qword [rbp-8], rax
	;uint32_t b = src_len
	mov dword [rbp-12], edi

	;uint8_t word_len = 0
	mov byte [rbp-13], 0
	;char *word = src // it will point on the first character after space
	mov qword [rbp-21], rax

	;uint16_t a = 1 // now we on line
	mov word [rbp-23], 1

	;if stack
	;0 = nothing = free
	;1 = for if return true
	;2 = skip to else or end
	;3 = skip to end
	;4 = for while pull stack
	;5 = for macro inic
	;6 = for macro do
	mov qword [rbp-31], if_stack_end

	;while stack
	mov qword [rbp-39], while_stack_end
	;while stack for len
	mov qword [rbp-47], while_stack_len_end

	;uint8_t now_we_are_in_the_quotes?
	mov byte [rbp-48], 0

	;macro names stack
	mov qword [rbp-56], mn_end
	;macro names len stack
	mov qword [rbp-64], mnl_end
	;macro implemantation stack
	mov qword [rbp-72], mi_end
	;macro back stack
	mov qword [rbp-80], mb_end
	;macro back len stack
	mov qword [rbp-88], mbl_end
	;macro next word my
	mov byte [rbp-89], 0
	;macro implemantation len stack
	mov qword [rbp-97], mil_end

	;include next word my
	mov byte [rbp-98], 0

	;uint8_t now_we_are_in_the_single_quotes?
	mov byte [rbp-99], 0

	;go to while
	jmp go_for_line

.error_file:
	strcmp_const "ERROR: amount of arguments don't equal to 2. Example: ./arth src.arth"
	mov rax, rdi
	mov rdi, rdx
	
	jmp exit_with_reason

;char *read_file(const char *file_name, size_t name_len);
;rax = file_name_addr
;rdi = file_name_len
;ret rax = file_content_addr (mmap)
;ret rdi = file_content_len
read_file:
    push rbp
    mov rbp, rsp
    mov rcx, rdi
    mov rsi, rax
    lea rdx, [rcx + 1]
    add rdx, 15
    and rdx, -16
    sub rsp, rdx
    mov rdi, rsp
    push rdi
    rep movsb
    mov byte [rdi], 0
    pop rax
    call read_file_C
    leave
    ret

;char *read_file_C(const char *file_name);
;rax = file_name
;ret src = rax
;ret src_len = rdi
read_file_C:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    mov rdi, rax
    xor rsi, rsi
    mov rax, 2
    syscall
    test rax, rax
    js .error
    mov r12, rax
    mov rdi, r12
    xor rsi, rsi
    mov rdx, 2
    mov rax, 8
    syscall
    mov r13, rax
    mov rdi, r12
    xor rsi, rsi
    xor rdx, rdx
    mov rax, 8
    syscall
    mov rsi, r13
    xor rdi, rdi
    mov rdx, 3
    mov r10, 34
    mov r8, -1
    xor r9, r9
    mov rax, 9
    syscall
    cmp rax, -1
    je .err_close
    mov r14, rax
    mov rdi, r12
    mov rsi, r14
    mov rdx, r13
    xor rax, rax
    syscall
    mov rdi, r12
    mov rax, 3
    syscall
    mov rax, r14
    mov rdi, r13
    jmp .exit

.err_close:
    mov rdi, r12
    mov rax, 3
    syscall

.error:
    xor rax, rax
    xor rdi, rdi

.exit:
    pop r14
    pop r13
    pop r12
    leave
    ret

;char *sum_two_strings(char *a, char *b, size_t a_len, size_t b_len)
;a = rax
;a_len = rdi
;b = rsi
;b_len = rdx
;ret rax = string
;ret rdi = len
sum_two_strings:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov rbx, rax            
    mov r12, rdi            
    mov r13, rsi            
    mov r14, rdx            
    lea r15, [r12 + r14]    
    mov rsi, r15            
    xor rdi, rdi            
    mov rdx, 3              
    mov r10, 34             
    mov r8, -1
    xor r9, r9
    mov rax, 9              
    syscall
    cmp rax, -1
    je .error
    mov rdi, rax            
    mov rsi, rbx            
    mov rcx, r12            
    push rdi                
    rep movsb               
    mov rsi, r13            
    mov rcx, r14            
    rep movsb
    pop rax                 
    mov rdi, r15            
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    leave
    ret

.error:
    xor rax, rax
    xor rdi, rdi
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    leave
    ret

;void free_allocated(char *a, size_t a_len)
;rax = a
;rdi = a_len
free_allocated:
    push rbp
    mov rbp, rsp

    mov rsi, rdi
    mov rdi, rax
    mov rax, 11
    syscall

    leave
    ret

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

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp command_finish

print_my:
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
	;if last if stack exists and is 2 or 3 (skip mode)
	mov rdi, qword [rbp-31]
	cmp rdi, if_stack_end
	je .no_skip
	
	mov rax, [rdi]
	cmp rax, 2
	je .push_skip
	cmp rax, 3
	je .push_skip

.no_skip:
	;get from mlv stack last
	mov rax, [r12]
	add r12, 8

	;if if condition true, set if stack[] = 1
	cmp rax, 1
	je .set_true

	;else set skip
	mov rax, qword [rbp-31]
	sub rax, 8
	mov qword [rax], 2
	mov qword [rbp-31], rax
	jmp command_finish

.set_true:
	mov rax, qword [rbp-31]
	sub rax, 8
	mov qword [rax], 1
	mov qword [rbp-31], rax
	jmp command_finish

.push_skip:
	;just push skip to nested stack
	mov rax, qword [rbp-31]
	sub rax, 8
	mov qword [rax], 2
	mov qword [rbp-31], rax
	jmp command_finish

else_my:
	;get from if stack last value
	mov rdi, qword [rbp-31]
	
	;if if stack empty, skip
	cmp rdi, if_stack_end
	je command_finish

	;if parent if stack exists and is 2 or 3, do nothing
	mov rax, rdi
	add rax, 8
	cmp rax, if_stack_end
	je .check_value
	
	mov rax, [rdi+8]
	cmp rax, 2
	je command_finish
	cmp rax, 3
	je command_finish

.check_value:
	;if current is 1 -> 2, if 2 -> 1
	mov rax, [rdi]
	cmp rax, 1
	je .set_two
	cmp rax, 2
	je .set_one
	jmp command_finish

.set_two:
	mov qword [rdi], 2
	jmp command_finish
.set_one:
	mov qword [rdi], 1
	jmp command_finish

return_to_while:
	;src = while stack last
	;src_len = while_len stack last
	mov rax, qword [rbp-39]
	mov rdi, qword [rax]
	mov qword [rbp-8], rdi

	mov rdi, qword [rbp-47]
	mov eax, dword [rdi]
	mov dword [rbp-12], eax

	jmp command_finish

end_my_while:
	;pop if stack
	add qword [rbp-31], 8

	;pop while stack
	add qword [rbp-39], 8

	;pop while len stack
	add qword [rbp-47], 4

	jmp command_finish

end_macro:
	;pop if_stack
	add qword [rbp-31], 8

	;if back_stack == mb_end
	mov rax, qword [rbp-80]
	cmp rax, mb_end
	je command_finish

	;src = macro back stack[]
	mov rax, qword [rbp-80]
	mov rdi, qword [rax]
	mov qword [rbp-8], rdi

	;src_len = macro back len stack[]
	mov rax, qword [rbp-88]
	mov rdi, qword [rax]
	mov dword [rbp-12], edi

	;pop macro back stack
	add qword [rbp-80], 8

	;pop macro back len stack
	add qword [rbp-88], 8

	jmp command_finish

end_my:
	;if last if stack value == 4
	mov rax, qword [rbp-31]
	cmp rax, if_stack_end
	je command_finish

	cmp qword [rax], 4
	je return_to_while

	;if last if stack value == 3
	cmp qword [rax], 3
	je end_my_while

	;if last if stack value == 5
	cmp qword [rax], 5
	je end_macro

	;if last if stack value == 6
	cmp qword [rax], 6
	je end_macro

	;remove last if stack value
	add qword [rbp-31], 8

	jmp command_finish

dup_my:
	;get but no remove last mlv
	mov rax, [r12]

	;push in mlv
	sub r12, 8
	mov [r12], rax

	jmp command_finish

two_dup_my:
	;get two numbers but no remove them
	mov r8, r12
	mov rdi, [r8]
	add r8, 8
	mov rax, [r8]
	add r8, 8

	;push mlv
	sub r12, 8
	mov [r12], rax
	sub r12, 8
	mov [r12], rdi

	jmp command_finish

not_equal_my:
	;save first stack
	mov rax, [r12]
	add r12, 8

	;save second stack
	mov rdi, [r12]
	add r12, 8

	;if a != b
	cmp rax, rdi
	jne equal_my_true

	;put 0 in rax
	mov rax, 0

	;ret false
	sub r12, 8
	mov [r12], rax

	jmp command_finish

above_my:
	;save first stack
	mov rax, [r12]
	add r12, 8

	;save second stack
	mov rdi, [r12]
	add r12, 8

	;if a > b
	cmp rdi, rax
	ja equal_my_true

	;put 0 in rax
	mov rax, 0

	;ret false
	sub r12, 8
	mov [r12], rax

	jmp command_finish

below_my:
	;save first stack
	mov rax, [r12]
	add r12, 8

	;save second stack
	mov rdi, [r12]
	add r12, 8

	;if a < b
	cmp rdi, rax
	jb equal_my_true

	;put 0 in rax
	mov rax, 0

	;ret false
	sub r12, 8
	mov [r12], rax

	jmp command_finish

above_equal_my:
	;save first stack
	mov rax, [r12]
	add r12, 8

	;save second stack
	mov rdi, [r12]
	add r12, 8

	;if a >= b
	cmp rdi, rax
	jae equal_my_true

	;put 0 in rax
	mov rax, 0

	;ret false
	sub r12, 8
	mov [r12], rax

	jmp command_finish

below_equal_my:
	;save first stack
	mov rax, [r12]
	add r12, 8

	;save second stack
	mov rdi, [r12]
	add r12, 8

	;if a <= b
	cmp rdi, rax
	jbe equal_my_true

	;put 0 in rax
	mov rax, 0

	;ret false
	sub r12, 8
	mov [r12], rax

	jmp command_finish

while_my:
	;if skip mode, push 3 and skip
	mov rdi, qword [rbp-31]
	cmp rdi, if_stack_end
	je .no_skip_init

	mov rax, [rdi]
	cmp rax, 2
	je .push_skip
	cmp rax, 3
	je .push_skip

.no_skip_init:
	;check if we already have this address in while_stack
	mov rdi, qword [rbp-39]
	cmp rdi, while_stack_end
	je .push_new

	mov rax, [rdi]
	cmp rax, qword [rbp-8]
	je .only_push_if_stack

.push_new:
	;push while stack space
	mov rax, qword [rbp-8]
	mov rdi, qword [rbp-39]
	sub rdi, 8
	mov qword [rdi], rax
	mov qword [rbp-39], rdi

	;save length
	mov eax, dword [rbp-12]
	mov rdi, qword [rbp-47]
	sub rdi, 4
	mov dword [rdi], eax
	mov qword [rbp-47], rdi

.only_push_if_stack:
	;push in if stack 4
	mov rax, qword [rbp-31]
	sub rax, 8
	mov qword [rax], 4
	mov qword [rbp-31], rax
	jmp command_finish

.push_skip:
	mov rax, qword [rbp-31]
	sub rax, 8
	mov qword [rax], 3
	mov qword [rbp-31], rax
	jmp command_finish

do_my:
	;check last if stack
	mov rax, qword [rbp-31]
	cmp rax, if_stack_end
	je command_finish

	cmp qword [rax], 4
	je .do_while
	jmp command_finish

.do_while:
	;pop mlv stack
	mov rax, [r12]
	add r12, 8

	;if != 1, skip to end
	cmp rax, 1
	jne .set_skip
	jmp command_finish

.set_skip:
	mov rax, qword [rbp-31]
	mov qword [rax], 3
	jmp command_finish

comment_my:
	;while *(src+1) != \n
	mov rax, qword [rbp-8]
	inc rax
	cmp byte [rax], 10
	je command_finish

	;if src_len == 0
	cmp dword [rbp-12], 0
	je exit

	;src++
	;src_len--
	inc qword [rbp-8]
	dec dword [rbp-12]

	jmp comment_my

mem_my:
	mov rax, mfu
	sub r12, 8
	mov [r12], rax

	jmp command_finish

load_my:
	;pop last mlv
	mov rax, [r12]
	add r12, 8

	;read one byte
	mov bl, byte [rax]
	movzx rax, bl

	;push one byte
	sub r12, 8
	mov [r12], rax

	jmp command_finish

store_my:
	;get last mlv (first = what store)
	mov rax, [r12]
	add r12, 8

	;get last mlv (second = address)
	mov rdi, [r12]
	add r12, 8

	;zip rax
	mov sil, al

	;set first el of mfu zip rax
	mov byte [rdi], sil

	jmp command_finish

syscall_one:
	;pop mlv (first and last argument)
	mov rdi, [r12]
	add r12, 8

	syscall

	jmp command_finish

syscall_two:
	;pop mlv (second arg)
	mov rsi, [r12]
	add r12, 8

	;pop mlv (first arg)
	mov rdi, [r12]
	add r12, 8

	syscall

	jmp command_finish

syscall_three:
	;pop mlv (third arg)
	mov rdx, [r12]
	add r12, 8

	;pop mlv (second arg)
	mov rsi, [r12]
	add r12, 8

	;pop mlv (first arg)
	mov rdi, [r12]
	add r12, 8

	syscall

	jmp command_finish

syscall_four:
	;pop mlv (fourth arg)
	mov r10, [r12]
	add r12, 8

	;pop mlv (third arg)
	mov rdx, [r12]
	add r12, 8

	;pop mlv (second arg)
	mov rsi, [r12]
	add r12, 8

	;pop mlv (first arg)
	mov rdi, [r12]
	add r12, 8

	syscall

	jmp command_finish

syscall_five:
	;pop mlv (five arg)
	mov r9, [r12]
	add r12, 8

	;pop mlv (fourth arg)
	mov r10, [r12]
	add r12, 8

	;pop mlv (third arg)
	mov rdx, [r12]
	add r12, 8

	;pop mlv (second arg)
	mov rsi, [r12]
	add r12, 8

	;pop mlv (first arg)
	mov rdi, [r12]
	add r12, 8

	syscall

	jmp command_finish

syscall_my:
	;pop mlv (syscall number)
	mov rax, [r12]
	add r12, 8

	;pop mlv (amount of arguments)
	mov rbx, [r12]
	add r12, 8

	;if n == 1
	cmp rbx, 1
	je syscall_one
	
	;if n == 2
	cmp rbx, 2
	je syscall_two

	;if n == 3
	cmp rbx, 3
	je syscall_three
	
	;if n == 4
	cmp rbx, 4
	je syscall_four

	;if n == 5
	cmp rbx, 5
	je syscall_five

	;if n == 6, do here

	;pop mlv (six arg)
	mov r8, [r12]
	add r12, 8

	;pop mlv (five arg)
	mov r9, [r12]
	add r12, 8

	;pop mlv (fourth arg)
	mov r10, [r12]
	add r12, 8

	;pop mlv (third arg)
	mov rdx, [r12]
	add r12, 8

	;pop mlv (second arg)
	mov rsi, [r12]
	add r12, 8

	;pop mlv (first arg)
	mov rdi, [r12]
	add r12, 8

	syscall

	jmp command_finish

drop_my:
	;pop mlv
	add r12, 8

	jmp command_finish

shr_my:
	;pop mlv (>> ?)
	mov rdi, [r12]
	add r12, 8

	;pop mlv (number)
	mov rax, [r12]
	add r12, 8

	;shr
	mov cl, dil
	shr rax, cl

	;push rax
	sub r12, 8
	mov [r12], rax

	jmp command_finish

shl_my:
	;pop mlv (<< ?)
	mov rdi, [r12]
	add r12, 8

	;pop mlv (number)
	mov rax, [r12]
	add r12, 8

	;shl
	mov cl, dil
	shl rax, cl

	;push rax
	sub r12, 8
	mov [r12], rax

	jmp command_finish

bor_my:
	;pop mlv (| ?)
	mov rdi, [r12]
	add r12, 8

	;pop mlv (number)
	mov rax, [r12]
	add r12, 8

	;or
	or rax, rdi

	;push rax
	sub r12, 8
	mov [r12], rax

	jmp command_finish

band_my:
	;pop mlv (& ?)
	mov rdi, [r12]
	add r12, 8

	;pop mlv (number)
	mov rax, [r12]
	add r12, 8

	;and
	and rax, rdi

	;push rax
	sub r12, 8
	mov [r12], rax

	jmp command_finish

swap_my:
	;[1, 2] [2, 1]
	mov rdi, [r12]
	add r12, 8
	mov rax, [r12]
	mov [r12], rdi
	sub r12, 8
	mov [r12], rax
	jmp command_finish

over_my:
	;[1, 2] [1, 2, 1]
	mov rax, [r12]
	add r12, 8
	mov rdi, [r12]
	mov [r12], rdi
	sub r12, 8
	mov [r12], rax
	sub r12, 8
	mov [r12], rdi
	jmp command_finish

push_str_my:
	;remove "
	inc qword [rbp-21]
	dec byte [rbp-13]

	;save start
	mov rax, r13

	;save len
	mov dl, byte [rbp-13]

	jmp .while_condition

.while_condition:
	;if word_len != 0
	cmp byte [rbp-13], 0
	jne .while_loop

	;push mlv start
	sub r12, 8
	mov [r12], rax

	;push mlv len
	movzx rax, dl
	sub r12, 8
	mov [r12], rax

	inc r13

	jmp command_finish

.while_loop:
	;if word[] == \
	mov rdi, qword [rbp-21]
	mov sil, byte [rdi]
	cmp sil, 92
	je .its_backside_flash

	;set mfus[] word[]
	mov rdi, qword [rbp-21]
	mov sil, byte [rdi]
	mov byte [r13], sil

	;mfus++ word++ word_len--
	inc r13
	inc qword [rbp-21]
	dec byte [rbp-13]

	jmp .while_condition

.its_backside_flash:
	mov rdi, qword [rbp-21]
	inc rdi

	;if *(word+1) == n
	cmp byte [rdi], 110
	je .n

	;if *(word+1) == t
	cmp byte [rdi], 116
	je .t

	;if *(word+1) == "
	cmp byte [rdi], 34
	je .q

	;set mfus[] \
	mov byte [r13], 92

	;mfus++ (word += 2) (word_len -= 2)
	inc r13
	add qword [rbp-21], 2
	sub byte [rbp-13], 2

	jmp .while_condition

.n:
	;set mfus[] \n
	mov byte [r13], 10

	;mfus++ (word += 2) (word_len -= 2)
	inc r13
	add qword [rbp-21], 2
	sub byte [rbp-13], 2

	jmp .while_condition

.t:
	;set mfus[] \t
	mov byte [r13], 9

	;mfus++ (word += 2) (word_len -= 2)
	inc r13
	add qword [rbp-21], 2
	sub byte [rbp-13], 2

	jmp .while_condition

.q:
	;set mfus[] "
	mov byte [r13], 34

	;mfus++ (word += 2) (word_len -= 2)
	inc r13
	add qword [rbp-21], 2
	sub byte [rbp-13], 2

	jmp .while_condition

macro_my:
	;set macro next word my 1
	mov byte [rbp-89], 1

	;push if stack 5
	mov rax, qword [rbp-31]
	sub rax, 8
	mov qword [rax], 5
	mov qword [rbp-31], rax

	jmp command_finish

macro_save_name:
	;push macro names stack word
	mov rax, qword [rbp-56]
	sub rax, 8
	mov rdi, qword [rbp-21]
	mov qword [rax], rdi
	mov qword [rbp-56], rax

	;push macro names len stack word_len
	mov rax, qword [rbp-64]
	sub rax, 8
	movzx rdi, byte [rbp-13]
	mov qword [rax], rdi
	mov qword [rbp-64], rax

	;push macro implemantation stack (src-1)
	mov rax, qword [rbp-72]
	sub rax, 8
	mov rdi, qword [rbp-8]
	dec rdi
	mov qword [rax], rdi
	mov qword [rbp-72], rax

	;push macro implemantation len stack src_len
	mov rax, qword [rbp-97]
	sub rax, 8
	mov edi, dword [rbp-12]
	mov qword [rax], rdi
	mov qword [rbp-97], rax

	;set macro next word my 0
	mov byte [rbp-89], 0

	jmp command_finish

include_my:
	;set include next word my 1
	mov byte [rbp-98], 1

	jmp command_finish

include_file_name:
	;set include next word my 0
	mov byte [rbp-98], 0

	;if word[] != "
	mov rax, qword [rbp-21]
	cmp byte [rax], 34
	jne command_finish

	;word++ word_len--
	inc qword [rbp-21]
	dec byte [rbp-13]

	mov rdi, 0

	;read_file
	mov rax, qword [rbp-21]
	mov dil, byte [rbp-13]
	call read_file

	mov r8, rax
	mov r9, rdi

	;if rax == 0
	cmp rax, 0
	je .error_file

	push rax
	push rdi
	mov rax, qword [rbp-8]
	mov rdi, 0
	mov edi, dword [rbp-12]
	push rax
	push rdi

	mov rax, r8
	mov rdi, r9
	mov rsi, qword [rbp-8]
	mov rdx, 0
	mov edx, dword [rbp-12]
	call sum_two_strings

	;src = string
	;src_len = len
	mov qword [rbp-8], rax
	mov dword [rbp-12], edi

	pop rdi
	pop rax
	call free_allocated

	pop rdi
	pop rax
	call free_allocated

	;DEBUG
	;mov rsi, qword [rbp-8]
	;mov rdx, 0
	;mov edx, dword [rbp-12]
	;call write

	jmp command_finish_save

.error_file:
	strcmp_const "ERROR `include` operation: this file don't exists"
	mov rax, rdi
	mov rdi, rdx
	
	jmp exit_with_reason

multi_my:
	;pop mlv
	mov rax, [r12]
	add r12, 8

	;pop mlv
	mov rdi, [r12]
	add r12, 8

	;multi
	imul rax, rdi

	;push mlv
	sub r12, 8
	mov [r12], rax

	jmp command_finish

mod_my:
	;pop mlv
	mov rdi, [r12]
	add r12, 8

	;pop mlv
	mov rax, [r12]
	add r12, 8

	;mod
	xor rdx, rdx
	idiv rdi
	mov rcx, rdx

	;push mlv
	sub r12, 8
	mov qword [r12], rcx

	jmp command_finish

push_char_my:
	;remove '
	;word++ word_len -= 2
	inc qword [rbp-21]
	sub byte [rbp-13], 2

	;if word_len == 0
	mov al, byte [rbp-13]
	cmp al, 0
	je .exit

	;if word == \n
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "\n"
	call strcmp
	cmp rax, 1
	je .n

	;if word == \t
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "\t"
	call strcmp
	cmp rax, 1
	je .t

	;if word == \'
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "\'"
	call strcmp
	cmp rax, 1
	je .q

	;convert simvol onto int
	mov rdi, qword [rbp-21]
	mov rax, 0
	mov al, byte [rdi]

	;push mlv
	sub r12, 8
	mov [r12], rax

	jmp command_finish

.n:
	;push mlv
	sub r12, 8
	mov qword [r12], 10

	jmp command_finish

.t:
	;push mlv
	sub r12, 8
	mov qword [r12], 9

	jmp command_finish

.q:
	;push mlv
	sub r12, 8
	mov qword [r12], 39

	jmp command_finish

.exit:
	;push mlv
	sub r12, 8
	mov qword [r12], 0
	
	jmp command_finish

do_command:
	;DEBUG
	;mov rsi, qword [rbp-21]
	;mov rdx, 0
	;mov dl, byte [rbp-13]
	;call write
	;mov rsi, newline_character
	;mov rdx, 1
	;call write

	;if word_len == 0
	cmp byte [rbp-13], 0
	je command_finish

	; end
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "end"
	call strcmp
	cmp rax, 1
	je end_my

	;if macro next word my == 1
	cmp byte [rbp-89], 1
	je macro_save_name

	;if include next word my == 1
	cmp byte [rbp-98], 1
	je include_file_name

	;if if stack == 5
	mov rax, qword [rbp-31]
	cmp qword [rax], 5
	je command_finish

	; if
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "if"
	call strcmp
	cmp rax, 1
	je if_my

	; else
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "else"
	call strcmp
	cmp rax, 1
	je else_my

	; while
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "while"
	call strcmp
	cmp rax, 1
	je while_my

	; do
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "do"
	call strcmp
	cmp rax, 1
	je do_my

	mov rdi, qword [rbp-31]
	cmp rdi, if_stack_end
	je .normal_exec
	
	mov rax, [rdi]
	cmp rax, 2
	je command_finish
	cmp rax, 3
	je command_finish

.normal_exec:
	;its_number(word_now, word_len)
	mov rax, qword [rbp-21]
	movzx rdi, byte [rbp-13]
	call its_number
	cmp rax, 1
	je push_my

	;if *word == "
	mov rax, qword [rbp-21]
	cmp byte [rax], 34
	je push_str_my

	;if *word == '
	mov rax, qword [rbp-21]
	cmp byte [rax], 39
	je push_char_my

	; dump
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "dump"
	call strcmp
	cmp rax, 1
	je dump_my

	; print
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "print"
	call strcmp
	cmp rax, 1
	je print_my

	; +
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "+"
	call strcmp
	cmp rax, 1
	je plus_my

	; -
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "-"
	call strcmp
	cmp rax, 1
	je minus_my

	; *
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "*"
	call strcmp
	cmp rax, 1
	je multi_my

	; =
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "="
	call strcmp
	cmp rax, 1
	je equal_my

	; !=
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "!="
	call strcmp
	cmp rax, 1
	je not_equal_my

	; >
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const ">"
	call strcmp
	cmp rax, 1
	je above_my

	; <
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "<"
	call strcmp
	cmp rax, 1
	je below_my

	; >=
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const ">="
	call strcmp
	cmp rax, 1
	je above_equal_my

	; <=
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "<="
	call strcmp
	cmp rax, 1
	je below_equal_my

	; dup
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "dup"
	call strcmp
	cmp rax, 1
	je dup_my

	; 2dup
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "2dup"
	call strcmp
	cmp rax, 1
	je two_dup_my

	; //
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "//"
	call strcmp
	cmp rax, 1
	je comment_my

	; mem
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "mem"
	call strcmp
	cmp rax, 1
	je mem_my

	; .
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "."
	call strcmp
	cmp rax, 1
	je store_my

	; ,
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const ","
	call strcmp
	cmp rax, 1
	je load_my

	; syscall
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "syscall"
	call strcmp
	cmp rax, 1
	je syscall_my

	; drop
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "drop"
	call strcmp
	cmp rax, 1
	je drop_my

	; shr
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "shr"
	call strcmp
	cmp rax, 1
	je shr_my

	; shl
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "shl"
	call strcmp
	cmp rax, 1
	je shl_my

	; bor
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "bor"
	call strcmp
	cmp rax, 1
	je bor_my

	; band
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "band"
	call strcmp
	cmp rax, 1
	je band_my

	; swap
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "swap"
	call strcmp
	cmp rax, 1
	je swap_my

	; over
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "over"
	call strcmp
	cmp rax, 1
	je over_my

	; macro
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "macro"
	call strcmp
	cmp rax, 1
	je macro_my

	; include
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "include"
	call strcmp
	cmp rax, 1
	je include_my

	; mod
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "mod"
	call strcmp
	cmp rax, 1
	je mod_my

	;check if there is in macro names stack
	mov r8, qword [rbp-56]
	mov r9, qword [rbp-64]
	mov r10, 0
	jmp checking_macro_names_condition

checking_macro_names_condition:
	;macro names stack != macro names stack end
	;macro names len stack != macro names stack end
	mov rax, mn_end
	cmp rax, r8
	je command_finish

	mov rax, mnl_end
	cmp rax, r9
	je command_finish

	jmp .while

.while:
	mov rax, qword [r8]
	mov rdi, qword [rbp-21]
	mov rsi, qword [r9]
	movzx rdx, byte [rbp-13]

	call strcmp
	cmp rax, 1
	je .find

	add r8, 8
	add r9, 8
	inc r10

	jmp checking_macro_names_condition

.find:
	;push macro back stack src
	mov rax, qword [rbp-80]
	sub rax, 8
	mov rdi, qword [rbp-8]
	mov qword [rax], rdi
	mov qword [rbp-80], rax

	;push macro back len stack src_len
	mov rax, qword [rbp-88]
	sub rax, 8
	mov edi, dword [rbp-12]
	mov qword [rax], rdi
	mov qword [rbp-88], rax

	;push if stack 6
	mov rax, qword [rbp-31]
	sub rax, 8
	mov qword [rax], 6
	mov qword [rbp-31], rax
	
	;get implemantation stack char *
	mov rax, qword [rbp-72]
	mov rdi, r10
	shl rdi, 3
	add rax, rdi

	;set src = char *
	mov rdi, qword [rax]
	mov qword [rbp-8], rdi

	;get implemantation len stack int
	mov rax, qword [rbp-97]
	mov rdi, r10
	shl rdi, 3
	add rax, rdi

	;set src_len = int
	mov rax, qword [rbp-97]
	mov rdi, qword [rax]
	mov dword [rbp-12], edi

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

command_finish_save:
	;if src_len == 0
	cmp dword [rbp-12], 0
	je exit

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

its_quotes:
	;if we are in single quotes
	mov al, byte [rbp-99]
	cmp al, 1
	je .ignore

	;set we are in quotes !
	mov al, byte [rbp-48]
	
	cmp al, 0
	je .true

	;if *(src-1) == \
	mov rax, qword [rbp-8]
	dec rax
	cmp byte [rax], 92
	je .ignore

	mov byte [rbp-48], 0

	;src++ src_len--
	inc qword [rbp-8]
	dec dword [rbp-12]

	jmp do_command

.ignore:
	;src++ src_len-- word_len++
	inc qword [rbp-8]
	dec dword [rbp-12]
	inc byte [rbp-13]

	jmp go_for_line

.true:
	mov byte [rbp-48], 1

	;src++ src_len-- word_len++
	inc qword [rbp-8]
	dec dword [rbp-12]
	inc byte [rbp-13]

	jmp go_for_line

its_space:
	;check we are in quotes
	mov al, byte [rbp-48]
	cmp al, 1
	je .ignore

	;check we are in the single quotes
	mov al, byte [rbp-99]
	cmp al, 1
	je .ignore

	jmp do_command

.ignore:
	;src++ src_len-- word_len++
	inc qword [rbp-8]
	dec dword [rbp-12]
	inc byte [rbp-13]

its_single_quotes:
	;if we are in the quotes
	mov al, byte [rbp-48]
	cmp al, 1
	je .ignore

	;set we are in single quotes !
	mov al, byte [rbp-99]
	
	;if we are in the single quotes == 0
	cmp al, 0
	je .true

	;if *(src-1) == \
	mov rax, qword [rbp-8]
	dec rax
	cmp byte [rax], 92
	je .ignore

	mov byte [rbp-99], 0

	;src++ src_len-- word_len++
	inc qword [rbp-8]
	dec dword [rbp-12]
	inc byte [rbp-13]

	jmp do_command

.ignore:
	;src++ src_len-- word_len++
	inc qword [rbp-8]
	dec dword [rbp-12]
	inc byte [rbp-13]

	jmp go_for_line

.true:
	mov byte [rbp-99], 1

	;src++ src_len-- word_len++
	inc qword [rbp-8]
	dec dword [rbp-12]
	inc byte [rbp-13]

	jmp go_for_line

go_for_line_loop:
	;if word == //
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "//"
	call strcmp
	;if true
	cmp rax, 1
	je comment_my

	mov rax, qword [rbp-8]

	;if its "
	cmp byte [rax], 34
	je its_quotes

	;if its '
	cmp byte [rax], 39
	je its_single_quotes

	;if its \n
	cmp byte [rax], 10
	je new_line

	;if its space
	cmp byte [rax], 32
	je its_space

	;if its \t
	cmp byte [rax], 9
	je its_space

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

exit_with_reason:
	;write error
	mov rsi, rax
	mov rdx, rdi
	call write

	;write \n
	mov rsi, newline_character
	mov rdx, 1
	call write

	;exit
	mov rax, 60
	mov rdi, 0
	syscall

segment readable writable

;LANGUAGE VARIABLES

;my language variables
mlv rq 1250
mlv_end:

;if stack
if_stack rb 10000
if_stack_end:

;while stack
while_stack rq 10000
while_stack_end:

;while_stack = while_stack_len

while_stack_len rd 10000
while_stack_len_end:

;memory for user
mfu rb 5000

;mfu + mfus = all memory for user

;memory for user string
mfus rb 5000

;MACRO
;macro names stack
mn rq 1000
mn_end:

;mn = mnl

;macro names len stack
mnl rb 1000
mnl_end:

;mn = mi

;macro implemantation stack
mi rq 1000
mi_end:

;macro implemantation len stack
mil rq 1000
mil_end:

;macro back stack
mb rq 1000
mb_end:

;macro back len stack
mbl rq 1000
mbl_end:
;MACRO

;LANGUAGE VARIABLES

newline_character db 10
