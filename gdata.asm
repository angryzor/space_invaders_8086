INCLUDE sprites.asm
OldVideoMode db ?

.FARDATA? videobufseg
videobuf db 64000 dup (?)
