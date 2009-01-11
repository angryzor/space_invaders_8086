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
INCLUDE themfire.asm
INCLUDE dispdraw.asm
INCLUDE fileio.asm
INCLUDE sblaster.asm
INCLUDE sbhelper.asm
d=1
makeBlasterHandler sbBuf, cSBBufSize, soundFile1
.STARTUP
if d
	call displayVgaMode
	displayHelpersFillGrayScalePalette bScratchPalette
	displaySetPaletteM bScratchPalette

	call keybInterruptInstall
	keybDisableTypematic
	
endif
	call sbHelpLoadFiles
	soundBlasterInit sbBuf, cSBBufSize
; MAIN LOOP
aloop:
if d
; PROCESS KEYS
	cli
	call keybBufferProcess
	
; UPDATE POSITIONS
	checkKeys
endif
	call updateMonsterPositions
	call theyTryToFire
	updateBulletPosition
	updateTheirBulletPosition
	call checkBulletsHit
	call checkShipHit
if d
; UPDATE SCREEN
	call displayClearScreen
	
  ; Draw debug line. This line indicates the keybbuf length
	displayHelpersDebugDrawHorizontalLineB bBufLen, 0
	mov si, offset sbBuf
	mov dh, [si]
	mov dl, [si+1]
	cmp dx, 0
	jns short noneg
	neg dx
noneg:
	mov cl, 7
	shr dx, cl

	displayHelpersDebugDrawHorizontalLineW dx, 1
	
  ; Draw ship
	graphicsDrawSpriteM bSpaceShip, shipX, shipY
  ; Draw monsters
	call monstersUpdateDisplay
	call bulletUpdateDisplay
	call theirBulletUpdateDisplay
	call drawLives
  ; Write to VRAM
	call displayUpdateVram
endif
	cmp bGameOver, 1
	jz gameOver
	sti
	jmp aloop

gameOver:
	
; DEINITIALIZATION STUFF
exitGame:
	sti
	soundBlasterRelease
	call sbHelpUnLoadFiles
if d
	
	call keybInterruptUninstall
	
	call displaySetOldMode
endif
.EXIT
END
