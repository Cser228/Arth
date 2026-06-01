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

	;malloc 48 byte
	sub rsp, 48

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
	;0 = nothing = free
	;1 = for if return true
	;2 = skip to else or end
	;3 = skip to end
	;4 = for while pull stack
	mov qword [rbp-31], if_stack_end
	;while stack
	mov qword [rbp-39], while_stack_end
	;while stack for len
	mov qword [rbp-47], while_stack_len_end

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

end_my:
	;if last if stack value == 4
	mov rax, qword [rbp-31]
	cmp qword [rax], 4
	je return_to_while

	;if last if stack value == 3
	cmp qword [rax], 3
	je end_my_while

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

	;push in if stack 4
	mov rax, qword [rbp-31]
	sub rax, 8
	mov qword [rax], 4
	mov qword [rbp-31], rax

	jmp command_finish

do_my:
	;check last if stack //FOR WHILE
	mov rax, qword [rbp-31]
	cmp qword [rax], 4
	je do_my_while

	jmp command_finish

do_my_while:
	;pop mlv stack
	mov rax, [r12]
	add r12, 8

	;if != 1
	cmp rax, 1
	jne do_my_while_end

	jmp command_finish

do_my_while_end:
	;replace last if stack into 3
	mov rax, qword [rbp-31]
	mov qword [rax], 3
	mov qword [rbp-31], rax

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

	;if last if stack is 3, skip all
	cmp rax, 3
	je command_finish

	;its_number(word_now, word_len)
	mov rax, qword [rbp-21]
	movzx rdi, byte [rbp-13]
	call its_number
	;if true
	cmp rax, 1
	je push_my

	;if word == "dump"
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "dump"
	call strcmp
	;if true
	cmp rax, 1
	je dump_my

	;if word == "+"
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "+"
	call strcmp
	;if true
	cmp rax, 1
	je plus_my

	;if word == "-"
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "-"
	call strcmp
	;if true
	cmp rax, 1
	je minus_my

	;if word == "="
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "="
	call strcmp
	;if true
	cmp rax, 1
	je equal_my

	;if word == "!="
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "!="
	call strcmp
	;if true
	cmp rax, 1
	je not_equal_my

	;if word == ">"
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const ">"
	call strcmp
	;if true
	cmp rax, 1
	je above_my

	;if word == "<"
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "<"
	call strcmp
	;if true
	cmp rax, 1
	je below_my

	;if word == ">="
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const ">="
	call strcmp
	;if true
	cmp rax, 1
	je above_equal_my

	;if word == "<="
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "<="
	call strcmp
	;if true
	cmp rax, 1
	je below_equal_my

	;if else word == "dup"
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "dup"
	call strcmp
	;if true
	cmp rax, 1
	je dup_my

	;if else word == "2dup"
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "2dup"
	call strcmp
	;if true
	cmp rax, 1
	je two_dup_my

	;if else word == "while"
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "while"
	call strcmp
	;if true
	cmp rax, 1
	je while_my

	;if else word == "do"
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "do"
	call strcmp
	;if true
	cmp rax, 1
	je do_my

	;if else word == "//"
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "//"
	call strcmp
	;if true
	cmp rax, 1
	je comment_my

	;if else word == "mem"
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "mem"
	call strcmp
	;if true
	cmp rax, 1
	je mem_my

	;if else word == "."
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "."
	call strcmp
	;if true
	cmp rax, 1
	je store_my

	;if else word == ","
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const ","
	call strcmp
	;if true
	cmp rax, 1
	je load_my

	;if else word == "syscall"
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "syscall"
	call strcmp
	;if true
	cmp rax, 1
	je syscall_my

	;if else word == "drop"
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "drop"
	call strcmp
	;if true
	cmp rax, 1
	je drop_my

	;if else word == "shr"
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "shr"
	call strcmp
	;if true
	cmp rax, 1
	je shr_my

	;if else word == "shl"
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "shl"
	call strcmp
	;if true
	cmp rax, 1
	je shl_my

	;if else word == "bor"
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "bor"
	call strcmp
	;if true
	cmp rax, 1
	je bor_my

	;if else word == "band"
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "band"
	call strcmp
	;if true
	cmp rax, 1
	je band_my

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
	;if word == //
	mov rax, qword [rbp-21]
	movzx rsi, byte [rbp-13]
	strcmp_const "//"
	call strcmp
	;if true
	cmp rax, 1
	je comment_my

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

;my language variables
mlv rb 800
mlv_end:

;100 because its 100 bytes, 1 byte = 1 flag
if_stack db 100 dup (0)
if_stack_end:

;its char **, 
while_stack rq 800
while_stack_end:

while_stack_len rd 400
while_stack_len_end:

;memory for user
mfu rb 800

newline_character db 10
