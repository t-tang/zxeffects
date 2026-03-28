Sub FastCall LoadColoriseAreaAsmCode()
Asm
    ret
    #include"asm/ColoriseArea/RenderColoriseAreaFrame.asm"
End Asm
End Sub
LoadColoriseAreaAsmCode()

'----------------------------------------------
' Render Box Frame
'----------------------------------------------
SUB FASTCALL RenderColoriseAreaFrame()
ASM
    jp RenderColoriseAreaFrame
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