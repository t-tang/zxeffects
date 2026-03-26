Const T_FRAME_1_COLORS as ubyte = 0
Const T_FRAME_2_COLORS as ubyte = 1
Const T_TEXT_CODES     as ubyte = 2

DIM xBase AS UINTEGER = 09
DIM yBase AS UINTEGER = 09
Dim manicTextFrame as ubyte
Dim ManicTextColorAddr as UINTEGER = $5800 + (yBase * $20) + xBase

Dim ManicTextData(2,5) as UBYTE ={_
    { $44,$42,$46,$41,$43,$45 }, _ 'Frame 1 colors
    { $45,$43,$42,$46,$44,$41 }, _ 'Frame 2 colors
    { 84, 69, 84, 82, 73, 83  }  _ 'Text codes
}

Sub RenderManicTextFrame()
    if manicTextFrame = 0 then
        RenderManicTextFrame1()
    else if manicTextFrame = 10 then
        RenderManicTextFrame2()
    else
        if manicTextFrame = 19 then manicTextFrame = -1
    end if
    manicTextFrame = manicTextFrame + 1
End sub

Sub InitManicText()
    for n = 0 to 5
        DSizeHalfChar(yBase + 00,xBase + n*2,ManicTextData(T_TEXT_CODES,n),0)
        DSizeHalfChar(yBase + 02,xBase + n*2,ManicTextData(T_TEXT_CODES,n),1)
    next
End Sub

SUB TestManicText()
    InitManicText()
    while 1
        RenderManicTextFrame1()
        PAUSE 10
        RenderManicTextFrame2()
        PAUSE 10
    end while
END SUB

Sub RenderManicTextFrame1()
    Dim colorAddr as UINTEGER = ManicTextColorAddr
    for n = 0 to 5
        if n mod 2 = 0 then
            ColorTopCell(colorAddr, ManicTextData(T_FRAME_1_COLORS, n))
            DSizeHalfChar(yBase + 01,xBase + n*2,ManicTextData(T_TEXT_CODES,n),1)
        else
            ColorBotCell(colorAddr, ManicTextData(T_FRAME_1_COLORS,n))
            DSizeHalfChar(yBase + 01,xBase + n*2,ManicTextData(T_TEXT_CODES, n),0)
        end if
        colorAddr = colorAddr + 2 
    next
End Sub

Sub RenderManicTextFrame2()
    Dim colorAddr as UINTEGER = ManicTextColorAddr
    for n = 0 to 5
        if n mod 2 = 0 then
            ColorBotCell(colorAddr,ManicTextData(T_FRAME_2_COLORS,n))
            DSizeHalfChar(yBase + 01,xBase + n*2,ManicTextData(T_TEXT_CODES,n),0)
        else
            ColorTopCell(colorAddr,ManicTextData(T_FRAME_2_COLORS,n))
            DSizeHalfChar(yBase + 01,xBase + n*2,ManicTextData(T_TEXT_CODES,n),1)
        end if
        colorAddr = colorAddr + 2 
    next
End Sub

Sub FastCall ColorTopCell(attrPtr AS UINTEGER, color AS UBYTE)
ASM
    POP DE
    POP AF     ; A = color
    PUSH DE

    LD BC,$001F
    LD (HL),A
    INC HL
    LD (HL),A

    ADD HL,BC
    LD (HL),A
    INC HL
    LD (HL),A

    ADD HL,BC
    LD (HL),0
    INC HL
    LD (HL),0
    RET

END ASM
END SUB

Sub FastCall ColorBotCell(attrPtr AS UINTEGER, color AS UBYTE)
ASM
    POP DE
    POP AF     ; A = color
    PUSH DE

    LD BC,$001F
    LD (HL),0
    INC HL
    LD (HL),0

    ADD HL,BC
    LD (HL),A
    INC HL
    LD (HL),A

    ADD HL,BC
    LD (HL),A
    INC HL
    LD (HL),A
    RET

END ASM
END SUB
