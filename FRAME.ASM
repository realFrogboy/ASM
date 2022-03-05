.model tiny
.code
locals 
org 100h

;================================================

VIDEOSEG			equ 0b800h
CMD 				equ 80h

LINE				equ 80d
CENTER				equ 40d
START_TEXT_LINE		equ 7d
START_FRAME_LINE 	equ 4d

NUM_OF_SYMB_IN_LINE	equ 3d
MAX_TEXT_LEN		equ 70d

WIG   				equ 10d
FRAME_COLOR 		equ 0cdh
TEXT_COLOR			equ 0fh

;================================================
;------------------------------------------------

.exitp		macro
			nop

			mov ax, 4c00h
			int 21h

			nop
			endm

;------------------------------------------------

.nextline	macro
			nop
			
			push bx
			mov bh, 00h

			add di, LINE * 2
			sub di, bx
			sub di, bx
			sub di, 4

			pop bx
			nop
			endm

;------------------------------------------------

.getch		macro
			nop

			xor ah, ah
			int 16h

			nop
			endm

;------------------------------------------------

.param		macro
			nop

			mov di, (START_TEXT_LINE * LINE + CENTER) * 2
			call CorrectDI
			mov si, CMD + 4
			sub di, LEN
			mov ah, TEXT_COLOR

			nop
			endm

;------------------------------------------------
;================================================

start: 		mov si, CMD + 4
			call Strlen								; find len of string and put the number in LEN
			
			cmp LEN, 0
			jne LenCheck
			mov dx, offset ZeroLen
			mov ah, 09h
			int 21h

			.exitp

LenCheck:	add LEN, 4

			cmp LEN, MAX_TEXT_LEN								; check LEN > 70
			ja TooLongStr

			call CorrectDI										; if DI is odd 

			mov bx, VIDEOSEG
			mov es, bx											; reg for videoseg

			add di, (START_FRAME_LINE * LINE + CENTER) * 2		; put left high corner (in fact, one line up: sm.: .newline)
			add di, LEN											; need for recursion: sm.: .newline 
			
			mov si, CMD + 2										; get a type of frame form cmd
			lodsb

			cmp al, '1'
			je FirstFrame

			cmp al, '2'
			je SecondFrame

			cmp al, '3'
			je ThirdFrame

TooLongStr:	mov dx, offset CMDOverflow
			mov ah, 09h
			int 21h

			.exitp

FirstFrame:	mov dx, offset CharsLineUp1 
			call SpecEffect

			.param
			call Printf

			.getch
			.exitp

SecondFrame: mov dx, offset CharsLineUp2
			call SpecEffect

			.param
			call Printf			

			.getch
			.exitp

ThirdFrame:	mov dx, offset CharsLineUp3
			call SpecEffect

			.param
			call Printf
			
			.getch
			.exitp


;================================================
;------------------------------------------------
;Draw frame with SPECIAL EFFECT: first, extend it, and than elong it
;
;Entry: DX = addr of array containing frame symbols of top row: [Lft] [Mid] [Rgt]
;		DI = start addr to draw
;Exit:  None
;Note:	ES = Video Seg addr
;Destr: AX BX CX DX SI DI
;------------------------------------------------
SpecEffect	proc

			xor bx, bx
			mov bl, 1d

@@Exten: 	inc bh
			call DrawFrame

			call Delay
			call Ret_DX_DI

			cmp bh, WIG - 2
			jne @@Exten

@@Elong:	inc bl
			call DrawFrame

			call Delay
			call Ret_DX_DI

			cmp bl, byte ptr LEN
			jne @@Elong

			ret
			endp

;------------------------------------------------
;Returns DX(addr of array containing frame symbols) and DI(start addr to draw) their start parametrs after draw frame
;
;Entry: None
;Exit:  None
;Note:	None
;Destr: CX DX DI
;------------------------------------------------
Ret_DX_DI	proc
			
			sub dx, NUM_OF_SYMB_IN_LINE * 2	; return DX

			xor cx, cx
			mov cl, bh						; put number of line, that DI should up
			add cl, 2	

@@RetDI:	sub di, LINE * 2				; return DI
			loop @@RetDI

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
;Draws a horizontal line
;
;Entry: SI = addr of array containing frame symbols: [Lft] [Mid] [Mid]... [Rgt]
;		DI = start addr to draw
;		CX = line length
;Exit:  None
;Note:	ES = Video Seg addr
;Destr: AX CX SI DI
;------------------------------------------------
DrawLine	proc

			cld

			.nextline
			mov ah, FRAME_COLOR

			lodsb
			stosw

			lodsb
			rep stosw

			lodsb
			stosw

			ret
			endp

;------------------------------------------------
;Draws a frame
;
;Entry: DX = addr of array containing frame symbols of top row: [Lft] [Mid] [Rgt]
;		DI = start addr to draw
;		BL = length of frame
;		BH = wight of the frame
;Exit:  None
;Note:	ES = Video Seg addr
;Destr: DX BX CX SI DI 
;------------------------------------------------
DrawFrame	proc

			mov si, dx						; give the addr with symbols to draw
			mov cl, bl						; put length of str in CX
			call DrawLine

			mov cl, bh						; put wight of frame
			add dx, NUM_OF_SYMB_IN_LINE		; get new symbols to print

@@PutVert:	mov si, dx						; give the addr with symbols to draw
			push dx							; save DX 
			mov dx, cx						; loop[DX] in loop[CX]
			mov cl, bl						; put length of str in CX			
			call DrawLine
			mov cx, dx
			pop dx
			loop @@PutVert

			add dx, NUM_OF_SYMB_IN_LINE		; get new symbols to print

			mov si, dx						; give the addr with symbols to draw
			mov cl, bl						; put length of str in CX
			call DrawLine

			ret
			endp

;------------------------------------------------
;Count number of symbols
;
;Entry: SI = addr of str
;Exit:  LEN
;Note:  String should end by '$' 
;Destr: AX BX SI 
;------------------------------------------------
Strlen			proc

				xor bx, bx

@@Count:		inc bx
				lodsb
				cmp al, '$'
				jne @@Count

				dec bx
				mov word ptr LEN, bx

				ret
				endp

;------------------------------------------------
;Output str in video
;
;Entry: SI = addr of str
;		DI = start addr to draw
;Exit: 	NONE
;Destr: AX BX SI
;------------------------------------------------
Printf			proc
				
				lodsb

@@Printf:		stosw
				lodsb
				cmp al, '$'
				jne @@Printf

				ret
				endp

;------------------------------------------------
;If LEN - even, then nothing have been changed
;		- odd , then DI := DI - 1
;
;Entry: LEN = length of str
;Exit: 	NONE
;Destr: AX BX DI 
;------------------------------------------------
CorrectDI		proc			
			
				mov ax, LEN
				xor bx, bx
				mov bh, 2
				div bh
				cmp ah, 0
				je @@Even
				dec di
@@Even:			
				ret
				endp

;------------------------------------------------
;================================================

CharsLineUp1	db '+-+'
CharsVert1  	db '| |'
CharsLineDown1	db '+-+'

CharsLineUp2	db 0c9h, 0cdh, 0bbh
CharsVert2  	db 0bah,  ' ', 0bah		; Double frame
CharsLineDown2  db 0c8h, 0cdh, 0bch

CharsLineUp3	db 0dah, 0c4h, 0bfh
CharsVert3		db 0b3h,  ' ', 0b3h		; Single frame
CharsLineDown3	db 0c0h, 0c4h, 0d9h

LEN 			dw ?

CMDOverflow		db 'ERROR: Text is too long$'
ZeroLen			db 'ERROR: Str has zero length$'

;================================================

end				start
