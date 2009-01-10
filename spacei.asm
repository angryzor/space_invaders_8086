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
	cmp bx, 0
	jz shipOnLeftBorder
	sub bx, 2
leftIsNotDown:
shipOnLeftBorder:
	mov al, bIsRightDown
	cmp al, 0
	jz rightIsNotDown
	cmp bx, cScrWidth-16
	jz shipOnRightBorder
	add bx, 2
rightIsNotDown:
shipOnRightBorder:
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
	
	; this code normally disables typematic (for extra speed). However... DOSBox doesn't process it (i checked the DOSBox source). Just leaving it in anyway.
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
	displayHelpersDebugDrawHorizontalLine bBufLen, 0
;	call graphicsDrawTest
	graphicsDrawSpriteM bSpaceShip, shipX, 150
	call monstersUpdateDisplay
	call displayUpdateVram
;	cmp bError, 4
;	ja exitGame
	jmp aloop
exitGame:
	call keybInterruptUninstall
	
	call displaySetOldMode
.EXIT
END
