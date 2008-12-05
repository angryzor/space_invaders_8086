; macro displayHelpersFillGrayScalePalette
; @param address: address of the destination palette (MUST BE 64 OR MORE COLORS PALETTE!!!)
; @destroys: AX, CX, ES, DI
; @returns: /
; @desc: fills palette with grayscale colors
displayHelpersFillGrayScalePalette MACRO address
	mov ax, seg address
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