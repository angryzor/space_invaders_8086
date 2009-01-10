.MODEL large
TITLE space-invader
.STACK 1024
.DATA 
;all data is defined in data.inc
INCLUDE DATA.asm

.CODE
INCLUDE graphics.asm
INCLUDE graphhlp.asm
INCLUDE shipmov.asm
INCLUDE monstmov.asm
INCLUDE collisn.asm
INCLUDE fire.asm
INCLUDE dispdraw.asm

.STARTUP
	call displayVgaMode
	displayHelpersFillGrayScalePalette bScratchPalette
	displaySetPaletteM bScratchPalette

	call keybInterruptInstall
	keybDisableTypematic
	
; MAIN LOOP
aloop:

; PROCESS KEYS
	call keybBufferProcess
	
; UPDATE POSITIONS
	checkKeys
	call updateMonsterPositions
	updateBulletPosition
	
; UPDATE SCREEN
	call displayClearScreen
	
  ; Draw debug line. This line indicates the keybbuf length
	displayHelpersDebugDrawHorizontalLine bBufLen, 0
	
  ; Draw ship
	graphicsDrawSpriteM bSpaceShip, shipX, shipY
  ; Draw monsters
	call monstersUpdateDisplay
	call bulletUpdateDisplay
  ; Write to VRAM
	call displayUpdateVram

	jmp aloop
	
; DEINITIALIZATION STUFF
exitGame:
	call keybInterruptUninstall
	
	call displaySetOldMode
.EXIT
END
