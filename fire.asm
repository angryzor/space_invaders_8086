fireBullet PROC NEAR USES AX BX DX
	cmp byte ptr bBulletExists, 1
	jz fireEnd
	
	mov bx, offset wwBulletPosition
	mov dx, shipX
	add dx, 6
	
	mov [bx], dx
	mov word ptr [bx+2], shipY-5
	
	mov bBulletExists, 1
fireEnd:
	ret
fireBullet ENDP

updateBulletPosition MACRO
	cmp byte ptr bBulletExists, 0
	jz updateBulletPositionEnd
	mov ax, wwBulletPosition+2
	sub ax, 2
	ja bulletNoDestroy
	mov bBulletExists, 0
bulletNoDestroy:
	mov wwBulletPosition+2, ax
updateBulletPositionEnd:
ENDM

checkBulletHit PROC NEAR USES AX BX CX DX SI DI
	cmp byte ptr bBulletExists, 0
	jz checkBulletHitEnd
	
	mov ax, seg bMonster1
	mov es, ax
	
	mov ax, offset wEnemySpriteAddresses
	mov dx, offset bEnemyAlive
	mov di, offset wwEnemyPositions
	mov bx, offset wwBulletPosition
	
	mov cx, cNumMonsters
aloop:
	mov si, dx
	cmp byte ptr [si], 0
	jz nohit
	
	mov si, ax
	mov si, [si]
	call collCheckHit
	jz nohit

	mov si, dx
	mov byte ptr [si], 0
	
	mov bBulletExists, 0
	jmp checkBulletHitEnd
	
nohit:
	add ax, 2
	inc dx
	add di, 4
	
	loop aloop
	
checkBulletHitEnd:
	ret
checkBulletHit ENDP
