monstersUpdateDisplay PROC NEAR USES SI BX CX
	mov ax, seg wwEnemyPositions
	mov es, ax
	mov di, offset wwEnemyPositions
	mov bx, offset wEnemySpriteAddresses
	mov si, offset bEnemyAlive
	
	mov cx, cNumMonsters
;	mov ax, 0
doloop:
	cmp byte ptr [si], 0
	jz nodraw
	push si
	push bx
	graphicsDrawSpriteMA [bx], [di], [di+2]
	pop bx
	pop si
nodraw:
	inc si
	add di, 4
	add bx, 2
	loop doloop
	ret
monstersUpdateDisplay ENDP

bulletUpdateDisplay PROC NEAR USES AX BX CX DI
	mov ax, seg wwBulletPosition
	mov es, ax
	mov bx, offset bBulletExists
	mov di, offset wwBulletPosition
	mov cx, cNumBullets
aloop:
	cmp byte ptr [bx], 0
	jz nodraw
	
	push bx
	graphicsDrawSpriteM bBullet, [di], [di+2]
	pop bx
nodraw:
	inc bx
	add di, 4
	loop aloop
	ret
bulletUpdateDisplay ENDP

theirBulletUpdateDisplay PROC
	cmp byte ptr bTheirBulletExists, 0
	jz nodraw
	
	graphicsDrawSpriteM bBulletEnemy, wTheirBulletX, wTheirBulletY
nodraw:
	ret
theirBulletUpdateDisplay ENDP


drawLives PROC NEAR USES BX CX
	mov bx, 10
	mov cl, bLives
	xor ch, ch
	
aloop:
	graphicsDrawSpriteM bSpaceship, bx, 190
	add bx, 20
	loop aloop
	ret
drawLives ENDP

	