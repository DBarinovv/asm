.model	tiny
.code
org	100h

locals @@

start:

	mov	ax, 4C00h
	int	21h

;==========================================================
; In:
;    DS:DI - address of string (0-terminated)
;	 AL - symbol to find
; Out:
;    SI - address
;
; Destroy:	DI, SI
;==========================================================

strrchr	proc

	cld                 ; DF = 0
	xor	si, si			; si = 0


@@loop:

	cmp	byte ptr ds:[di], 0
	je	@@check			    ; if (!*di) break;

	scasb
	jne	@@loop			    ; if (*di != al) continue

	mov	si, di              ;{
	dec	si			        ;{ si = di - 1

	jmp	@@loop


@@check:

	test si, si             ; if (si != 0) goto end
	jne	@@end

	mov	si, di              ; si = di


@@end:

	ret

strrchr	endp

;==========================================================
; In:
;	DS:DI - address of string (0-terminated)
;   AH - max len
; Out:
;    CX   - length of string
; Destroy:
;	AL, DI, CX;
;==========================================================
strlen	proc

	cld                 ; DF = 0

	xor	al, al		    ; al = 0
	mov	cx, AH  	    ; cx = AH - max len

	repne	scasb		; while (*(di++) != 0);

	sub	AH, cx          ;{
	mov AH, cx          ;{
	dec	cx		        ;{ cx = len

	ret

strlen	endp

;==========================================================
; In:
;   ES:DI - address of string to   (0-terminated)
;	DS:SI - address of string from (0-terminated)
; Out:
;	Dtring from copied to string to
; Destroy:
;	DI, SI
;==========================================================
strcpy	proc

	cld                         ; DF = 0


@@loop:

	cmp	byte ptr ds:[si], 0
	je	@@end                   ; if 0

	movsb                       ; ES:DI++ = DS:SI++

	jmp	@@loop


@@end:

	mov	byte ptr es:[di], 0     ; make 0-terminated
	ret

strcpy	endp

;==========================================================
; In:
;   ES:DI - address of string 1 (0-terminated)
;	DS:SI - address of string 2 (0-terminated)
; Out:
;   Flags - cmp of end of one string and same byte in other
; Destroy:
;	DI, SI
;==========================================================
strcmp	proc

	cld                     ; DF = 0

@@loop:

	cmpsb
	jne	@@end

	cmp	byte ptr es:[di - 1], 0  ; end 1 string
	je	@@end_di

	cmp	byte ptr ds:[si - 1], 0  ; end 2 string
	je	@@end_si

	jmp	@@loop


@@end_di:

	cmp	byte ptr ds:[si - 1], 0
	ret


@@end_si:

	cmp	0, byte ptr es[di - 1]
	ret


@@end:

	ret

strcmp	endp

;==========================================================
; In:
;   DS:DI - address string (0-terminated)
;	AL    - symbol to find
; Out:
;   DI - address of first byte AL in string or 0
;==========================================================
strchr	proc

	cld

@@loop:

	cmp	byte ptr ds:[di], 0
	je	@@end		    	; if (!*di) break;
	scasb
	je	@@found			    ; if (*(di++) == al) break;
	jmp	@@loop


@@found:

	dec	di			    ; di--


@@end:

	ret

strchr	endp

;==========================================================
; In:
;   ES:DI - adress
;	AL - byte to put in
;	CX - length
; Destroy:
;	CX, DI
;==========================================================
memset	proc

	cld
	rep	stosb
	ret

memset	endp

;==========================================================
; In:
;   DS:SI - address from
;	ES:DI - address to
;	CX - length
; Destroy:
;   AX, CX, DI, SI
;==========================================================
memcpy	proc

	cld
	rep	movsb
	ret

memcpy	endp
                 j
;==========================================================
; In:
;	DI - first address
;	SI - second address
;	CX - length
; Out:
;   FLAGS - cmp of first bytes which are not equal
; Destroy:
;	AX, CX, SI, DI, ES
;==========================================================
memcmp	proc

	mov	ax, ds      ; ax = ds
	mov	es, ax      ; es = ax

	repe cmpsb

	ret

memcmp	endp

;==========================================================
; In:
;   DS:DI - address
;	CX - length
;	AL - symbol to find
; Out:
;   DI - adress of first equal byte or end if where was not equal
; Destroy:
;   AL, CX, DI
;==========================================================
memchr	proc

	cld
	repne scasb
	jne	@@end

	sub	di, 1


@@end:

    ret

memchr	endp

end	start
