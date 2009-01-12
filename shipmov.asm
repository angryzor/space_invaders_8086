; Turns keys on/off
procKeyLeftDown MACRO
	mov bIsLeftDown, 1
ENDM
procKeyRightDown MACRO
	mov bIsRightDown, 1
ENDM
procKeySpaceDown MACRO
;	mov bIsSpaceDown, 1
	call fireBullet
ENDM
procKeyLeftUp MACRO
	mov bIsLeftDown, 0
ENDM
procKeyRightUp MACRO
	mov bIsRightDown, 0
ENDM
procKeySpaceUp MACRO
;	mov bIsSpaceDown, 0
;	mov spacetimems, 0
ENDM

INCLUDE keyb.asm

checkKeys MACRO
	mov bx, shipX
	mov al, bIsLeftDown
	cmp al, 0
	jz leftIsNotDown
	cmp bx, 0
	jz shipOnLeftBorder
	sub bx, 2
leftIsNotDown:
shipOnLeftBorder:
	mov al, bIsRightDown
	cmp al, 0
	jz rightIsNotDown
	cmp bx, cScrWidth-16
	jz shipOnRightBorder
	add bx, 2
rightIsNotDown:
shipOnRightBorder:
	mov shipX, bx
;	mov al, bIsSpaceDown
;	cmp al, 0
;	jz spaceIsNotDown
;	cmp spacetimems, 80
;	jb spaceIsNotDown
;	mov spacetimems, 0
;	call fireBullet
;spaceIsNotDown:
ENDM
