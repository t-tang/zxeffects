PROC
RenderColoriseBorderFrame
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