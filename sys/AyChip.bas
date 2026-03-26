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

FUNCTION FASTCALL ReadAyRegister(register as ubyte) AS UBYTE
ASM
;------------------------------------------
; in  : A = register
; out : A = register value
; keep: DE,HL
;------------------------------------------
readAyRegister:
    LD BC, $FFFD
    OUT (C),A      ; select the register
    IN A,(C)       ; read the value
END ASM
END FUNCTION

SUB WriteAyRegister(register as ubyte, value as ubyte)
ASM
    
    LD BC, $FFFD
    OUT (C),A      ; select the register

    LD A,(ix+7)
    LD BC,$BFFD
    OUT (C),A      ; write the value

END ASM
END SUB

