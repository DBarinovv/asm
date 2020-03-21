.model tiny
locals @@
.data
;=================================================

format_string   db  'I love %s ', 0
helper_string   db  15  Dup (0), '$'
;res_string      db  100 Dup (0)         ; 100 - max size of string

;=================================================

.code
org 100h

start:

    call My_Printf

;    push 'A'
;    push 'B'
;    push 'C'
;    push 1359d
;    push 1488d
;
;    push offset format_string
;
;
;    call Output_String
;
;    pop ax
;    mov cl, 10d
;    call Conver_Dec_And_Output
;    pop ax
;    call Conver_Dec_And_Output
;
;    call Output_Char
;    call Output_Char
;    call Output_Char

    ret


;=================================================
; My printf
; In:
;    Format string in stack
;=================================================

My_Printf   proc

    pop si

    mov bx, offset format_string
    dec bx



@@again:

    inc bx
    mov dl, [bx]
    cmp dl, 0
    je @@exit

    cmp dl, '%'
    je @@character_%

    mov ah, 02h
    int 21h

    jmp @@again


@@character_%:

    inc bx
    mov dl, [bx]


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
    mov ah, 02h
    int 21h

    jmp @@again


;-------------------------------------------------
@@call_%s:

    call Output_String
    jmp @@again

;-------------------------------------------------
@@call_%d:

    pop ax
    mov cl, 10d
    call Conver_Dec_And_Output
    jmp @@again

;-------------------------------------------------
@@call_%b:

    pop ax
    mov cl, 2d
    call Conver_Dec_And_Output
    jmp @@again

;-------------------------------------------------
@@call_%x:

    pop ax
    mov cl, 16d
    call Conver_Dec_And_Output
    jmp @@again

;-------------------------------------------------
@@call_%o:

    pop ax
    mov cl, 8d
    call Conver_Dec_And_Output
    jmp @@again

;-------------------------------------------------
@@call_%c:

    call Output_Char
    jmp @@again

;-------------------------------------------------
@@exit:

    push si

    ret
    endp


;=================================================
; Output char (%c)
; In:
;    Symbol in stack
; Destroy:
;    AX, DX
;    Pop last from stack
;=================================================

Output_Char proc

    pop dx          ; save address of call
    pop ax          ; ax = argument from stack
    push dx         ; restore address of call (for ret)

    mov dl, al      ; dl = al = symbol for output

    mov ah, 02h     ;}
    int 21h         ;} output

    ret
    endp


;=================================================
; Conversion from decimal system to another and output (%d, %b, %x)
; In:
;    AX = decimal number
;    CL = which system
; Destroy:
;    AX, BX, DX
;=================================================

Conver_Dec_And_Output  proc

    mov bx, offset helper_string    ;}
    add bx, 14                       ;} *bx = helper_string.end

@@again:

    div cl          ; ah = ax % cl = ax % 10
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

    ret
    endp


;=================================================
; Output string (%s)
; In:
;    Address of string in stack 0-terminated
; Destroy:
;    AX, BX, DX
;    Pop last from stack
;=================================================

Output_String   proc

    pop ax
    pop bx
    push ax

    mov ah, 02h

@@again:

    mov dl, [bx]
    int 21h

    inc bx

    mov dx, [bx]
    cmp dx, 0
    jne @@again


    ret
    endp


;=================================================
; Output result string
;=================================================

;Output_Result_String    proc
;
;    mov dx, offset res_string
;
;    mov ah, 09h
;    int 21h
;
;    ret
;    endp


;=================================================


end     start
