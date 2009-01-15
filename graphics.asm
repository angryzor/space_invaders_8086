; Graphics engine 
; ----------------------------
; Interface:
;    -- draw address, x, y
;    -- clrScr
;    -- updateVRAM

; constants
cScrWidth 				= 320
cScrHeight 				= 200

; macro setVideoMode
; @destroys: AX
; @result: OldMode: old mode
; @desc: sets video mode to NewMode, saves old mode in OldMode
setVideoMode macro NewMode, OldMode
	;current mode
	mov ah,0Fh
    int 10h
    mov OldMode,al
	;Set new video Mode
    mov ah,00h
    mov al,NewMode
    int 10h
ENDM

; macro restoreVideoMode
; @destroys: AX
; @result: /
; @desc: sets video mode back to OldMode
restoreVideoMode macro OldMode
    mov ah,00h
    mov al,OldMode
    int 10h
ENDM

; proc Vgamode
; @destroys: /
; @result: /
; @desc: Set video mode to VGA 320x200x256 (Mode 13h)
displayVgaMode PROC NEAR USES AX

	setvideomode 13h, OldVideoMode
	ret

displayVgaMode ENDP

;proc displaySetOldMode
; @destroys: /
; @result: /
; @desc: Sets video mode back to original mode
displaySetOldMode PROC NEAR USES AX
	RestoreVideoMode OldVideoMode
	ret
displaySetOldMode ENDP

; proc displayClearScreen
; @destroys: /
; @result: /
; @desc Clears videobuf
displayClearScreen PROC NEAR USES ES DI AX CX 

	mov ax, seg videobuf 
	mov es, ax				; ES is pointer naar het fardata segment waar de videobuf zich bevindt
	ASSUME ES:seg videobuf 	;optioneel, voor betere error messages
	mov DI, offset videobuf ;pointer naar offset videobuf
	
	mov AX, 0               ; we want to fill the videobuf with 0's
	mov CX, cVideobufSize   ; this has to be done cVideobufSize times
	cld ;clear direction flag
	rep stosb               ; do CX times : copy one byte from AL to ES::DI
	ret
	
displayClearScreen ENDP

; proc displayUpdateVram
; @destroys: /
; @result: /
; @desc: Updates VGA VRAM with videobuf contents
displayUpdateVram PROC NEAR USES SI AX ES DI DX

	mov ax, seg videobuf
	mov ds, ax
	ASSUME DS:seg videobuf
	mov SI, offset videobuf
	
	mov CX, cVideobufSize

	mov AX, 0A000h ;address of vram
	mov ES, AX	
	Xor DI, DI
    mov dx, 03dah ; VGA status port                 
TestBusyWithVblank:
	in AL, DX ;because 03dah > 256 we first have to load the address of the desired port in dx;
	and AL, 8
	jnz TestBusyWithVblank
TestStartVblank:
	in AL, DX
	and AL, 8
	jz TestStartVblank
	;copy videobuf to vram
	cld
	rep movsb 
	
	mov AX, @DATA ; verzekeren dat DS terug naar DATA segment wijst
	mov DS, AX
	ASSUME DS:@DATA
	ret

displayUpdateVram ENDP
	
; proc displaySetPalette
; @param ES:SI: palette
; @destroys: /
; @result: /
; @desc: sets video palette to palette in ES:DX
displaySetPalette PROC NEAR USES AX BX CX DX
	mov ax, 1012h
	xor bx, bx
	xor cx, cx
	mov cl, byte ptr es:[si]
	mov dx, si
	inc dx
	int 10h
	ret
displaySetPalette ENDP

; macro displaySetPaletteM
; @param palette: the palette to be used
; @destroys: AX, ES, SI
; @result: /
; @desc: sets video palette to palette in ES:DX
displaySetPaletteM MACRO palette
	mov ax, seg palette
	mov es, ax
	ASSUME ES:seg palette
	mov si, offset palette
	call displaySetPalette
ENDM

; macro xyConvertToMemOffset
; @destroys: AX, DX
; @result: AX: contains memory offset
; @desc: converts 2 registers containing x and y to a memory offset
xyConvertToMemOffset MACRO x ,y
	mov ax, cScrWidth
	mul y
	add ax, x
ENDM

; macro xyConvertToMemOffsetSafe
; @destroys: /
; @result: AX: contains memory offset
; @desc: a register-safe version of xyConvertToMemOffset
xyConvertToMemOffsetSafe MACRO x, y
	push dx
	xyConvertToMemOffset x, y
	pop dx
ENDM

; proc graphicsDraw
; @param SI = sprite address
; @param BX = x offset
; @param DX = y offset
; @destroys: /
; @result: /
; @desc: Draws a sprite to memory buffer
graphicsDrawSprite PROC NEAR USES ax bx cx dx si di es
	mov ax, seg videobuf		; set video buf segment
	mov es, ax
	ASSUME ES:SEG videobuf

	mov di, offset videobuf		; set videobuf offset

	xyConvertToMemOffset bx, dx	; haal sprite coordinaten op en converteer naar een memory offset > AX
	add di, ax    	; zet beginpositie in de videobuf op de destination coordinaten van de sprite
	mov dx, [si]				; haal sprite width op >  DL
	mov ax, [si+2]				; haal sprite height op > AL

	add si, 4					; increment source pointer
loopDraw:
	mov cx, dx
innerLoopDraw:
	cmp byte ptr [si], 0FFh ; transparent
	jz transparent
	cld
    movsb					; kopieer 1 pixel
	jmp short notransp
transparent:
	inc di
	inc si
notransp:
	dec cx
	jnz innerLoopDraw
	add di, cScrWidth 			; verzet dest ptr naar volgende lijn
	sub di, dx					; begin terug op juiste x waarde
	dec ax						; teller 1 omlaag
	jnz loopDraw				; loopen
	ret							; return

graphicsDrawSprite ENDP

; proc graphicsDraw
; @destroys: /
; @result: /
; @desc: Draws a 256 color test line
graphicsDrawTest PROC NEAR USES AX ES DI CX
	mov ax, seg videobuf		; set video buf segment
	mov es, ax
	ASSUME ES:SEG videobuf

	mov di, offset videobuf		; set videobuf offset
	
	mov ax, 255
	add di, ax
	
	mov CX, 200
loopDrawTest:
	std
	stosb
	dec ax
	jnz loopDrawTest
	
	mov ax, 255
	add di, cScrWidth
	add di, ax
	
	loop loopDrawTest
	ret
graphicsDrawTest ENDP

; macro graphicsDrawSpriteM
; @destroys: SI, BX, DX
; @result: /
; @desc: Draws a sprite to memory buffer (convenience macro)
graphicsDrawSpriteM MACRO spriteAddr, x, y
	mov si, offset spriteAddr
	mov bx, x
	mov dx, y
	call graphicsDrawSprite
ENDM

; macro graphicsDrawSpriteFarM
; @destroys: SI, AX, BX, DX
; @result: /
; @desc: Draws a sprite to memory buffer (convenience macro)
graphicsDrawSpriteFarM MACRO spriteAddr, x, y
	mov bx, x
	mov dx, y
	mov ax, seg spriteAddr
	mov ds, ax
	ASSUME DS:seg spriteAddr
	mov si, offset spriteAddr
	call graphicsDrawSprite
	mov dx, @DATA
	mov ds, dx
	ASSUME DS:@DATA
ENDM

; macro graphicsDrawSpriteMA
; @destroys: SI, BX, DX
; @result: /
; @desc: Draws a sprite to memory buffer (convenience macro)
graphicsDrawSpriteMA MACRO spriteAddr, x, y
	mov si, spriteAddr
	mov bx, x
	mov dx, y
	call graphicsDrawSprite
ENDM
