; Graphics engine 
; ----------------------------
; Interface:
;    -- draw address, x, y
;    -- clrScr
;    -- updateVRAM

; constants
cScrWidth 				= 320
cScrHeight 				= 200
videobuf_size			= 64000

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
	RestoreVideoMode OldVideoMode
	ret
displaySetOldMode ENDP

;proc displayClearScreen
;@desc Clears screen


displayClearScreen PROC NEAR USES ES DI AX CX 

	mov ax, seg videobuf 
	mov es, ax				; ES is pointer naar het fardata segment waar de videobuf zich bevindt
	ASSUME ES:seg videobuf 	;optioneel, voor betere error messages
	mov DI, offset videobuf ;pointer naar offset videobuf
	
	mov AX, 0
	mov CX, videobuf_size
	cld ;clear direction flag
	rep stosb
	ret
	
displayClearScreen ENDP

displayUpdateVram PROC NEAR USES SI AX ES DI DX

	mov ax, seg videobuf
	mov ds, ax
	ASSUME DS:seg videobuf
	mov SI, offset videobuf
	
	mov CX, videobuf_size

	mov AX, 0A000h ;address of vram
	mov ES, AX	
	Xor DI, DI
    mov dx, 03dah ; VGA status port                 
TestBusyWithVblank:
	in AL, DX
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

	xyConvertToMemOffset bx, dx	; haal sprite coordinaten op en converteer naar een memory offset > AX
	add di, ax    	; zet beginpositie in de videobuf op de destination coordinaten van de sprite
	xor dx, dx
	xor ax, ax
	mov dl, [si]				; haal sprite width op >  DL
	mov al, [si+1]				; haal sprite height op > AL

	add si, 2					; increment source pointer
loopDraw:
	mov cx, dx
	cld
    rep movsb					; kopieer 1 lijn
	add di, cScrWidth 			; verzet dest ptr naar volgende lijn
	sub di, dx					; begin terug op juiste x waarde
	dec ax						; teller 1 omlaag
	jnz loopDraw				; loopen
	ret							; return

graphicsDraw ENDP

	
