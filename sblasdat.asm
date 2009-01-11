cSBBufSize = 22050
sbBuf db cSBBufSize dup (?)
soundFile1 dw 0

soundFile1FN db "some.wav$",0

old_IRQ7_seg dw 0
old_IRQ7_off dw 0
next_bufpart dw 0
