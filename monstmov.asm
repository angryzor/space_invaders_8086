

;var
cMinPos = 15
cMaxPos = 75
	
updateMonsterPositions PROC NEAR USES SI dx cx ax

	mov ax, seg wwEnemyPositions
	mov es, ax
	mov SI, offset wwEnemyPositions
	mov dx, bIncValue
	mov cx, cNumMonsters					;nr of monsters
moveAll:									;move all monster bIncValue pixels ( bIncValue can be negative or positive) 
	mov ax, [SI]							;x-coordinate of monster
	add ax,dx								;add bIncValue to x-coordinate
	mov [SI], ax							;change value in wwEnemyPositions
	add SI, 4 								;we use words and y doesn't need to be adjusted
	loop moveAll
movement:
	mov SI, offset wwEnemyPositions			;back to the start of wwEnemyPositions
	mov ax, [SI]
	cmp ax, cMaxPos							;x-coordinate of the first monster must be >= 15 and <= 75			(>= because they will change the next time function is called)
	jge endScreen
	cmp ax, cMinPos
	jle endScreen
	jmp positionsUpdated
	
	
endScreen:									; change sign bIncValue so monsters will move to opposite direction
	neg dx
	mov bIncValue, dx
positionsUpdated:
	ret
	
updateMonsterPositions ENDP 