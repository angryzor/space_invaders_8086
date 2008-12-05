.MODEL large
TITLE space-invader
.STACK 1024
.DATA 
;all data is defined in data.inc
INCLUDE DATA.asm
.CODE
INCLUDE graphics.asm
.STARTUP
	call displayVgaMode
	call displayClearScreen
	graphicsDrawSpriteM bMonster1, 140, 100
	call displayUpdateVram
tehloop:
	jmp tehloop
	call displaySetOldMode
.EXIT




END
