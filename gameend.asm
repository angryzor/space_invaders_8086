setmem MACRO mem, memsize, val
	push ax
	push cx
	push es
	push di
	cld
	mov ax, seg mem
	mov es, ax
	ASSUME ES:seg mem
	mov di, offset mem
	
	mov ax, val
	mov cx, memsize
	rep stosb
	pop di
	pop es
	pop cx
	pop ax
ENDM
	

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

resetNewLevel PROC NEAR 
	setmem bEnemyAlive, cNumMonsters, 1
	setmem bBulletExists, cNumBullets, 0
	inc bLives
	ret
resetNewLevel ENDP
