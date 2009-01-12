findEmptyBullet MACRO
	mov bx, offset bBulletExists
	mov si, offset wwBulletPosition
	mov cx, cNumBullets
loopsrch:
	cmp byte ptr [bx], 0
	jz bulletFound
	
	inc bx
	add si, 4
	loop loopsrch
	
	jmp fireEnd
bulletFound:
ENDM

fireBullet PROC NEAR USES AX BX CX DX SI
	findEmptyBullet
	
	mov dx, shipX
	add dx, 6
	
	mov [si], dx
	mov word ptr [si+2], shipY-5
	
	mov byte ptr [bx], 1
fireEnd:
	ret
fireBullet ENDP

updateBulletPosition MACRO
	mov bx, offset bBulletExists
	mov si, offset wwBulletPosition
	mov cx, cNumBullets
updateBulletLoop:
	cmp byte ptr [bx], 0
	jz updateBulletPositionEnd
	mov ax, [si+2]
	sub ax, 2
	ja bulletNoDestroy
	mov byte ptr [bx], 0
bulletNoDestroy:
	mov [si+2], ax
updateBulletPositionEnd:
	inc bx
	add si, 4
	loop updateBulletLoop
ENDM

checkBulletsHit PROC NEAR USES SI BX AX
	mov si, offset bBulletExists
	mov bx, offset wwBulletPosition
	
	mov cx, cNumBullets
aloop:
	cmp byte ptr [si], 0
	jz next
	
	call checkBulletHit
	mov [si], al
next:
	add bx, 4
	inc si
	loop aloop
	ret
checkBulletsHit ENDP

; PARAM: BX: offset of bullet position
checkBulletHit PROC NEAR USES BX CX DX SI DI
	mov ax, seg bMonster1
	mov es, ax
	
	mov ax, offset wEnemySpriteAddresses
	mov dx, offset bEnemyAlive
	mov di, offset wwEnemyPositions
	
	mov cx, cNumMonsters
aloop:
	mov si, dx
	cmp byte ptr [si], 0
	jz nohit
	
	mov si, ax
	mov si, [si]
	call collCheckHit
	jz nohit
; it did hit
	mov si, dx
	mov byte ptr [si], 0
	
	mov ax, 0
	jmp checkBulletHitEnd
	
nohit:
	add ax, 2
	inc dx
	add di, 4
	
	loop aloop
	mov ax, 1
checkBulletHitEnd:
	ret
checkBulletHit ENDP
