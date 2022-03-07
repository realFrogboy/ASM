.186
.model tiny
.code
org 100h

;------------------------------------------------

CKey        equ 02h
DKey        equ 03h
EKey        equ 04h
FKey        equ 05h
GKey        equ 06h
AKey        equ 07h
BKey        equ 08h

;------------------------------------------------

start:                  
                    mov ax, 3508h
                    int 21h
                    mov OldSeg, es
                    mov OldOff, bx
                    
                    cli
                    mov ax, 2509h
                    mov dx, offset Pianino
                    int 21h
                    sti

                    mov ax, 3100h
                    mov dx, offset EOP
                    shr dx, 4
                    inc dx
                    int 21h

                    mov ax, 4c00h
                    int 21h

;------------------------------------------------

Pianino             proc
                    push ax bx

                    in al, 60h

                    cmp al, CKey
                    je PlayC

                    cmp al, DKey
                    je PlayD

                    cmp al, EKey
                    je PlayE

                    cmp al, FKey
                    je PlayF

                    cmp al, GKey
                    je PlayG

                    cmp al, AKey
                    je PlayA

                    cmp al, BKey
                    je PlayB

                    jmp EndInt

PlayC:              
                    mov bx, C3
                    call PlayNote

                    jmp EndInt

PlayD:              
                    mov bx, D3
                    call PlayNote

                    jmp EndInt

PlayE:              
                    mov bx, E3
                    call PlayNote

                    jmp EndInt

PlayF:              
                    mov bx, F3
                    call PlayNote

                    jmp EndInt

PlayG:              
                    mov bx, G3
                    call PlayNote

                    jmp EndInt

PlayA:              
                    mov bx, A3
                    call PlayNote

                    jmp EndInt

PlayB:              
                    mov bx, B3
                    call PlayNote

EndInt:             
                    ;push OldSeg
                    ;push OldSeg

                    mov al, 20h
                    out 20h, al

                    pop bx ax
                    iret
                    endp


;------------------------------------------------
;Play note
;
;Entry: BX = divider for port 42h. It depend on note
;Exit:  None
;Note:	None
;Destr: AX CX
;------------------------------------------------
PlayNote            proc

                    mov al, 0b6h
                    out 43h, al
                    mov al, bl     
                    out 42h, al
                    mov al, bh
                    out 42h, al

                    in al, 61h
                    or al, 3
                    out 61h, al

                    call Delay
                    call Delay

                    in al, 61h
                    and al, not 3
                    out 61h, al

                    ret
                    endp


;------------------------------------------------
;Make a delay
;
;Entry: None
;Exit:  None
;Note:	None
;Destr: CX
;------------------------------------------------
Delay		proc

			mov cx, 0FFFFh
@@Delay:	loop @@Delay

			ret
			endp

;------------------------------------------------                    

;C3          dw  0c123h
;D3          dw  0d61fh
;E3          dw  581ch
;F3          dw  0b71ah
;G3          dw  0b717h
;A3          dw  2115h
;B3          dw  0e512h

C3          dw  7104h
D3          dw  0f503h
E3          dw  8603h
F3          dw  5403h
G3          dw  0f702h
A3          dw  0a402h
B3          dw  5a02h

OldSeg      dw 0
OldOff      dw 0

EOP:
end         start
