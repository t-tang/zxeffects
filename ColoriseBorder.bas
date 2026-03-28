Sub FastCall LoadColoriseBorderAsmCode()
Asm
    ret
    #include"asm/ColoriseBorder/RenderColoriseBorderFrame.asm"
End Asm
End Sub
LoadColoriseBorderAsmCode()

'----------------------------------------------
' Render Border Frame
'----------------------------------------------
SUB FASTCALL RenderColoriseBorderFrame()
ASM
    jp RenderColoriseBorderFrame
END ASM
END SUB

'----------------------------------------------
' Add colorise border
'----------------------------------------------
SUB AddColoriseBorder(attrAddr as UINTEGER, colorTablePtr as UINTEGER, height as UBYTE, width as UBYTE, frames AS UBYTE)
ASM
PROC
    LD A,(coloriseBorderQueueLen)   ; next free slot
    CALL calcColoriseBorderQueuePtr ; HL = colorise queue ptr

    LD A,(ix+4)
    LD (HL),A                  ; lsb attr address

    INC HL
    LD A,(ix+5)
    LD (HL),A                  ; msb attr address

    INC HL
    LD A,(ix+6)
    LD (HL),A                  ; lsb color table ptr

    INC HL
    LD A,(ix+7)
    LD (HL),A                  ; msb color table ptr

    INC HL
    LD A,(ix+9)
    LD (HL),A                  ; height

    INC HL
    LD A,(ix+11)
    LD (HL),A                  ; width

    INC HL
    LD A,(ix+13)
    LD (HL),A                  ; frames

    INC HL
    LD A,(ix+6)
    LD (HL),A                  ; lsb current color table ptr

    INC HL
    LD A,(ix+7)
    LD (HL),A                  ; msb current color table ptr

    INC HL
    XOR A
    LD (HL),A                  ; current frame

    LD HL,coloriseBorderQueueLen
    INC (HL)
    JR done

;------------------------------------
; A = queue slot number
; HL -> colorise queue ptr
; C,DE preserved
;------------------------------------
LOCAL calcColoriseBorderQueuePtr
calcColoriseBorderQueuePtr
    LD HL,coloriseBorderQueue
    OR A
    RET Z

    LD B,A
LOCAL nextSlot
nextSlot
    LD A,10    ; slot size is 10
    ADD A,L
    LD L,A
    JR NC, maybeNextSlot
    INC H

LOCAL maybeNextSlot
maybeNextSlot
    DJNZ nextSlot
    RET

LOCAL done
done
ENDP
END ASM
END SUB

'----------------------------------------------
' Remove Colorise Borders
'----------------------------------------------
SUB FASTCALL RemoveColoriseBorders()
ASM
    XOR A
    LD (coloriseBorderQueueLen),A
END ASM
END SUB

'----------------------------------------------
' Border Color Table 1
'----------------------------------------------
FUNCTION BorderColorTable0() AS UINTEGER
ASM
    LD HL,colorTable0
END ASM
END FUNCTION

'----------------------------------------------
' Border Color Table 1
'----------------------------------------------
FUNCTION BorderColorTable1() AS UINTEGER
ASM
    LD HL,colorTable1
END ASM
END FUNCTION

'----------------------------------------------
' Colorise Border Test
'----------------------------------------------
SUB TestDrawColoriseBorder()

    PRINT "\F\F\F\F\F\F\F"
    PRINT "\F"; INK 7; BRIGHT 1; "LEVEL"; INK 0; BRIGHT 0;"\F"
    PRINT "\F"; INK 7; "00000"; INK 0; "\F"
    PRINT "\F\F\F\F\F\F\F"
    PRINT
    PRINT "\:'\''\''\''\''\''\':"
    PRINT "\: "; INK 7; BRIGHT 1; "LEVEL"; INK 0; BRIGHT 0;"\ :"
    PRINT "\: "; INK 7; "00000"; INK 0; "\ :"
    PRINT "\:.\..\..\..\..\..\.:"

    AddColoriseBorder($5800,BorderColorTable0(),4,7,4)
    AddColoriseBorder($58A0,BorderColorTable1(),4,7,6)

END SUB

SUB TestColoriseBorder()
    TestDrawColoriseBorder()
    for n = 0 to 65535
        RenderColoriseBorderFrame()
        PAUSE 1
    next n
    RemoveColoriseBorders()
END SUB
