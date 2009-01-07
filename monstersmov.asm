

;var
bIncValue db 1
	
updateMonsterPositions PROC NEAR USES SI dx cx ax

	mov ES, seg wwEnemyPositions
	mov SI, offset wwEnemyPositions
	movsx dx, byte ptr bIncValue
	mov cx, 20                     ; nr of monsters
moveAll:
	mov ax, [SI]
	add ax,dx
	add SI, 4 		;we use words and y doesn't need to be adjusted
	mov [SI], ax
	loop moveAll
movement:
	mov SI, offset wwEnemyPositions
	cmp [SI], cScrWidth
	je endScreen
	cmp [SI], 0
	je endScreen
	jmp positionsUpdated
	
	
endScreen:	
	neg dx
	mov bIncValue, dx
positionsUpdated:
	ret
	
updateMonsterPositions ENDP 