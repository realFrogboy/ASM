.186
.model tiny
.code
locals
org 100h

;------------------------------------------------

VIDEOSEG        equ 0b800h

;------------------------------------------------

start:          

                cli
                mov ax, 2509h           ; Set new ISR 09h
                mov dx, offset New09    ; DS = CS: model tiny
                int 21h
                sti

                cli
                mov ax, 2508h
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
                push ax di es
       
                mov ax, VIDEOSEG
                mov es, ax

                mov di, (12*80 + 40) * 2
                mov ah, 1eh
                
                in al, 60h
                stosw

                cmp al, 2h
                je TurnOn08

                cmp al, 3h
                je TurnOff08

                jmp @@Skip

TurnOn08:
                call RememberVideo
                mov FLAG, 1
                jmp @@Skip

TurnOff08:
                mov FLAG, 0
                call ReturnVideo

@@Skip:          
                mov al, 20h
                out 20h, al

                pop es di ax
                iret
                endp

;------------------------------------------------

New08           proc
                push ax di es

                cmp FLAG, 1
                jne @@Skip
                
                mov ax, VIDEOSEG
                mov es, ax

                mov di, (5*80 + 40) * 2
                mov ah, 0eh
                
                in al, 60h
                stosw

@@Skip:         
                mov al, 20h
                out 20h, al

                pop es di ax
                iret
                endp

;------------------------------------------------

RememberVideo   proc
                push ax di es

                mov ax, VIDEOSEG
                mov es, ax

                mov di, (5*80 + 40) * 2

                mov ax, es:[di]
                mov Video, ax

                pop es di ax
                ret
                endp

;------------------------------------------------

ReturnVideo     proc
                push ax di es 

                mov ax, VIDEOSEG
                mov es, ax

                mov di, (5*80 + 40) * 2

                mov ax, Video
                stosw

                pop es di ax
                ret
                endp


FLAG        db  0
Video       dw  ?

EOP:
end             start
