section .text

                global _start

_start:
                push pstr
                push 'k'
                push pstr1
                push 't'
                push str
                call printf
                add rsp, 40

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

                xor rbx, rbx
                mov bl, [rsi]
                sub bl, 0x63

                mov rdx, [table + rbx*8]
                jmp rdx

putSmbl:        
                call putch
                jmp continue

char:
                call putChar
                jmp continue

string:         call putStr
                jmp continue

continue:       loop nextSmbl  

                pop rbp
                ret

;------------------------------------------------
;Insert char in CMD
;
;Entry:
; 
;Destr:
;------------------------------------------------
putch:
                push rdi
                push rsi
                push cx
                push ax

                mov rsi, rsp
                mov rax, 1
                mov rdi, 1
                mov rdx, 1
                syscall

                pop ax
                pop cx
                pop rsi
                pop rdi
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


;------------------------------------------------
;Insert char instead of '%c'
;
;Entry: RDI = number of val
; 
;Destr: AX RDX
;------------------------------------------------
putChar:
                mov al, [rbp + 16 + 8*rdi]

                call putch

                inc rsi
                dec cx

                ret


;------------------------------------------------
;Insert string instead of '%s'
;
;Entry: RDI = number of val
; 
;Destr: AX RBX CX RDX RSI
;------------------------------------------------
putStr:         
                mov rbx, [rbp + 16 + 8*rdi]

.nextSmbl:
                mov al, [rbx]
                call putch 

                inc rbx

                mov al, '$'
                cmp [rbx], al
                jne .nextSmbl

                inc rsi
                dec cx

                ret




section .data
pstr:       db  "danya$"
pstr1:      db  "clown$"
len         dw  0
str:        db  "hello %c friend --%s-- %c how %s!!$"
table:      dq  char, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, string 
 