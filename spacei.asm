.MODEL large
TITLE space-invader
.STACK 1024
.DATA 
;all data is defined in data.inc
INCLUDE DATA.asm
.CODE
INCLUDE graphics.asm
INCLUDE graphhlp.asm
procKeyLeftDown MACRO
	mov bIsLeftDown, 1
ENDM
procKeyRightDown MACRO
	mov bIsRightDown, 1
ENDM
procKeySpaceDown MACRO
	mov bIsSpaceDown, 1
ENDM
procKeyLeftUp MACRO
	mov bIsLeftDown, 0
ENDM
procKeyRightUp MACRO
	mov bIsRightDown, 0
ENDM
procKeySpaceUp MACRO
	mov bIsSpaceDown, 0
ENDM
INCLUDE keyb.asm
checkKeys MACRO
	mov bx, shipX
	mov al, bIsLeftDown
	cmp al, 0
	jz leftIsNotDown
	sub bx, 2
leftIsNotDown:
	mov al, bIsRightDown
	cmp al, 0
	jz rightIsNotDown
	add bx, 2
rightIsNotDown:
	mov shipX, bx
ENDM

INCLUDE monstmov.asm
INCLUDE collisn.asm

monstersUpdateDisplay PROC USES SI BX CX
	mov ax, seg wwEnemyPositions
	mov es, ax
	mov di, offset wwEnemyPositions
	mov bx, offset wEnemySpriteAddresses
	
	mov cx, cNumMonsters
doloop:
	push bx
	graphicsDrawSpriteMA [bx], [di], [di+2]
	pop bx
	add di, 4
	add bx, 2
	loop doloop
	ret
monstersUpdateDisplay ENDP




.STARTUP
	call displayVgaMode
	displayHelpersFillGrayScalePalette bScratchPalette
	displaySetPaletteM bScratchPalette
;	call displayClearScreen
;	call graphicsDrawTest
;	call displayUpdateVram

	call keybInterruptInstall
	mov al, 0F9h
	call SendCmd
	test KbdFlags4, 80h
	jnz exitGame
	
;	xor ah, ah
;	int 16h
aloop:
	call keybBufferProcess
	checkKeys
	call updateMonsterPositions
	call displayClearScreen
;	call graphicsDrawTest
	graphicsDrawSpriteM bSpaceShip, shipX, 150
	call monstersUpdateDisplay
	call displayUpdateVram
	jmp aloop
exitGame:
	call keybInterruptUninstall
	
	call displaySetOldMode
.EXIT
END
