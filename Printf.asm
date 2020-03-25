.model tiny
.386
locals @@

;=================================================
.const

C_max_len   equ 15
;=================================================

.make_right_di      macro

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

    inc si         ; counter++

    inc bx               ;}
    mov dl, [bx]         ;} look next element after '%'


    cmp dl, 's'
    je @@call_%s

    cmp dl, 'd'
    je @@call_%d

    cmp dl, 'b'
    je @@call_%b

    cmp dl, 'x'
    je @@call_%x

    cmp dl, 'o'
    je @@call_%o

    cmp dl, 'c'
    je @@call_%c

    cmp dl, '%'

    dec si

    .output_dl

    jmp @@again


;-------------------------------------------------
@@call_%s:

    .make_right_di

    push bx
    mov bx, ax

    call Output_String
    pop bx

    jmp @@again

;-------------------------------------------------
@@call_%d:

    .make_right_di

    mov cl, 10d

    call Conver_Dec_And_Output
    jmp @@again

;-------------------------------------------------
@@call_%b:

    .make_right_di

    mov cl, 2d

    call Conver_Dec_And_Output
    jmp @@again

;-------------------------------------------------
@@call_%x:

    .make_right_di

    mov cl, 16d

    call Conver_Dec_And_Output
    jmp @@again

;-------------------------------------------------
@@call_%o:

    .make_right_di

    mov cl, 8d

    call Conver_Dec_And_Output
    jmp @@again

;-------------------------------------------------
@@call_%c:

    .make_right_di

    call Output_Char
    jmp @@again

;-------------------------------------------------
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
; Conversion from decimal system to another and output (%d, %b, %x)
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
;    Address of string in stack (0-terminated)
;
; Destroy:
;    AX, BX, DX
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
