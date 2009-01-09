

;var
cMinPos = 15
cMaxPos = 75
	
updateMonsterPositions PROC NEAR USES SI dx cx ax

	mov ax, seg wwEnemyPositions
	mov es, ax
	mov SI, offset wwEnemyPositions
	mov dx, bIncValue
	mov cx, cNumMonsters                     ; nr of monsters
moveAll:
	mov ax, [SI]
	add ax,dx
	mov [SI], ax
	add SI, 4 		;we use words and y doesn't need to be adjusted
	loop moveAll
movement:
	mov SI, offset wwEnemyPositions
	mov ax, [SI]
	cmp ax, cMaxPos
	jge endScreen
	cmp ax, cMinPos
	jle endScreen
	jmp positionsUpdated
	
	
endScreen:	
	neg dx
	mov bIncValue, dx
positionsUpdated:
	ret
	
updateMonsterPositions ENDP 