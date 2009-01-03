.MODEL large
TITLE space-invader
.STACK 1024
.DATA 
;all data is defined in data.inc
INCLUDE DATA.asm
.CODE
INCLUDE graphics.asm
INCLUDE graphhlp.asm
INCLUDE keyb.asm
procKeyLeftDown PROC
	graphicsDrawSpriteM bSpaceShip, 200, 100
	ret
procKeyLeftDown ENDP
procKeyRightDown PROC
	graphicsDrawSpriteM bSpaceShip, 200, 100
	ret
procKeyRightDown ENDP
procKeyLeftUp PROC
	graphicsDrawSpriteM bSpaceShip, 200, 100
	ret
procKeyLeftUp ENDP
procKeyRightUp PROC
	graphicsDrawSpriteM bSpaceShip, 200, 100
	ret
procKeyRightUp ENDP
procKeySpaceUp PROC USES SI BX DX
	graphicsDrawSpriteM bSpaceShip, 10, 10
	ret
procKeySpaceUp ENDP
procKeySpaceDown PROC USES SI BX DX
	graphicsDrawSpriteM bSpaceShip, 10, 10
	ret
procKeySpaceDown ENDP
.STARTUP
	call displayVgaMode
	displayHelpersFillGrayScalePalette bScratchPalette
	displaySetPaletteM bScratchPalette
	call displayClearScreen
	call graphicsDrawTest
	graphicsDrawSpriteM bMonster1, 140, 100
	graphicsDrawSpriteM bMonster1, 140, 120
	graphicsDrawSpriteM bMonster1, 140, 140
	graphicsDrawSpriteM bMonster1, 140, 160
	graphicsDrawSpriteM bMonster1, 140, 180
	graphicsDrawSpriteM bMonster1, 140, 80
	graphicsDrawSpriteM bMonster1, 140, 60
	graphicsDrawSpriteM bSpaceShip, 160, 100
	call displayUpdateVram

	call keybInterruptInstall
;	xor ah, ah
;	int 16h
aloop:
	call keybBufferProcess
	call displayUpdateVram
	jmp aloop
exitGame:
	call keybInterruptUninstall
	
	call displaySetOldMode
.EXIT
END
