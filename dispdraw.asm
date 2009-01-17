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
	mov bx, offset bBulletExists				; we need to check if the bullet exists, if it doesn't, we don't draw it
	mov di, offset wwBulletPosition				; we need to draw the bullets at the correct positions
	mov cx, cNumBullets							; loop cNumBullets times (operate on all bullets)
aloop:
	cmp byte ptr [bx], 0						; see if the bullet is dead
	jz nodraw									; if so, don't draw it (jump to nodraw)
	
	push bx										; graphicsDrawSpriteM destroys bx. save it
	graphicsDrawSpriteM bBullet, [di], [di+2]	; draw the bullet sprite to the correct position ([di],[di+2])
	pop bx										; restore the bx register
nodraw:
	inc bx										; increment array pointer
	add di, 4									; increment array pointer (2 words)
	loop aloop									; loop for every bullet
	ret
bulletUpdateDisplay ENDP

; proc theirBulletUpdateDisplay
; @destroys: SI, BX, DX
; @result: /
; @desc: Draws the "their" bullets
theirBulletUpdateDisplay PROC
	cmp byte ptr bTheirBulletExists, 0								; see if their bullet is dead
	jz nodraw														; if so, don't draw it
	
	graphicsDrawSpriteM bBulletEnemy, wTheirBulletX, wTheirBulletY	; draw their bullet to the correct place
nodraw:
	ret
theirBulletUpdateDisplay ENDP

; proc drawLives
; @destroys: SI, DX
; @result: /
; @desc: Draws the ship's remaining lives
drawLives PROC NEAR USES BX CX
	mov bx, 10									; start drawing the remaining lives 10 pixels from the left border
	mov cl, bLives								; load cl with the number of lives left
	xor ch, ch									; loop uses cx, not cl, so clear the upper byte.
	
aloop:
	graphicsDrawSpriteM bSpaceship, bx, 190		; draw the spaceship sprite at (bx, 190)
	add bx, 20									; next life will be drawn 20 px further
	loop aloop									; loop for the number of lives left
	ret
drawLives ENDP

	