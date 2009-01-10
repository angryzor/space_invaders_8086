fireBullet PROC USES AX BX DX
	mov al, bBulletExists
	cmp al, 1
	jz fireEnd
	
	mov bx, offset wwBulletPosition
	mov dx, shipX
	add dx, 6
	
	mov [bx], dx
	mov ax, shipY-5
	mov [bx+2], ax
	
	mov bBulletExists, 1
fireEnd:
	ret
fireBullet ENDP

updateBulletPosition MACRO
	mov ax, wwBulletPosition+2
	dec ax
	jnz bulletNoDestroy
	mov bBulletExists, 0
bulletNoDestroy:
	mov wwBulletPosition+2, ax
ENDM
