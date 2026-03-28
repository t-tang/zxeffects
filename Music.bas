#define PLY_AKG_INIT $F3A9
#define PLY_AKG_PLAY $F442  

#ifdef entertainer
#define MUSIC        $FA1B
Const musicfile as string = "entertainer.bin"
#endif

#ifdef mountainking
#define MUSIC        $FA41
Const musicfile as string = "mountainking.bin"
#endif

#ifdef popcorn
#define MUSIC        $FA46
Const musicfile as string = "popcorn.bin"
#endif

#ifdef popcornclean
#define MUSIC        $FA46
Const musicfile as string = "popcornclean.bin"
#endif

#ifdef tetris
#define MUSIC        $FA41
Const musicfile as string = "tetris.bin"
#endif

#ifdef MUSIC
LOAD musicfile CODE $F3A0

ASM
    ld hl,MUSIC
    xor a                                   ;Subsong 0.
    call PLY_AKG_INIT
END ASM

Sub FASTCALL RenderMusic()
ASM
    CALL PLY_AKG_PLAY
END ASM
END SUB

#else
Sub RenderMusic()
End Sub
#endif

