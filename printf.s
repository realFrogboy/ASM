section .text

                global _start

_start:
                push 't'
                push str
                call printf
                add rsp, 16

                mov rsi, str	
                mov dx, [len]
                mov rdi, 1	        ;file descriptor (stdout)
                mov rax, 1	        ;system call number (sys_write)
                syscall  	        ;call kernel

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

                mov rdi, positions          ; RDI = addr positions
                xor rbx, rbx
nextPos:
                push rdi                    ; save RDI
                push rbx                    ; save RBX

                xor rdx, rdx                ; clear RDX
                mov dh, '%'                 ; smlb to find

                push pos                    ; var for position
                call Strchr                 ; pos = strchr(RSI, %)
                add rsp, 8                  ; clear stack

                pop rbx                     ; ret RBX
                pop rdi                     ; ret RDI
                
                mov cx, [pos]               ; CX = pos

                mov ax, -1                  ;
                cmp cx, ax                  ; check string for % availability 
                je @break                   ;

                add rsi, rcx                ;
                inc rsi                     ; address offset

                cmp rbx, 0
                je bxz


                push rbx                    ; save RBX

nextTerm:                                   ; 
                dec rbx                     ; 
                add cx, [rdi + rbx*2]       ;  find position from the begin of str
                                            ;  
                cmp  rbx, 0                 ; 
                jne nextTerm                ;

                pop rbx                     ; ret RBX

bxz:                
                mov [rdi + rbx*2], cx
                inc rbx

                jmp nextPos

@break:
                mov rcx, [rdi + (rbx-1)*2]
                sub rsi, rcx
                dec rsi

                jrcxz def
                

                mov rbx, [positions]

                mov dh, 'c'
                cmp [rsi + rbx + 1], dh
                je char

                jmp def

char:           
                mov dh, [rbp + 24]
                mov [rsi + rbx], dh

                mov cx, [len]
                sub cx, bx
                dec cx

                inc bx

shiftStr:          
                inc bx

                mov dh, [rsi + rbx]
                mov [rsi + rbx - 1], dh

                loop shiftStr

                mov cx, [len]
                dec cx
                mov [len], cx

def:            
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


;------------------------------------------------
;Find position of symbol in DH in string from SI
;
;Entry: RSI = addr of str
;       DH = symbol
;       PUSH addr of position param
;Exit: 
;Note:  String should be ended by '$' 
;Destr: RAX RBX DH RDI
;------------------------------------------------
Strchr:			
                push rbp
                mov rbp, rsp

                xor rbx, rbx
                xor rax, rax
                xor rdi, rdi

.count:		    
                inc rbx
                lodsb
                cmp al, '$'
                je  .break
                cmp al, dh
                jne .count

                sub rsi, rbx
                dec rbx

                mov rdi, [rbp + 16]
                mov [rdi], bx

                pop rbp
                ret

.break:		
                sub rsi, rbx
                        
                mov rdi, [rbp + 16]
                mov bx, -1
                mov [rdi], bx
                
                pop rbp
                ret

section .data
len         dw  0
str:        db  "hello %c friend$"
positions   dw  0, 0, 0, 0, 0, 0, 0, 0, 0, 0
pos         dw  0
 