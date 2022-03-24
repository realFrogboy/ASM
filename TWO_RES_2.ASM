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
                push bp
                mov bp, sp
                push si di es ax bx cx dx 

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

                mov bx, (START_TEXT_LINE * LINE + CENTER - 3) * 2
                dec bx

                mov ax, [bp - 8]
                mov di, offset RegAX    ; output AX
                call OutputRegFrame

                add bx, LINE * 2

                mov ax, [bp - 6]
                mov di, offset RegBX    ; output BX
                call OutputRegFrame

                add bx, LINE * 2

                mov ax, [bp - 4]
                mov di, offset RegCX    ; output CX
                call OutputRegFrame

                add bx, LINE * 2

                mov ax, [bp - 2]
                mov di, offset RegDX    ; output DX
                call OutputRegFrame

                pop ds

                mov FLAG, 0

@@Skip:         
                mov al, 20h
                out 20h, al

                pop dx cx bx ax es di si
                pop bp

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

                mov cx, 6d
                xor bx, bx

@@nextLine:     
                push cx
                mov cx, 15d

@@nextByte:
                mov ax, es:[di]
                mov Video + bx, ax

                add bx, 2
                add di, 2
                loop @@nextByte

                add di, (LINE - 15) * 2
                pop cx

                loop @@nextLine

                ret
                endp

;------------------------------------------------

ReturnVideo     proc

                mov ax, VIDEOSEG
                mov es, ax

                xor di, di
		add di, ((START_FRAME_LINE + 1) * LINE + CENTER) * 2		
                sub di, 9 * 2		

                mov cx, 6d
                xor bx, bx

@@nextLine:
                push cx
                mov cx, 15d

@@nextByte:
                mov ax, Video + bx
                stosw
                add bx, 2

                loop @@nextByte

                add di, (LINE - 15) * 2
                pop cx

                loop @@nextLine

                ret
                endp

;------------------------------------------------
;Output the frame with reg
;
;Entry: AX = register
;       DI = addr of Text
;Exit:  
;
;Destr: AX BX CX DX SI DI
;------------------------------------------------
OutputRegFrame  proc
                push ax bx cx dx si di bx

                mov si, di
                push offset Text
                call Strcpy

                push offset value
                call PutReginStr

                push offset Text
                push offset value
                call BADStrcat

                pop di
                mov si, offset Text
                sub di, LEN
                mov ah, TEXT_COLOR
                call Printf

                pop di si dx cx bx ax
                ret
                endp

;------------------------------------------------
;Put value of register in string
;
;Entry: AX = register
;       PUSH_1 = addr of str
;Exit:  
;
;Destr: AX BX CX DX
;------------------------------------------------

PutReginStr     proc
                push bp
                mov bp, sp
                push ax bx cx dx si

                mov si, [bp + 4]
                mov cx, 4
                xor bx, bx

@@NextNum:
                xor dx, dx
                mov bx, 16
                div bx
                cmp dx, 10
                jb @@Num
                
                add dl, 55
                mov bx, cx
                dec bx
                mov si[bx], dl

                jmp @@Continue

@@Num:          
                add dl, 30h
                mov bx, cx
                dec bx
                mov si[bx], dl
                
@@Continue:     loop @@NextNum

                mov al, '$'
                mov si[4], al

                pop si dx cx bx ax
                pop bp
                ret 2
                endp

;------------------------------------------------
;Add the insert str at the end of the main str
;
;Entry: PUSH_1 = addr of main str
;       PUSH_2 = addr of insert str
;Exit:  
;
;Destr: AX BX CX DX
;------------------------------------------------

BADStrcat       proc
                push bp
                mov bp, sp
                push ax bx cx si di

                mov si, [bp + 6]
                mov di, [bp + 4]

                mov cx, 5
                xor bx, bx

@@PutSmbl:      
                mov al, di[bx]
                mov si[5 + bx], al
                inc bx
                loop @@PutSmbl

                pop di si cx bx ax
                pop bp
                ret 4
                endp

;------------------------------------------------
;Copy string from SI
;
;Entry: SI = addr of str
;Exit:  COPY
;Note:  String should be ended by '$' 
;Destr: AL BX CX
;------------------------------------------------
Strcpy	        proc
                push bp
                mov bp, sp 

                push offset LEN
		call Strlen

                mov di, [bp + 4]

                mov cx, LEN
                inc cx              ; need to put '$' at the end of copystr
                mov bx, cx

@@Copy:         dec bx
                mov al, si[bx] 
                mov di[bx], al
		loop @@Copy

                pop bp
                ret 2
                endp


;------------------------------------------------
;Count number of symbolss
;
;Entry: SI = addr of str
;Exit:  LEN
;Note:  String should be ended by '$' 
;Destr: AL BX DI
;------------------------------------------------
Strlen		proc
                push bp
                mov bp, sp

                xor bx, bx

@@Count:	inc bx
                lodsb
                cmp al, '$'
                jne @@Count

                sub si, bx
                dec bx
                mov di, [bp + 4]
                mov word ptr [di], bx

                pop bp
                ret 2
                endp



FLAG            db  0
Video           dw  90 dup (?)

RegAX           db  'AX = $', 5 dup (?)
RegBX           db  'BX = $', 5 dup (?)
RegCX           db  'CX = $', 5 dup (?)
RegDX           db  'DX = $', 5 dup (?)

value           db  5 dup (?)
Text            db  10 dup (?)

LEN             dw  ?


EOP:
end             start