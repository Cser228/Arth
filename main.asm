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
	;inic stack
	push rbp
	mov rbp, rsp
	sub rsp, 256

	mov r14, mlva

	mov byte [rbp-100], 3
	mov qword [rbp-108], 0
	mov qword [rbp-117], include_dop_end
	mov byte [rbp-109], 0
	mov byte [rbp-118], 0
	mov byte [rbp-119], 0

	;get argc
    mov r8, qword [rbp+8]

	mov qword [r14], r8
	add r14, 8

	mov rax, qword [rbp+16]
	mov qword [r14], rax
	add r14, 8

    ;if argc == 1
    cmp r8, 1
    jle .just_name
    
    ;drop program name
	dec r8

	;while of args
 	mov r13, rbp
	add r13, 24
	jmp .args_condition

;r8 - argc
;r9 - src
;r10 - src_len
;r11/r12 - argv string
;r13 - for pop
.args_condition:
	;while argc != 0
	cmp r8, 0
	jne .args_while

	cmp r9, 0
	je .input_file

	mov rax, r9
	mov rdi, r10

	jmp .after_args

.args_while:
	;get *argv
	mov rax, qword [r13]
	add r13, 8

	mov qword [r14], rax
	add r14, 8

	call strlen_C

	mov r11, rax
	mov r12, rdi

	; -f
	mov rax, r11
	mov rsi, r12
	strcmp_const "-f"
	call strcmp
	cmp rax, 1
	je .set_file

	; -out
	mov rax, r11
	mov rsi, r12
	strcmp_const "-out"
	call strcmp
	cmp rax, 1
	je .out

	; -asm
	mov rax, r11
	mov rsi, r12
	strcmp_const "-asm"
	call strcmp
	cmp rax, 1
	je .asm

	; -o
	mov rax, r11
	mov rsi, r12
	strcmp_const "-o"
	call strcmp
	cmp rax, 1
	je .o

	; -sim
	mov rax, r11
	mov rsi, r12
	strcmp_const "-sim"
	call strcmp
	cmp rax, 1
	je .simulation

	; -com
	mov rax, r11
	mov rsi, r12
	strcmp_const "-com"
	call strcmp
	cmp rax, 1
	je .compilation

	; -I
	mov rax, r11
	mov rsi, r12
	strcmp_const "-I"
	call strcmp
	cmp rax, 1
	je .include_folder_set

	; -r
	mov rax, r11
	mov rsi, r12
	strcmp_const "-r"
	call strcmp
	cmp rax, 1
	je .run_after_compile

	cmp byte [rbp-118], 1
	je .include_folder

	jmp .end

.run_after_compile:
	mov byte [rbp-119], 1

	jmp .end

.include_folder_set:
	mov byte [rbp-118], 1

	jmp .end

.include_folder:
	mov rax, r11
	mov rdi, r12
	call string_to_C

	mov rdi, rax

	mov rax, qword [rbp-117]
	sub rax, 8
	mov qword [rax], rdi
	mov qword [rbp-117], rax

	jmp .end
	
.set_file:
	mov byte [rbp-118], 0

	dec r8
	cmp r8, 0
	jle .input_after_file

	mov rax, qword [r13]
	add r13, 8

	mov qword [r14], rax
	add r14, 8

	push r8
	call read_file_C
	pop r8

	mov r9, rax
	mov r10, rdi

	jmp .end

.simulation:
	mov byte [rbp-118], 0

	mov byte [rbp-100], 1

	jmp .end

.compilation:
	mov byte [rbp-118], 0

	mov byte [rbp-100], 0

	jmp .end

.out:
	mov byte [rbp-118], 0

	dec r8
	cmp r8, 0
	jle .output_after_file

	mov rax, qword [r13]
	add r13, 8

	mov qword [r14], rax
	add r14, 8

	mov qword [rbp-108], rax
	mov byte [rbp-109], 0

	jmp .end

.asm:
	mov byte [rbp-118], 0

	dec r8
	cmp r8, 0
	jle .output_after_file

	mov rax, qword [r13]
	add r13, 8

	mov qword [r14], rax
	add r14, 8

	mov qword [rbp-108], rax
	mov byte [rbp-109], 2

	jmp .end

.o:
	mov byte [rbp-118], 0

	dec r8
	cmp r8, 0
	jle .output_after_file

	mov rax, qword [r13]
	add r13, 8

	mov qword [r14], rax
	add r14, 8

	mov qword [rbp-108], rax
	mov byte [rbp-109], 1

	jmp .end

.end:
	;argc--
	dec r8

	jmp .args_condition

.add_mlv_args:
	;while r14 >= mlva
	cmp r14, mlva
	jae .add_mlv_args_while

	jmp .inic_all

.add_mlv_args_while:
	mov rax, qword [r14]

	sub r12, 8
	mov qword [r12], rax

	sub r14, 8

	jmp .add_mlv_args

.after_args:
	push rax
	push rdi

	cmp byte [rbp-100], 3
	je .where_mode
	
	;inic stack my language
	mov r12, mlv_end

	mov qword [r14], 0

	cmp byte [rbp-100], 1
	je .add_mlv_args

	jmp .inic_all

.inic_all:
	pop rdi
	pop rax

	;inic memory for user string
	mov r13, mfus

	;inic compilation string
	mov r14, com_buff

	;inic stc_my stack
	mov r15, stc_my_end

	;inic variables

	;char *a = src
	mov qword [rbp-8], rax
	;uint32_t b = src_len
	mov dword [rbp-12], edi

	;uint8_t word_len = 0
	mov byte [rbp-13], 0
	;char *word = src // it will point on the first character after space
	mov qword [rbp-21], rax

	;macro work
	mov byte [rbp-22], 0

	;/*
	mov byte [rbp-23], 0

	;if stack
	;0 = nothing = free
	;1 = for if return true
	;2 = skip to else or end
	;3 = skip to end
	;4 = for while pull stack
	;5 = for macro inic
	;6 = for macro do
	;7 = for skip without while stack
	mov qword [rbp-31], if_stack_end

	;while stack
	mov qword [rbp-39], while_stack_end
	;while stack for len OR for com its counter for while_
	mov qword [rbp-47], while_stack_len_end

	mov rax, qword [rbp-47]
	mov rdi, 1
	cmp byte [rbp-100], 0
	cmove rax, rdi
	mov qword [rbp-47], rax

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

	;bool mode = sim or com
	;0 = com
	;1 = sim
	;2 = macro save
	;mov byte [rbp-100], ARGS

	;uint8_t name of file, he needs
	;mov qword [rbp-108], ARGS

	;uint8_t where i need stop
	;0 = elf
	;1 = o
	;2 = asm
	;mov byte [rbp-109], ARGS

	;char**
	;mov qword [rbp-117], include_dop_end ARGS

	;bool
	;mov byte [rbp-118], -I забирает всё себе ARGS

	;bool
	;mov byte [rbp-119], -r ARGS

	;char * save src for all time
	mov rax, qword [rbp-8]
	mov qword [rbp-127], rax


	;FREE 2 byte ASSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS


	;uint32_t counter for blocks
	mov dword [rbp-133], 0

	;uint32_t counter for end_
	mov dword [rbp-137], 1

	;if stack com хранит counter для себя, а while_stack хранит кто это? if или while
	mov qword [rbp-145], if_stack_com_end

	;void*
	;0 = if
	mov qword [rbp-153], stc_save_end

	;add firsts strings for compilation file if select compilation mode
	cmp byte [rbp-100], 0
	je .com_finish

	;go for while
	jmp go_for_line

.com_finish:
	mov rsi, asm_gen_start
	mov rdi, r14
	mov rcx, asm_gen_start_len
	rep movsb
	mov r14, rdi

	push r15

	mov r15, fasm_cmd

	strcmp_const "fasm output.asm"
	mov rsi, rdi
	mov rdi, r15
	mov rcx, rdx
	rep movsb
	mov r15, rdi

	cmp byte [rbp-109], 1
	je .o_change

	mov byte [r15], 0
	inc r15

	jmp do_elf

.o_change:
	mov byte [r15], 32
	inc r15

	mov rax, qword [rbp-108]
	call strlen_C

	mov rsi, rax
	mov rcx, rdi
	mov rdi, r15
	rep movsb
	mov r15, rdi

	mov byte [r15], 0
	inc r15

	jmp do_elf

.where_mode:
	strcmp_const "Don't find the mode. Example: ./arth -f src.arth -sim"
	mov rax, rdi
	mov rdi, rdx
	
	jmp exit_with_reason

.just_name:
	strcmp_const "Don't find any flags. Example: ./arth -f src.arth -sim"
	mov rax, rdi
	mov rdi, rdx
	
	jmp exit_with_reason

.input_file:
	strcmp_const "Don't find the input file name. Example: ./arth -f src.arth -sim"
	mov rax, rdi
	mov rdi, rdx
	
	jmp exit_with_reason

.input_after_file:
	strcmp_const "Don't find the input file name after flag. Example: ./arth -f src.arth -sim"
	mov rax, rdi
	mov rdi, rdx
	
	jmp exit_with_reason

.output_after_file:
	strcmp_const "Don't find the output file name after flag. Example: ./arth -f src.arth -sim -out a"
	mov rax, rdi
	mov rdi, rdx
	
	jmp exit_with_reason

do_elf:
	mov rdx, r15
	pop r15

	cmp byte [rbp-109], 0
	jne go_for_line

	push r15
	mov r15, rdx

	cmp qword [rbp-108], 0
	je .true

	mov r15, elf_cmd

	strcmp_const "ld output.o -o "
	mov rsi, rdi
	mov rdi, r15
	mov rcx, rdx
	rep movsb
	mov r15, rdi

	mov rax, qword [rbp-108]
	call strlen_C

	mov rsi, rax
	mov rcx, rdi
	mov rdi, r15
	rep movsb
	mov r15, rdi

	mov byte [r15], 0
	inc r15

	pop r15
	jmp go_for_line

.true:
	mov r15, elf_cmd

	strcmp_const "ld output.o -o output"
	mov rsi, rdi
	mov rdi, r15
	mov rcx, rdx
	rep movsb
	mov r15, rdi

	mov byte [r15], 0
	inc r15

	pop r15
	jmp go_for_line

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

	jmp .error

.error:
    xor rax, rax
    xor rdi, rdi

	jmp .exit

.exit:
    pop r14
    pop r13
    pop r12
    leave
    ret

;GET
;rax = 0/1/2 (stc_)
stc_number_to_write:
	cmp rax, 0
	je .int

	cmp rax, 1
	je .ptr

	cmp rax, 2
	je .bool

	ret

.int:
	strcmp_const "int"
	mov rsi, rdi
	call write

	ret

.ptr:
	strcmp_const "ptr"
	mov rsi, rdi
	call write

	ret

.bool:
	strcmp_const "bool"
	mov rsi, rdi
	call write

	ret

;GET
;он сам берёт qword [rbp-21], qword [rbp-127]
;RETURN
;rax = lines
;rdi = characters
count_lines_and_characters:
	;save registers
	push r8

	;r8 = curr = word
	;rsi = lines counter
	;rdx = was \n?
	mov r8, qword [rbp-21]
	mov rsi, 1
	mov rdx, 0

	jmp .cond

.cond:
	;while word != _src
	cmp r8, qword [rbp-127]
	ja .while

	jmp .end

.while:
	;if *word == \n
	cmp byte [r8], 10
	je .newline

	jmp .while_next
	
.newline:
	inc rsi

	cmp rdx, 0
	je .characters_count

	jmp .while_next

.characters_count:
	mov rdx, 1

	mov rax, qword [rbp-21]
	sub rax, r8
	push rax

	jmp .while_next

.while_next:
	dec r8

	jmp .cond

.end:
	cmp rdx, 1
	je .end_with_newline

	mov rax, rsi
	mov rdi, qword [rbp-21]
	sub rdi, r8
	inc rdi

	pop r8
	ret

.end_with_newline:
	mov rax, rsi
	pop rdi

	pop r8
	ret

;GET
;rax = curr
;rdi = stack end
;RETURN
;rax = stack len
stack_len:
	;stack end - curr
	sub rdi, rax
	mov rax, rdi
	mov rdi, 8

	cqo
	idiv rdi

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
	strcmp_const "mmap error"
	mov rax, rdi
	mov rdi, rdx
	
	jmp exit_with_reason

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

;uint8_t its_number(char* a, uint8_t len)
;a = rax
;len = rdi
;ret = rax
its_number:
	push r8
	push r9

	;save rax
	mov r8, rax

	;save rdi
	mov r9, rdi

	jmp .loop

.loop:
	;if len == 0
	cmp r9, 0
	je .true

	;if (*a >= '0' && *a <= '9')
	cmp byte [r8], 48
	jl .false
	cmp byte [r8], 57
	jg .false

	;continue loop
	inc r8
	dec r9

	jmp .loop

.false:
	;return false
	mov rax, 0

	;ret
	pop r9
	pop r8
	ret

.true:
	;return true
	mov rax, 1
	
	;ret
	pop r9
	pop r8
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
	sub r15, 8
	mov qword [r15], 0

	cmp byte [rbp-100], 0
	je .com

	;string_to_int
	mov rax, qword [rbp-21]
	movzx rdi, byte [rbp-13]
	call string_to_int

	;add to my stack
	sub r12, 8
	mov [r12], rax

	jmp command_finish

.com:
	;
	inc dword [rbp-133]

	mov rsi, asm_gen_block_start
	mov rdi, r14
	mov rcx, asm_gen_block_start_len
	rep movsb
	mov r14, rdi

	mov rax, 0
	mov eax, dword [rbp-133]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14
	;

	mov rsi, push_com
	mov rdi, r14
	mov rcx, push_com_len
	rep movsb
	mov r14, rdi

	mov rsi, qword [rbp-21]
	mov rdi, r14
	movzx rcx, byte [rbp-13]
	rep movsb
	mov r14, rdi

	mov byte [r14], 10
	inc r14

	mov byte [r14], 10
	inc r14

	jmp command_finish

dump_my:
	mov rax, r15
	mov rdi, stc_my_end
	call stack_len
	cmp rax, 1
	jb .error_below

	add r15, 8

	cmp byte [rbp-100], 0
	je .com

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

.error_below:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: not enough arguments for the `dump` instruction"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.com:
	;
	inc dword [rbp-133]

	mov rsi, asm_gen_block_start
	mov rdi, r14
	mov rcx, asm_gen_block_start_len
	rep movsb
	mov r14, rdi

	mov rax, 0
	mov eax, dword [rbp-133]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14
	;

	mov rsi, dump_com
	mov rdi, r14
	mov rcx, dump_com_len
	rep movsb
	mov r14, rdi

	jmp command_finish

print_my:
	mov rax, r15
	mov rdi, stc_my_end
	call stack_len
	cmp rax, 1
	jb .error_below

	add r15, 8

	cmp byte [rbp-100], 0
	je .com

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

.error_below:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: not enough arguments for the `print` instruction"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.com:
	;
	inc dword [rbp-133]

	mov rsi, asm_gen_block_start
	mov rdi, r14
	mov rcx, asm_gen_block_start_len
	rep movsb
	mov r14, rdi

	mov rax, 0
	mov eax, dword [rbp-133]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14
	;

	mov rsi, print_com
	mov rdi, r14
	mov rcx, print_com_len
	rep movsb
	mov r14, rdi

	jmp command_finish

plus_my:
	;check stc stack len < 2
	mov rax, r15
	mov rdi, stc_my_end
	call stack_len
	cmp rax, 2
	jb .error_below

	;if a_type == INT and b_type == INT
	mov rdx, 0
	mov rsi, 1
	mov rax, qword [r15]
	cmp rax, 0
	cmove rdx, rsi

	mov rax, r15
	add rax, 8
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 0
	cmove rax, rsi

	add rax, rdx
	cmp rax, 2
	je .stc_continue_int

	;if a_type == INT and b_type == PTR
	mov rdx, 0
	mov rsi, 1

	mov rax, r15
	add rax, 8
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 0
	cmove rdx, rsi

	mov rax, r15
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 1
	cmove rax, rsi

	add rax, rdx
	cmp rax, 2
	je .stc_continue_ptr

	;if a_type == PTR and b_type == INT
	mov rdx, 0
	mov rsi, 1

	mov rax, r15
	add rax, 8
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 1
	cmove rdx, rsi

	mov rax, r15
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 0
	cmove rax, rsi

	add rax, rdx
	cmp rax, 2
	je .stc_continue_ptr

	jmp .error_type

.stc_continue_int:
	add r15, 8
	mov qword [r15], 0

	jmp .stc_continue

.stc_continue_ptr:
	add r15, 8
	mov qword [r15], 1

	jmp .stc_continue

.stc_continue:
	cmp byte [rbp-100], 0
	je .com

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

.error_below:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: not enough arguments for the `+` operation"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.error_type:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: invalid argument types for `+` operation, `"
	mov rsi, rdi
	call write

	mov rdi, r15
	add rdi, 8
	mov rax, qword [rdi]
	call stc_number_to_write

	strcmp_const "` and `"
	mov rsi, rdi
	call write

	mov rax, qword [r15]
	call stc_number_to_write

	strcmp_const "`"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.com:
	;
	inc dword [rbp-133]

	mov rsi, asm_gen_block_start
	mov rdi, r14
	mov rcx, asm_gen_block_start_len
	rep movsb
	mov r14, rdi

	mov rax, 0
	mov eax, dword [rbp-133]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14
	;

	mov rsi, sum_com
	mov rdi, r14
	mov rcx, sum_com_len
	rep movsb
	mov r14, rdi

	jmp command_finish

minus_my:
	;check stc stack len < 2
	mov rax, r15
	mov rdi, stc_my_end
	call stack_len
	cmp rax, 2
	jb .error_below

	;if a_type == INT and b_type == INT
	mov rdx, 0
	mov rsi, 1
	mov rax, qword [r15]
	cmp rax, 0
	cmove rdx, rsi

	mov rax, r15
	add rax, 8
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 0
	cmove rax, rsi

	add rax, rdx
	cmp rax, 2
	je .stc_continue_int

	;if a_type == PTR and b_type == INT
	mov rdx, 0
	mov rsi, 1

	mov rax, r15
	add rax, 8
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 1
	cmove rdx, rsi

	mov rax, r15
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 0
	cmove rax, rsi

	add rax, rdx
	cmp rax, 2
	je .stc_continue_ptr

	;if a_type == PTR and b_type == PTR
	mov rdx, 0
	mov rsi, 1

	mov rax, r15
	add rax, 8
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 1
	cmove rdx, rsi

	mov rax, r15
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 1
	cmove rax, rsi

	add rax, rdx
	cmp rax, 2
	je .stc_continue_int

	jmp .error_type

.stc_continue_int:
	add r15, 8
	mov qword [r15], 0

	jmp .stc_continue

.stc_continue_ptr:
	add r15, 8
	mov qword [r15], 1

	jmp .stc_continue

.stc_continue:
	cmp byte [rbp-100], 0
	je .com

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

.error_below:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: not enough arguments for the `-` operation"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.error_type:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: invalid argument types for `-` operation, `"
	mov rsi, rdi
	call write

	mov rdi, r15
	add rdi, 8
	mov rax, qword [rdi]
	call stc_number_to_write

	strcmp_const "` and `"
	mov rsi, rdi
	call write

	mov rax, qword [r15]
	call stc_number_to_write

	strcmp_const "`"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.com:
	;
	inc dword [rbp-133]

	mov rsi, asm_gen_block_start
	mov rdi, r14
	mov rcx, asm_gen_block_start_len
	rep movsb
	mov r14, rdi

	mov rax, 0
	mov eax, dword [rbp-133]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14
	;

	mov rsi, minus_com
	mov rdi, r14
	mov rcx, minus_com_len
	rep movsb
	mov r14, rdi

	jmp command_finish

equal_my:
	;check stc stack len < 2
	mov rax, r15
	mov rdi, stc_my_end
	call stack_len
	cmp rax, 2
	jb .error_below

	;if a_type == INT and b_type == INT
	mov rdx, 0
	mov rsi, 1
	mov rax, qword [r15]
	cmp rax, 0
	cmove rdx, rsi

	mov rax, r15
	add rax, 8
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 0
	cmove rax, rsi

	add rax, rdx
	cmp rax, 2
	je .stc_continue

	;if a_type == PTR and b_type == PTR
	mov rdx, 0
	mov rsi, 1

	mov rax, r15
	add rax, 8
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 1
	cmove rdx, rsi

	mov rax, r15
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 1
	cmove rax, rsi

	add rax, rdx
	cmp rax, 2
	je .stc_continue

	jmp .error_type

.stc_continue:
	add r15, 8
	mov qword [r15], 2

	cmp byte [rbp-100], 0
	je .com

	;save first stack
	mov rax, [r12]
	add r12, 8

	;save second stack
	mov rdi, [r12]
	add r12, 8

	mov rsi, 0
	mov rdx, 1

	;if a == b
	cmp rax, rdi
	cmove rsi, rdx

	;ret
	sub r12, 8
	mov [r12], rsi

	jmp command_finish

.error_below:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: not enough arguments for the `=` operation"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.error_type:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: invalid argument types for `=` operation, `"
	mov rsi, rdi
	call write

	mov rdi, r15
	add rdi, 8
	mov rax, qword [rdi]
	call stc_number_to_write

	strcmp_const "` and `"
	mov rsi, rdi
	call write

	mov rax, qword [r15]
	call stc_number_to_write

	strcmp_const "`"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.com:
	;
	inc dword [rbp-133]

	mov rsi, asm_gen_block_start
	mov rdi, r14
	mov rcx, asm_gen_block_start_len
	rep movsb
	mov r14, rdi

	mov rax, 0
	mov eax, dword [rbp-133]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14
	;

	mov rsi, equ_com
	mov rdi, r14
	mov rcx, equ_com_len
	rep movsb
	mov r14, rdi

	jmp command_finish

;bool strcmp(char *a, char *b, uint8_t a_len, uint8_t b_len)
;a = rax
;b = rdi
;a_len = rsi
;b_len = rdx
;ret = rax
strcmp:
	push r8

	;if a_len != b_len
	cmp rsi, rdx
	jne .false

	jmp .loop

.loop:
	;if a_len != 0 && b_len != 0
	cmp rsi, 0
	je .true

	cmp rdx, 0
	je .true

	;if a != b
	mov r8b, byte [rdi]
	cmp byte [rax], r8b
	jne .false

	;a++
	;b++
	;a_len--
	;b_len--
	inc rax
	inc rdi
	dec rsi
	dec rdx

	jmp .loop

.true:
	;ret true
	mov rax, 1
	
	pop r8
	ret

.false:
	;ret false
	mov rax, 0

	pop r8
	ret

if_my:
	;check stc stack len < 1
	mov rax, r15
	mov rdi, stc_my_end
	call stack_len
	cmp rax, 1
	jb .error_below

	;if a.type == BOOL
	mov rax, qword [r15]
	cmp rax, 2
	je .stc_continue_checks_one

	jmp .error_type

.stc_continue_checks_one:
	add r15, 8

	;stack_snapshots.push((stack, 0))
	mov rax, qword [rbp-153]
	sub rax, 8
	mov qword [rax], r15
	sub rax, 1
	mov byte [rax], 0
	mov qword [rbp-153], rax

	;DEBUG мб убрать это если это всё
	jmp .stc_continue

.stc_continue:
	cmp byte [rbp-100], 0
	je .com

	;if last if stack exists and is 2 or 3 (skip mode)
	mov rdi, qword [rbp-31]
	cmp rdi, if_stack_end
	je .no_skip
	
	mov rax, [rdi]
	cmp rax, 2
	je .push_skip
	cmp rax, 3
	je .push_skip

	jmp .no_skip

.error_below:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: not enough arguments for the if-block"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.error_type:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: invalid argument type for if-block condition. Expected `bool`, get `"
	mov rsi, rdi
	call write

	mov rdi, r15
	add rdi, 8
	mov rax, qword [rdi]
	call stc_number_to_write

	strcmp_const "`"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.com:
	;put in if stack end_ counter, end_ counter += 2, put in while stack its if
	mov rax, qword [rbp-145]
	sub rax, 8
	mov rdi, 0
	mov edi, dword [rbp-137]
	mov qword [rax], rdi
	mov qword [rbp-145], rax

	add dword [rbp-137], 2

	mov rax, qword [rbp-39]
	sub rax, 8
	mov qword [rax], 0
	mov qword [rbp-39], rax

	;
	inc dword [rbp-133]

	mov rsi, asm_gen_block_start
	mov rdi, r14
	mov rcx, asm_gen_block_start_len
	rep movsb
	mov r14, rdi

	mov rax, 0
	mov eax, dword [rbp-133]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14
	;

	mov rsi, if_com
	mov rdi, r14
	mov rcx, if_com_len
	rep movsb
	mov r14, rdi

	mov rdi, qword [rbp-145]
	mov rax, qword [rdi]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], 10
	inc r14

	mov byte [r14], 10
	inc r14

	cmp byte [rbp-22], 1
	je .macro_end

	jmp command_finish

.macro_end:
	mov rax, qword [rbp-31]
	sub rax, 8
	mov qword [rax], 7
	mov qword [rbp-31], rax

	jmp command_finish

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
	cmp byte [rbp-100], 0
	je .com

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

	jmp .check_value

.com:
	mov rsi, else_com
	mov rdi, r14
	mov rcx, else_com_len
	rep movsb
	mov r14, rdi

	mov rdi, qword [rbp-145]
	mov rax, qword [rdi]
	inc rax
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], 10
	inc r14

	mov rsi, end_com
	mov rdi, r14
	mov rcx, end_com_len
	rep movsb
	mov r14, rdi

	mov rdi, qword [rbp-145]
	mov rax, qword [rdi]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14

	mov rax, qword [rbp-145]
	inc qword [rax]
	mov qword [rbp-145], rax

	cmp byte [rbp-22], 1
	je .macro_end

	jmp command_finish

.macro_end:
	mov rax, qword [rbp-31]
	sub rax, 8
	mov qword [rax], 7
	mov qword [rbp-31], rax

	jmp command_finish

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
	mov byte [rbp-22], 0

	;pop if_stack
	add qword [rbp-31], 8

	;if back_stack == mb_end
	mov rax, qword [rbp-80]
	cmp rax, mb_end
	je .check

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

	cmp byte [rbp-100], 2
	je .set_0

	jmp command_finish

.set_0:
	mov byte [rbp-100], 0

	jmp command_finish

.check:
	cmp byte [rbp-100], 2
	je .set_0

	jmp command_finish

end_my:
	mov rax, qword [rbp-31]
	cmp rax, if_stack_end
	je .error_below_ifstack

	;if stc_save was be called by if
	mov rax, qword [rbp-153]
	cmp byte [rax], 0
	je .stc_if

	jmp .stc_continue

.stc_if:
	mov rax, qword [rbp-153]
	inc rax
	cmp qword [rax], r15
	jne .error_stcsave

	jmp .stc_continue

.error_stcsave:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: else-less if block is not allowed to alter the types of the arguments on the data stack"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.stc_continue:
	add qword [rbp-153], 9

	;if last if stack value == 6
	mov rax, qword [rbp-31]
	cmp qword [rax], 6
	je end_macro

	cmp byte [rbp-100], 0
	je .com

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

	;remove last if stack value
	add qword [rbp-31], 8

	jmp command_finish

.error_below_ifstack:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: unexpected `end`, no matching block to close"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.com:
	mov rax, qword [rbp-39]
	mov rdi, qword [rax]
	cmp rdi, 0
	je .if

	cmp rdi, 1
	je .while

	cmp byte [rbp-22], 1
	je .macro_end

	jmp command_finish

.while:
	mov rsi, endwhile_com
	mov rcx, endwhile_com_len
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov rdi, qword [rbp-145]
	mov rax, qword [rdi]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], 10
	inc r14

	mov rsi, while_com
	mov rcx, while_com_len
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov rdi, qword [rbp-145]
	mov rax, qword [rdi]
	inc rax
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14

	add qword [rbp-145], 8
	add qword [rbp-39], 8

	cmp byte [rbp-22], 1
	je .macro_end

	jmp command_finish

.if:
	mov rsi, end_com
	mov rdi, r14
	mov rcx, end_com_len
	rep movsb
	mov r14, rdi

	mov rdi, qword [rbp-145]
	mov rax, qword [rdi]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14

	add qword [rbp-145], 8
	add qword [rbp-39], 8

	cmp byte [rbp-22], 1
	je .macro_end

	jmp command_finish

.macro_end:
	add qword [rbp-31], 8

	jmp command_finish

dup_my:
	;check stc stack len < 1
	mov rax, r15
	mov rdi, stc_my_end
	call stack_len
	cmp rax, 1
	jb .error_below

	mov rax, qword [r15]
	sub r15, 8
	mov qword [r15], rax

	cmp byte [rbp-100], 0
	je .com

	;get but no remove last mlv
	mov rax, [r12]

	;push in mlv
	sub r12, 8
	mov [r12], rax

	jmp command_finish

.error_below:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: not enough arguments for the `dup` instruction"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.com:
	;
	inc dword [rbp-133]

	mov rsi, asm_gen_block_start
	mov rdi, r14
	mov rcx, asm_gen_block_start_len
	rep movsb
	mov r14, rdi

	mov rax, 0
	mov eax, dword [rbp-133]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14
	;

	mov rsi, dup_com
	mov rdi, r14
	mov rcx, dup_com_len
	rep movsb
	mov r14, rdi

	jmp command_finish

two_dup_my:
	;check stc stack len < 2
	mov rax, r15
	mov rdi, stc_my_end
	call stack_len
	cmp rax, 2
	jb .error_below

	mov rax, r15
	mov rsi, qword [rax]
	add rax, 8
	mov rdx, qword [rax]

	sub r15, 8
	mov qword [r15], rdx

	sub r15, 8
	mov qword [r15], rsi

	cmp byte [rbp-100], 0
	je .com

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

.error_below:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: not enough arguments for the `2dup` instruction"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.com:
	;
	inc dword [rbp-133]

	mov rsi, asm_gen_block_start
	mov rdi, r14
	mov rcx, asm_gen_block_start_len
	rep movsb
	mov r14, rdi

	mov rax, 0
	mov eax, dword [rbp-133]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14
	;

	mov rsi, twodup_com
	mov rdi, r14
	mov rcx, twodup_com_len
	rep movsb
	mov r14, rdi

	jmp command_finish

not_equal_my:
	;check stc stack len < 2
	mov rax, r15
	mov rdi, stc_my_end
	call stack_len
	cmp rax, 2
	jb .error_below

	;if a_type == INT and b_type == INT
	mov rdx, 0
	mov rsi, 1
	mov rax, qword [r15]
	cmp rax, 0
	cmove rdx, rsi

	mov rax, r15
	add rax, 8
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 0
	cmove rax, rsi

	add rax, rdx
	cmp rax, 2
	je .stc_continue

	;if a_type == PTR and b_type == PTR
	mov rdx, 0
	mov rsi, 1

	mov rax, r15
	add rax, 8
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 1
	cmove rdx, rsi

	mov rax, r15
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 1
	cmove rax, rsi

	add rax, rdx
	cmp rax, 2
	je .stc_continue

	jmp .error_type

.stc_continue:
	add r15, 8
	mov qword [r15], 2

	cmp byte [rbp-100], 0
	je .com

	;save first stack
	mov rax, [r12]
	add r12, 8

	;save second stack
	mov rdi, [r12]
	add r12, 8

	mov rsi, 0
	mov rdx, 1

	;if a != b
	cmp rax, rdi
	cmovne rsi, rdx

	;ret
	sub r12, 8
	mov [r12], rsi

	jmp command_finish

.error_below:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: not enough arguments for the `!=` operation"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.error_type:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: invalid argument types for `!=` operation, `"
	mov rsi, rdi
	call write

	mov rdi, r15
	add rdi, 8
	mov rax, qword [rdi]
	call stc_number_to_write

	strcmp_const "` and `"
	mov rsi, rdi
	call write

	mov rax, qword [r15]
	call stc_number_to_write

	strcmp_const "`"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.com:
	;
	inc dword [rbp-133]

	mov rsi, asm_gen_block_start
	mov rdi, r14
	mov rcx, asm_gen_block_start_len
	rep movsb
	mov r14, rdi

	mov rax, 0
	mov eax, dword [rbp-133]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14
	;

	mov rsi, notequ_com
	mov rdi, r14
	mov rcx, notequ_com_len
	rep movsb
	mov r14, rdi

	jmp command_finish

above_my:
	;check stc stack len < 2
	mov rax, r15
	mov rdi, stc_my_end
	call stack_len
	cmp rax, 2
	jb .error_below

	;if a_type == INT and b_type == INT
	mov rdx, 0
	mov rsi, 1
	mov rax, qword [r15]
	cmp rax, 0
	cmove rdx, rsi

	mov rax, r15
	add rax, 8
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 0
	cmove rax, rsi

	add rax, rdx
	cmp rax, 2
	je .stc_continue

	;if a_type == PTR and b_type == PTR
	mov rdx, 0
	mov rsi, 1

	mov rax, r15
	add rax, 8
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 1
	cmove rdx, rsi

	mov rax, r15
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 1
	cmove rax, rsi

	add rax, rdx
	cmp rax, 2
	je .stc_continue

	jmp .error_type

.stc_continue:
	add r15, 8
	mov qword [r15], 2

	cmp byte [rbp-100], 0
	je .com

	;save first stack
	mov rax, [r12]
	add r12, 8

	;save second stack
	mov rdi, [r12]
	add r12, 8

	mov rsi, 0
	mov rdx, 1

	;if a > b
	cmp rdi, rax
	cmova rsi, rdx

	;ret false
	sub r12, 8
	mov [r12], rsi

	jmp command_finish

.error_below:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: not enough arguments for the `>` operation"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.error_type:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: invalid argument types for `>` operation, `"
	mov rsi, rdi
	call write

	mov rdi, r15
	add rdi, 8
	mov rax, qword [rdi]
	call stc_number_to_write

	strcmp_const "` and `"
	mov rsi, rdi
	call write

	mov rax, qword [r15]
	call stc_number_to_write

	strcmp_const "`"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.com:
	;
	inc dword [rbp-133]

	mov rsi, asm_gen_block_start
	mov rdi, r14
	mov rcx, asm_gen_block_start_len
	rep movsb
	mov r14, rdi

	mov rax, 0
	mov eax, dword [rbp-133]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14
	;

	mov rsi, above_com
	mov rdi, r14
	mov rcx, above_com_len
	rep movsb
	mov r14, rdi

	jmp command_finish

below_my:
	;check stc stack len < 2
	mov rax, r15
	mov rdi, stc_my_end
	call stack_len
	cmp rax, 2
	jb .error_below

	;if a_type == INT and b_type == INT
	mov rdx, 0
	mov rsi, 1
	mov rax, qword [r15]
	cmp rax, 0
	cmove rdx, rsi

	mov rax, r15
	add rax, 8
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 0
	cmove rax, rsi

	add rax, rdx
	cmp rax, 2
	je .stc_continue

	;if a_type == PTR and b_type == PTR
	mov rdx, 0
	mov rsi, 1

	mov rax, r15
	add rax, 8
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 1
	cmove rdx, rsi

	mov rax, r15
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 1
	cmove rax, rsi

	add rax, rdx
	cmp rax, 2
	je .stc_continue

	jmp .error_type

.stc_continue:
	add r15, 8
	mov qword [r15], 2

	cmp byte [rbp-100], 0
	je .com

	;save first stack
	mov rax, [r12]
	add r12, 8

	;save second stack
	mov rdi, [r12]
	add r12, 8

	mov rsi, 0
	mov rdx, 1

	;if a < b
	cmp rdi, rax
	cmovb rsi, rdx

	;ret false
	sub r12, 8
	mov [r12], rsi

	jmp command_finish

.error_below:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: not enough arguments for the `<` operation"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.error_type:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: invalid argument types for `<` operation, `"
	mov rsi, rdi
	call write

	mov rdi, r15
	add rdi, 8
	mov rax, qword [rdi]
	call stc_number_to_write

	strcmp_const "` and `"
	mov rsi, rdi
	call write

	mov rax, qword [r15]
	call stc_number_to_write

	strcmp_const "`"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.com:
	;
	inc dword [rbp-133]

	mov rsi, asm_gen_block_start
	mov rdi, r14
	mov rcx, asm_gen_block_start_len
	rep movsb
	mov r14, rdi

	mov rax, 0
	mov eax, dword [rbp-133]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14
	;

	mov rsi, below_com
	mov rdi, r14
	mov rcx, below_com_len
	rep movsb
	mov r14, rdi

	jmp command_finish

above_equal_my:
	;check stc stack len < 2
	mov rax, r15
	mov rdi, stc_my_end
	call stack_len
	cmp rax, 2
	jb .error_below

	;if a_type == INT and b_type == INT
	mov rdx, 0
	mov rsi, 1
	mov rax, qword [r15]
	cmp rax, 0
	cmove rdx, rsi

	mov rax, r15
	add rax, 8
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 0
	cmove rax, rsi

	add rax, rdx
	cmp rax, 2
	je .stc_continue

	;if a_type == PTR and b_type == PTR
	mov rdx, 0
	mov rsi, 1

	mov rax, r15
	add rax, 8
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 1
	cmove rdx, rsi

	mov rax, r15
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 1
	cmove rax, rsi

	add rax, rdx
	cmp rax, 2
	je .stc_continue

	jmp .error_type

.stc_continue:
	add r15, 8
	mov qword [r15], 2

	cmp byte [rbp-100], 0
	je .com

	;save first stack
	mov rax, [r12]
	add r12, 8

	;save second stack
	mov rdi, [r12]
	add r12, 8

	mov rsi, 0
	mov rdx, 1

	;if a >= b
	cmp rdi, rax
	cmovae rsi, rdx

	;ret false
	sub r12, 8
	mov [r12], rsi

	jmp command_finish

.error_below:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: not enough arguments for the `>=` operation"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.error_type:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: invalid argument types for `>=` operation, `"
	mov rsi, rdi
	call write

	mov rdi, r15
	add rdi, 8
	mov rax, qword [rdi]
	call stc_number_to_write

	strcmp_const "` and `"
	mov rsi, rdi
	call write

	mov rax, qword [r15]
	call stc_number_to_write

	strcmp_const "`"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.com:
	;
	inc dword [rbp-133]

	mov rsi, asm_gen_block_start
	mov rdi, r14
	mov rcx, asm_gen_block_start_len
	rep movsb
	mov r14, rdi

	mov rax, 0
	mov eax, dword [rbp-133]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14
	;

	mov rsi, aboveequ_com
	mov rdi, r14
	mov rcx, aboveequ_com_len
	rep movsb
	mov r14, rdi

	jmp command_finish

below_equal_my:
	;check stc stack len < 2
	mov rax, r15
	mov rdi, stc_my_end
	call stack_len
	cmp rax, 2
	jb .error_below

	;if a_type == INT and b_type == INT
	mov rdx, 0
	mov rsi, 1
	mov rax, qword [r15]
	cmp rax, 0
	cmove rdx, rsi

	mov rax, r15
	add rax, 8
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 0
	cmove rax, rsi

	add rax, rdx
	cmp rax, 2
	je .stc_continue

	;if a_type == PTR and b_type == PTR
	mov rdx, 0
	mov rsi, 1

	mov rax, r15
	add rax, 8
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 1
	cmove rdx, rsi

	mov rax, r15
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 1
	cmove rax, rsi

	add rax, rdx
	cmp rax, 2
	je .stc_continue

	jmp .error_type

.stc_continue:
	add r15, 8
	mov qword [r15], 2

	cmp byte [rbp-100], 0
	je .com

	;save first stack
	mov rax, [r12]
	add r12, 8

	;save second stack
	mov rdi, [r12]
	add r12, 8

	mov rsi, 0
	mov rdx, 1

	;if a <= b
	cmp rdi, rax
	cmovbe rsi, rdx

	;ret false
	sub r12, 8
	mov [r12], rsi

	jmp command_finish

.error_below:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: not enough arguments for the `<=` operation"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.error_type:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: invalid argument types for `<=` operation, `"
	mov rsi, rdi
	call write

	mov rdi, r15
	add rdi, 8
	mov rax, qword [rdi]
	call stc_number_to_write

	strcmp_const "` and `"
	mov rsi, rdi
	call write

	mov rax, qword [r15]
	call stc_number_to_write

	strcmp_const "`"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.com:
	;
	inc dword [rbp-133]

	mov rsi, asm_gen_block_start
	mov rdi, r14
	mov rcx, asm_gen_block_start_len
	rep movsb
	mov r14, rdi

	mov rax, 0
	mov eax, dword [rbp-133]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14
	;

	mov rsi, belowequ_com
	mov rdi, r14
	mov rcx, belowequ_com_len
	rep movsb
	mov r14, rdi

	jmp command_finish

while_my:
	cmp byte [rbp-100], 0
	je .com

	;if skip mode, push skip marker without while stack
	mov rdi, qword [rbp-31]
	cmp rdi, if_stack_end
	je .no_skip_init

	mov rax, [rdi]
	cmp rax, 2
	je .push_skip
	cmp rax, 3
	je .push_skip

	jmp .no_skip_init

.com:
	mov rsi, while_com
	mov rcx, while_com_len
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov rax, qword [rbp-47]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14

	mov rdi, qword [rbp-47]
	mov rax, qword [rbp-145]
	sub rax, 8
	mov qword [rax], rdi
	mov qword [rbp-145], rax

	mov rax, qword [rbp-39]
	sub rax, 8
	mov qword [rax], 1
	mov qword [rbp-39], rax

	add qword [rbp-47], 2

	cmp byte [rbp-22], 1
	je .macro_end

	jmp command_finish

.macro_end:
	mov rax, qword [rbp-31]
	sub rax, 8
	mov qword [rax], 7
	mov qword [rbp-31], rax

	jmp command_finish

.no_skip_init:
	;check if we already have this address in while_stack
	mov rdi, qword [rbp-39]
	cmp rdi, while_stack_end
	je .push_new

	mov rax, [rdi]
	cmp rax, qword [rbp-8]
	je .only_push_if_stack

	jmp .push_new

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

	jmp .only_push_if_stack

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
	mov qword [rax], 7
	mov qword [rbp-31], rax
	jmp command_finish

do_my:
	cmp byte [rbp-100], 0
	je .com

	;check last if stack
	mov rax, qword [rbp-31]
	cmp rax, if_stack_end
	je command_finish

	cmp qword [rax], 4
	je .do_while

	jmp command_finish

.error_type:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: `do` instruction expects `bool` argument"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.error_below:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: not enough arguments for the `do` instruction"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.com:
	;
	inc dword [rbp-133]

	mov rsi, asm_gen_block_start
	mov rdi, r14
	mov rcx, asm_gen_block_start_len
	rep movsb
	mov r14, rdi

	mov rax, 0
	mov eax, dword [rbp-133]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14
	;

	mov rsi, do_com
	mov rcx, do_com_len
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov rdi, qword [rbp-145]
	mov rax, qword [rdi]
	inc rax
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], 10
	inc r14

	mov byte [r14], 10
	inc r14

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
	sub r15, 8
	mov qword [r15], 1

	cmp byte [rbp-100], 0
	je .com

	mov rax, mfu
	sub r12, 8
	mov [r12], rax

	jmp command_finish

.com:
	;
	inc dword [rbp-133]

	mov rsi, asm_gen_block_start
	mov rdi, r14
	mov rcx, asm_gen_block_start_len
	rep movsb
	mov r14, rdi

	mov rax, 0
	mov eax, dword [rbp-133]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14
	;

	mov rsi, mem_com
	mov rdi, r14
	mov rcx, mem_com_len
	rep movsb
	mov r14, rdi

	jmp command_finish

mems_my:
	sub r15, 8
	mov qword [r15], 1

	cmp byte [rbp-100], 0
	je .com

	mov rax, mfus
	sub r12, 8
	mov [r12], rax

	jmp command_finish

.com:
	;
	inc dword [rbp-133]

	mov rsi, asm_gen_block_start
	mov rdi, r14
	mov rcx, asm_gen_block_start_len
	rep movsb
	mov r14, rdi

	mov rax, 0
	mov eax, dword [rbp-133]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14
	;

	mov rsi, mems_com
	mov rdi, r14
	mov rcx, mems_com_len
	rep movsb
	mov r14, rdi

	jmp command_finish

mems_free_my:
	sub r15, 8
	mov qword [r15], 1

	cmp byte [rbp-100], 0
	je .com

	mov rax, r13
	sub r12, 8
	mov [r12], rax

	jmp command_finish

.com:
	;
	inc dword [rbp-133]

	mov rsi, asm_gen_block_start
	mov rdi, r14
	mov rcx, asm_gen_block_start_len
	rep movsb
	mov r14, rdi

	mov rax, 0
	mov eax, dword [rbp-133]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14
	;

	mov rsi, memsfree_com
	mov rdi, r14
	mov rcx, memsfree_com_len
	rep movsb
	mov r14, rdi

	jmp command_finish

load_my:
	;check stc stack len < 1
	mov rax, r15
	mov rdi, stc_my_end
	call stack_len
	cmp rax, 1
	jb .error_below

	;if a.type == PTR
	mov rax, qword [r15]
	cmp rax, 1
	jne .error_type

	mov qword [r15], 0 ;ASDASDSADJASHDJ DEBUG DEBUG NADO KAKA SKIBIDI XZ CHTO LOZHIT

	cmp byte [rbp-100], 0
	je .com

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

.error_below:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: not enough arguments for the `,` instruction"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.error_type:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: invalid argument types for `,` instruction, `"
	mov rsi, rdi
	call write

	mov rax, qword [r15]
	call stc_number_to_write

	strcmp_const "`"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.com:
	;
	inc dword [rbp-133]

	mov rsi, asm_gen_block_start
	mov rdi, r14
	mov rcx, asm_gen_block_start_len
	rep movsb
	mov r14, rdi

	mov rax, 0
	mov eax, dword [rbp-133]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14
	;

	mov rsi, load_com
	mov rdi, r14
	mov rcx, load_com_len
	rep movsb
	mov r14, rdi

	jmp command_finish

store_my:
	;check stc stack len < 2
	mov rax, r15
	mov rdi, stc_my_end
	call stack_len
	cmp rax, 2
	jb .error_below

	;if a_type == PTR and b_type == INT
	mov rdx, 0
	mov rsi, 1

	mov rax, r15
	add rax, 8
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 1
	cmove rdx, rsi

	mov rax, r15
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 0
	cmove rax, rsi

	add rax, rdx
	cmp rax, 2
	je .stc_continue

	;if a_type == PTR and b_type == PTR
	mov rdx, 0
	mov rsi, 1

	mov rax, r15
	add rax, 8
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 1
	cmove rdx, rsi

	mov rax, r15
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 1
	cmove rax, rsi

	add rax, rdx
	cmp rax, 2
	je .stc_continue

	;if a_type == PTR and b_type == BOOL
	mov rdx, 0
	mov rsi, 1

	mov rax, r15
	add rax, 8
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 1
	cmove rdx, rsi

	mov rax, r15
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 2
	cmove rax, rsi

	add rax, rdx
	cmp rax, 2
	je .stc_continue

	jmp .error_type

.stc_continue:
	add r15, 16

	cmp byte [rbp-100], 0
	je .com

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

.error_below:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: not enough arguments for the `.` instruction"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.error_type:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: invalid argument types for `.` instruction, `"
	mov rsi, rdi
	call write

	mov rdi, r15
	add rdi, 8
	mov rax, qword [rdi]
	call stc_number_to_write

	strcmp_const "` and `"
	mov rsi, rdi
	call write

	mov rax, qword [r15]
	call stc_number_to_write

	strcmp_const "`"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.com:
	;
	inc dword [rbp-133]

	mov rsi, asm_gen_block_start
	mov rdi, r14
	mov rcx, asm_gen_block_start_len
	rep movsb
	mov r14, rdi

	mov rax, 0
	mov eax, dword [rbp-133]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14
	;

	mov rsi, store_com
	mov rdi, r14
	mov rcx, store_com_len
	rep movsb
	mov r14, rdi

	jmp command_finish

syscall_one:
	;check stc stack len < 2
	mov rax, r15
	mov rdi, stc_my_end
	call stack_len
	cmp rax, 2
	jb .error_below

	add r15, 8
	mov qword [r15], 0

	cmp byte [rbp-100], 0
	je .com

	mov rax, qword [r12]
	add r12, 8

	mov rdi, qword [r12]
	syscall

	mov qword [r12], rax

	jmp command_finish

.error_below:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: not enough arguments for the `syscall1` instruction"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.com:
	;
	inc dword [rbp-133]

	mov rsi, asm_gen_block_start
	mov rdi, r14
	mov rcx, asm_gen_block_start_len
	rep movsb
	mov r14, rdi

	mov rax, 0
	mov eax, dword [rbp-133]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14
	;

	mov rsi, syscall_one_com
	mov rcx, syscall_one_com_len
	mov rdi, r14
	rep movsb
	mov r14, rdi

	jmp command_finish

syscall_two:
	;check stc stack len < 3
	mov rax, r15
	mov rdi, stc_my_end
	call stack_len
	cmp rax, 3
	jb .error_below

	add r15, 8
	add r15, 8
	mov qword [r15], 0

	cmp byte [rbp-100], 0
	je .com

	mov rax, qword [r12]
	add r12, 8

	mov rsi, qword [r12]
	add r12, 8

	mov rdi, qword [r12]
	syscall

	mov qword [r12], rax

	jmp command_finish

.error_below:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: not enough arguments for the `syscall2` instruction"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.com:
	;
	inc dword [rbp-133]

	mov rsi, asm_gen_block_start
	mov rdi, r14
	mov rcx, asm_gen_block_start_len
	rep movsb
	mov r14, rdi

	mov rax, 0
	mov eax, dword [rbp-133]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14
	;

	mov rsi, syscall_two_com
	mov rcx, syscall_two_com_len
	mov rdi, r14
	rep movsb
	mov r14, rdi

	jmp command_finish

syscall_three:
	;check stc stack len < 4
	mov rax, r15
	mov rdi, stc_my_end
	call stack_len
	cmp rax, 4
	jb .error_below

	add r15, 8
	add r15, 8
	add r15, 8
	mov qword [r15], 0

	cmp byte [rbp-100], 0
	je .com

	mov rax, qword [r12]
	add r12, 8

	mov rdx, qword [r12]
	add r12, 8

	mov rsi, qword [r12]
	add r12, 8

	mov rdi, qword [r12]
	syscall

	mov qword [r12], rax

	jmp command_finish

.error_below:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: not enough arguments for the `syscall3` instruction"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.com:
	;
	inc dword [rbp-133]

	mov rsi, asm_gen_block_start
	mov rdi, r14
	mov rcx, asm_gen_block_start_len
	rep movsb
	mov r14, rdi

	mov rax, 0
	mov eax, dword [rbp-133]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14
	;

	mov rsi, syscall_three_com
	mov rcx, syscall_three_com_len
	mov rdi, r14
	rep movsb
	mov r14, rdi

	jmp command_finish

syscall_four:
	;check stc stack len < 5
	mov rax, r15
	mov rdi, stc_my_end
	call stack_len
	cmp rax, 5
	jb .error_below

	add r15, 8
	add r15, 8
	add r15, 8
	add r15, 8
	mov qword [r15], 0

	cmp byte [rbp-100], 0
	je .com

	mov rax, qword [r12]
	add r12, 8

	mov r10, qword [r12]
	add r12, 8

	mov rdx, qword [r12]
	add r12, 8

	mov rsi, qword [r12]
	add r12, 8

	mov rdi, qword [r12]
	syscall

	mov qword [r12], rax

	jmp command_finish

.error_below:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: not enough arguments for the `syscall4` instruction"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.com:
	;
	inc dword [rbp-133]

	mov rsi, asm_gen_block_start
	mov rdi, r14
	mov rcx, asm_gen_block_start_len
	rep movsb
	mov r14, rdi

	mov rax, 0
	mov eax, dword [rbp-133]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14
	;

	mov rsi, syscall_four_com
	mov rcx, syscall_four_com_len
	mov rdi, r14
	rep movsb
	mov r14, rdi

	jmp command_finish

syscall_five:
	;check stc stack len < 6
	mov rax, r15
	mov rdi, stc_my_end
	call stack_len
	cmp rax, 6
	jb .error_below

	add r15, 8
	add r15, 8
	add r15, 8
	add r15, 8
	add r15, 8
	mov qword [r15], 0

	cmp byte [rbp-100], 0
	je .com

	mov rax, qword [r12]
	add r12, 8

	mov r8, qword [r12]
	add r12, 8

	mov r10, qword [r12]
	add r12, 8

	mov rdx, qword [r12]
	add r12, 8

	mov rsi, qword [r12]
	add r12, 8

	mov rdi, qword [r12]
	syscall

	mov qword [r12], rax

	jmp command_finish

.error_below:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: not enough arguments for the `syscall5` instruction"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.com:
	;
	inc dword [rbp-133]

	mov rsi, asm_gen_block_start
	mov rdi, r14
	mov rcx, asm_gen_block_start_len
	rep movsb
	mov r14, rdi

	mov rax, 0
	mov eax, dword [rbp-133]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14
	;

	mov rsi, syscall_five_com
	mov rcx, syscall_five_com_len
	mov rdi, r14
	rep movsb
	mov r14, rdi

	jmp command_finish

syscall_six:
	;check stc stack len < 7
	mov rax, r15
	mov rdi, stc_my_end
	call stack_len
	cmp rax, 7
	jb .error_below

	add r15, 8
	add r15, 8
	add r15, 8
	add r15, 8
	add r15, 8
	add r15, 8
	mov qword [r15], 0

	cmp byte [rbp-100], 0
	je .com

	mov rax, qword [r12]
	add r12, 8

	mov r9, qword [r12]
	add r12, 8

	mov r8, qword [r12]
	add r12, 8

	mov r10, qword [r12]
	add r12, 8

	mov rdx, qword [r12]
	add r12, 8

	mov rsi, qword [r12]
	add r12, 8

	mov rdi, qword [r12]
	syscall

	mov qword [r12], rax

	jmp command_finish

.error_below:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: not enough arguments for the `syscall6` instruction"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.com:
	;
	inc dword [rbp-133]

	mov rsi, asm_gen_block_start
	mov rdi, r14
	mov rcx, asm_gen_block_start_len
	rep movsb
	mov r14, rdi

	mov rax, 0
	mov eax, dword [rbp-133]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14
	;

	mov rsi, syscall_six_com
	mov rcx, syscall_six_com_len
	mov rdi, r14
	rep movsb
	mov r14, rdi

	jmp command_finish

drop_my:
	;check stc stack len < 1
	mov rax, r15
	mov rdi, stc_my_end
	call stack_len
	cmp rax, 1
	jb .error_below

	add r15, 8

	cmp byte [rbp-100], 0
	je .com

	;pop mlv
	add r12, 8

	jmp command_finish

.error_below:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: not enough arguments for the `drop` instruction"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.com:
	;
	inc dword [rbp-133]

	mov rsi, asm_gen_block_start
	mov rdi, r14
	mov rcx, asm_gen_block_start_len
	rep movsb
	mov r14, rdi

	mov rax, 0
	mov eax, dword [rbp-133]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14
	;

	mov rsi, drop_com
	mov rdi, r14
	mov rcx, drop_com_len
	rep movsb
	mov r14, rdi

	jmp command_finish

shr_my:
	;check stc stack len < 2
	mov rax, r15
	mov rdi, stc_my_end
	call stack_len
	cmp rax, 2
	jb .error_below

	;if a_type == INT and b_type == INT
	mov rdx, 0
	mov rsi, 1

	mov rax, r15
	add rax, 8
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 0
	cmove rdx, rsi

	mov rax, r15
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 0
	cmove rax, rsi

	add rax, rdx
	cmp rax, 2
	je .stc_continue_int

	;if a_type == PTR and b_type == INT
	mov rdx, 0
	mov rsi, 1

	mov rax, r15
	add rax, 8
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 1
	cmove rdx, rsi

	mov rax, r15
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 0
	cmove rax, rsi

	add rax, rdx
	cmp rax, 2
	je .stc_continue_ptr

	jmp .error_type

.stc_continue_int:
	add r15, 8
	mov qword [r15], 0
	
	jmp .stc_continue

.stc_continue_ptr:
	add r15, 8
	mov qword [r15], 1
	
	jmp .stc_continue

.stc_continue:
	cmp byte [rbp-100], 0
	je .com

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

.error_below:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: not enough arguments for the `shr` instruction"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.error_type:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: invalid argument types for `shr` instruction, `"
	mov rsi, rdi
	call write

	mov rdi, r15
	add rdi, 8
	mov rax, qword [rdi]
	call stc_number_to_write

	strcmp_const "` and `"
	mov rsi, rdi
	call write

	mov rax, qword [r15]
	call stc_number_to_write

	strcmp_const "`"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.com:
	;
	inc dword [rbp-133]

	mov rsi, asm_gen_block_start
	mov rdi, r14
	mov rcx, asm_gen_block_start_len
	rep movsb
	mov r14, rdi

	mov rax, 0
	mov eax, dword [rbp-133]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14
	;

	mov rsi, shr_com
	mov rdi, r14
	mov rcx, shr_com_len
	rep movsb
	mov r14, rdi

	jmp command_finish

shl_my:
	;check stc stack len < 2
	mov rax, r15
	mov rdi, stc_my_end
	call stack_len
	cmp rax, 2
	jb .error_below

	;if a_type == INT and b_type == INT
	mov rdx, 0
	mov rsi, 1

	mov rax, r15
	add rax, 8
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 0
	cmove rdx, rsi

	mov rax, r15
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 0
	cmove rax, rsi

	add rax, rdx
	cmp rax, 2
	je .stc_continue_int

	;if a_type == PTR and b_type == INT
	mov rdx, 0
	mov rsi, 1

	mov rax, r15
	add rax, 8
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 1
	cmove rdx, rsi

	mov rax, r15
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 0
	cmove rax, rsi

	add rax, rdx
	cmp rax, 2
	je .stc_continue_ptr

	jmp .error_type

.stc_continue_int:
	add r15, 8
	mov qword [r15], 0
	
	jmp .stc_continue

.stc_continue_ptr:
	add r15, 8
	mov qword [r15], 1
	
	jmp .stc_continue

.stc_continue:
	cmp byte [rbp-100], 0
	je .com

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

.error_below:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: not enough arguments for the `shl` instruction"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.error_type:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: invalid argument types for `shl` instruction, `"
	mov rsi, rdi
	call write

	mov rdi, r15
	add rdi, 8
	mov rax, qword [rdi]
	call stc_number_to_write

	strcmp_const "` and `"
	mov rsi, rdi
	call write

	mov rax, qword [r15]
	call stc_number_to_write

	strcmp_const "`"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.com:
	;
	inc dword [rbp-133]

	mov rsi, asm_gen_block_start
	mov rdi, r14
	mov rcx, asm_gen_block_start_len
	rep movsb
	mov r14, rdi

	mov rax, 0
	mov eax, dword [rbp-133]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14
	;

	mov rsi, shl_com
	mov rdi, r14
	mov rcx, shl_com_len
	rep movsb
	mov r14, rdi

	jmp command_finish

bor_my:
	;check stc stack len < 2
	mov rax, r15
	mov rdi, stc_my_end
	call stack_len
	cmp rax, 2
	jb .error_below

	;if a_type == INT and b_type == INT
	mov rdx, 0
	mov rsi, 1

	mov rax, r15
	add rax, 8
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 0
	cmove rdx, rsi

	mov rax, r15
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 0
	cmove rax, rsi

	add rax, rdx
	cmp rax, 2
	je .stc_continue_int

	;if a_type == PTR and b_type == INT
	mov rdx, 0
	mov rsi, 1

	mov rax, r15
	add rax, 8
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 1
	cmove rdx, rsi

	mov rax, r15
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 0
	cmove rax, rsi

	add rax, rdx
	cmp rax, 2
	je .stc_continue_ptr

	;if a_type == INT and b_type == PTR
	mov rdx, 0
	mov rsi, 1

	mov rax, r15
	add rax, 8
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 0
	cmove rdx, rsi

	mov rax, r15
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 1
	cmove rax, rsi

	add rax, rdx
	cmp rax, 2
	je .stc_continue_ptr

	;if a_type == PTR and b_type == PTR
	mov rdx, 0
	mov rsi, 1

	mov rax, r15
	add rax, 8
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 1
	cmove rdx, rsi

	mov rax, r15
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 1
	cmove rax, rsi

	add rax, rdx
	cmp rax, 2
	je .stc_continue_ptr

	jmp .error_type

.stc_continue_int:
	add r15, 8
	mov qword [r15], 0
	
	jmp .stc_continue

.stc_continue_ptr:
	add r15, 8
	mov qword [r15], 1
	
	jmp .stc_continue

.stc_continue:
	cmp byte [rbp-100], 0
	je .com

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

.error_below:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: not enough arguments for the `bor` instruction"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.error_type:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: invalid argument types for `bor` instruction, `"
	mov rsi, rdi
	call write

	mov rdi, r15
	add rdi, 8
	mov rax, qword [rdi]
	call stc_number_to_write

	strcmp_const "` and `"
	mov rsi, rdi
	call write

	mov rax, qword [r15]
	call stc_number_to_write

	strcmp_const "`"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.com:
	;
	inc dword [rbp-133]

	mov rsi, asm_gen_block_start
	mov rdi, r14
	mov rcx, asm_gen_block_start_len
	rep movsb
	mov r14, rdi

	mov rax, 0
	mov eax, dword [rbp-133]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14
	;

	mov rsi, bor_com
	mov rdi, r14
	mov rcx, bor_com_len
	rep movsb
	mov r14, rdi

	jmp command_finish

band_my:
	;check stc stack len < 2
	mov rax, r15
	mov rdi, stc_my_end
	call stack_len
	cmp rax, 2
	jb .error_below

	;if a_type == INT and b_type == INT
	mov rdx, 0
	mov rsi, 1

	mov rax, r15
	add rax, 8
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 0
	cmove rdx, rsi

	mov rax, r15
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 0
	cmove rax, rsi

	add rax, rdx
	cmp rax, 2
	je .stc_continue_int

	;if a_type == PTR and b_type == INT
	mov rdx, 0
	mov rsi, 1

	mov rax, r15
	add rax, 8
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 1
	cmove rdx, rsi

	mov rax, r15
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 0
	cmove rax, rsi

	add rax, rdx
	cmp rax, 2
	je .stc_continue_ptr

	;if a_type == INT and b_type == PTR
	mov rdx, 0
	mov rsi, 1

	mov rax, r15
	add rax, 8
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 0
	cmove rdx, rsi

	mov rax, r15
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 1
	cmove rax, rsi

	add rax, rdx
	cmp rax, 2
	je .stc_continue_ptr

	;if a_type == PTR and b_type == PTR
	mov rdx, 0
	mov rsi, 1

	mov rax, r15
	add rax, 8
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 1
	cmove rdx, rsi

	mov rax, r15
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 1
	cmove rax, rsi

	add rax, rdx
	cmp rax, 2
	je .stc_continue_ptr

	jmp .error_type

.stc_continue_int:
	add r15, 8
	mov qword [r15], 0
	
	jmp .stc_continue

.stc_continue_ptr:
	add r15, 8
	mov qword [r15], 1
	
	jmp .stc_continue

.stc_continue:
	cmp byte [rbp-100], 0
	je .com

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

.error_below:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: not enough arguments for the `band` instruction"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.error_type:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: invalid argument types for `band` instruction, `"
	mov rsi, rdi
	call write

	mov rdi, r15
	add rdi, 8
	mov rax, qword [rdi]
	call stc_number_to_write

	strcmp_const "` and `"
	mov rsi, rdi
	call write

	mov rax, qword [r15]
	call stc_number_to_write

	strcmp_const "`"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.com:
	;
	inc dword [rbp-133]

	mov rsi, asm_gen_block_start
	mov rdi, r14
	mov rcx, asm_gen_block_start_len
	rep movsb
	mov r14, rdi

	mov rax, 0
	mov eax, dword [rbp-133]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14
	;

	mov rsi, band_com
	mov rdi, r14
	mov rcx, band_com_len
	rep movsb
	mov r14, rdi

	jmp command_finish

swap_my:
	;check stc stack len < 2
	mov rax, r15
	mov rdi, stc_my_end
	call stack_len
	cmp rax, 2
	jb .error_below

	mov rdi, qword [r15]
	add r15, 8
	mov rax, qword [r15]
	mov qword [r15], rdi
	sub r15, 8
	mov qword [r15], rax

	cmp byte [rbp-100], 0
	je .com

	;[1, 2] [2, 1]
	mov rdi, [r12]
	add r12, 8
	mov rax, [r12]
	mov [r12], rdi
	sub r12, 8
	mov [r12], rax
	jmp command_finish

.error_below:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: not enough arguments for the `swap` instruction"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.com:
	;
	inc dword [rbp-133]

	mov rsi, asm_gen_block_start
	mov rdi, r14
	mov rcx, asm_gen_block_start_len
	rep movsb
	mov r14, rdi

	mov rax, 0
	mov eax, dword [rbp-133]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14
	;

	mov rsi, swap_com
	mov rdi, r14
	mov rcx, swap_com_len
	rep movsb
	mov r14, rdi

	jmp command_finish

over_my:
	;check stc stack len < 2
	mov rax, r15
	mov rdi, stc_my_end
	call stack_len
	cmp rax, 2
	jb .error_below

	;pop pop push push push
	mov rax, r15
	add rax, 8
	mov rdi, qword [rax]
	sub r15, 8
	mov qword [r15], rdi

	cmp byte [rbp-100], 0
	je .com

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

.error_below:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: not enough arguments for the `over` instruction"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.com:
	;
	inc dword [rbp-133]

	mov rsi, asm_gen_block_start
	mov rdi, r14
	mov rcx, asm_gen_block_start_len
	rep movsb
	mov r14, rdi

	mov rax, 0
	mov eax, dword [rbp-133]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14
	;

	mov rsi, over_com
	mov rdi, r14
	mov rcx, over_com_len
	rep movsb
	mov r14, rdi

	jmp command_finish

push_str_my:
	sub r15, 8
	mov qword [r15], 1
	
	sub r15, 8
	mov qword [r15], 0

	;remove "
	inc qword [rbp-21]
	dec byte [rbp-13]

	;save start
	mov rax, r13

	;save len
	mov rdx, 0
	mov dl, byte [rbp-13]

	cmp byte [rbp-100], 0
	je .com

	jmp .while_condition

.com:
	;
	inc dword [rbp-133]

	mov rsi, asm_gen_block_start
	mov rdi, r14
	mov rcx, asm_gen_block_start_len
	rep movsb
	mov r14, rdi

	mov rax, 0
	mov eax, dword [rbp-133]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14
	;

	mov rsi, pushstr_one_com
	mov rcx, pushstr_one_com_len
	mov rdi, r14
	rep movsb
	mov r14, rdi

	movzx r8, byte [rbp-13]

	jmp .com_condition

.com_condition:
	;if word_len != 0
	cmp byte [rbp-13], 0
	jne .com_loop

	mov rsi, pushstr_four_com
	mov rcx, pushstr_four_com_len
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov rax, r8
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], 10
	inc r14

	mov byte [r14], 10
	inc r14

	jmp command_finish

.com_loop:
	;if word[] == \
	mov rdi, qword [rbp-21]
	mov rsi, 0
	mov sil, byte [rdi]
	cmp sil, 92
	je .com_its_backside_flash

	;set mfus[] word[]
	mov rsi, pushstr_two_com
	mov rcx, pushstr_two_com_len
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov rdi, qword [rbp-21]
	movzx rax, byte [rdi]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], 10
	inc r14

	mov rsi, pushstr_three_com
	mov rcx, pushstr_three_com_len
	mov rdi, r14
	rep movsb
	mov r14, rdi

	;word++ word_len--
	inc qword [rbp-21]
	dec byte [rbp-13]

	jmp .com_condition

.com_its_backside_flash:
	mov rdi, qword [rbp-21]
	inc rdi

	;if *(word+1) == n
	cmp byte [rdi], 110
	je .com_n

	;if *(word+1) == t
	cmp byte [rdi], 116
	je .com_t

	;if *(word+1) == "
	cmp byte [rdi], 34
	je .com_q

	;if *(word+1) == 0
	cmp byte [rdi], 48
	je .com_z

	;if *(word+1) == \
	cmp byte [rdi], 92
	je .com_f

	jmp .end

.end:
	;mfus++ (word += 2) (word_len -= 2) rdx--
	mov rsi, pushstr_three_com
	mov rcx, pushstr_three_com_len
	mov rdi, r14
	rep movsb
	mov r14, rdi

	add qword [rbp-21], 2
	sub byte [rbp-13], 2
	dec r8

	jmp .com_condition

.com_f:
	;set mfus[] \
	mov rsi, pushstr_two_com
	mov rcx, pushstr_two_com_len
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov rax, 92
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], 10
	inc r14

	jmp .end

.com_n:
	;set mfus[] \n
	mov rsi, pushstr_two_com
	mov rcx, pushstr_two_com_len
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov rax, 10
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], 10
	inc r14

	jmp .end

.com_t:
	;set mfus[] \t
	mov rsi, pushstr_two_com
	mov rcx, pushstr_two_com_len
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov rax, 9
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], 10
	inc r14

	jmp .end

.com_q:
	;set mfus[] "
	mov rsi, pushstr_two_com
	mov rcx, pushstr_two_com_len
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov rax, 34
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], 10
	inc r14

	jmp .end

.com_z:
	;set mfus[] \0
	mov rsi, pushstr_two_com
	mov rcx, pushstr_two_com_len
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov rax, 0
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], 10
	inc r14

	jmp .end

.while_condition:
	;if word_len != 0
	cmp byte [rbp-13], 0
	jne .while_loop

	;push mlv start
	sub r12, 8
	mov [r12], rax

	;push mlv len
	sub r12, 8
	mov [r12], rdx

	jmp command_finish

.while_loop:
	;if word[] == \
	mov rdi, qword [rbp-21]
	mov rsi, 0
	mov sil, byte [rdi]
	cmp sil, 92
	je .its_backside_flash

	;set mfus[] word[]
	mov rdi, qword [rbp-21]
	mov rsi, 0
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

	;if *(word+1) == 0
	cmp byte [rdi], 48
	je .z

	;if *(word+1) == \
	cmp byte [rdi], 92
	je .f

	;mfus++ (word += 2) word_len-- rdx--
	inc r13
	add qword [rbp-21], 2
	dec byte [rbp-13]
	dec rdx

	jmp .while_condition

.f:
	;set mfus[] \
	mov byte [r13], 92

	;mfus++ (word += 2) word_len-- rdx--
	inc r13
	add qword [rbp-21], 2
	dec byte [rbp-13]
	dec rdx

	jmp .while_condition

.n:
	;set mfus[] \n
	mov byte [r13], 10

	;mfus++ (word += 2) word_len-- rdx--
	inc r13
	add qword [rbp-21], 2
	dec byte [rbp-13]
	dec rdx

	jmp .while_condition

.t:
	;set mfus[] \t
	mov byte [r13], 9

	;mfus++ (word += 2) word_len-- rdx--
	inc r13
	add qword [rbp-21], 2
	dec byte [rbp-13]
	dec rdx

	jmp .while_condition

.q:
	;set mfus[] "
	mov byte [r13], 34

	;mfus++ (word += 2) word_len-- rdx--
	inc r13
	add qword [rbp-21], 2
	dec byte [rbp-13]
	dec rdx

	jmp .while_condition

.z:
	;set mfus[] \0
	mov byte [r13], 0

	;mfus++ (word += 2) word_len-- rdx--
	inc r13
	add qword [rbp-21], 2
	dec byte [rbp-13]
	dec rdx

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
	mov rdi, 0
	mov edi, dword [rbp-12]
	mov qword [rax], rdi
	mov qword [rbp-97], rax

	;set macro next word my 0
	mov byte [rbp-89], 0

	cmp byte [rbp-100], 0
	je .set_2

	jmp command_finish

.set_2:
	mov byte [rbp-100], 2

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

	;if not exists
	mov   rax, qword [rbp-21]
	movzx rdi, byte [rbp-13]
	call string_to_C
	push rax
	mov rdi, rax

	mov rax, 4
	mov rsi, stat_buff
	syscall

	test rax, rax
	js .not_found

	pop rax
	call strlen_C
	call free_allocated

	;read_file
	mov rax, qword [rbp-21]
	movzx rdi, byte [rbp-13]
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

	jmp command_finish_save

.not_found:
	pop rax
	call strlen_C
	call free_allocated

	;while [rbp-117] != include_dop_end
	cmp qword [rbp-117], include_dop_end
	jne .while

	jmp .error_file

.while:
	;get string
	mov rdi, qword [rbp-117]
	mov rax, qword [rdi]
	call strlen_C
	mov rsi, qword [rbp-21]
	movzx rdx, byte [rbp-13]
	call sum_two_strings
	call string_to_C
	push rax
	mov rdi, rax

	;if not exists
	mov rax, 4
	mov rsi, stat_buff
	syscall

	test rax, rax
	js .end

	pop rax
	call strlen_C
	call free_allocated

	;open
	mov rdi, qword [rbp-117]
	mov rax, qword [rdi]
	call strlen_C
	mov rsi, qword [rbp-21]
	movzx rdx, byte [rbp-13]
	call sum_two_strings
	call read_file

	mov r8, rax
	mov r9, rdi

	;if rax == 0
	cmp rax, 0
	je .error_file

	push r8
	push r9
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

	jmp command_finish_save

.end:
	pop rax
	call strlen_C
	call free_allocated

	add qword [rbp-117], 8

	jmp .not_found

.error_file:
	strcmp_const "ERROR `include` operation: this file don't exists"
	mov rax, rdi
	mov rdi, rdx
	
	jmp exit_with_reason

multi_my:
	;check stc stack len < 2
	mov rax, r15
	mov rdi, stc_my_end
	call stack_len
	cmp rax, 2
	jb .error_below

	;if a_type == INT and b_type == INT
	mov rdx, 0
	mov rsi, 1
	mov rax, qword [r15]
	cmp rax, 0
	cmove rdx, rsi

	mov rax, r15
	add rax, 8
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 0
	cmove rax, rsi

	add rax, rdx
	cmp rax, 2
	je .stc_continue_int

	jmp .error_type

.stc_continue_int:
	add r15, 8
	mov qword [r15], 0

	jmp .stc_continue

.stc_continue:
	cmp byte [rbp-100], 0
	je .com

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

.error_below:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: not enough arguments for the `*` operation"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.error_type:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: invalid argument types for `*` operation, `"
	mov rsi, rdi
	call write

	mov rdi, r15
	add rdi, 8
	mov rax, qword [rdi]
	call stc_number_to_write

	strcmp_const "` and `"
	mov rsi, rdi
	call write

	mov rax, qword [r15]
	call stc_number_to_write

	strcmp_const "`"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.com:
	;
	inc dword [rbp-133]

	mov rsi, asm_gen_block_start
	mov rdi, r14
	mov rcx, asm_gen_block_start_len
	rep movsb
	mov r14, rdi

	mov rax, 0
	mov eax, dword [rbp-133]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14
	;

	mov rsi, multi_com
	mov rdi, r14
	mov rcx, multi_com_len
	rep movsb
	mov r14, rdi

	jmp command_finish

mod_my:
	;check stc stack len < 2
	mov rax, r15
	mov rdi, stc_my_end
	call stack_len
	cmp rax, 2
	jb .error_below

	;if a_type == INT and b_type == INT
	mov rdx, 0
	mov rsi, 1
	mov rax, qword [r15]
	cmp rax, 0
	cmove rdx, rsi

	mov rax, r15
	add rax, 8
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 0
	cmove rax, rsi

	add rax, rdx
	cmp rax, 2
	je .stc_continue_int

	;if a_type == PTR and b_type == INT
	mov rdx, 0
	mov rsi, 1

	mov rax, r15
	add rax, 8
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 1
	cmove rdx, rsi

	mov rax, r15
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 0
	cmove rax, rsi

	add rax, rdx
	cmp rax, 2
	je .stc_continue_int

	jmp .error_type

.stc_continue_int:
	add r15, 8
	mov qword [r15], 0

	jmp .stc_continue

.stc_continue:
	cmp byte [rbp-100], 0
	je .com

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

.error_below:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: not enough arguments for the `mod` operation"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.error_type:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: invalid argument types for `mod` operation, `"
	mov rsi, rdi
	call write

	mov rdi, r15
	add rdi, 8
	mov rax, qword [rdi]
	call stc_number_to_write

	strcmp_const "` and `"
	mov rsi, rdi
	call write

	mov rax, qword [r15]
	call stc_number_to_write

	strcmp_const "`"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.com:
	;
	inc dword [rbp-133]

	mov rsi, asm_gen_block_start
	mov rdi, r14
	mov rcx, asm_gen_block_start_len
	rep movsb
	mov r14, rdi

	mov rax, 0
	mov eax, dword [rbp-133]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14
	;

	mov rsi, mod_com
	mov rdi, r14
	mov rcx, mod_com_len
	rep movsb
	mov r14, rdi

	jmp command_finish

push_char_my:
	sub r15, 8
	mov qword [r15], 0

	;remove '
	;word++ word_len -= 2
	inc qword [rbp-21]
	sub byte [rbp-13], 2

	;if word_len == 0
	mov al, byte [rbp-13]
	cmp al, 0
	je command_finish

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
	mov rax, qword [rbp-21]
	mov rdi, 0
	mov dil, byte [rax]

	push rdi

	cmp byte [rbp-100], 0
	je .com

	pop rdi

	;push mlv
	sub r12, 8
	mov [r12], rdi

	jmp command_finish

.com:
	;
	inc dword [rbp-133]

	mov rsi, asm_gen_block_start
	mov rdi, r14
	mov rcx, asm_gen_block_start_len
	rep movsb
	mov r14, rdi

	mov rax, 0
	mov eax, dword [rbp-133]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14
	;

	mov rsi, pushchar_com
	mov rdi, r14
	mov rcx, pushchar_com_len
	rep movsb
	mov r14, rdi

	pop rdi
	mov rax, rdi
	call int_to_string
	
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], 10
	inc r14

	mov byte [r14], 10
	inc r14

	jmp command_finish

.n:
	mov rdi, 10

	push rdi

	cmp byte [rbp-100], 0
	je .com

	pop rdi

	;push mlv
	sub r12, 8
	mov qword [r12], rdi

	jmp command_finish

.t:
	mov rdi, 9

	push rdi

	cmp byte [rbp-100], 0
	je .com

	pop rdi

	;push mlv
	sub r12, 8
	mov qword [r12], rdi

	jmp command_finish

.q:
	mov rdi, 39

	push rdi

	cmp byte [rbp-100], 0
	je .com

	pop rdi

	;push mlv
	sub r12, 8
	mov qword [r12], rdi

	jmp command_finish

or_my:
	;check stc stack len < 2
	mov rax, r15
	mov rdi, stc_my_end
	call stack_len
	cmp rax, 2
	jb .error_below

	;if a_type == BOOL and b_type == BOOL
	mov rdx, 0
	mov rsi, 1

	mov rax, r15
	add rax, 8
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 2
	cmove rdx, rsi

	mov rax, r15
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 2
	cmove rax, rsi

	add rax, rdx
	cmp rax, 2
	je .stc_continue

	jmp .error_type

.stc_continue:
	add r15, 8
	mov qword [r15], 2

	cmp byte [rbp-100], 0
	je .com

	;pop mlv
    mov rax, [r12]
    add r12, 8

	;pop mlv
    mov rdi, [r12]
    add r12, 8

	mov rsi, 0
	mov rdx, 1

	cmp rax, 1
	cmove rsi, rdx
	cmp rdi, 1
	cmove rsi, rdx

	;push false
    sub r12, 8
    mov qword [r12], rsi

    jmp command_finish

.error_below:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: not enough arguments for the `or` operation"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.error_type:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: invalid argument types for `or` operation, `"
	mov rsi, rdi
	call write

	mov rdi, r15
	add rdi, 8
	mov rax, qword [rdi]
	call stc_number_to_write

	strcmp_const "` and `"
	mov rsi, rdi
	call write

	mov rax, qword [r15]
	call stc_number_to_write

	strcmp_const "`"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.com:
	;
	inc dword [rbp-133]

	mov rsi, asm_gen_block_start
	mov rdi, r14
	mov rcx, asm_gen_block_start_len
	rep movsb
	mov r14, rdi

	mov rax, 0
	mov eax, dword [rbp-133]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14
	;

	mov rsi, or_com
	mov rdi, r14
	mov rcx, or_com_len
	rep movsb
	mov r14, rdi

	jmp command_finish

and_my:
	;check stc stack len < 2
	mov rax, r15
	mov rdi, stc_my_end
	call stack_len
	cmp rax, 2
	jb .error_below

	;if a_type == BOOL and b_type == BOOL
	mov rdx, 0
	mov rsi, 1

	mov rax, r15
	add rax, 8
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 2
	cmove rdx, rsi

	mov rax, r15
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 2
	cmove rax, rsi

	add rax, rdx
	cmp rax, 2
	je .stc_continue

	jmp .error_type

.stc_continue:
	add r15, 8
	mov qword [r15], 2

	cmp byte[rbp-100], 0
	je .com

	push r8

	;pop mlv
    mov rax, [r12]
    add r12, 8

	;pop mlv
    mov rdi, [r12]
    add r12, 8

	mov rsi, 0
	mov rdx, 0
	mov r8, 1

	cmp rax, 1
	cmove rsi, r8
	cmp rdi, 1
	cmove rdx, r8
	add rsi, rdx
	mov rdx, 0
	cmp rsi, 2
	cmove rdx, r8

	;push mlv
    sub r12, 8
    mov qword [r12], rdx

	pop r8

    jmp command_finish

.error_below:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: not enough arguments for the `and` operation"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.error_type:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: invalid argument types for `and` operation, `"
	mov rsi, rdi
	call write

	mov rdi, r15
	add rdi, 8
	mov rax, qword [rdi]
	call stc_number_to_write

	strcmp_const "` and `"
	mov rsi, rdi
	call write

	mov rax, qword [r15]
	call stc_number_to_write

	strcmp_const "`"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.com:
	;
	inc dword [rbp-133]

	mov rsi, asm_gen_block_start
	mov rdi, r14
	mov rcx, asm_gen_block_start_len
	rep movsb
	mov r14, rdi

	mov rax, 0
	mov eax, dword [rbp-133]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14
	;

	mov rsi, and_com
	mov rdi, r14
	mov rcx, and_com_len
	rep movsb
	mov r14, rdi

	jmp command_finish

break_my:
    mov rax, qword [rbp-31]

	jmp .condition

.condition:
    cmp rax, if_stack_end
    je command_finish

    mov rdi, qword [rax]
    cmp rdi, 4
    je .found

    add rax, 8
    jmp .condition

.found:
    mov qword [rax], 3
    jmp command_finish

div_my:
	;check stc stack len < 2
	mov rax, r15
	mov rdi, stc_my_end
	call stack_len
	cmp rax, 2
	jb .error_below

	;if a_type == INT and b_type == INT
	mov rdx, 0
	mov rsi, 1
	mov rax, qword [r15]
	cmp rax, 0
	cmove rdx, rsi

	mov rax, r15
	add rax, 8
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 0
	cmove rax, rsi

	add rax, rdx
	cmp rax, 2
	je .stc_continue_int

	;if a_type == PTR and b_type == INT
	mov rdx, 0
	mov rsi, 1

	mov rax, r15
	add rax, 8
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 1
	cmove rdx, rsi

	mov rax, r15
	mov rdi, qword [rax]
	mov rax, 0
	cmp rdi, 0
	cmove rax, rsi

	add rax, rdx
	cmp rax, 2
	je .stc_continue_int

	jmp .error_type

.stc_continue_int:
	add r15, 8
	mov qword [r15], 0

	jmp .stc_continue

.stc_continue:
	cmp byte [rbp-100], 0
	je .com

	;pop mlv
	mov rdi, [r12]
	add r12, 8
	
	;pop mlv
	mov rax, [r12]
	add r12, 8

	;div
	cqo
	idiv rdi

	;push mlv
	sub r12, 8
	mov qword [r12], rax

	jmp command_finish

.error_below:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: not enough arguments for the `/` operation"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.error_type:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: invalid argument types for `/` operation, `"
	mov rsi, rdi
	call write

	mov rdi, r15
	add rdi, 8
	mov rax, qword [rdi]
	call stc_number_to_write

	strcmp_const "` and `"
	mov rsi, rdi
	call write

	mov rax, qword [r15]
	call stc_number_to_write

	strcmp_const "`"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.com:
	;
	inc dword [rbp-133]

	mov rsi, asm_gen_block_start
	mov rdi, r14
	mov rcx, asm_gen_block_start_len
	rep movsb
	mov r14, rdi

	mov rax, 0
	mov eax, dword [rbp-133]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14
	;

	mov rsi, div_com
	mov rdi, r14
	mov rcx, div_com_len
	rep movsb
	mov r14, rdi

	jmp command_finish

free_string_my:
	;check stc stack len < 1
	mov rax, r15
	mov rdi, stc_my_end
	call stack_len
	cmp rax, 1
	jb .error_below

	;if a.type == INT
	mov rax, qword [r15]
	cmp rax, 0
	jne .error_type

	add r15, 8

	cmp byte [rbp-100], 0
	je .com

	;pop mlv
	mov rax, [r12]
	add r12, 8

	;mfus - len
	sub r13, rax

	jmp command_finish

.error_below:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: not enough arguments for the `free_string` instruction"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.error_type:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: invalid argument types for `free_string` instruction, `"
	mov rsi, rdi
	call write

	mov rax, qword [r15]
	call stc_number_to_write

	strcmp_const "`"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

.com:
	;
	inc dword [rbp-133]

	mov rsi, asm_gen_block_start
	mov rdi, r14
	mov rcx, asm_gen_block_start_len
	rep movsb
	mov r14, rdi

	mov rax, 0
	mov eax, dword [rbp-133]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14
	;

	mov rsi, freestring_com
	mov rdi, r14
	mov rcx, freestring_com_len
	rep movsb
	mov r14, rdi

	jmp command_finish

argc_my:
	sub r15, 8
	mov qword [r15], 0

	cmp byte [rbp-100], 0
	je .com

	mov rdi, mlva
	mov rax, qword [rdi]

	;push mlv
	sub r12, 8
	mov qword [r12], rax

	jmp command_finish

.com:
	;
	inc dword [rbp-133]

	mov rsi, asm_gen_block_start
	mov rdi, r14
	mov rcx, asm_gen_block_start_len
	rep movsb
	mov r14, rdi

	mov rax, 0
	mov eax, dword [rbp-133]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14
	;

	mov rsi, argc_com
	mov rcx, argc_com_len
	mov rdi, r14
	rep movsb
	mov r14, rdi

	jmp command_finish

argv_my:
	sub r15, 8
	mov qword [r15], 1

	cmp byte [rbp-100], 0
	je .com

	mov rax, mlva
	add rax, 8

	;push mlv
	sub r12, 8
	mov qword [r12], rax

	jmp command_finish

.com:
	;
	inc dword [rbp-133]

	mov rsi, asm_gen_block_start
	mov rdi, r14
	mov rcx, asm_gen_block_start_len
	rep movsb
	mov r14, rdi

	mov rax, 0
	mov eax, dword [rbp-133]
	call int_to_string
	mov rsi, rax
	mov rcx, rdi
	mov rdi, r14
	rep movsb
	mov r14, rdi

	mov byte [r14], ':'
	inc r14

	mov byte [r14], 10
	inc r14
	;

	mov rsi, argv_com
	mov rcx, argv_com_len
	mov rdi, r14
	rep movsb
	mov r14, rdi

	jmp command_finish

do_command:
	;if word_len == 0
	cmp byte [rbp-13], 0
	je command_finish

	cmp byte [rbp-23], 1
	je command_finish

	cmp byte [rbp-100], 0
	je .normal_exec_com

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

	;if if stack == 5 or 7
	mov rax, qword [rbp-31]
	cmp qword [rax], 5
	je .if_stack_five
	cmp qword [rax], 7
	je .if_stack_five

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

	jmp .normal_exec

.normal_exec_com:
	;if macro next word my == 1
	cmp byte [rbp-89], 1
	je macro_save_name

	;if include next word my == 1
	cmp byte [rbp-98], 1
	je include_file_name

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

	; end
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "end"
	call strcmp
	cmp rax, 1
	je end_my

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

	jmp .normal_exec

.if_stack_five:
	; if
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "if"
	call strcmp
	cmp rax, 1
	je .if_stack_five_true

	; while
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "while"
	call strcmp
	cmp rax, 1
	je .if_stack_five_true

	jmp command_finish

.if_stack_five_true:
	;push if stack 7
	mov rax, qword [rbp-31]
	sub rax, 8
	mov qword [rax], 7
	mov qword [rbp-31], rax

	jmp command_finish

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

	; /
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "/"
	call strcmp
	cmp rax, 1
	je div_my

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

	; mems
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "mems"
	call strcmp
	cmp rax, 1
	je mems_my

	; mems_free
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "mems_free"
	call strcmp
	cmp rax, 1
	je mems_free_my

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

	; syscall1
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "syscall1"
	call strcmp
	cmp rax, 1
	je syscall_one

	; syscall2
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "syscall2"
	call strcmp
	cmp rax, 1
	je syscall_two

	; syscall3
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "syscall3"
	call strcmp
	cmp rax, 1
	je syscall_three

	; syscall4
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "syscall4"
	call strcmp
	cmp rax, 1
	je syscall_four

	; syscall5
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "syscall5"
	call strcmp
	cmp rax, 1
	je syscall_five

	; syscall6
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "syscall6"
	call strcmp
	cmp rax, 1
	je syscall_six

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

	; or
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "or"
	call strcmp
	cmp rax, 1
	je or_my

	; and
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "and"
	call strcmp
	cmp rax, 1
	je and_my

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

	; break
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "break"
	call strcmp
	cmp rax, 1
	je break_my

	; free_string
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "free_string"
	call strcmp
	cmp rax, 1
	je free_string_my

	; argc
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "argc"
	call strcmp
	cmp rax, 1
	je argc_my

	; argv
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "argv"
	call strcmp
	cmp rax, 1
	je argv_my

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
	je .error_unknown_word

	mov rax, mnl_end
	cmp rax, r9
	je .error_unknown_word

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

	mov byte [rbp-22], 1
	
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
	mov rdi, qword [rax]
	mov dword [rbp-12], edi

	jmp command_finish

.error_unknown_word:
	;1 line 5 character: ...
	call count_lines_and_characters
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " line "
	mov rsi, rdi
	call write

	call count_lines_and_characters
	mov rax, rdi
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write

	strcmp_const " character: unknown word `"
	mov rsi, rdi
	call write

	mov rsi, qword [rbp-21]
	movzx rdx, byte [rbp-13]
	call write

	strcmp_const "`"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

command_finish:
	;DEBUG
	;mov r8, r15
	;jmp .debug
	;DEBUG

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

;DEBUG
.debug:
	cmp r8, stc_my_end
	jne .while

	mov rsi, newline_character
	mov rdx, 1
	call write

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

.while:
	mov rax, qword [r8]
	add r8, 8
	
	call int_to_string
	mov rsi, rax
	mov rdx, rdi
	call write
	mov rsi, space_character
	mov rdx, 1
	call write

	jmp .debug
;DEBUG

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

	jmp go_for_line

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
	cmp rax, 1
	je comment_my

	;if word == /*
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "/*"
	call strcmp
	cmp rax, 1
	je .start_c_my

	;if word == */
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "*/"
	call strcmp
	cmp rax, 1
	je .end_c_my

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

.start_c_my:
	mov byte [rbp-23], 1

	;word=src word_len=0
	mov rax, qword [rbp-8]
	mov qword [rbp-21], rax
	mov byte [rbp-13], 1
	
	jmp go_for_line

.end_c_my:
	mov byte [rbp-23], 0

	;src++ src_len-- word=src word_len=0
	inc qword [rbp-8]
	dec dword [rbp-12]
	mov rax, qword [rbp-8]
	mov qword [rbp-21], rax
	mov byte [rbp-13], 0
	
	jmp go_for_line

go_for_line:
	;if src_len != 0
	cmp dword [rbp-12], 0
	jne go_for_line_loop

	;if word_len != 0
	cmp byte [rbp-13], 0
	jne do_command

	;check stc stack len > 0
	mov rax, r15
	mov rdi, stc_my_end
	call stack_len
	cmp rax, 0
	ja .error_above

	;exit
	jmp exit

.error_above:
	strcmp_const "unhandled data on the stack"
	mov rsi, rdi
	call write

	mov rsi, newline_character
	mov rdx, 1
	call write

	jmp exit_f

exit:
	cmp byte [rbp-100], 0
	je .add_str_my

	jmp exit_f

.add_str_my:
	mov rsi, asm_gen_end
	mov rdi, r14
	mov rcx, asm_gen_end_len
	rep movsb
	mov r14, rdi

	mov rdi, asm_standart

	mov rsi, qword [rbp-108]

	;make .asm
	;if 2 set name
	cmp byte [rbp-109], 2
	cmove rdi, rsi

    mov rax, 2
    mov rsi, 577
    mov rdx, 420
    syscall
    mov r15, rax

    mov rax, 1
    mov rdi, r15
    mov rsi, com_buff
    mov rdx, r14
    sub rdx, com_buff
    syscall

    mov rax, 3
    mov rdi, r15
    syscall

	;make .o
	cmp byte [rbp-109], 2
	je exit_f

	mov rsi, fasm_cmd
	call run_system

	mov rsi, rm_asm_cmd
	call run_system

	;make elf
	cmp byte [rbp-109], 1
	je exit_f

	mov rsi, elf_cmd
	call run_system

	mov rsi, rm_o_cmd
	call run_system

	cmp byte [rbp-119], 1
	je .run_after_execute

	jmp exit_f

.run_after_execute:
	cmp qword [rbp-108], 0
	je .r_default

	strcmp_const "./"
	mov rsi, rdi
	mov rdi, run_after_execute_cmd
	mov rcx, rdx
	rep movsb
	push rdi

	mov rax, qword [rbp-108]
	call strlen_C
	mov rsi, rax
	mov rcx, rdi
	pop rdi
	rep movsb

	mov byte [rdi], 0

	mov rsi, run_after_execute_cmd
	call run_system

	jmp exit_f

.r_default:
	strcmp_const "./output"
	mov rsi, rdi
	mov rdi, run_after_execute_cmd
	mov rcx, rdx
	rep movsb

	mov byte [rdi], 0

	mov rsi, run_after_execute_cmd
	call run_system

	jmp exit_f

exit_f:
	;free stack
	mov rsp, rbp
	pop rbp

	jmp exit_s

exit_s:
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
	jmp exit_f

;GET: rsi = string with 0
run_system:
	push r10

    push r12
    mov r12, rsi

    mov rax, 57
    syscall
    
    cmp rax, 0
    jl .fork_error
    je .child

.parent:
    mov rdi, rax
    xor rsi, rsi
    xor rdx, rdx
    xor r10, r10
    mov rax, 61
    syscall
    
    pop r12
	pop r10
    ret

.child:
    mov qword [argv_generic + 16], r12

    mov rax, 59
    mov rdi, shell_path
    mov rsi, argv_generic
    xor rdx, rdx
    syscall
    
    mov rax, 60
    mov rdi, 1
    syscall

.fork_error:
    pop r12
	pop r10
    ret

segment readable writable

;LANGUAGE VARIABLES

;my language variables
mlv rq 10000
mlv_end:

;stack for mlv arguments
mlva rq 1000

;STC

;stack for static type checking
stc_my rq 10000
stc_my_end:

;stack for (save stc_my, who save?)
stc_save rq 10000
stc_save_end:

;STC

;if stack
if_stack rb 10000
if_stack_end:

;if stack com
if_stack_com rb 10000
if_stack_com_end:

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

;this is a string with file, for compilation
com_buff rb 65536
com_buff_end:

;this is a list of strings for compilation push str my
com_strmy rq 5000
com_strmy_end:

;this is a list of len strings for compilation push str my
com_strmy_len rb 5000
com_strmy_len_end:

include_dop rq 50
include_dop_end:

stat_buff rb 144

;LANGUAGE VARIABLES
asm_gen_start db "format ELF64", 10, "public _start", 10, 10, "section '.text' executable", 10, 10, "int_to_string:", 10, "    push rbp", 10, "    mov rbp, rsp", 10, "    sub rsp, 32", 10, "    mov rcx, 10", 10, "    mov rdi, rsp", 10, "    add rdi, 31", 10, "    mov byte [rdi], 0", 10, "    dec rdi", 10, "    test rax, rax", 10, "    jnz .convert", 10, "    mov byte [rdi], '0'", 10, "    dec rdi", 10, "    jmp .done", 10, ".convert:", 10, "    xor rdx, rdx", 10, "    div rcx", 10, "    add dl, '0'", 10, "    mov [rdi], dl", 10, "    dec rdi", 10, "    test rax, rax", 10, "    jnz .convert", 10, ".done:", 10, "    inc rdi", 10, "    mov rax, rdi", 10, "    mov rsi, rsp", 10, "    add rsi, 31", 10, "    sub rsi, rdi", 10, "    mov rdi, rsi", 10, "    mov rsp, rbp", 10, "    pop rbp", 10, "    ret", 10, 10, "write:", 10, "    mov rax, 1", 10, "    mov rdi, 1", 10, "    syscall", 10, "    ret", 10, 10, "_start:", 10, "    mov r14, mems_my", 10, "    mov [args_ptr], rsp", 10, 10
asm_gen_start_len = $ - asm_gen_start
asm_gen_end db "    ;===exit===", 10, "    mov rax, 60", 10, "    mov rdi, 0", 10, "    syscall", 10, 10, "section '.bss' writable", 10, "mem_my rb 5000", 10, "mems_my rb 5000", 10, "args_ptr rq 1", 10, 10, "section '.data' writable", 10, "newline_character db 10", 10
asm_gen_end_len = $ - asm_gen_end

asm_gen_end_strmy db "str_"
asm_gen_end_strmy_len = $ - asm_gen_end_strmy
asm_gen_end_strmy2 db " db "
asm_gen_end_strmy2_len = $ - asm_gen_end_strmy2

asm_gen_block_start db "block_"
asm_gen_block_start_len = $ - asm_gen_block_start

newline_character db 10
space_character   db 32

asm_standart      db "output.asm", 0
shell_path        db "/bin/zsh", 0
zsh_flag          db "-c", 0

fasm_cmd          rb 100

elf_cmd           rb 100

rm_asm_cmd        db "rm output.asm", 0
rm_o_cmd          db "rm output.o", 0

run_after_execute_cmd rb 100

align 8
argv_generic:
    dq shell_path
    dq zsh_flag
    dq 0
    dq 0



push_com db "    ;===push_int===", 10, "    push "
push_com_len = $ - push_com

dump_com db "    ;===dump===", 10, "    pop rax", 10, "    call int_to_string", 10, "    mov rsi, rax", 10, "    mov rdx, rdi", 10, "    call write", 10, "    mov rsi, newline_character", 10, "    mov rdx, 1", 10, "    call write", 10, 10
dump_com_len = $ - dump_com
print_com db "    ;===print===", 10, "    pop rax", 10, "    call int_to_string", 10, "    mov rsi, rax", 10, "    mov rdx, rdi", 10, "    call write", 10, 10
print_com_len = $ - print_com

sum_com db "    ;===plus===", 10, "    pop rax", 10, "    pop rdi", 10, "    add rax, rdi", 10, "    push rax", 10, 10
sum_com_len = $ - sum_com
minus_com db "    ;===minus===", 10, "    pop rax", 10, "    pop rdi", 10, "    sub rdi, rax", 10, "    push rdi", 10, 10
minus_com_len = $ - minus_com
multi_com db "    ;===multi===", 10, "    pop rax", 10, "    pop rdi", 10, "    imul rax, rdi", 10, "    push rax", 10, 10
multi_com_len = $ - multi_com
mod_com db "    ;===mod===", 10, "    pop rdi", 10, "    pop rax", 10, "    xor rdx, rdx", 10, "    idiv rdi", 10, "    mov rcx, rdx", 10, "    push rcx", 10, 10
mod_com_len = $ - mod_com
div_com db "    ;===div===", 10, "    pop rdi", 10, "    pop rax", 10, "    cqo", 10, "    idiv rdi", 10, "    push rax", 10, 10
div_com_len = $ - div_com

equ_com db "    ;===equal===", 10, "    pop rax", 10, "    pop rdi", 10, "    mov rsi, 0", 10, "    mov rdx, 1", 10, "    cmp rax, rdi", 10, "    cmove rsi, rdx", 10, "    push rsi", 10, 10
equ_com_len = $ - equ_com
notequ_com db "    ;===not equal===", 10, "    pop rax", 10, "    pop rdi", 10, "    mov rsi, 0", 10, "    mov rdx, 1", 10, "    cmp rax, rdi", 10, "    cmovne rsi, rdx", 10, "    push rsi", 10, 10
notequ_com_len = $ - notequ_com
above_com db "    ;===above===", 10, "    pop rax", 10, "    pop rdi", 10, "    mov rsi, 0", 10, "    mov rdx, 1", 10, "    cmp rdi, rax", 10, "    cmova rsi, rdx", 10, "    push rsi", 10, 10
above_com_len = $ - above_com
below_com db "    ;===below===", 10, "    pop rax", 10, "    pop rdi", 10, "    mov rsi, 0", 10, "    mov rdx, 1", 10, "    cmp rdi, rax", 10, "    cmovb rsi, rdx", 10, "    push rsi", 10, 10
below_com_len = $ - below_com
aboveequ_com db "    ;===above equ===", 10, "    pop rax", 10, "    pop rdi", 10, "    mov rsi, 0", 10, "    mov rdx, 1", 10, "    cmp rdi, rax", 10, "    cmovae rsi, rdx", 10, "    push rsi", 10, 10
aboveequ_com_len = $ - aboveequ_com
belowequ_com db "    ;===below equ===", 10, "    pop rax", 10, "    pop rdi", 10, "    mov rsi, 0", 10, "    mov rdx, 1", 10, "    cmp rdi, rax", 10, "    cmovbe rsi, rdx", 10, "    push rsi", 10, 10
belowequ_com_len = $ - belowequ_com

dup_com db "    ;===dup===", 10, "    pop rax", 10, "    push rax", 10, "    push rax", 10, 10
dup_com_len = $ - dup_com
twodup_com db "    ;===2dup===", 10, "    pop rax", 10, "pop rdi", 10, "    push rdi", 10, "    push rax", 10, "    push rdi", 10, "    push rax", 10, 10
twodup_com_len = $ - twodup_com

mem_com db "    ;===mem===", 10, "    mov rax, mem_my", 10, "    push rax", 10, 10
mem_com_len = $ - mem_com
mems_com db "    ;===mems===", 10, "    mov rax, mems_my", 10, "    push rax", 10, 10
mems_com_len = $ - mems_com
memsfree_com db "    ;===mems free===", 10, "    mov rax, r14", 10, "    push rax", 10, 10
memsfree_com_len = $ - memsfree_com

store_com db "    ;===store===", 10, "    pop rax", 10, "    pop rdi", 10, "    mov sil, al", 10, "    mov byte [rdi], sil", 10, 10
store_com_len = $ - store_com
load_com db "    ;===load===", 10, "    pop rax", 10, "    mov bl, byte [rax]", 10, "    movzx rax, bl", 10, "    push rax", 10, 10
load_com_len = $ - load_com

drop_com db "    ;===drop===", 10, "    pop rax", 10, 10
drop_com_len = $ - drop_com

shr_com db "    ;===shr===", 10, "    pop rdi", 10, "    pop rax", 10, "    mov cl, dil", 10, "    shr rax, cl", 10, "    push rax", 10, 10
shr_com_len = $ - shr_com
shl_com db "    ;===shl===", 10, "    pop rdi", 10, "    pop rax", 10, "    mov cl, dil", 10, "    shl rax, cl", 10, "    push rax", 10, 10
shl_com_len = $ - shl_com

bor_com db "    ;===bor===", 10, "    pop rdi", 10, "    pop rax", 10, "    or rax, rdi", 10, "    push rax", 10, 10
bor_com_len = $ - bor_com
band_com db "    ;===band===", 10, "    pop rdi", 10, "    pop rax", 10, "    and rax, rdi", 10, "    push rax", 10, 10
band_com_len = $ - band_com

or_com db "    ;===or===", 10, "    pop rax", 10, "    pop rdi", 10, "    mov rsi, 0", 10, "    mov rdx, 1", 10, "    cmp rax, 1", 10, "    cmove rsi, rdx", 10, "    cmp rdi, 1", 10, "    cmove rsi, rdx", 10, "    push rsi", 10, 10
or_com_len = $ - or_com
and_com db "    ;===and===", 10, "    pop rax", 10, "    pop rdi", 10, "    mov rsi, 0", 10, "    mov rdx, 0", 10, "    mov r8, 1", 10, "    cmp rax, 1", 10, "    cmove rsi, r8", 10, "    cmp rdi, 1", 10, "    cmove rdx, r8", 10, "    add rsi, rdx", 10, "    mov rdx, 0", 10, "    cmp rsi, 2", 10, "    cmove rdx, r8", 10, "    push rdx", 10, 10
and_com_len = $ - and_com

swap_com db "    ;===swap===", 10, "    pop rax", 10, "    pop rdi", 10, "    push rax", 10, "    push rdi", 10, 10
swap_com_len = $ - swap_com
over_com db "    ;===over===", 10, "    pop rax", 10, "    pop rdi", 10, "    push rdi", 10, "    push rax", 10, "    push rdi", 10, 10
over_com_len = $ - over_com

freestring_com db "    ;===free string===", 10, "    pop rax", 10, "    sub r14, rax", 10, 10
freestring_com_len = $ - freestring_com

pushchar_com db "    ;===push char===", 10, "    push "
pushchar_com_len = $ - pushchar_com

pushstr_one_com db "    ;===push str===", 10, "    push r14", 10
pushstr_one_com_len = $ - pushstr_one_com
pushstr_two_com db "    mov byte [r14], "
pushstr_two_com_len = $ - pushstr_two_com
pushstr_three_com db "    inc r14", 10
pushstr_three_com_len = $ - pushstr_three_com
pushstr_four_com db "    push "
pushstr_four_com_len = $ - pushstr_four_com

syscall_one_com db "    ;===syscall1===", 10, "    pop rax", 10, "    pop rdi", 10, "    syscall", 10, "    push rax", 10, 10
syscall_one_com_len = $ - syscall_one_com
syscall_two_com db "    ;===syscall2===", 10, "    pop rax", 10, "    pop rsi", 10, "    pop rdi", 10, "    syscall", 10, "    push rax", 10, 10
syscall_two_com_len = $ - syscall_two_com
syscall_three_com db "    ;===syscall3===", 10, "    pop rax", 10, "    pop rdx", 10, "    pop rsi", 10, "    pop rdi", 10, "    syscall", 10, "    push rax", 10, 10
syscall_three_com_len = $ - syscall_three_com
syscall_four_com db "    ;===syscall4===", 10, "    pop rax", 10, "    pop r10", 10, "    pop rdx", 10, "    pop rsi", 10, "    pop rdi", 10, "    syscall", 10, "    push rax", 10, 10
syscall_four_com_len = $ - syscall_four_com
syscall_five_com db "    ;===syscall5===", 10, "    pop rax", 10, "    pop r8", 10, "    pop r10", 10, "    pop rdx", 10, "    pop rsi", 10, "    pop rdi", 10, "    syscall", 10, "    push rax", 10, 10
syscall_five_com_len = $ - syscall_five_com
syscall_six_com db "    ;===syscall6===", 10, "    pop rax", 10, "    pop r9", 10, "    pop r8", 10, "    pop r10", 10, "    pop rdx", 10, "    pop rsi", 10, "    pop rdi", 10, "    syscall", 10, "    push rax", 10, 10
syscall_six_com_len = $ - syscall_six_com

if_com db "    ;===if===", 10, "    pop rax", 10, "    test rax, rax", 10, "    jz end_"
if_com_len = $ - if_com
else_com db "    ;===else===", 10, "    jmp end_"
else_com_len = $ - else_com
end_com db "end_"
end_com_len = $ - end_com

while_com db "while_"
while_com_len = $ - while_com
do_com db "    ;===do===", 10, "    pop rax", 10, "    test rax, rax", 10, "    jz while_"
do_com_len = $ - do_com
endwhile_com db "    ;===end while===", 10, "    jmp while_"
endwhile_com_len = $ - endwhile_com

argc_com db "    ;===argc===", 10, "    mov rax, [args_ptr]", 10, "    mov rax, [rax]", 10, "    push rax", 10, 10
argc_com_len = $ - argc_com
argv_com db "    ;===argv===", 10, "    mov rax, [args_ptr]", 10, "    add rax, 8", 10, "    push rax", 10, 10
argv_com_len = $ - argv_com



;INT  = 0
;PTR  = 1
;BOOL = 2
