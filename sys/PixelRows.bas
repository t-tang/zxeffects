#ifndef __PIXEL_ROWS__
#define __PIXEL_ROWS__

#define D_PIXELROW_TABLE_ADDR $F220
Const PixelRowTableAddr AS UINTEGER = D_PIXELROW_TABLE_ADDR
Print "Loading Pixel Row Table"
Load "PixelRowTable.bin" CODE PixelRowTableAddr

Sub FastCall LoadPixelRowAsmCode()
ASM
ret
;----------------------------------------
; in : a = y (0-191)
; out: hl = pointer into pixel row table
;----------------------------------------
PixelRowTablePtr
    ld h,$00
    ld l,a
    add hl,hl   ; each table entry is 2 bytes
    ld de, D_PIXELROW_TABLE_ADDR
    add hl,de
    ret
END ASM
END Sub

LoadPixelRowAsmCode()
#endif