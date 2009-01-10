random2 proc near USES DX
a=16333
b=25887
    mov ax,randomnumber
    ;times a
    mov dx,a
    mul dx
    ;add b
    add ax,b ;no need for adc, bits will be lost anyway
    ;mask 15 first bits to perform mod 2^15
    and ax,7FFFh
    mov randomnumber,ax
    ret
random2 endp

moveToNextAlive MACRO
nextAliveLoop:
	add bx, 4
	inc si
	cmp si, (offset bEnemyAlive)+cNumMonsters
	ja resetToBeginning

nextAliveLoop2:	
	
	cmp byte ptr [si], 1
	jz endNextAlive
	
	jmp nextAliveLoop
resetToBeginning:
	mov bx, offset wwEnemyPositions
	mov si, offset bEnemyAlive
	jmp nextAliveLoop2
endNextAlive:
ENDM
	
	
	
	

theyTryToFire PROC NEAR USES AX BX
	cmp byte ptr bTheirBulletExists, 1
	jz noFire
	
	call random2
;	mov bl, cNumMonsters
;	div bl
	
;	mov bl, ah
;	xor bh, bh
	and ax, 11111b
	mov si, ax
	shl ax, 1
	shl ax, 1
	mov bx, ax
	
	add bx, offset wwEnemyPositions
	add si, offset bEnemyAlive
	cmp byte ptr [si], 1
	jz okFoundIt
	moveToNextAlive
	
okFoundIt:
	mov ax, [bx]
	add ax, 8
	mov wTheirBulletX, ax
	
	mov ax, [bx+2]
	add ax, 14
	mov wTheirBulletY, ax
	
	mov bTheirBulletExists, 1
noFire:
	ret
theyTryToFire ENDP

updateTheirBulletPosition MACRO
	cmp byte ptr bTheirBulletExists, 0
	jz updateTheirBulletPositionEnd
	mov ax, wTheirBulletY
	add ax, 2
	cmp ax, cScrHeight-5
	jb theirBulletNoDestroy
	mov bTheirBulletExists, 0
theirBulletNoDestroy:
	mov wTheirBulletY, ax
updateTheirBulletPositionEnd:
ENDM

checkShipHit PROC NEAR USES SI BX DI
	mov si, offset bSpaceship
	mov di, offset shipX
	mov bx, offset wTheirBulletX
	
	call collCheckHit
	jz exitproc
	
	mov bTheirBulletExists, 0
	dec bLives
	jnz exitproc
	
	mov bGameOver, 1
exitproc:
	ret
checkShipHit ENDP
