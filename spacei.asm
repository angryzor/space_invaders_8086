.MODEL large
TITLE space-invader
.STACK 1024
.DATA 
;all data is defined in data.inc
INCLUDE DATA.asm
.CODE
.STARTUP
	call displayVgaMode
	call displayClearScreen
	mov SI, offset bMonster1
	mov BX, 10
	mov DX, 20
	mov CX, 64000
	call graphicsDraw
	call displayUpdateVram
tehloop:
	loop tehloop
	call displaySetOldMode
.EXIT



INCLUDE graphics.asm

END
