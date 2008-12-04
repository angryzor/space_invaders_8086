INCLUDE sprites.asm
OldVideoMode db ?

.FARDATA? videobufseg
cVideobufSize			= 64000
videobuf db cVideobufSize dup (?)
