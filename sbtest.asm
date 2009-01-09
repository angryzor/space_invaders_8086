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
print macro character
    mov ah,02h
    mov dl,character
    int 21h
endm

printcrlf macro
    mov ah,02h
    mov dl,0Ah
    int 21h
    mov ah,02h
    mov dl,0Dh
    int 21h
endm
makeBlasterHandler sbbuf, cBufSize, h
.STARTUP
	fileOpenForReading fn, h, noOpen
	fileSeekStart h, 0, 44, noSeek
;	fileRead h, stobuf, 32768, EOF, noRead
	
	soundBlasterInit sbbuf, cBufSize
	
	;int 0Fh
;	in al, 21h
	
;loopb:
;	mov ax, seg sbbuf
;	mov es, ax
;	mov si, offset sbbuf
;	
;	xor ax, ax
;	mov cx, 5511
;loopa:
;	mov bx, [si]
;	cmp bx, 0
;	jns short noneg
;	neg bx
;noneg:
;	sar ax, 1
;	sar bx, 1
;	add ax, bx
;	add si, 4
;	loop loopa
;	
;	mov cl, 9
;	sar ax, cl
;	
;	mov cx, ax
;	cmp cx, 0
;	jz crlf
;
;loopc:
;	print 'H'
;	loop loopc
;crlf:
;	printcrlf
;	jmp loopb

	xor ah, ah
	int 16h
	
	soundBlasterRelease
	
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
