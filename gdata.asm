INCLUDE sprites.asm
OldVideoMode db ?

.FARDATA? videobufseg
cVideobufSize			= 64000
videobuf db cVideobufSize dup (?)
bScratchPalette db ?
				db 256*3 dup (?)
