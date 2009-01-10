OldIntHandler dd ?
KbdFlags4 db 0
bKeybInputBuffer db 256 dup (?)
bKeybInputBufferLoBound db 0
bKeybInputBufferHiBound db 0
bKeybNextIsArrow db 0

bBufLen db 0
bError db 0