monstersUpdateDisplay PROC USES SI BX CX
	mov ax, seg wwEnemyPositions
	mov es, ax
	mov di, offset wwEnemyPositions
	mov bx, offset wEnemySpriteAddresses
	mov si, offset bEnemyAlive
	
	mov cx, cNumMonsters
	mov ax, 0
doloop:
	cmp [si], ax
	jz nodraw
	push si
	push bx
	graphicsDrawSpriteMA [bx], [di], [di+2]
	pop bx
	pop si
nodraw:
	add di, 4
	add bx, 2
	loop doloop
	ret
monstersUpdateDisplay ENDP

bulletUpdateDisplay PROC
	mov al, bBulletExists
	cmp al, 0
	jz nodraw
	
	mov ax, seg wwBulletPosition
	mov es, ax
	mov di, offset wwBulletPosition
	graphicsDrawSpriteM bBullet, [di], [di+2]
nodraw:
	ret
bulletUpdateDisplay ENDP
