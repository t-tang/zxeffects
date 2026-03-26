SUB DrawColorChar(colorCellAddr AS UINTEGER, charBytes AS UINTEGER, color AS UBYTE)
ASM
PROC
                    ; HL = color cell address
    LD E,(IX+6)
    LD D,(IX+7)     ; DE = charBytes
    LD C,(ix+9)     ; C = new color to OR in

;---------------------------------------------
; in : DE = character bytes
; in : HL = color cell address
; in : C  = color to OR into display
; Draw a character using color cells
;---------------------------------------------
;---------------------------------------------
; outer loop uses:
; C  = counter
; DE = char bytes
;---------------------------------------------
;---------------------------------------------
; inner loops uses:
; B'  = counter
; C'  = new color
; HL' = color cell
;---------------------------------------------

; initialize the shadow registers
    PUSH BC
    PUSH HL
    EXX
    POP HL
    POP BC
    EXX

    LD B,8          ; 8 bytes to copy

copyByte:
LOCAL copyByte:
    LD A,(DE)       ; A = character byte
;---------------- START INNER LOOP ------------
    EXX             ; switch to shadow registers
    LD B,8          ; 8 bits to copy

copyBit:
LOCAL copyBit:
    RLA                 ; C flag <-- char byte
    JR NC,maybeNextBit  ; skip setting the color cell

    EX AF,AF'           ; save the byte under consideration
    LD A,(HL)           ; grab the color cell currently on display
    OR C                ; OR existing color cell with the new color
    LD (HL),A           ; put combined color cell to display
    EX AF,AF'           ; restore the byte under consideration

maybeNextBit:
LOCAL maybeNextBit:
    INC HL
    DJNZ copyBit

    ; move to next color cell row
    LD A,$20 - $08  ; $08 because we moved during the loop
    ADD A,L
    LD L,A
    JR NC, endInner
    INC H
endInner:
LOCAL endInner:
    EXX             ; switch back to normal registers
;---------------- END INNER LOOP ------------

maybeNextByte:
LOCAL maybeNextByte:
    INC DE          ; next char byte
    DJNZ copyByte

endproc:
LOCAL endproc

ENDP
END ASM
END SUB

SUB CopyScreenBytes(destPtr as UINTEGER)
    POKE destPtr + 0,PEEK($4000)
    POKE destPtr + 1,PEEK($4100)
    POKE destPtr + 2,PEEK($4200)
    POKE destPtr + 3,PEEK($4300)
    POKE destPtr + 4,PEEK($4400)
    POKE destPtr + 5,PEEK($4500)
    POKE destPtr + 6,PEEK($4600)
    POKE destPtr + 7,PEEK($4700)
END SUB

FUNCTION AttrAddr(yPos as UINTEGER, xPos AS UINTEGER) AS UINTEGER
    return $5800 + yPos * $20 + xPos
END FUNCTION

Const fx as UBYTE = $C0
DIM topString as string = "GAME"
DIM botString as string = "OVER"
DIM topColors(3) as ubyte = {fx bOR ($01 << 3), fx bOR ($02 << 3), fx bOR ($03 << 3), fx bOR ($06 << 3) }
DIM botColors(3) as ubyte = {fx bOR $03, fx bOR $06, fx bOR $01, fx bOR $02 }

DIM charbufferstorage(7) AS UBYTE
DIM charbuffer AS UINTEGER = @charbufferstorage(0)

SUB RenderManicColor(ypos as UBYTE)
    DIM yoff as ubyte
    for n = 0 to 3
        PRINT AT 0,0,;" "
        printat42(0,0): print42(topString(n)): CopyScreenBytes(charbuffer)
        yoff = ypos - 4 * (n mod 2)
        print topColors(n)
        DrawColorChar(AttrAddr(yoff,n * 6), charbuffer, topColors(n))
    next

    for n = 0 to 3
        PRINT AT 0,0,;" "
        printat42(0,0): print42(botString(n)): CopyScreenBytes(charbuffer)
        yoff = ypos - 4 * NOT (n mod 2)
        print yoff
        DrawColorChar(AttrAddr(yoff,n * 6), charbuffer, botColors(n))
    next
END SUB
