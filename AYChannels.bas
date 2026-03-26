SUB FASTCALL TryDecayChannel(channel as ubyte)
ASM
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
    call PixelRowTablePtr ; hl = initial screen table ptr

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

ENDP
END ASM
END SUB

SUB FASTCALL DisplayChannel(channel as ubyte, newValue as ubyte)
ASM
PROC

    ; a = channel number
    ld c,(ix+7)             ; c = new value
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
END ASM
END SUB

Function fastcall ChannelData(channel as ubyte) as UINTEGER
ASM
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
END ASM
END FUNCTION

SUB FASTCALL RenderChannelAsm(channel as ubyte)
ASM
PROC
    ; a = channel number
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
END ASM
End Sub

Sub InitChannel(channel as ubyte, yoff as ubyte, xoff as ubyte, ayReg as ubyte)
    dim channelPtr as UINTEGER = ChannelData(channel)
    poke channelPtr + 0, $00
    poke channelPtr + 1, yoff
    poke channelPtr + 2, xoff
    poke channelPtr + 3, ayReg

    dim endrow as UBYTE = yoff / 8

    PRINT AT endrow - 3,xoff;INK 2; "  "
    PRINT AT endrow - 2,xoff;INK 6; "  "
    PRINT AT endrow - 1,xoff;INK 4; "  "
    PRINT AT endrow - 0,xoff;INK 4; "  "
End Sub

Sub InitChannelTest()
    InitChannel(0, 183, 28, 0)
    InitChannel(1, 183, 29, 1)
    InitChannel(2, 183, 30, 2)
End sub

Sub ChannelTest()
    InitChannelTest()
    while 1
        RenderMusic()
        RenderChannelAsm(0)
        RenderChannelAsm(1)
        RenderChannelAsm(2)
        pause 1
    end while
End Sub
