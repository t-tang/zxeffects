;------------------------------------------
; in  : A = register
; out : A = register value
; keep: DE,HL
;------------------------------------------
readAyRegister:
    LD BC, $FFFD
    OUT (C),A      ; select the register
    IN A,(C)       ; read the value
    RET