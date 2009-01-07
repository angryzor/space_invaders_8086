

;var
bIncValue db 1
	
updateMonsterPositions PROC NEAR USES SI dx cx ax

	mov ax, seg wwEnemyPositions
	mov es, ax
	mov SI, offset wwEnemyPositions
	mov dh, byte ptr bIncValue
	mov cl, 8
	sar dx, cl
	mov cx, 20                     ; nr of monsters
moveAll:
	mov ax, [SI]
	add ax,dx
	add SI, 4 		;we use words and y doesn't need to be adjusted
	mov [SI], ax
	loop moveAll
movement:
	mov SI, offset wwEnemyPositions
	mov ax, [SI]
	cmp ax, 40
	je endScreen
	cmp ax, 0
	je endScreen
	jmp positionsUpdated
	
	
endScreen:	
	neg dx
	mov bIncValue, dl
positionsUpdated:
	ret
	
updateMonsterPositions ENDP 