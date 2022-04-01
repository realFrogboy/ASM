BIAS    equ 48d  


section .text

                global printfAsm

printfAsm:
                pop r14

                push r9
                push r8
                push rcx
                push rdx
                push rsi        
                push rdi

                push r14

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


                xor rbx, rbx
                mov bl, [rsi]

                cmp bl, '%'
                je putPercent


                sub bl, 0x62
                inc rdi

                mov rdx, [table + rbx*8]
                jmp rdx

putSmbl:        
                call putch
                jmp continue

char:
                call putChar
                jmp continue

string:         
                mov rbx, [rbp + 16 + 8*rdi]
                call putStr
                jmp continue

dec:            
                mov bx, 10
                call putNum
                jmp continue

oct:
                mov bx, 8
                call putNum
                jmp continue

bin:            
                mov bx, 2
                call putNum
                jmp continue

hexdec:            
                mov bx, 16
                call putNum
                jmp continue 

putPercent:     
                call putch
                
                inc rsi
                dec cx          


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
.nextSmbl:
                mov al, [rbx]
                call putch 

                inc rbx

                mov al, 0
                cmp [rbx], al
                jne .nextSmbl

                inc rsi
                dec cx

                ret


;------------------------------------------------
;Insert number instead of '%d' in the currient notation
;
;Entry: RDI = number of val
;       BX  = notation (2 8 10 16)
; 
;Destr: AX RBX CX RDX RSI
;------------------------------------------------
putNum:        
                push rcx

                mov rax, [rbp + 16 + 8*rdi]
                push rbx
                push dstr
                call itoa
                add rsp, 16

                mov rbx, dstr

                pop rcx
                call putStr

                ret


;------------------------------------------------
;Count number of symbols
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
				cmp al, 0
				jne .count

                sub rsi, rbx
				dec rbx
                mov rdi, [rbp + 16]
				mov [rdi], bx

                pop rbp
                ret

;------------------------------------------------
;Translate int to string
;
;Entry: AX = number
;       PUSH = DIGIT (2 8 10 16)
;       PUSH = addr of str
;Exit:
;Note:  Nuber should be < 65536
;Destr: AX BX CX DX
;------------------------------------------------
itoa:
                push rbp
                mov rbp, rsp
                push rdi

                mov cx, [rbp + 24]
                xor rbx, rbx        

Continue:       xor rdx, rdx

                div rcx              ; DX = AX mod CX, AX = AX div CX
                mov dl, [numTbl + rdx]

convert:                
                mov [tmp + rbx], dl     ; DX < 10 -> DL = DX 
                inc rbx

                cmp rax, 0
                jne Continue

                push rsi
                push rbx             ; save number of digit in number
                mov cx, bx          ; initialization of counter (number of digit)
                xor dx, dx
                mov rsi, [rbp + 16]


.CoupStr:       mov bx, cx
                dec bx
                mov al, [tmp + rbx]     ; takes char from temprorary str

                mov bx, dx
                mov [rsi + rbx], al      ; puts char in DI

                inc dx
                loop .CoupStr

                pop rbx

                mov al, 0
                mov [rsi + rbx], al     ; puts termination symb at the end of str

                pop rsi

                pop rdi
                pop rbp
                ret


section .data
tmp         db  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 
dstr        db  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 
pstr:       db  "danya\0"
pstr1:      db  "clown\0"
len         dw  0
str:        db  "%% %x hello %c friend %% --%s-- %c how %d, %s!!EXAPLE%%: %d, oct - %o, bin - %b, hex - %x\0"

test:       db  "Maratic lox\0"
table:      dq  bin, char, dec, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, oct, 0, 0, 0, string, 0, 0, 0, 0, hexdec 
hexTbl:     db  "A", "B", "C", "D", "E", "F"
numTbl      db "0123456789ABCDEF"
