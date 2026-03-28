PROC
;----------------------------------
; in : ix = channel ptr
;----------------------------------
tryDecayChannel:

    ld b,(ix+0)             ; b = cvalue
    xor a
    cp b                    ; is there anything to decay?
    ret z                   ; already 0, nothing to decay

    ld a,(ix+1)             ; a  = yoff
    sub b                   ; a  = yoff - cvalue
    call PixelRowTablePtr   ; hl = initial screen table ptr

; decode the screen table ptr
    ld e,(hl)               ; decode screen table ptr
    inc hl
    ld d,(hl)               ; de = screen address
    dec hl                  ; reset hl

; add the x offset
    ld a,(ix+2)
    add a,e
    ld e,a
    jr nc, setByte
    inc d

setByte:
LOCAL setByte:
    xor a
    ld (de),a               ; set the screen pixel

; decay the cvalue
    dec b
    ld (ix+0),b
    ret

ENDP