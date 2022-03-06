.186
.model tiny
.code
org 100h

start:      mov ax, 2509h           ; Set new ISR 09h
            mov dx, offset New09    ; DS = CS: model tiny
            int 21h

            ;in al, 61h
            ;or al, 3
            ;out 61h, al

            ;in al, 61h
            ;and al, not 3
            ;out 61h, al

            mov ax, 3100h           ; TSR
            mov dx, offset EOP      ; End of programm
            shr dx, 4
            inc dx
            int 21h

            mov ax, 4c00h
            int 21h

New09       proc
            push ax di es

            push 0b800h
            pop es

            mov di, (12*80 + 40) * 2
            mov ah, 1eh

            in al, 60h
            stosw

            mov al, 0b6h
            out 43h, al
            mov al, 90h
            out 42h, al
            mov al, 0ah
            out 42h, al

            in al, 61h
            or al, 81h
            xor al, 03h
            out 61h, al
            and al, not 80h
            out 61h, al

            mov al, 20h
            out 20h, al

            pop es di ax
            iret
            endp

EOP:

end         start