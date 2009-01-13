.MODEL large
TITLE space-invader
.STACK 1024
.DATA 
;all data is defined in data.inc
INCLUDE DATA.asm

.CODE
INCLUDE fileio.asm
INCLUDE graphics.asm
INCLUDE graphhlp.asm
INCLUDE shipmov.asm
INCLUDE monstmov.asm
INCLUDE collisn.asm
INCLUDE fire.asm
INCLUDE themfire.asm
INCLUDE dispdraw.asm
INCLUDE sblaster.asm
INCLUDE sbhelper.asm
INCLUDE gameend.asm
INCLUDE play.asm
makeBlasterHandler sbBuf, cSBBufSize, soundFile1
.STARTUP
	call displayVgaMode

	call displayHelpersLoadPaletteFile
	displaySetPaletteM bScratchPalette

	call keybInterruptInstall
	keybDisableTypematic
	
	sbHelpLoadFiles
	soundBlasterInit sbBuf, cSBBufSize
	jmp the_menu
noLoadWAVFile:
	mov byte ptr bNoSound, 1
the_menu:
	mov byte ptr bInMenu, 1
	call displayHelpersLoadMenu
	graphicsDrawSpriteFarM wwbLargeSprite, 0, 0 
	call displayUpdateVram
wait_loop:
	call keybBufferProcess
	cmp byte ptr bInMenu, 1
	jz wait_loop
	

the_game:
	call displayHelpersLoadBG
; MAIN LOOP
aloop:
; PROCESS KEYS
	cli
	call keybBufferProcess
	
; UPDATE POSITIONS
	checkKeys
	call updateMonsterPositions
	call theyTryToFire
	updateBulletPosition
	updateTheirBulletPosition
	call checkBulletsHit
	call checkShipHit
; UPDATE SCREEN
	graphicsDrawSpriteFarM wwbLargeSprite, 0, 0 
	
  ; Draw ship
	graphicsDrawSpriteM bSpaceShip, shipX, shipY

  ; Draw monsters
	call monstersUpdateDisplay
	call bulletUpdateDisplay
	call theirBulletUpdateDisplay
	call drawLives
  ; Write to VRAM
	call displayUpdateVram

	cmp bGameOver, 1
	jz gameOver
	call checkGameWin
	sti

	jmp aloop

gameOver:
; DEINITIALIZATION STUFF
exitGame:
	sti

	cmp byte ptr bNoSound, 1
	jz noWAVRelease
	
	soundBlasterRelease
	call sbHelpUnLoadFiles
	
noWAVRelease:
	call keybInterruptUninstall
	
	call displaySetOldMode
.EXIT
END
