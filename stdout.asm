; proc strOut
; @destroys: /
; @param DS:DX: the $ terminated string
; @returns: /
; @desc: prints a string to stdo
strOut PROC NEAR USES AX
	mov ah, 09h
	int 21
strOut ENDP

; macro strOutM
; @destroys: DX
; @param stri: the $ terminated string
; @returns: /
; @desc: prints a string to stdo
strOutM MACRO stri
	mov DX, offset stri
	call strOut
ENDM
