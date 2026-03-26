FUNCTION FASTCALL CharCellAddress(y as uByte, x as uByte) AS UINTEGER
' takes an ascii code value for a character.
' By Britlion, 2012.
ASM
;--------------------------------------
; ZX Basic entry point
;--------------------------------------
                 ; A = y cell coord
POP DE           ; ZX Basic return address
POP BC           ;
LD C,B           ; C = x cell coord
PUSH DE          ; restore return address

;--------------------------------------
; in  : A  - y cell coord
; in  : C  - x cell coord
; out : HL - screen address
; keep: BC,D
; Z80 entry point
;--------------------------------------

CharCellAddress:
;' A=y value
LD E,A
AND 24           ; calculate
OR 64            ; screen
LD H,A           ; address
LD A,E           ; for
AND 7            ; row
OR a             ; Y
RRA
RRA
RRA
RRA
LD E,A

LD A,C     ;' X Value
ADD A,E         ;' correct address for column value. (add it in)
LD L,A
END ASM
END FUNCTION
