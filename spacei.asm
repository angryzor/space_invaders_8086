.MODEL large
TITLE space-invader
.STACK 1024
.DATA 
;all data is defined in data.inc
INCLUDE DATA.asm
printchar macro char
    mov dl,char
    mov ah,02h
    int 21h
endm


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
INCLUDE timer.asm
d=1
makeBlasterHandler sbBuf, cSBBufSize, soundFile1
.STARTUP
if d
	call displayVgaMode
;	displayHelpersFillGrayScalePalette bScratchPalette
endif
	call displayHelpersLoadPaletteFile
	displaySetPaletteM bScratchPalette

	call displayHelpersLoadBG
if d

	call keybInterruptInstall
	keybDisableTypematic
	
;	call timerInstall
	
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
	cmp monstupdms, 0
	jb nomonsterupdate
	mov word ptr monstupdms, 0
	call updateMonsterPositions
nomonsterupdate:
	call theyTryToFire
	updateBulletPosition
	updateTheirBulletPosition
	call checkBulletsHit
	call checkShipHit
if d
; UPDATE SCREEN
;	call displayClearScreen
;	call graphicsDrawTest
	graphicsDrawSpriteFarM wwbLargeSprite, 0, 0 
	
  ; Draw debug line. This line indicates the keybbuf length;
;	displayHelpersDebugDrawHorizontalLineB bBufLen, 0
  ; Draw ship
endif
	graphicsDrawSpriteM bSpaceShip, shipX, shipY
if d
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
	call checkGameWin
	sti

	jmp aloop

gameOver:
	
; DEINITIALIZATION STUFF
exitGame:
	sti
	soundBlasterRelease
	call sbHelpUnLoadFiles
if d
;	call timerUninstall
	
	call keybInterruptUninstall
	
	call displaySetOldMode
endif
.EXIT
END
