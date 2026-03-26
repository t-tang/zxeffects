SUB DSizeHalfChar(y as uByte, x as uByte, thingToPrint as uByte, topOrBottom AS uByte)
' Prints a single character double sized.
' Takes X and Y values as character positions, like print.
' takes an ascii code value for a character.
' By Britlion, 2012.

ASM
;' A=y value
LD E,A
AND 24           ; calculate
OR 64            ; screen
LD H,A           ; address
LD A,E           ; for
AND 7            ; row
OR a             ; Y
RRA
RRA
RRA
RRA
LD E,A

LD A,(IX+7)     ;' X Value
ADD A,E         ;' correct address for column value. (add it in)
LD L,A
EX DE,HL        ;' Save it in DE
;-----------------------------------------------------------

LD A,(IX+9)     ;'Character

LD L,A
LD H,0

ADD HL,HL
ADD HL,HL
ADD HL,HL   ;' multiply by 8.
LD BC,(23606)   ;' Chars
ADD HL,BC   ;' Hl -> Character data.
EX DE,HL    ;' DE -> character data, HL-> screen address.

LD A,(ix+11)
OR A
JR Z, doIt
INC DE
INC DE
INC DE
INC DE

doIt:
dsSizePrintCharRotateLoopCharRowLoopOuter:
LD b,4 ;' 4 source bytes to count through per character row.
dsPrintCharRotateLoopCharRowLoopInner:
   PUSH BC

   LD A,(DE) ;' Grab a bitmap.
   PUSH DE

   LD B,4
   LD C,A ; Copy byte so we can put two into the big version.
   dsPrintCharRotateLoop1:
      RRA  ; one bit into carry
      RR E ; one bit into result
      RR C ; same bit into carry again
      RR E ; duplicated bit into result
   DJNZ dsPrintCharRotateLoop1

   LD B,4
   dsPrintCharRotateLoop2:
       RRA
       RR D ; Other register for other half of big 16 bit line.
       RR C
       RR D
   DJNZ dsPrintCharRotateLoop2

   LD (HL),D    ;' Output first byte
   INC HL   ;' Move right
   LD (HL),E    ;' Second half.
   DEC HL   ;' Move left
   INC H    ;' Move down
   LD (HL),D    ;' Output second row (copy of first), first byte.
   INC HL   ;' Move right
   LD (HL),E    ; Output second row, second byte
   DEC HL   ; Move left
   INC H    ; Move down.
   POP DE
   INC DE
   POP BC

DJNZ dsPrintCharRotateLoopCharRowLoopInner
END ASM
END SUB
