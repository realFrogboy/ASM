section .text

                global _start

_start:
                xor rdx, rdx

                mov rsi, str
                mov dh, '%'
                push POS
                call Strchr

                mov rax, [POS]
                add rax, '0' 
                mov [POS], rax
                
                mov rsi, POS
                mov rdx, 1
                mov rdi, 1	           ;file descriptor (stdout)
                mov rax, 1	           ;system call number (sys_write)
                syscall

                mov rax, 0x3c
                xor rdi, rdi
                syscall


;------------------------------------------------
;Find position of symbol in DH in string from SI
;
;Entry: SI = addr of str
;       DH = symbol
;Exit:  POS
;Note:  String should be ended by '$' 
;Destr: RAX RBX DH RDI
;------------------------------------------------
Strchr:			
                push rbp
                mov rbp, rsp

                xor rbx, rbx
                xor rax, rax
                xor rdi, rdi

@@Count:		    
                inc bx
                lodsb
                cmp al, '$'
                je  @@break
                cmp al, dh
                jne @@Count

                sub rsi, rbx
                dec bx

                mov rdi, [rbp + 16]
                mov [rdi], bx

                pop rbp
                ret 2h

@@break:		
                sub rsi, rbx
                        
                mov rdi, [rbp + 16]
                mov bx, -1
                mov [rdi], bx
                
                pop rbp
                ret 2h

section .data
POS     dw  0
str:    db  "hello %d$"
