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
d=1
.STARTUP
if d
	call displayVgaMode
	displayHelpersFillGrayScalePalette bScratchPalette
	displaySetPaletteM bScratchPalette

	call keybInterruptInstall
	keybDisableTypematic
endif
; MAIN LOOP
aloop:
if d
; PROCESS KEYS
	call keybBufferProcess
	
; UPDATE POSITIONS
	checkKeys
endif
	call updateMonsterPositions
	updateBulletPosition
	call checkBulletHit
if d
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
endif
	jmp aloop
	
; DEINITIALIZATION STUFF
exitGame:
if d
	call keybInterruptUninstall
	
	call displaySetOldMode
endif
.EXIT
END
