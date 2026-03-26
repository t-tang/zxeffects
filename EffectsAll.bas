#include<print42.bas>
#include"sys/Defines.bas"
#include"sys/AyChip.bas"
#include"sys/PixelRows.bas"
#include"sys/Charset.bas"
#include"sys/CharBitsAddress.bas"
#include"sys/CharCellAddress.bas"
#include"sys/DoubleSizePrint.bas"
#include"sys/DSizeHalfChar.bas"
#include"sys/DrawBox.bas"

#include"ColoriseBorder.bas"
#include"ColoriseArea.bas"
#include"ManicText.bas"
#include"ScrollCounter.bas"
#include"DrawColorChar.bas"
#include"Music.bas"
#include"AYChannels.bas"

BORDER 0: PAPER 0 : INK 0: CLS

RenderManicColor(17)

'----------------------
' Colorise Border
'----------------------
DrawBox(0,0,7,4,"********")
PRINT AT 1,1;INK 7;BRIGHT 1;"SCORE"
PRINT AT 2,1;INK 7;"00000"

DrawBox(5,0,7,4,"\:'\''\':\: \ :\:.\..\.:")
PRINT AT 6,1;INK 7;BRIGHT 1;"LEVEL"
PRINT AT 7,1;INK 7;"00000"

AddColoriseBorder($5800,BorderColorTable0(),4,7,4)
AddColoriseBorder($58A0,BorderColorTable1(),4,7,6)

'----------------------
' Colorise Box
'----------------------
doubleSizePrint(0,9,"SINGLE")
doubleSizePrint(3,9,"DOUBLE")
doubleSizePrint(6,9,"TRIPLE")

PRINT AT 10,4; INK 2; "@"
PRINT AT 11,3; INK 2; "@"

AddColoriseArea($5809, ColoriseAreaShiftTable1(), 2, 12,2)
AddColoriseArea($5869, ColoriseAreaShiftTable0(), 2, 12,4)
AddColoriseArea($58C9, ColoriseAreaCycleTable(), 2, 12,2)

AddColoriseArea($5944, ColoriseAreaShiftTable2(), 1, 1,10)

AddCounter(2,1,5,0)
AddCounter(7,1,5,3)
SetCounterTarget(0,65535)
SetCounterTarget(1,65535)

InitManicText()
InitChannelTest()

FOR i = 0 to 65535
    PAUSE 1
    RenderColoriseAreaFrame()
    RenderColoriseBorderFrame()
    RenderManicTextFrame()
    RenderCounterFrame()
    'RenderManicTune()
    RenderMusic()
    RenderChannelAsm(0)
    RenderChannelAsm(1)
    RenderChannelAsm(2)
next

RemoveColoriseAreas()
RemoveColoriseBorders()
