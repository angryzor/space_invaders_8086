; Graphics engine 
; ----------------------------
; Interface:
;    -- draw address, x, y
;    -- clrScr
;    -- updateVRAM

; constants
cScrWidth 				= 320
cScrHeight 				= 200


; macro xyConvertToMemOffset
; @destroys: AX, DX
; @result: @x: contains memory offset
; @description: converts 2 registers containing x and y to a memory offset
xyConvertToMemOffset MACRO x ,y
	mov ax, cScrWidth
	mul y
	add ax, x
ENDM

; macro xyConvertToMemOffsetSafe
; @destroys: /
; @result: @x: contains memory offset
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
; @param CX = y offset
; @desc Draws a sprite to memory buffer
graphicsDraw PROC NEAR USES ax di es
	mov ax, seg videobuf
	mov es, ax
	ASSUME ES:SEG videobuf
	mov di, videobuf
	xyConvertToMemOffset bx, cx
	add di, ax
	