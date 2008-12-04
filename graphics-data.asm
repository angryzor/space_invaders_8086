INCLUDE sprites.asm
OldVideoMode db ?

.FARDATA? videobufseg
videobuf dw 64000 dup (?)

