.model tiny
.386
locals @@

;=================================================
.const

C_max_len   equ 15
;=================================================

.make_right_ax      macro

    mov di, bp
    add di, 4      ; for skip saved bp

    add di, si     ;}
    add di, si     ;|  di += (si - 1) * 2
    dec di         ;|
    dec di         ;}

    mov ax, [di]

    endm

;-------------------------------------------------

.output_dl      macro

    mov ah, 02h
    int 21h

    endm

;=================================================


.data

in_string   db  'I love %s %c%c %d %%! %b', 0   ; printf ("in_string")
helper_string   db  C_max_len  Dup (0), '$'
string_1    db  'EDA', 0

;res_string      db  100 Dup (0)         ; 100 - max size of string

;=================================================

.code
org 100h

start:

    push 127d
    push 100d
    push 'a'
    push 'n'
    push offset string_1


    xor si, si

    call My_Printf

    add sp, si  ; pop arguments


;    push 'A'                           ;}
;    push 'B'                           ;|
;    push 'C'                           ;|
;    push 1359d                         ;|
;    push 1488d                         ;|
;                                       ;|
;    push offset string                 ;|
;                                       ;|
;                                       ;|
;    call Output_String                 ;| Tests for functions
;                                       ;|
;    pop ax                             ;|
;    mov cl, 10d                        ;|
;    call Conver_Dec_And_Output         ;|
;    pop ax                             ;|
;    call Conver_Dec_And_Output         ;|
;                                       ;|
;    call Output_Char                   ;|
;    call Output_Char                   ;|
;    call Output_Char                   ;}

    ret


;=================================================
; My printf
; In:
;    Format string and arguments in stack
;
; Destroy:
;    SI, AX, BX, CX, DX
;
; Call:
;   Output_Char, Conver_Dec_And_Output, Output_String
;=================================================

My_Printf   proc

    push bp ; save bp
    mov bp, sp

    mov bx, offset in_string
    dec bx


@@again:

    inc bx               ; next element
    mov dl, [bx]
    cmp dl, 0            ;}
    je @@exit            ;} if end of string

    cmp dl, '%'
    je @@character_%

    .output_dl          ;} if element != '%' output it

    jmp @@again


@@character_%:

    inc si        ; counter++

    inc bx               ;}
    mov dl, [bx]         ;} look next element after '%'

    cmp dl, '%'
    jne @@next

    dec si

    .output_dl

    jmp @@again

@@next:

    .make_right_ax      ; make ax = argument from stack

    xor dh, dh
    mov di, dx
    sub di, 'b'

    shl di, 1d

    lea dx, [@@jmp_table]
    add dx, di

    jmp dx

;-------------------------------------------------
@@jmp_table:

    jmp short @@call_%b           ;   'b'
    jmp short @@call_%c           ;   'c'
    jmp short @@call_%d           ;   'd'
    jmp short @@again                     ;   'e'
    jmp short @@again                     ;   'f'
    jmp short @@again                     ;   'g'
    jmp short @@again                     ;   'h'
    jmp short @@again                     ;   'i'
    jmp short @@again                     ;   'j'
    jmp short @@again                     ;   'k'
    jmp short @@again                     ;   'l'
    jmp short @@again                     ;   'm'
    jmp short @@again                     ;   'n'
    jmp short @@call_%o           ;  'o'
    jmp short @@again                     ;   'p'
    jmp short @@again                     ;   'q'
    jmp short @@again                     ;   'r'
    jmp short @@call_%s           ;  's'
    jmp short @@again                     ;   't'
    jmp short @@again                     ;   'u'
    jmp short @@again                     ;   'v'
    jmp short @@again                     ;   'w'
    jmp short @@call_%x           ;  'x'

;-------------------------------------------------
@@call_%s:

    push bx
    mov bx, ax

    call Output_String
    pop bx

    jmp @@again

;-------------------------------------------------
@@call_%d:

    mov cl, 10d

    call Conver_Dec_And_Output
    jmp @@again

;-------------------------------------------------
@@call_%b:

    mov cl, 2d

    call Conver_Dec_And_Output
    jmp @@again

;-------------------------------------------------
@@call_%x:

    mov cl, 16d

    call Conver_Dec_And_Output
    jmp @@again

;-------------------------------------------------
@@call_%o:

    mov cl, 8d

    call Conver_Dec_And_Output
    jmp @@again

;-------------------------------------------------
@@call_%c:

    call Output_Char
    jmp @@again


@@exit:

    pop bp

    ret
    endp


;=================================================
; Output char (%c)
; In:
;    AX - symbol for output
;
; Destroy:
;    AX, DL
;    Pop last from stack
;=================================================

Output_Char proc

    push bp ; save bp
    mov bp, sp

    mov dl, al      ; dl = al = symbol for output

    .output_dl      ;} output

    pop bp

    ret
    endp


;=================================================
; Conversion from decimal system to another and output (%d, %b, %x, %o)
; In:
;    AX = decimal number
;    CL = which system
;
; Destroy:
;    AX
;=================================================

Conver_Dec_And_Output  proc

    push bp ; save bp
    mov bp, sp

    push bx     ; "save" bx

    mov bx, offset helper_string    ;}
    add bx, C_max_len - 1           ;} *bx = helper_string.end

@@again:

    div cl          ; ah = ax % cl = ax % 10

    cmp ah, 9
    jbe @@less_10

    add ah, 'A' - '0' - 10   ; for output A, B, C, D...

@@less_10:

    add ah, '0'     ; al = ax / cl = ax / 10
    mov [bx], ah    ; helper_string[bx] = ah
    dec bx          ; bx--

    xor ah, ah
    cmp ax, 0

    ja @@again

    inc bx          ; }
    mov dx, bx      ; |
                    ; | - output string (our number)
    mov ah, 09h     ; |
    int 21h         ; }

    pop bx      ; restore bx

    pop bp

    ret
    endp


;=================================================
; Output string (%s)
; In:
;    Address of string in AX
;
; Destroy:
;    AX, DX
;    Pop last from stack
;=================================================

Output_String   proc

    push bp ; save bp
    mov bp, sp

    mov ah, 02h ; for 21h

@@again:

    mov dl, [bx]        ;}
    int 21h             ;|
                        ;|
    inc bx              ;| - output symbol bu symbol
                        ;|
    mov dl, [bx]        ;|
    cmp dl, 0           ;}
    jne @@again

    pop bp

    ret
    endp


;=================================================
; Output result string
;=================================================

;Output_Result_String    proc                  ;
;                                              ;
;    mov dx, offset res_string                 ;
;                                              ;
;    mov ah, 09h                               ; I thought that we make string and then output it
;    int 21h                                   ;
;                                              ;
;    ret                                       ;
;    endp                                      ;


;=================================================


end     start
