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


cDoDisplayVolume = 1

clear macro beginchar,numberofchars ;clears numberofchars characters starting at beginchar
    push ax
    push cx
    push es
    push di
    mov ax,0b800h ;prepare regs for stosw
    mov es,ax
    mov di,beginchar*2
    ;read current character formatting (little endian so high byte is last in a word)
    mov ah,byte ptr es:[di+1]
    mov al,' '   ;space character
    mov cx,numberofchars ;clear numberofchar characters
    rep stosw    ;set memory
    pop di
    pop es
    pop cx
    pop ax
endm

cls macro ;fill video ram with spaces, formatting black background, white foregorund
    push ax
    push cx
    push es
    push di
    mov ax,0b800h ;prepare regs for stosw
    mov es,ax
    xor di,di
    ;read current character formatting (little endian so high byte is last in a word)
    mov ah,byte ptr es:[di+1]
    mov al,' '   ;space character
    mov cx,80*25 ;size of video page ascii mode 
    rep stosw    ;set memory
    pop di
    pop es
    pop cx
    pop ax
endm

hidecursor macro
    push ax
    push cx
    ;use function 1 of int 10h to hide cursor
    ;formatting of cursor in ch, bit 5 = 1 means hide cursor
    xor cx,cx
    or cx,2000h
    mov ah,01h
    int 10h
    pop cx
    pop ax
endm

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
	
IF cDoDisplayVolume
    cls ;clear screen
    hidecursor ;hide cursor
loopb:
    ;move cursor to 0,0 using int 10h, function 2
    xor dx,dx
    mov bh, 0
    mov ah, 2
    int 10h

	mov ax, seg sbbuf
	mov es, ax
	mov si, offset sbbuf
	
	xor ax, ax
	mov cx, 5511
loopa:
	mov bx, [si]
	cmp bx, 0
	jns short noneg
	neg bx
noneg:
	sar ax, 1
	sar bx, 1
	add ax, bx
	add si, 4
	loop loopa
	
	mov cl, 9
	sar ax, cl
	
	mov cx, ax
	mov dx, 60
	sub dx, cx
	cmp cx, 0
	jz loopb

loopc:
	print 'H'
	loop loopc
	mov cx, dx
loop_d:
	print ' '
	loop loop_d
;crlf:
;	printcrlf
	jmp loopb
ELSE
	xor ah, ah
	int 16h
ENDIF

	soundBlasterRelease
	
	fileClose h, noClose
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
