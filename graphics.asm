; Graphics engine 
; ----------------------------
; Interface:
;    -- draw address, x, y
;    -- clrScr
;    -- updateVRAM

; constants
cScrWidth 				= 320
cScrHeight 				= 200
videobuf_size				= 64000

;MACROS;
;Macro SetVideoMode.
SetVideoMode macro NewMode, OldMode
	;current mode
	mov ah,0Fh
    int 10h
    mov OldMode,al
	;Set new video Mode
    mov ah,00h
    mov al,NewMode
    int 10h
ENDM

;Macro restore video Mode.
RestoreVideoMode macro OldMode
    mov ah,00h
    mov al,OldMode
    int 10h
ENDM

;proc Vgamode
;Set video mode on vga 320x200x256
displayVgaMode proc near
	setvideomode 13h, OldVideoMode
	ret
displayVgaMode ENDP

;Proc SetOldMode
displaySetOldMode proc near
	RestorveVideoMode macro OldVideoMode
	ret
displaySetOldMode ENDP

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
	ret
displayClearScreen ENDP

displayUpdateVram PROC NEAR USES DS SI AX ES DI AL

	mov DS, seg videobuf
	ASSUME DS:seg videobuf
	mov SI, offset videobuf
	
	mov CX, videobuf_size

	mov AX, 0A000h ;address of vram
	mov ES, AX	
	Xor DI, DI
TestBusyWithVblank:
	in AL, DX
	and AL, 8
	jnz BusyWithVblank
TestStartVblank:
	in AL, DX
	and AL, 8
	jz TestStartVblank
	;copy videobuf to vram
	cld
	rep movsb 
	ret

displayUpdateVram ENDP
	





	
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
	ret

graphicsDraw ENDP

	
