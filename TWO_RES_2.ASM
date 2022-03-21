.186
.model tiny
.code
locals
org 100h

start:          
                mov ax, 3509h
                int 21h
                mov word ptr Old09+2, es
                mov word ptr Old09, bx

                mov ax, 3508h
                int 21h
                mov word ptr Old08+2, es
                mov word ptr Old08, bx


                push ds
                push cs
                pop ds

                cli
                mov ax, 2509h           ; Set new ISR 09h
                mov dx, offset New09    ; DS = CS: model tiny
                int 21h
                sti

                push cs
                pop ds

                cli
                mov ax, 2508h
                mov dx, offset New08
                int 21h
                sti

                pop ds

                mov ax, 3100h           ; TSR
                mov dx, offset EOP      ; End of programm
                shr dx, 4
                inc dx
                int 21h

;------------------------------------------------  

include ResFr.ASM

New09           proc
                push ax bx cx di es
       
                mov ax, VIDEOSEG
                mov es, ax

                mov di, (12*LINE + CENTER) * 2
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
                call ReturnVideo

@@Skip:          
                mov al, 20h
                out 20h, al

                pop es di cx bx ax
                
        db  0eah
Old09   dd  0

                endp

;------------------------------------------------

New08           proc
                push ax bx cx dx si di es

                cmp FLAG, 1
                jne @@Skip

                START_TEXT_LINE = 6d
                START_FRAME_LINE = 4d

                mov ax, VIDEOSEG
                mov es, ax

                push ds
                push cs
                pop ds

                xor cx, cx
                xor di, di
                call ResidentFrame

                pop ds

                mov FLAG, 0

@@Skip:         
                mov al, 20h
                out 20h, al

                pop es di si dx cx bx ax

        db  0eah
Old08   dd  0

                endp

;------------------------------------------------

RememberVideo   proc

                mov ax, VIDEOSEG
                mov es, ax

                xor di, di
		add di, ((START_FRAME_LINE + 1) * LINE + CENTER) * 2
                sub di, 9 * 2			

                mov cx, 15d
                xor bx, bx

@@nextByte:
                mov ax, es:[di]
                mov Video + bx, ax

                add bx, 2
                add di, 2
                loop @@nextByte

                ret
                endp

;------------------------------------------------

ReturnVideo     proc

                mov ax, VIDEOSEG
                mov es, ax

                xor di, di
		add di, ((START_FRAME_LINE + 1) * LINE + CENTER) * 2		
                sub di, 9 * 2		

                mov cx, 15d
                xor bx, bx

@@nextByte:
                mov ax, Video + bx
                stosw
                add bx, 2

                loop @@nextByte

                ret
                endp

;------------------------------------------------

FLAG            db  0
Video           dw  15 dup (?)
Text            db  'helloq$'

EOP:
end             start