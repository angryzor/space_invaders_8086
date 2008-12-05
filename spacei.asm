.MODEL large
TITLE space-invader
.STACK 1024
.DATA 
;all data is defined in data.inc
INCLUDE DATA.asm
.CODE
INCLUDE graphics.asm
INCLUDE graphhlp.asm
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

	xor ah, ah
	int 16h
	
	call displaySetOldMode
.EXIT




END
