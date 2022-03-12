%macro  putch 0

        mov rax, 1
        mov rdi, 1
        mov rdx, 1
        syscall

%endmacro

section .text

                global _start

_start:
                push 'k'
                push 't'
                push str
                call printf
                add rsp, 24

                mov rax, 0x3c
                xor rdi, rdi
                syscall


printf:
                push rbp
                mov rbp, rsp

                mov rsi, [rbp + 16]         ; get addr of str from stack
                push len                    ; var for lentgh
                call Strlen                 ; len = strlen(ESI)
                add rsp, 8                  ; clear stack

                mov cx, [len]
                xor rdi, rdi

nextSmbl:
                xor rax, rax
                lodsb

                cmp al, '%'
                jne putSmbl

                inc rdi

                mov al, 'c'
                cmp [rsi], al
                je char

putSmbl:        mov rbx, rsi
                push cx

                push ax

                mov rsi, rsp
                putch

                pop ax

                pop cx
                mov rsi, rbx

                jmp continue

char:
                mov rbx, rsi
                push cx

                mov ax, [rbp + 16 + 8*rdi]
                push rdi
                push ax

                mov rsi, rsp
                putch

                pop ax
                pop rdi

                pop cx
                mov rsi, rbx

                inc rsi
                dec cx

                jmp continue
continue:       loop nextSmbl       

                pop rbp
                ret
                

;------------------------------------------------
;Count number of symbolss
;
;Entry: RSI = addr of str
;       PUSH addr of length param
;Exit:  
;Note:  String should be ended by '$' 
;Destr: RAX RBX RDI
;------------------------------------------------
Strlen:	
                push rbp
                mov rbp, rsp

				xor rbx, rbx
                xor rax, rax
                xor rdi, rdi

.count:		    inc rbx
				lodsb
				cmp al, '$'
				jne .count

                sub rsi, rbx
				dec rbx
                mov rdi, [rbp + 16]
				mov [rdi], bx

                pop rbp
                ret




section .data
len         dw  0
str:        db  "hello %c friend %c how$"
 