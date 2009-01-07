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
.STARTUP
	call displayVgaMode
	displayHelpersFillGrayScalePalette bScratchPalette
	displaySetPaletteM bScratchPalette
	call displayClearScreen
	call graphicsDrawTest
;	graphicsDrawSpriteM bMonster1, 140, 100
;	graphicsDrawSpriteM bMonster1, 140, 120
;	graphicsDrawSpriteM bMonster1, 140, 140
;	graphicsDrawSpriteM bMonster1, 140, 160
;	graphicsDrawSpriteM bMonster1, 140, 180
;	graphicsDrawSpriteM bMonster1, 140, 80
;	graphicsDrawSpriteM bMonster1, 140, 60
;	graphicsDrawSpriteM bSpaceShip, 160, 100
	call displayUpdateVram

;	mov al, 0F3h
;	call SendCmd
;	mov al, 01111111y
;	call SendCmd
	mov al, 0F9h
	call SendCmd
	call keybInterruptInstall
;	xor ah, ah
;	int 16h
aloop:
	call keybBufferProcess
	checkKeys
	call displayClearScreen
	graphicsDrawSpriteM bSpaceShip, shipX, 150
	call displayUpdateVram
	jmp aloop
exitGame:
	call keybInterruptUninstall
	
	call displaySetOldMode
.EXIT
END
