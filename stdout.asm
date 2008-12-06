; proc strOut
; @destroys: /
; @param DS:DX: the $ terminated string
; @returns: /
; @desc: prints a string to stdo
strOut PROC NEAR USES AX
	mov ah, 09h
	int 21
strOut ENDP
