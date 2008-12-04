; Graphics engine 
; ----------------------------
; Interface:
;    -- draw address, x, y
;    -- clrScr
;    -- updateVRAM

; constants
cScrWidth 				= 320
cScrHeight 				= 200

 
;proc displayClearScreen
;@desc Clears screen


displayClearScreen PROC NEAR USES ES DI AX CX 

	mov ES, seg videobuf ; ES is pointer naar het fardata segment waar de videobuf zich bevindt
	ASSUME ES:seg videobuf ;optioneel, voor betere error messages
	mov DI, offset videobuf ;pointer naar offset videobuf
	
	mov AX, 0
	mov CX, videobuf_size
	cld ;clear direction flag
	rep stosb
ENDP

displayUpdateVram PROC NEAR USES

	mov DS, seg videobuf
	ASSUME DS:seg videobuf
	mov DI, offset videobuf
	
	mov ES, seg 
	
;under construction



; macro xyConvertToMemOffset
; @destroys: AX, DX
; @result: AX: contains memory offset
; @description: converts 2 registers containing x and y to a memory offset
xyConvertToMemOffset MACRO x ,y
	mov ax, cScrWidth
	mul y
	add ax, x
ENDM

; macro xyConvertToMemOffsetSafe
; @destroys: /
; @result: AX: contains memory offset
; @description: a register-safe version of xyConvertToMemOffset
xyConvertToMemOffsetSafe MACRO x, y
	push ax
	push dx
	xyConvertToMemOffset x, y
	pop dx
	pop ax
ENDM

; proc graphicsDraw
; @param SI = sprite address
; @param BX = x offset
; @param DX = y offset
; @desc Draws a sprite to memory buffer
graphicsDraw PROC NEAR USES ax cx di es
	mov ax, seg videobuf		; set video buf segment
	mov es, ax
	ASSUME ES:SEG videobuf

	mov di, offset videobuf		; set videobuf offset

	xyConvertToMemOffset bx, dx	; 
	add di, ax

	mov cx, es:[di]
	mov ax, es:[di+1]

	add di, 2
loopDraw:
        rep movsb
	add di, cScrWidth 
	dec ax
	jnz loopDraw

graphicsDraw ENDP





	
