; macro displayHelpersFillGrayScalePalette
; @param address: address of the destination palette (MUST BE 64 OR MORE COLORS PALETTE!!!)
; @destroys: AX, CX, ES, DI
; @returns: /
; @desc: fills palette with grayscale colors
displayHelpersFillGrayScalePalette MACRO address
	mov ax, seg address			; 
	mov es, ax
	ASSUME ES:seg address
	
	mov di, offset address
	
	mov al, 64
	mov byte ptr es:[di], al	;set palette size to 64
	inc di						; set DI to start of palette data
	
	xor ax, ax					; AX = 0
		
	mov cx, 64					; loop 64 times
	
fillGSLoop:
	stosb						; store AL in es:[di] and increment di, 3 times
	stosb						;
	stosb						;
	inc al						; increment AL
	loop fillGSLoop 			; loop
ENDM

; proc displayHelpersLoadPaletteFile
; @destroys: AX, CX, ES, DI
; @returns: /
; @desc: loads a palette file into the scratchpalette
displayHelpersLoadPaletteFile PROC NEAR
	mov ax, seg bScratchPalette													; point to Scratch Palette
	mov es, ax
	mov ES:byte ptr bScratchPalette, 250										; tell the palette that it is 250 colors large
	fileOpenForReading bPaletteFileName, wTMPFile, noPaletteLoad				; open palette file, wTMPFile is file handle
	fileRead wTMPFile, (bScratchPalette+1), 768, noPaletteLoad, noPaletteLoad	; read 768 bytes from the file
	fileClose wTMPFile, noPaletteLoad											; close the file
	mov di, (offset bScratchPalette)+1											; we want a possible value of 0-63 for every color component (RGB) (6 bits per main color, or RGB666). However, an ACT palette is formatted in RGB888 format. We have to convert it.
	mov cx, 768																	; And we're gonna do this for every color in the palette
aloop:
	mov al, es:[di]																
	shr al, 1
	shr al, 1
	stosb
	loop aloop
noPaletteLoad:
	
	ret
displayHelpersLoadPaletteFile ENDP

; proc displayHelpersLoadBG
; @destroys: ES
; @returns: /
; @desc: loads the background into the wwbLargeSprite
displayHelpersLoadBG PROC NEAR USES AX
	mov ax, seg wwbLargeSprite
	mov es, ax
	ASSUME ES:seg wwbLargeSprite
	mov word ptr wwbLargeSprite, 320
	mov word ptr (wwbLargeSprite+2), 200
	fileOpenForReading bBGFileName, wTMPFile, noBGLoad
	fileRead wTMPFile, (wwbLargeSprite+4), cVideoBufSize, noBGLoad, noBGLoad
	fileClose wTMPFile, noBGLoad
noBGLoad:
	ret
displayHelpersLoadBG ENDP

; proc displayHelpersLoadMenu
; @destroys: ES
; @returns: /
; @desc: loads the background into the wwbLargeSprite
displayHelpersLoadMenu PROC NEAR USES AX
	mov ax, seg wwbLargeSprite
	mov es, ax
	ASSUME ES:seg wwbLargeSprite
	mov word ptr wwbLargeSprite, 320
	mov word ptr (wwbLargeSprite+2), 200
	fileOpenForReading bTitleFileName, wTMPFile, noBGLoad
	fileRead wTMPFile, (wwbLargeSprite+4), cVideoBufSize, noBGLoad, noBGLoad
	fileClose wTMPFile, noBGLoad
noBGLoad:
	ret
displayHelpersLoadMenu ENDP

displayHelpersDebugDrawHorizontalLineB MACRO llength, yline
	mov ax, seg videobuf		; set video buf segment
	mov es, ax
	ASSUME ES:SEG videobuf

	mov di, offset videobuf		; set videobuf offset
	
	mov bx, yline
	mov ax, cScrWidth
	mul bx
	add di, ax

	mov ax, 03fh
	xor cx, cx
	mov cl, llength
	cld
	rep stosb
ENDM
displayHelpersDebugDrawHorizontalLineW MACRO llength, yline
	push dx
	mov ax, seg videobuf		; set video buf segment
	mov es, ax
	ASSUME ES:SEG videobuf

	mov di, offset videobuf		; set videobuf offset
	
	mov bx, yline
	mov ax, cScrWidth
	mul bx
	add di, ax

	mov ax, 03fh
	pop dx
	mov cx, llength
	cld
	rep stosb
ENDM
