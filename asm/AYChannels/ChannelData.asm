PROC
;----------------------------------------
; in  : a = channel number
; out : hl = channel ptr
; keep: bc,de
;----------------------------------------
calcChanPtr:
    ld l,a
    sla a
    sla a      ; mult3 to get offset

    ld hl,channels
    add a,l
    ld l,a
    ret nc
    inc h

    ret
;----------------------------------------
; 0 = cvalue
; 1 = yoff
; 2 = xoff 
; 3 = ay register
;----------------------------------------
channels:
LOCAL channels:
    db $00, 191, 15, $00
    db $00, 191, 16, $01
    db $00, 191, 17, $02
ENDP