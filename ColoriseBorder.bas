'----------------------------------------------
' Render Border Frame
'----------------------------------------------
SUB FASTCALL RenderColoriseBorderFrame()
ASM
PROC
    LD A,(coloriseBorderQueueLen)
    OR A
    RET Z

    PUSH IX

    LD C,A                 ; number of queue entries
    LD IX,coloriseBorderQueue

renderItems
LOCAL renderItems
    CALL renderItem        ; render queue item

    DEC C                  ; any more queue items?
    JR Z, doneRender       ; all queue items processed

    LD A,10                 ; queue entry size
    ADD A,IXL
    LD IXL,A               ; lsb for next queue item
    JR NC, renderItems
    INC IXH                ; msb for next queue item
    JR renderItems

LOCAL doneRender
doneRender
    POP IX
    RET

;--------------------------------
; renderColoriseBoxFrame
; IX - queue entry ptr
; C, IX preserved
;--------------------------------
renderItem
LOCAL renderItem

    LD A,(IX+9)
    OR A
    JR NZ,bumpFrame  ; skip this frame

doRenderItem
LOCAL doRenderItem

    LD L,(IX+7)     ; HL = current color table ptr
    LD H,(IX+8)
 
    LD E,(IX+0)
    LD D,(IX+1)     ; DE = attr address

    CALL colorAcross

    DEC DE           ; Massage DE into next attribute cell
    LD A,E
    ADD A,D_DISPLAY_WIDTH
    LD E,A
    JR NC, renderDown
    INC D

renderDown
LOCAL renderDown
    CALL colorDown

    DEC DE           ; Massage DE into next attribute cell
    LD A,E
    SUB D_DISPLAY_WIDTH
    LD E,A
    JR NC, renderBack
    DEC D

renderBack
LOCAL renderBack
    CALL colorBack

    INC DE           ; Massage DE into next attribute cell
    LD A,E
    SUB D_DISPLAY_WIDTH
    LD E,A
    JR NC, renderUp
    DEC D

renderUp
LOCAL renderUp
    CALL colorUp

doneRenderItem
LOCAL doneRenderItem
    CALL setNextColor ; for next frame
    LD (IX+7),L       ; Save color table ptr for next frame
    LD (IX+8),H

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

;----------------------------
; colorUp
; IX - queue entry ptr
; C preserved
;----------------------------
LOCAL colorUp
colorUp
    LD B,(IX+04)     ; B = height
    DEC B
    DEC B

LOCAL nextUpCell
nextUpCell
    LD A,(HL)       ; A = color
    LD (DE),A       ; set the color

    LD A,E
    SUB D_DISPLAY_WIDTH
    LD E,A
    JR NC,nextUpCell_0
    DEC D

nextUpCell_0
LOCAL nextUpCell_0
    CALL setNextColor
    DJNZ nextUpCell
    RET

;----------------------------
; colorBack
; IX - queue entry ptr
; C preserved
;----------------------------
LOCAL colorBack
colorBack
    LD B,(IX+05)     ; B = width
    DEC B

LOCAL nextBackCell
nextBackCell:
    LD A,(HL)
    LD (DE),A

    DEC DE          ; ready DE for next attribute cell
    CALL setNextColor
    DJNZ nextBackCell
    RET

;----------------------------
; IX - queue entry ptr
; C preserved
;----------------------------
LOCAL colorDown
colorDown
    LD B,(IX+04)     ; B = height
    DEC B

LOCAL nextDownCell
nextDownCell:
    LD A,(HL)       ; A = color
    LD (DE),A       ; set the color

    LD A,E
    ADD A,D_DISPLAY_WIDTH
    LD E,A
    JR NC,nextDownCell_0
    INC D

nextDownCell_0
LOCAL nextDownCell_0
    CALL setNextColor
    DJNZ nextDownCell
    RET

;----------------------------
; IX - queue entry ptr
; C preserved
;----------------------------
LOCAL colorAcross
colorAcross
    LD B,(IX+05)     ; B = width

LOCAL nextAcrossCell
nextAcrossCell:
    LD A,(HL)       ; A = color
    LD (DE),A       ; set the color

    INC DE          ; ready DE for next attribute cell
    CALL setNextColor
    DJNZ nextAcrossCell
    RET

;----------------------------
; IX - queue entry ptr
; BC,DE,HL,IX preserved
;----------------------------
LOCAL setNextColor
setNextColor
    INC HL
checkEndColorTable
LOCAL checkEndColorTable
    LD A,(HL)
    CP $FF
    RET NZ

    LD L,(IX+2)
    LD H,(IX+3)

    RET

coloriseBorderQueueLen:
    db $00
;----------------------------
; 0 - attr address
; 2 - color table ptr
; 4 - width
; 5 - height
; 6 = frames
; 7 - current color table ptr
; 9 - current frame
;----------------------------
coloriseBorderQueue
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00

;----------------------------
; Color table 0
;----------------------------
colorTable0
    db $41, $42, $FF    ; $FF is end of color table TODO: not needed?

;----------------------------
; Color table 1
;----------------------------
colorTable1
    db $41, $46, $FF

ENDP
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
