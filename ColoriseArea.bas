'----------------------------------------------
' Render Box Frame
'----------------------------------------------
SUB FASTCALL RenderColoriseAreaFrame()
ASM
PROC
    LD A,(coloriseAreaQueueLen)
    OR A
    RET Z                   ; Queue is empty

    PUSH IX
    LD IX,coloriseAreaQueue  ; start going through the queue

    LD B,A                  ; number of queue items
renderItems
LOCAL renderItems
    PUSH BC                 ; save queue counter
    CALL renderItem
    POP BC                  ; recover queue counter

    DEC B                   ; are we done with the queue?
    JR Z,retBasic

    LD A,10                 ; queue item size
    ADD A,IXL               ; bump lsb of queue item ptr
    LD IXL,A
    JR NC, renderItems
    INC IXH                 ; bump msb of queue item ptr
    JR renderItems

retBasic
LOCAL retBasic
    POP IX
    RET

;--------------------------------
; IX - queue ptr
; IX preserved
;--------------------------------
renderItem
LOCAL renderItem

    LD A,(IX+9)
    OR A
    JR NZ,bumpFrame

doRenderItem
LOCAL doRenderItem
    LD L,(IX+07)
    LD H,(IX+08)  ; HL = current color table ptr

    LD A,(HL)     ; fetch the instruction
checkSkipFrame
LOCAL checkSkipFrame
    CP $FE
    JR NZ, checkReset

    INC HL      ; skip this frame
    JR endRender

checkReset
LOCAL checkReset
    CP $FF
    JR NZ, coloriseRows

    LD L,(IX+2)
    LD H,(IX+3)  ; HL = base color table ptr
    LD (IX+07),L
    LD (IX+08),H  ; reset current color table ptr

;--------------------------------
; IX - queue ptr
; IX preserved
;--------------------------------

LOCAL coloriseRows  
coloriseRows
    LD E,(IX+0)
    LD D,(IX+1)  ; DE = dest attr addr

    LD C,(IX+4)  ; C = height
LOCAL nextRow
nextRow
    PUSH DE           ; save attr addr
    CALL coloriseRow  ; colorise the row
    POP DE            ; retrieve attr addr
    DEC C
    JR Z, endRender   ; more rows?
    
    LD A,D_DISPLAY_WIDTH ; next attr addr
    ADD A,E
    LD E,A
    JR NC, nextRow
    INC D
    JR nextRow

LOCAL endRender
endRender
;--------------------------------
; HL -> next color table entry
;--------------------------------
    LD (IX+07),L
    LD (IX+08),H   ; Save color table ptr for next frame

bumpFrame
LOCAL bumpFrame
    LD A,(IX+9)
    INC A             ; Bump frame counter
    LD B,(IX+6)
    CP B              ; have we hit frames
    JR C, storeFrameCount
    XOR A

storeFrameCount
LOCAL storeFrameCount
    LD (IX+9),A       ; store the frame count

    RET

;----------------------------------
; IX - coloriseBorderQueuePtr
; DE - attr addr
; C, IX Preserved
;----------------------------------
LOCAL coloriseRow
coloriseRow:

    LD L,(IX+07)
    LD H,(IX+08)  ; HL = current color table ptr

LOCAL colorizeRow_0
colorizeRow_0
    LD B,(IX+5)    ; B = width
colorizeRow_1

    LD A,(HL)      ; A = color
    LD (DE),A      ; copy color to attr addr
    INC DE
    INC HL

    DJNZ colorizeRow_1
    RET

coloriseAreaQueueLen
    DB $00
;-----------------------------
; 0 - attr addr
; 2 - color table ptr
; 4 - height
; 5 - width
; 6 - frames
; 7 - current color table ptr
; 9 - current frame
;-----------------------------
coloriseAreaQueue
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00

coloriseAreaShiftTable0:
    DW $4141, $4242, $4343, $4444, $4545, $4646
    DW $4646, $4141, $4242, $4343, $4444, $4545
    DW $4545, $4646, $4141, $4242, $4343, $4444
    DW $4444, $4545, $4646, $4141, $4242, $4343
    DW $4343, $4444, $4545, $4646, $4141, $4242
    DW $4242, $4343, $4444, $4545, $4646, $4141
    DB $FF

coloriseAreaShiftTable1:
    DW $4646, $4242, $4242, $4242, $4242, $4242
    DW $4242, $4646, $4242, $4242, $4242, $4242
    DW $4242, $4242, $4646, $4242, $4242, $4242
    DW $4242, $4242, $4242, $4646, $4242, $4242
    DW $4242, $4242, $4242, $4242, $4646, $4242
    DW $4242, $4242, $4242, $4242, $4242, $4646
    DW $FEFE, $FEFE

    DW $4242, $4242, $4242, $4242, $4646, $4242
    DW $4242, $4242, $4242, $4646, $4242, $4242
    DW $4242, $4242, $4646, $4242, $4242, $4242
    DW $4242, $4646, $4242, $4242, $4242, $4242
    DW $4646, $4242, $4242, $4242, $4242, $4242
    DW $FEFE, $FEFE
    DB $FF

coloriseAreaShiftTable2:
    DB $00,$02,$42,$FE,$FE,$FF

coloriseAreaCycleUpTable:
    DW $4141, $4141, $4141, $4141, $4141, $4141
    DW $4242, $4242, $4242, $4242, $4242, $4242
    DW $4343, $4343, $4343, $4343, $4343, $4343
    DW $4444, $4444, $4444, $4444, $4444, $4444
    DW $4545, $4545, $4545, $4545, $4545, $4545
    DW $4646, $4646, $4646, $4646, $4646, $4646
    DW $4747, $4747, $4747, $4747, $4747, $4747
    DW $FEFE, $FEFE

colorCycleDnTable:
    DW $0707, $0707, $0707, $0707, $0707, $0707
    DW $0606, $0606, $0606, $0606, $0606, $0606
    DW $0505, $0505, $0505, $0505, $0505, $0505
    DW $0404, $0404, $0404, $0404, $0404, $0404
    DW $0303, $0303, $0303, $0303, $0303, $0303
    DW $0202, $0202, $0202, $0202, $0202, $0202
    DW $0101, $0101, $0101, $0101, $0101, $0101
    DW $0000, $0000, $0000, $0000, $0000, $0000
    DW $FEFE
    DB $FF

colorShiftEnd
ENDP
END ASM
END SUB

'------------------------------------------------------------
' Add Box Effect'
'------------------------------------------------------------
SUB AddColoriseArea(attrAddr as UINTEGER, colorTablePtr as UINTEGER, height as UBYTE, width as UBYTE, frames AS UBYTE)
ASM
    LD A,(coloriseAreaQueueLen)
    CALL calcColoriseAreaQueuePtr

    LD A,(ix+4)    ; lsb attribute address
    LD (HL),A      

    INC HL
    LD A,(ix+5)    ; msb attribute address
    LD (HL),A      

    INC HL         ; lsb color table ptr
    LD A,(ix+6)
    LD(HL),A

    INC HL         ; msb color table ptr
    LD A,(ix+7)
    LD(HL),A

    INC HL         ; height
    LD A,(ix+9)
    LD(HL),A

    INC HL         ; width
    LD A,(ix+11)
    LD(HL),A

    INC HL         ; frames
    LD A,(ix+13)
    LD(HL),A

    INC HL
    LD A,(ix+6)   ; lsb current color table ptr
    LD(HL),A

    INC HL
    LD A,(ix+7)   ; msb current color table ptr
    LD(HL),A

    INC HL        ; current frame count
    XOR A
    LD (HL),A

    LD HL,coloriseAreaQueueLen
    INC (HL)

    JR endProc

;------------------------------------
; TODO: combine with Border calc
; A = queue slot number
; HL -> colorise queue ptr
; C,DE preserved
;------------------------------------
calcColoriseAreaQueuePtr
LOCAL calcColoriseAreaQueuePtr
    LD HL,coloriseAreaQueue
    OR A 
    RET Z

    LD B,A
nextSlot
LOCAL nextSlot
    LD A,10
    ADD A,L
    LD L,A
    JR NC, next
    INC H

next
LOCAL next
    DJNZ nextSlot
    RET

endProc
LOCAL endProc
END ASM
END SUB

'------------------------------------------------------------
' Remove colorise box effects
'------------------------------------------------------------
SUB FASTCALL RemoveColoriseAreas()
ASM
    LD A,$00
    LD (coloriseAreaQueueLen),A
END ASM
END SUB

'------------------------------------------------------------
' Colorise Box Color Tables
'------------------------------------------------------------
FUNCTION FASTCALL ColoriseAreaShiftTable0() AS UINTEGER
ASM
    LD HL, coloriseAreaShiftTable0
END ASM
END FUNCTION

FUNCTION FASTCALL ColoriseAreaShiftTable1() AS UINTEGER
ASM
    LD HL, coloriseAreaShiftTable1
END ASM
END FUNCTION

FUNCTION FASTCALL ColoriseAreaShiftTable2() AS UINTEGER
ASM
    LD HL, coloriseAreaShiftTable2
END ASM
END FUNCTION

FUNCTION FASTCALL ColoriseAreaCycleTable() AS UINTEGER
ASM
    LD HL, coloriseAreaCycleUpTable
END ASM
END FUNCTION

'------------------------------------------------------------
' Test Colorise Box
'------------------------------------------------------------
SUB TestDrawColoriseArea()
    doubleSizePrint(0,9,"SINGLE")
    doubleSizePrint(3,9,"DOUBLE")
    doubleSizePrint(6,9,"TETRIS")

    AddColoriseArea($5809, ColoriseAreaShiftTable1(), 2, 12,2)
    AddColoriseArea($5869, ColoriseAreaShiftTable0(), 2, 12,4)
    AddColoriseArea($58C9, ColoriseAreaCycleTable(), 2, 12,2)
END SUB

SUB TestColoriseArea()
    for i = 1 to 20 * 6 * 2
        RenderColoriseAreaFrame()
        PAUSE 1
    next

    RemoveColoriseAreas()
END SUB