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
	graphicsDrawSpriteM bSpaceShip, 160, 100
	call displayUpdateVram

	xor ah, ah
	int 16h
	
	call displaySetOldMode
.EXIT




END
