; sprite:=   1 byte width,
;            1 byte height,
; 	         arbitrary bytes

bMonster1 dw	16, 14
db				000h,000h,000h,03fh,03fh,000h,000h,000h,000h,000h,000h,03fh,03fh,000h,000h,000h
db				000h,000h,000h,03fh,03fh,000h,000h,000h,000h,000h,000h,03fh,03fh,000h,000h,000h
db				000h,000h,000h,000h,000h,03fh,03fh,000h,000h,03fh,03fh,000h,000h,000h,000h,000h
db				000h,000h,000h,000h,000h,03fh,03fh,000h,000h,03fh,03fh,000h,000h,000h,000h,000h
db				000h,000h,000h,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,000h,000h,000h
db				000h,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,000h
db				000h,03fh,03fh,03fh,03fh,000h,000h,03fh,03fh,000h,000h,03fh,03fh,03fh,03fh,000h
db				03fh,03fh,03fh,03fh,03fh,049h,000h,03fh,03fh,049h,000h,03fh,03fh,03fh,03fh,03fh
db				03fh,03fh,000h,000h,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,000h,000h,03fh,03fh
db				03fh,03fh,000h,000h,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,000h,000h,03fh,03fh
db				03fh,03fh,000h,000h,03fh,03fh,000h,000h,000h,000h,03fh,03fh,000h,000h,03fh,03fh
db				03fh,03fh,000h,000h,03fh,03fh,000h,000h,000h,000h,03fh,03fh,000h,000h,03fh,03fh
db				000h,000h,000h,000h,000h,03fh,000h,000h,000h,000h,03fh,000h,000h,000h,000h,000h
db				000h,000h,000h,000h,000h,03fh,03fh,000h,000h,03fh,03fh,000h,000h,000h,000h,000h
				
bSpaceship dw   16, 8
db				000h,000h,000h,000h,000h,000h,000h,03fh,03fh,000h,000h,000h,000h,000h,000h,000h
db				000h,000h,000h,000h,000h,000h,03fh,03fh,03fh,03fh,000h,000h,000h,000h,000h,000h
db				000h,03fh,000h,000h,000h,000h,03fh,03fh,03fh,03fh,000h,000h,000h,000h,03fh,000h
db				000h,03fh,000h,03fh,000h,03fh,03fh,03fh,03fh,03fh,03fh,000h,03fh,000h,03fh,000h
db				000h,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,000h
db				03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh
db				000h,03fh,03fh,000h,000h,000h,03fh,03fh,03fh,03fh,000h,000h,000h,03fh,03fh,000h
db				000h,03fh,000h,000h,000h,000h,000h,03fh,03fh,000h,000h,000h,000h,000h,03fh,000h

bBullet dw 		3, 5
db				0ffh,03fh,0ffh
db				0ffh,03fh,0ffh
db				0ffh,03fh,0ffh
db				03fh,03fh,03fh
db				0ffh,03fh,0ffh

bBulletEnemy dw 		3, 5
db				0ffh,03fh,0ffh
db				03fh,03fh,03fh
db				0ffh,03fh,0ffh
db				0ffh,03fh,0ffh
db				0ffh,03fh,0ffh
