;-------------------------------------
; in  : A  = character code
; out : HL = address of character bitmap
; keep: A,BC
;-------------------------------------
CharBitsAddress:
    LD L,A
    LD H,0

    ADD HL,HL
    ADD HL,HL
    ADD HL,HL       ; mult8
    LD DE,(23606)   ; Sytem variable Chars
    ADD HL,DE       ; hl -> Character data.
    RET