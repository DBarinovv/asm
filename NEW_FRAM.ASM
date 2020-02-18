.model tiny
;=================================================

START_LINE  equ 5d
START_COORD equ 5d
START_LEN_X equ 10d
START_LEN_Y equ 5d

MAX_X    equ 80d
MAX_Y    equ 25d
VIDEOSEG equ 0b800h

DWLGF	 equ 27h	; dark white letter, green fone

VER	 equ 0bah	; vertival   for frame
HOR	 equ 0cdh	; horizontal for frame
ULC	 equ 0c9h	; up-left    corner
URC	 equ 0bbh	; up-right   corner
DLC	 equ 0c8h	; down-left  corner
DRC 	 equ 0bch	; down-right corner
SPC   	 equ 20h	; space

;=================================================

.govideoseg	macro
		
		mov bx, VIDEOSEG
		mov es, bx
		
		endm

;=================================================
.code
org 100h 

start:
		.govideoseg
		
		mov ah, DWLGF
		mov dl, START_LEN_X - 8d	; -8d for resize
		mov dh, START_LEN_Y - 3d	; -3d for resize

zoom:
		add dl, 8d			; zoom
		add dh, 3d			; zoom
		
		mov al, ULC			;}
		mov cx, 1d			;|
		mov bh, START_LINE		;| draw up-left symbol
		mov bl, START_COORD		;|
		call Draw_Line			;}
		
		push bx				; "save" bx
		inc bx
			
		push dx
		xor dh, dh
		mov al, HOR			;}
		mov cx, dx			;| draw up line
		call Draw_Line			;}
		add bx, dx
		pop dx
		
		mov al, URC			;}
		mov cx, 1d			;| draw up-right symbol
		call Draw_Line			;}

		pop bx				; restore bx
		inc bh				; go next line

		xor si, si
do_frame:
		inc si
		push dx
		xor dl, dl
		cmp si, 10
		jae end_frame
		pop dx

		mov al, VER
		mov cx, 1d
		call Draw_Line

		push bx
		inc bl

		push dx
		xor dh, dh
		mov al, SPC
		mov cx, dx
		call Draw_Line
		add bl, dl
		pop dx

		mov al, VER
		mov cx, 1d
		call Draw_Line

		pop bx
		inc bh
	
		jmp do_frame 

end_frame:
		pop dx	
	
		mov al, DLC
		mov cx, 1d
		call Draw_Line
		push bx
		inc bl

		push dx
		xor dh, dh
		mov al, HOR
		mov cx, dx
		call Draw_Line
		add bx, dx
		pop dx

		mov al, DRC
		mov cx, 1d
		call Draw_Line
				
		ret			; exit (0)

;=================================================
; Draw horizontal line
; In:  
; 	AH - color
;	AL - symbol to draw
;	BH - y-coord (line)
;	BL - x-cord (column)
;	CX - length
; Destroy:
;	CX, ES, DI
;	CX = 0
;	ES = VIDEOSEG
;=================================================

Draw_Line	proc
	
		push ax			; "save" ax
		
		mov al, MAX_X
		mul bh			; ax = bh * MAX_X
		add al, bl		; ax += bx
		shl ax, 1		; ax *= 2

		mov di, ax		; di = ax

		pop ax			; restore ax

		rep stosw		; mov es:[di++], ax

		ret			
		endp

end 		start