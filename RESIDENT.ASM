.186
.model tiny
.code
org 100h

start:                  cli

                        xor di, di
                        mov es, di

                        mov di, 09h * 4

                        mov ax, es:[di]
                        mov Oldosoft, ax

                        mov ax, es:[di+2]
                        mov OldoSeg, ax

                        mov es:[di], offset New09

                        push cs
                        pop ax
                        mov es:[di+2], ax

                        sti

WaitEsc:                in al, 60h
                        cmp al, 1
                        jne WaitEsc
                        
                        mov ax, 3100h
                        mov dx, offset EOP
                        shr dx, 4
                        inc dx
                        int 21h

;------------------------------------------------

New09                   proc
                        push ax di es
                        
                        mov di, 0b800h
                        mov es, di

                        mov di, (5*80 + 40) * 2
                        mov ah, 0eh
                        cld

Next:                   in al, 60h
                        stosw

                        in al, 61h
                        mov ah, al
                        or al, 80h
                        out 61h, al
                        mov al, ah
                        out 61h, al

                        mov al, 20h
                        out 20h, al

                        pop es di ax
                        iret

            db 0eah
Oldosoft    dw 0
OldoSeg     dw 0
                        endp

EOP:

end                     start