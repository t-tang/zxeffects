Sub Fastcall LoadDrawColorCharAsmCode()
Asm
    ret
    #include"asm/DrawColorChar/DrawColorChar.asm"
End Asm
End Sub
LoadDrawColorCharAsmCode()

SUB DrawColorChar(colorCellAddr AS UINTEGER, charBytes AS UINTEGER, color AS UBYTE)
ASM
                    ; HL = color cell address
    LD E,(IX+6)
    LD D,(IX+7)     ; DE = charBytes
    LD C,(ix+9)     ; C = new color to OR in

    call DrawColorChar
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
