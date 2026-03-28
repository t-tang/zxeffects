RenderCounterFrame:
PROC

    LD A,(nCounters)
    OR A
    RET Z

    PUSH IX
    LD IX,counters

renderNextCounter:
LOCAL renderNextCounter
    PUSH AF             ; save the counter number

    CALL renderCounter

    POP AF              ; restore counter number
    DEC A
    JR Z, allCountersRendered

    LD DE,30
    ADD IX,DE
    JR renderNextCounter

allCountersRendered:
LOCAL allCountersRendered:

    POP IX
    RET

renderCounter:
LOCAL renderCounter
    LD A,(IX+29)
    OR A
    JR Z,doRenderCounter

    DEC (IX+29)          ; decrement delay countdown
    RET

doRenderCounter:
LOCAL doRenderCounter:
    LD A,(IX+27)
    CP $08 
    JR NZ, scrollDigits

    CALL compareThisAndTarget
    RET Z

    XOR A                  ; reset frame count to 0
    LD (IX+27),A

    LD C,$00
    CALL bitmapPtrAddress  ; find addr of bitmap array in struct
    LD B,12                ; max 6 digits
    XOR A
resetBitmapPtr:
LOCAL resetBitmapPtr:
    LD (HL),A
    INC HL
    DJNZ resetBitmapPtr

    CALL bumpCounter

scrollDigits:
LOCAL scrollDigits:
    LD C,(IX+2)            ; C = number of digits

scrollDigit:
LOCAL scrollDigit:
    DEC C
    JR Z, lastDigit
    CALL scrollInDigitByte
    JR scrollDigit

lastDigit:
LOCAL lastDigit:
    CALL scrollInDigitByte

    INC (IX+27)              ; bump frame
    LD A,(IX+28)             ; reset delay countdown
    LD (IX+29),A

    RET

;----------------------------------
; scroll in next bitmap byte
; IX - counter address
; C  - digit index
; C,IX preserved
;----------------------------------
scrollInDigitByte:
LOCAL scrollInDigitByte:

    CALL bitmapPtrAddress   ; HL = ptr in counter struct for bitmap
    LD A,(HL)
    OR A                    ; Check to see if this digit needs to be scrolled
    RET Z

    EX DE,HL                ; Save ptr in counter struct for bitmap

    LD L,(IX+0)             ; calculate the screen address for this digit
    LD H,(IX+1)
    LD A,C
    ADD A,L
    LD L,A
    JR NC, moveDigitUp
    INC H                   ; HL = screen address for this digit

moveDigitUp:
LOCAL moveDigitUp:
    LD B,7                   ; move 7 bytes up

moveBytesUp:
LOCAL moveBytesUp:
    INC H
    LD A,(HL)                ; PEEK byte on next line
    DEC H
    LD (HL),A                ; POKE into current line
    INC H
    DJNZ moveBytesUp         ; move all bytes

    EX DE,HL                 ; DE = ptr to next byte to be scrolled in

    LD A,(HL)                ; follow ptr to get the actual bitmap address
    INC HL
    LD B,(HL)
    LD L,A
    LD H,B                   ; HL = bitmap ptr of byte 0

    LD A,(IX+27)             ; A = frame counter
    ADD A,L                  ; add in the frame counter as offset into bitmap bytes
    LD L,A
    JR NC, rollInNextByte
    INC H

rollInNextByte:
LOCAL rollInNextByte:
    LD A,(HL)                ; A = next bitmap byte to roll in
    LD (DE),A                ; POKE bitmap byte into screen

    RET

;----------------------------------
; Bump Counter
; IX - counter ptr
; B preserved
;----------------------------------
bumpCounter:
LOCAL bumpCounter:
    LD C,(IX+2)            ; C = number of digits
    DEC C

;----------------------------------
; Bump Digit
; IX - counter ptr
; C  - counter digit index
; BC - preserved
;----------------------------------
bumpDigit:
LOCAL bumpDigit:
    LD A,C
    AND $80                  ; check to see if we went past leading digit (digit index < 0)
    RET NZ

    PUSH IX 
    POP HL                   ; HL = counter struct ptr 
    LD A,$03                 ; HL = offset to this counter digit array
    ADD A,C                  ; offset by digit index
    ADD A,L
    LD L,A
    JR NC,bumpCounter_0
    INC H

bumpCounter_0:
LOCAL bumpCounter_0:
    INC (HL)                 ; bump digit
    LD A,(HL)
    CP $3A                   ; check for rollover from 9 to 0
    JR NZ, storeDigit
    LD A,$30                 ; rollover from 9 to 0

storeDigit:
LOCAL storeDigit:
    LD (HL),A                ; save updated digit into struture
    PUSH AF                  ; save the updated digit to avoid recalculating address

    CALL CharBitsAddress     ; HL = bitmap ptr for digit
    EX DE,HL                 ; DE = bitmap ptr for digit

    CALL bitmapPtrAddress    ; HL = ptr into counter struct for bitmap ptr

    LD (HL),E                ; store the bitmap ptr into counter struct
    INC HL
    LD (HL),D

    POP AF                  ; restore updated digit
    CP $30                  ; did we roll from 9 to 0
    RET NZ

    DEC C
    JR bumpDigit

    RET                     ; TODO bump next if C = 0

;----------------------------------
; ptr in counter struct for bitmap
; IX - counter struct ptr
; C  - digit index
; HL -> bitmap ptr addr
; IX preserved
;----------------------------------
bitmapPtrAddress:
LOCAL bitmapPtrAddress:
    PUSH IX
    POP HL                   ; calculate storage offset for bitmap ptr

    LD A,C
    SLA A                    ; digit offset in bitmap ptr array
    ADD A,$0F                ; offset into counter struct
    ADD A,L
    LD L,A
    RET NC
    INC H
    RET

;----------------------------------
; compare counter digits
; IX - counter struct ptr
; Z flat set if counters are the same
;----------------------------------
compareThisAndTarget:
LOCAL compareThisAndTarget:

    PUSH IX
    POP HL
    LD A,$09
    ADD A,L
    LD L,A
JR NC, calcThisAddr
    INC H             ; HL = target counter address in struct

calcThisAddr:
LOCAL calcThisAddr:
    PUSH IX
    POP DE
    INC DE
    INC DE
    INC DE            ; DE = this counter address in struct

    LD B,(IX+2)       ; counter length

compareNextDigit:
LOCAL compareNextDigit:
    LD A,(DE)
    CP (HL)
    RET NZ

    INC HL
    INC DE

    DJNZ compareNextDigit
    RET

nCounters:
    DB $00
;----------------------------------
; Counters data
; 0 - screenAddress
; 2 - counter length
; 3 - this counter (6 bytes)
; 9 - target counter (6 bytes)
; 15 - bitmap ptr for digit (12 bytes)
; 27 - frame counter
; 28 - delay (frame skip)
; 29 - delay countdown
;----------------------------------
counters:
    DW $0000 ; screen address
    DB $00   ; counter length
    DB $31,$32,$33,$34,$35,$36 ; this counter
    DB $39,$30,$30,$30,$38,$38 ; target counter
    DW $ffff, $ffff, $ffff, $ffff, $ffff, $ffff ; bitmaps
    DB $00 ; frame
    DB $00 ; delay (frame skip)
    DB $00 ; countdown delay

counters1:
    DW $4020 ; screen address
    DB $06   ; counter length
    DB $38,$38,$38,$38,$38,$38 ; this counter
    DB $39,$39,$39,$39,$39,$39 ; target counter
    DW $ffff, $ffff, $ffff, $ffff, $ffff, $ffff ; bitmaps
    DB $08 ; frame
    DB $00 ; delay (frame skip)
    DB $00 ; countdown delay

counters2:
    dw $4000 ; screen address
    db $06   ; counterlength
    db $30,$30,$30,$30,$30,$30 ; this counter
    db $30,$30,$30,$30,$30,$30 ; target counter
    dw $ffff, $ffff, $ffff, $ffff, $ffff, $ffff ; bitmaps
    db $08 ; frame
    db $00 ; delay (frame skip)
    db $00 ; countdown delay
ENDP