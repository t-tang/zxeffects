;----------------------------------------
; a = channel number
;----------------------------------------
RenderAYChannel
PROC
    ld e,a                  ; save the channel number
    push ix

    call calcChanPtr        ; hl = channel ptr
    push hl                 ; point ix to the channel data
    pop ix                  ; ix = channel ptr

    ld a,(ix+3)             ; a = AY register
    call readAyRegister     ; a = regster value
    srl a
    srl a
    srl a
    ld b,(ix+0)             ; b = cvalue
    cp b                    ; test newvalue > cvalue
    jr z,doDecay
    jr c,doDecay            ; cvalue > newvalue

    ld c,a                  ; c = new value
    ld a,e                  ; recover channel number
    call displayChannel     ;
    jr endproc              ; exit with new register, accepted

doDecay:
    call tryDecayChannel
    call tryDecayChannel

endproc:
LOCAL endproc:
    pop ix
ENDP