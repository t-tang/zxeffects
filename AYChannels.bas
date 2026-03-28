Sub Fastcall LoadAYChannelAsmCode()
Asm
    ret
    #include"asm/AYChannels/TryDecayChannel.asm"
    #include"asm/AYChannels/ReadAYRegister.asm"
    #include"asm/AYChannels/DisplayChannel.asm"
    #include"asm/AYChannels/ChannelData.asm"
    #include"asm/AYChannels/RenderAYChannel.asm"
End Asm
End Sub

LoadAYChannelAsmCode()

/' Not used
SUB FASTCALL TryDecayChannel(channel as ubyte)
ASM
    JP tryDecayChannel
END ASM
END SUB

SUB FASTCALL DisplayChannel(channel as ubyte, newValue as ubyte)
ASM
    ; a = channel number
    ld c,(ix+7)             ; c = new value
    jp displayChannel
END ASM
END SUB
'/

Function Fastcall ChannelData(channel as ubyte) as UINTEGER
ASM
    jp calcChanPtr
END ASM
END FUNCTION

SUB FASTCALL RenderAYChannel(channel as ubyte)
ASM
    jp RenderAYChannel
END ASM
End Sub

CONST ChanAFinePitch   AS UBYTE = $00
CONST ChanACoarsePitch AS UBYTE = $01
CONST ChanBFinePitch   AS UBYTE = $02
CONST ChanBCoarsePitch AS UBYTE = $03
CONST ChanCFinePitch   AS UBYTE = $04
CONST ChanCCoarsePitch AS UBYTE = $05

CONST Mixer AS UBYTE = $07

CONST ChanAVol AS UBYTE = $08
CONST ChanBVol AS UBYTE = $09
CONST ChanCVol AS UBYTE = $0A

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
        RenderAYChannel(0)
        RenderAYChannel(1)
        RenderAYChannel(2)
        pause 1
    end while
End Sub
