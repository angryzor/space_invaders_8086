; macro setmem
; @destroys: /
; @result: /
; @desc: Set a piece of memory to a certain value (per-byte-basis)
setmem MACRO mem, memsize, val
	push ax
	push cx
	push es
	push di
	cld
	mov ax, seg mem			
	mov es, ax
	ASSUME ES:seg mem
	mov di, offset mem		; address
	
	mov ax, val				; value
	mov cx, memsize			; size
	rep stosb				; do it (does this really need commenting? :P)
	pop di
	pop es
	pop cx
	pop ax
ENDM
	
; macro dmaSetMode
; @destroys: AL
; @result: /
; @desc: Set the DMA "mode".
checkGameWin PROC NEAR USES SI AX CX
	mov si, offset bEnemyAlive
	mov cx, cNumMonsters
aloop:
	mov al, [si]
	cmp al, 1
	jz noNotWon
	inc si
	loop aloop
won:
	call resetNewLevel
noNotWon:
	ret
checkGameWin ENDP

; macro resetNewLevel
; @destroys: /
; @result: /
; @desc: Resets the game for a new level
resetNewLevel PROC NEAR 
	setmem bEnemyAlive, cNumMonsters, 1
	setmem bBulletExists, cNumBullets, 0
	cmp byte ptr bLives, 8
	jz noinc
	inc bLives
noinc:
	ret
resetNewLevel ENDP
