
	dwSpaceShipPositionY dw 190
	dwSpaceShipPositionX dw 152 ;Schip begint in het midden
	
procKeyLeftDown PROC 
	mov SI, offset dwSpaceShipPositionX
	mov bx, [SI]
	add bx, -2
	mov [SI], bx
	call displayClearScreen
	graphicsDrawSpriteM bSpaceShip, bx, dwSpaceShipPositionY
	ret
procKeyLeftDown ENDP
procKeyRightDown PROC
	mov SI, offset dwSpaceShipPositionX
	mov bx, [SI]
	add bx, 2
	mov [SI], bx
	call displayClearScreen
	graphicsDrawSpriteM bSpaceShip, bx, dwSpaceShipPositionY
	ret
procKeyRightDown ENDP
procKeyLeftUp PROC
	ret
procKeyLeftUp ENDP
procKeyRightUp PROC
	ret
procKeyRightUp ENDP
procKeySpaceUp PROC USES SI BX DX
	ret
procKeySpaceUp ENDP
procKeySpaceDown PROC USES SI BX DX
;Hier moet het schip schieten?
	ret
procKeySpaceDown ENDP