; This file contains some functions that use the graphics routines to draw stuff to the screen

; proc monstersUpdateDisplay
; @destroys: AX, ES
; @result: /
; @desc: Draws the monsters
; @use: Need an abstraction for this. Just gets too cluttered otherwise.
monstersUpdateDisplay PROC NEAR USES SI BX CX
	mov ax, seg wwEnemyPositions			; set ES to segment of wwEnemyPositions... why? i honestly don't know. Take this out in the next revision
	mov es, ax								; FIXME
	mov di, offset wwEnemyPositions			; we need our enemy positions
	mov bx, offset wEnemySpriteAddresses	; we need the sprites that every enemy uses
	mov si, offset bEnemyAlive				; we need to check whether our enemies are alive
	
	mov cx, cNumMonsters					; we're gonna loop cNumMonsters times
;	mov ax, 0
doloop:
	cmp byte ptr [si], 0					; check if this monster is dead
	jz nodraw								; if so, don't draw it
	push si									; graphicsDrawSpriteMA destroys these. push them
	push bx									;     "
	graphicsDrawSpriteMA [bx], [di], [di+2]	; use a macro that calls the drawing routine
	pop bx									; pop our saved data
	pop si									;     "
nodraw:
	inc si									; si is a byte array. increment the pointer with 1
	add di, 4								; di is an array of paired words. increment the pointer with 4
	add bx, 2								; bx is a word array. increment the pointer with 2
	loop doloop								; repeat for every monster
	ret
monstersUpdateDisplay ENDP

; proc bulletUpdateDisplay
; @destroys: ES
; @result: /
; @desc: Draws the ship's bullets
bulletUpdateDisplay PROC NEAR USES AX BX CX DI
	mov ax, seg wwBulletPosition				; another completely unnecessary segment register set D:
	mov es, ax									; 
	mov bx, offset bBulletExists				; 
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

	