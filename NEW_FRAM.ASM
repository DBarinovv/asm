.model tiny
.386
;=================================================

START_LINE  equ 5d
START_COORD equ 5d

CNT_OF_ZOOM equ 3d
ZOOM_FOR_X  equ 2d
ZOOM_FOR_Y  equ 2d

MAX_X    equ 80d         ; max x coord
MAX_Y    equ 25d         ; max y coord
VIDEOSEG equ 0b800h

DWLGF	 equ 27h	; dark white letter, green fone
WLRF	 equ 04fh	; white letter, red fone

SPC      equ 20h    ; space ' '
ULC	     equ 0c9h	; up-left    corner
URC	     equ 0bbh	; up-right   corner
DLC	     equ 0c8h	; down-left  corner
DRC   	 equ 0bch	; down-right corner
;=================================================

.govideoseg	macro

		mov bx, VIDEOSEG
		mov es, bx

		endm

;-------------------------------------------------

.if_digit macro

        cmp al, '0'
        jb initialization_again
        cmp al, '9'
        ja initialization_again

        endm

;=================================================
.data

start_len_x db 16d
start_len_y db 8d
arr_ver	     dw 0bah, '*', '#', 'D'	; vertival   for frame
arr_hor	     dw 0cdh, '*', '#', 'D'	; horizontal for frame
index        db 0
ver          db 0bah            ; default vertical
hor          db 0cdh            ; default horizontal
;=================================================

.code
org 100h

start:

            call Initialization

            .govideoseg


            mov ah, DWLGF

            mov dl, start_len_x
            add dl, start_len_x
            sub dl, ZOOM_FOR_X

            mov dh, start_len_y
            sub dh, ZOOM_FOR_Y


            call Draw_Full_Zoom_Frame

            ret				; exit (0)


;=================================================
; Initialization for frame
; Destroy:
;   CX, SI, AX
;=================================================

Initialization proc

            xor cx, cx     ; cx = 0
        	mov si, 81h    ; - adress of command line start


initialization_again:

        	lodsb         ; al = ds[si++]
        	cmp al, 0
        	je initialization_exit

            .if_digit

        	cmp cx, 0
        	je initialization_first

            cmp cx, 1
            je initialization_second

            sub al, '0'
            mov index, al


        	jmp initialization_exit


initialization_first:

            sub al, '0'
        	mov start_len_x, al

        	lodsb
        	.if_digit

            sub al, '0'

            push bx
            push cx

            mov cl, al
            mov al, start_len_x

            mov bl, 10d
            mul bl
            add al, cl
            mov start_len_x, al

            pop cx
            pop bx

        	inc cx
        	jmp initialization_again


initialization_second:

        	sub al, '0'
        	mov start_len_y, al

        	lodsb

        	.if_digit

            sub al, '0'

            push bx
            push cx

            mov cl, al
            mov al, start_len_y

            mov bl, 10d
            mul bl
            add al, cl
            mov start_len_y, al

            pop cx
            pop bx

            inc cx
        	jmp initialization_again


initialization_exit:

            push bx
            push cx
            xor cx, cx

            mov bx, offset arr_ver
            mov cl, index
            add bx, cx
            add bx, cx

            mov cx, [bx]
            mov ver, cl


            mov bx, offset arr_hor
            mov cl, index
            add bx, cx
            add bx, cx

            mov cx, [bx]
            mov hor, cl

            pop cx
            pop bx

            ret
            endp

;=================================================
; Draw one symbol
; In:
;	AH - color
;	AL - symbol to draw
; 	ES - VIDEOSEG
;	BX - where draw
; Destroy:
;	BX
;	BX += 2
;=================================================

Draw_Symbol	proc

		mov byte ptr es:[bx], al	; es[bx] = al
		inc bx                          ; bx++
		push ax                         ; "save" ax
		mov al, ah                      ; al = ah
		xor ah, ah                      ; al = 0
		mov byte ptr es:[bx], al        ; es:[bx] = al
		pop ax                          ; restore ax
		inc bx                          ; bx++

		ret
		endp

;=================================================
; Draw horizontal line
; In:
;    AH - color
;    AL - symbol to draw
;    BX - where draw
;    CX - length
;    ES = VIDEOSEG
;
; Destroy:
;    CX, DI
;    BX += CX
;    CX = 0
;=================================================

Draw_Line	proc

		mov di, bx		; di = bx
		add bx, cx              ; }
		add bx, cx              ; | bx += 2*cx

		rep stosw		; mov es:[di++], ax

		ret
		endp

;=================================================
; Draw UP line with ULC, =, URC
; In:
;    AH - fone
;    BX - start draw point
;    DL - width
;
; Destroy:
;    AL, CX, BX, DI
;    AL = URC
;
; Call:
;    Draw_Symbol
;    Draw_Line
;=================================================

Draw_Up_Line proc

        mov al, ULC                     ; al = up-left sumbol

		push bx                         ; "save" bx
		call Draw_Symbol

		push dx				; "save" dx
		xor dh, dh			; dh = 0
		mov al, hor			;}-----
		mov cx, dx			;| draw up line
		call Draw_Line			;}-----
		pop dx				; restore dx

		mov al, URC			; al = up-right symbol
		call Draw_Symbol

		pop bx				; restore bx

        	ret
        	endp

;=================================================
; Draw DOWN line with DLC, =, DRC
; In:
;    AH - fone
;    BX - start draw point
;    DL - width
;
; Destroy:
;    AL, CX, BX, DI
;    AL = DRC
;
; Call:
;    Draw_Symbol
;    Draw_Line
;=================================================

Draw_Down_Line proc

        mov al, DLC			    ; al = down-left sumbol
		push bx                 ; "save" bx
		call Draw_Symbol

		push dx				; "save" dx
		xor dh, dh			; dh = 0
		mov al, hor			;}-----
		mov cx, dx			;| draw down line
		call Draw_Line			;}-----
		pop dx				; restore dx

		mov al, DRC			; al = draw down-right symbol
		call Draw_Symbol
		pop bx				; restore bx

		ret
		endp

;=================================================
; Draw main part (without up and down line) of frame (VER, SPC...SPC, VER)
; In:
;    DH - height of frame
;    DL - width  of frame
;
; Destroy:
;    AL, CX, BX, DI
;    AL = DRC
;
; Call:
;    Draw_Symbol
;    Draw_Line
;=================================================

Draw_Main_Part_Of_Frame proc

        push si				; "save" si
		xor si, si			; si = 0
do_frame:
		inc si				; si++
		push dx				; "save" dx
		mov dl, dh			;}-----
		xor dh, dh			;| change dh and dl to cmp with si
		cmp si, dx			;}-----
		jae end_frame			; if (si >= dx) goto end_frame
		pop dx				; restore dx

		mov al, ver			; draw left symbol for main part of frame
		push bx
		call Draw_Symbol

		push dx				; "save" dx
		xor dh, dh			; dh = 0
		mov al, SPC			;}-----
		mov cx, dx			;| draw main line
		call Draw_Line			;}-----
		pop dx				; restore dx

		mov al, ver			; draw right symbol for main part of frame
		call Draw_Symbol		;

		pop bx				; restore bx
		add bx, 80*2

		jmp do_frame 		; goto do_frame

end_frame:
		pop dx				; restore dx
		pop si				; restore si

        	ret
		endp

;=================================================
; Draw FULL frame
; In:
;    DH - height of frame
;    DL - width  of frame
;    AH - fone
;
; Destroy:
;   BX, AL, CX, DI
;
; Call:
;   Draw_Up_Line
;   Draw_Main_Part_Of_Frame
;   Draw_Down_Line
;=================================================

Draw_Full_Frame proc

        mov bx, ((START_LINE*80) + START_COORD)*2 	; bx = start point
        call Draw_Up_Line

		add bx, 80*2 					; go next line

		call Draw_Main_Part_Of_Frame

		call Draw_Down_Line

        ret
        endp

;=================================================
; Draw FULL ZOOM frame
; In:
;    DH - height of frame
;    DL - width  of frame
;    AH - fone
;
; Destroy:
;   BX, AL, CX, DI
;
; Call:
;
;=================================================

Draw_Full_Zoom_Frame	proc

		xor si, si				    ; si = 0
zoom:
		inc si					    ; si++
		cmp si, CNT_OF_ZOOM
		jae end_zoom				; if (si >= 3d) goto end_zoom

		add dl, ZOOM_FOR_X			; zoom (x-coord)
		add dh, ZOOM_FOR_Y			; zoom (y-coord)

        call Draw_Full_Frame

		call Delay
		jmp zoom
end_zoom:

		ret
		endp

;=================================================
; Draw DED in the middle of frame
; Destroy:
;	BX, AX
; Use:
;	Draw_Symbol
;=================================================

Draw_Ded	proc

		mov bx, (80*(START_LINE + (ZOOM_FOR_Y*CNT_OF_ZOOM)/2 + 1) + START_COORD + (ZOOM_FOR_X*CNT_OF_ZOOM)/2 + 1) * 2	; in middle

		mov al, 'D'
			            	; al = D
		mov ah, WLRF
		call Draw_Symbol

		mov al, 'E'                     ; al = E
		call Draw_Symbol

		mov al, 'D'                     ; al = D
		call Draw_Symbol

		ret
		endp

;=================================================
; Delay
;=================================================

Delay   	proc

		push bx				; "save" bx
		xor bx, bx			; bx = 0
again:
		add bx, 1			; bx++ (counter++)
		push bx				;}-----
		pop bx				;|
		push bx				;|
		pop bx				;| long time commands
		push bx				;| to make delay
		pop bx				;|
		push bx				;|
		pop bx				;}-----
		cmp bx, 15000			;
		jbe again			; if (bx <= 15000) goto again

		pop bx				; restore bx

        	ret
        	endp


end		start
