bIsLeftDown db 0
bIsRightDown db 0
bIsSpaceDown db 0
shipX dw 100

cNumMonsters = 40

wEnemySpriteAddresses 		dw cNumMonsters dup (bMonster1)
wwEnemyPositions 			dw  30,  10
							dw  60,  10
							dw  90,  10
							dw 120,  10
							dw 150,  10
							dw 180,  10
							dw 210,  10
							dw 240,  10
							dw  30,  30
							dw  60,  30
							dw  90,  30
							dw 120,  30
							dw 150,  30
							dw 180,  30
							dw 210,  30
							dw 240,  30
							dw  30,  50
							dw  60,  50
							dw  90,  50
							dw 120,  50
							dw 150,  50
							dw 180,  50
							dw 210,  50
							dw 240,  50
							dw  30,  70
							dw  60,  70
							dw  90,  70
							dw 120,  70
							dw 150,  70
							dw 180,  70
							dw 210,  70
							dw 240,  70
							dw  30,  90
							dw  60,  90
							dw  90,  90
							dw 120,  90
							dw 150,  90
							dw 180,  90
							dw 210,  90
							dw 240,  90
							
bIncValue dw 1