.MODEL large
TITLE space-invader
.STACK 1024
.DATA 
sbbuf db 16384 dup (?)
stobuf db 32768 dup (?)
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
makeBlasterHandler sbbuf, 16384, stobuf, 32768
.STARTUP
	fileOpenForReading fn, h, noOpen
	fileSeekStart h, 0, 44, noSeek
	fileRead h, stobuf, 32768, EOF, noRead
	fileClose h, noClose
	
;	mov cx, 16384
;	mov si, offset stobuf
;	mov ax, seg sbbuf
;	mov es, ax
;	mov di, offset sbbuf
;	rep movsb
;	
;	mov ax, 0
;	mov di, offset stobuf
;	mov cx, 32768
;	rep stosb

	
	soundBlasterInit sbbuf, 16384
	
	;int 0Fh
	in al, 21h
	

	xor ah, ah
	int 16h
	
	in al, 21h
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
