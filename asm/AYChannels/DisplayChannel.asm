PROC
;----------------------------------------
; in : a = channel number
; in : c = new value
;----------------------------------------
displayChannel:

    push ix                 ; save ix for basic

    call calcChanPtr        ; hl = channel ptr
    push hl                 ; point ix to the channel data
    pop ix                  ; ix = channel ptr

    ld b,(ix+0)             ; b = cvalue
    ld a,(ix+1)             ; a  = yoff
    sub b                   ; a  = yoff - cvalue
    call PixelRowTablePtr   ; hl = initial screen table ptr

; main loop to set the screen pixels
nextRow:
LOCAL nextRow:

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
    ld a,$7e                ; single border pixel either side
    ld (de),a               ; set the screen pixel

    dec hl
    dec hl                  ; point to next table entry

; check for more rows to be rendered
    inc b
    ld a,c
    cp b
    jr nc,nextRow

; set the new value
    ld (ix+0),c

endproc:
LOCAL endproc:
    pop ix                  ; restore ix
ENDP