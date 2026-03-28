Sub LoadScrollCounterAsmCode()
Asm
    ret
    #include"asm/ScrollCounter/RenderCounterFrame.asm"
    #include"asm/ScrollCounter/CharBitsAddress.asm"
    #include"asm/ScrollCounter/CharCellAddress.asm"
End Asm
End Sub

LoadScrollCounterAsmCode()

Sub FASTCALL RenderCounterFrame()
ASM
    JP RenderCounterFrame
END ASM
END Sub

'-----------------------------------------------------------------
' Add Counter
'-----------------------------------------------------------------
FUNCTION AddCounter(yPos as UBYTE, xPos as UBYTE, counterLen as UBYTE, delay AS UBYTE) AS UINTEGER
ASM
PROC

    LD HL,nCounters
    LD A,(HL)
    INC (HL)

    LD HL,counters

    OR A
    JR Z,next_1

    LD B,A
    LD DE,30
next_0:
LOCAL next_0:
    ADD HL,DE
    DJNZ next_0
    
next_1:
LOCAL next_1:
    LD A,(IX+5)   ; yPos
    LD C,(IX+7)   ; xPos

    PUSH HL
    CALL CharCellAddress
    EX DE,HL
    POP HL

    LD (HL),E    ; lsb screen address

    INC HL
    LD (HL),D    ; msb screen address

    INC HL
    LD A,(IX+9)   ; counter len
    LD (HL),A

    INC HL        ; counter digits
    LD (HL),$30   ; digit 0
    LD D,H
    LD E,L
    INC DE
    LD BC,$0B
    LDIR

    INC HL
    INC DE
    LD (HL),$00  ; zero out bitmap ptrs
    LD BC,$0B
    LDIR

    INC HL
    LD(HL),$08   ; frame

    INC HL
    LD A,(IX+11) ; delay (frame skip)
    LD (HL), A

    INC HL
    LD (HL),$00 ; delay countdown

ENDP
END ASM
END FUNCTION

FUNCTION FASTCALL CountersPtr() AS UINTEGER
ASM
    LD HL,counters
END ASM
END FUNCTION

SUB SetCounterTarget(nCounter AS UINTEGER, n AS UINTEGER) 
    DIM x AS STRING = STR(n)
    x = "000000"(TO 5 - LEN(x)) + x
    DIM p as UINTEGER = CountersPtr() + nCounter * 30 + 9
    for i = 0 to 4
        POKE p + i, CODE(x(i))
    next
END SUB

Sub TestDrawCounter()
    AddCounter(2,1,5,3)
    AddCounter(7,1,5,0)
    SetCounterTarget(0,65535)
    SetCounterTarget(1,65535)
End Sub

SUB TestCounter()
    while 1
        for i = 0 to 7
            RenderCounterFrame()
            pause 1
        next
    end while
END SUB