.186
.model tiny
.code
locals
org 100h

;------------------------------------------------

DIGIT   equ 10d
BIAS    equ 48d  

;------------------------------------------------
.separation macro
            nop

            mov dl, ':'
            mov ah, 02h
            int 21h

            nop
            endm

.printf     macro
            nop

            mov ah, 09h
            int 21h

            nop
            endm

.putch      macro
            nop

            call itoa
            mov dx, NSTR

            .printf

            nop
            endm

;------------------------------------------------

start:      mov si, offset mystr
            
            push offset LEN
            call Strlen

            mov ax, LEN
            .putch
            .separation

            mov dh, '0'
            push offset POS
            call Strchr

            cmp POS, 0FFFFh
            jne PutPos
            mov dx, offset NoSymb
            .printf
            .separation
            jmp Nope

PutPos:     mov ax, POS
            .putch
            .separation

Nope:       push offset COPY
            call Strcpy
            mov dx, COPY
            .printf
            .separation

            call atoi
            add val, 1234d
            
            mov ax, val
            .putch
            .separation

            mov di, offset cmpstrg
            push offset CmpRES
            call Strcmp

            mov ax, CmpRES
            .putch

            mov ax, 4c00h
            int 21h

;------------------------------------------------
;Count number of symbolss
;
;Entry: SI = addr of str
;Exit:  LEN
;Note:  String should be ended by '$' 
;Destr: AL BX 
;------------------------------------------------
Strlen			proc
                push bp
                mov bp, sp

				xor bx, bx

@@Count:		inc bx
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


;------------------------------------------------
;Find position of symbol in DH in string from SI
;
;Entry: SI = addr of str
;       DH = symbol
;Exit:  POS
;Note:  String should be ended by '$' 
;Destr: AL BX DH
;------------------------------------------------
Strchr			proc
                push bp
                mov bp, sp

                xor bx, bx

@@Count:		inc bx
				lodsb
                cmp al, '$'
                je  @@break
				cmp al, dh
				jne @@Count

                sub si, bx
                dec bx

                mov di, [bp + 4]
				mov word ptr [di], bx

                pop bp
                ret 2

@@break:		sub si, bx
                
                mov di, [bp + 4]
                mov word ptr [di], -1
                
                pop bp
                ret 2
				endp


;------------------------------------------------
;Copy string from SI
;
;Entry: SI = addr of str
;Exit:  COPY
;Note:  String should be ended by '$' 
;Destr: AL BX CX 
;------------------------------------------------
Strcpy			proc
                push bp
                mov bp, sp 

                push offset LEN
				call Strlen

                mov cx, LEN
                inc cx              ; need to put '$' at the end of copystr
                mov bx, cx

@@Copy:         dec bx
                mov al, si[bx] 
                mov copystr[bx], al
				loop @@Copy

                mov di, [bp + 4]
				mov word ptr [di], offset copystr

                pop bp
				ret 2
				endp


;------------------------------------------------
;Translate int to string
;
;Entry: AX = number
;       DI = addr of str
;Exit:  DI
;Note:  Nuber should be < 65536
;Destr: AX BX CX DX
;------------------------------------------------
itoa            proc

                mov cx, DIGIT 
                xor bx, bx        

@@Continue:     xor dx, dx

                div cx              ; DX = AX mod CX, AX = AX div CX
                add dx, BIAS        ; from int to char

                mov tmp[bx], dl     ; DX < 10 -> DL = DX 
                inc bx

                cmp ax, 0
                jne @@Continue

                push bx             ; save number of digit in number
                mov cx, bx          ; initialization of counter (number of digit)
                xor dx, dx

@@CoupStr:      mov bx, cx
                dec bx
                mov al, tmp[bx]     ; takes char from temprorary str

                mov bx, dx
                mov iStr[bx], al      ; puts char in DI

                inc dx
                loop @@CoupStr

                pop bx
                mov iStr[bx], '$'     ; puts termination symb at the end of str

                mov NSTR, offset iStr

                ret
                endp


;------------------------------------------------
;Translate string to int 
;
;Entry: SI = addr of the 1st str
;       DI = addr of the 2nd str
;Exit:  CmpRES
;Note:  Strings should be ended by '$'
;Destr: AX BX CX 
;------------------------------------------------
Strcmp          proc
                push bp
                mov bp, sp

                push offset LEN
                call Strlen 

                mov ah, byte ptr LEN

                push si
                mov si, di
                
                push offset LEN
                call Strlen

                mov al, byte ptr LEN

                pop si

                cmp ah, al
                jb @@First
                ja @@Second

                mov cx, LEN
                xor bx, bx

@@CmpNextChar:  mov ah, si[bx]
                mov al, di[bx]
                inc bx

                cmp ah, al
                jb @@First
                ja @@Second

                loop @@CmpNextChar

                mov bx, [bp + 4]
                mov word ptr [bx], 0

                pop bp
                ret 2

@@First:        mov bx, [bp + 4]
                mov word ptr [bx], 1

                pop bp
                ret 2

@@Second:       mov bx, [bp + 4]
                mov word ptr [bx], -1

                pop bp
                ret 2

                endp


;------------------------------------------------
;Translate string to int 
;
;Entry: SI = addr of str
;Exit:  VAL
;Note:  1. String should be ended by '$'
;       2. Nuber should be < 65536
;Destr: AX BX CX DX
;------------------------------------------------
atoi            proc

                mov VAL, 0h

                push offset LEN
                call Strlen             ; LEN = lenght of str
                mov cx, LEN             ; initialization of counter
                xor dx, dx              ; number digit

@@NextSmb:      xor ax, ax

                mov bx, cx              ; begins from the lowest digit
                dec bx

                mov al, si[bx]
                xor ah, ah              ; increase reg AL to reg AX
                sub ax, BIAS            ; from char to int

                push cx                 ; save CX
                mov cx, dx              ; dx - counter (number digit)
                jcxz @@ZeroDigit
                mov bx, DIGIT
                push dx                 ;save DX before mul

@@Mult:         mul bx                  ; reduction to the required digit
                loop @@Mult

                pop dx

@@ZeroDigit:    inc dx                  ; increase digit

                pop cx                  ; ret CX

                add word ptr VAL, ax
                loop @@NextSmb

                ret
                endp


;------------------------------------------------

mystr   db '1234$'
cmpstrg db '1234$'
copystr db 10 dup(?)
tmp     db 6 dup(?)
iStr    db 6 dup(?)

POS     dw 0000h
LEN     dw 0000h
VAL     dw 0000h
COPY    dw 0000h
NSTR    dw 0000h
CmpRES  dw ?

NoSymb  db 'There is no such symbol int the str$'

end         start