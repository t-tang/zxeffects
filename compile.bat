@ECHO OFF
IF "%1" == "" GOTO nomusic
SET MUSIC=%1
ECHO Compiling with %MUSIC%
c:\portable\zx\zxbasic\zxbc.exe          ^
   -M memory.txt -O0                     ^
   --output-format=tap --autorun --BASIC ^
   -W160 -W170 -W190 -W110               ^
   -D %MUSIC%                            ^
   --append-binary bin\PixelRowTable.bin ^
   --append-binary bin\Charset.bin       ^
   --append-binary tunes\%MUSIC%.bin     ^
   EffectsAll.bas
GOTO :eof

:nomusic
c:\portable\zx\zxbasic\zxbc.exe          ^
   -O0                                   ^
   --output-format=tap --autorun --BASIC ^
   -W160 -W170 -W190                     ^
   --append-binary bin\PixelRowTable.bin ^
   --append-binary bin\Charset.bin       ^
   EffectsAll.bas