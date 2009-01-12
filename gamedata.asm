bIsLeftDown db 0
bIsRightDown db 0
bIsSpaceDown db 0
shipX dw 100
shipY = 175
shipY_ForSpeedOptimizations dw shipY

cNumMonsters = 40

bEnemyAlive	db cNumMonsters dup (1)
wEnemySpriteAddresses 		dw 16 dup (bMonster3)
							dw 16 dup (bMonster1)
							dw 8 dup (bMonster2)
wwEnemyPositions 			dw  32,  10
							dw  62,  10
							dw  92,  10
							dw 122,  10
							dw 152,  10
							dw 182,  10
							dw 212,  10
							dw 242,  10
							dw  32,  30
							dw  62,  30
							dw  92,  30
							dw 122,  30
							dw 152,  30
							dw 182,  30
							dw 212,  30
							dw 242,  30
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

cNumBullets = 12

bBulletExists db cNumBullets dup (0)
wwBulletPosition dw cNumBullets dup (?,?)
bTheirBulletExists db 0
wTheirBulletX dw 0
wTheirBulletY dw 0

randomnumber dw 1254

wMonsterTimeout dw 1
bLives db 3
bGameOver db 0




wTMPFile dw 0
bPaletteFileName db "palette.act$",0
bBGFileName db "space.raw$",0
bTitleFileName db "title.raw$",0
bInMenu db 1
bNoSound db 0
