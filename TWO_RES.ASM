.186
.model tiny
.code
org 100h

VIDEOSEG        equ 0b800h

start:          
                mov ax, 3508h
                int 21h
                mov OldSeg, es
                mov OldOff, bx

                cli
                mov ax, 2509h           ; Set new ISR 09h
                mov dx, offset New09    ; DS = CS: model tiny
                int 21h
                sti

                cli
                mov ax, 2572h
                mov dx, offset New08
                int 21h
                sti

                mov ax, 3100h           ; TSR
                mov dx, offset EOP      ; End of programm
                shr dx, 4
                inc dx
                int 21h

                mov ax, 4c00h
                int 21h

;------------------------------------------------                

New09           proc
                push ax dx di ds es
       
                push 0b800h
                pop es

                mov di, (12*80 + 40) * 2
                mov ah, 1eh
                
                in al, 60h
                stosw

                cmp al, 01fh
                je Start08

                cmp al, 33h
                je Finish08

                jmp EndInt

Start08:      
                cli
                mov ax, 2572h
                mov dx, offset New08
                int 21h
                sti

                jmp EndInt

Finish08:       
                cli
                mov ax, 2572h
                mov dx, OldOff
                mov ds, OldSeg
                int 21h
                sti


EndInt:         
                mov al, 20h
                out 20h, al

                pop es ds di dx ax
                iret
                endp

;------------------------------------------------

New08           proc
                push ax di es

                in al, 61h
                or al, 3
                out 61h, al

                mov al, 20h
                out 20h, al

                pop es di ax
                iret
                endp


OldSeg          dw 0
OldOff          dw 0

EOP:
end             start