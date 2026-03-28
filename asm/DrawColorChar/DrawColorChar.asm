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

PROC
DrawColorChar
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