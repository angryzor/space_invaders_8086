.MODEL large
TITLE space-invader
.STACK 1024
.DATA 
cBufSize = 22050
sbbuf db cBufSize dup (?)
h dw 0
fn db "some.wav$",0
noOpenS db "noOpen$",0
noSeekS db "noSeek$",0
noReadS db "noRead$",0
noCloseS db "noClose$",0
now db "now$",0
INCLUDE sblasdat.asm
.CODE
INCLUDE fileio.asm
INCLUDE stdout.asm
INCLUDE sblaster.asm
makeBlasterHandler sbbuf, cBufSize, h
.STARTUP
	fileOpenForReading fn, h, noOpen
	fileSeekStart h, 0, 44, noSeek
;	fileRead h, stobuf, 32768, EOF, noRead
	
	soundBlasterInit sbbuf, cBufSize
	
	;int 0Fh
;	in al, 21h
	

	xor ah, ah
	int 16h
	
	fileClose h, noClose
;	in al, 21h
	jmp term
noOpen:
	strOutM noOpenS
	jmp term
noSeek:
	strOutM noSeekS
	jmp term
noRead:
	strOutM noReadS
	jmp term
noClose:
	strOutM noCloseS
EOF:
term:
.EXIT 0




END
