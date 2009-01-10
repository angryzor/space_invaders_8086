

; proc collCheckHit
; @param ES:SI: ptr to monster sprite
;                DS:DI: ptr to ship/monster position
;                DS:BX: ptr to bullet position
; @destroys: /
; @result: AX: 1 if collision
; @desc: sets video palette to palette in ES:DX
collCheckHit PROC NEAR USES AX
;	!((([BX+1] + 4) < [DI+1]) || 
;	  (([BX]+2) < [DI]) ||
;	  ([BX+1] < ([DI+1] + [SI+1])) ||
;	  ([BX] < ([DI] + [SI])))
;
;	(([BX+1] + 4) >= [DI+1]) && 
;	(([BX]+2) >= [DI]) &&
;	([BX+1] >= ([DI+1] + [SI+1])) &&
;	([BX] >= ([DI] + [SI]))
	  
	mov ax, [BX+2]
	add ax, 5
	cmp ax, [DI+2]
	jb noCollision
	mov ax, [BX]
	add ax, 3
	cmp ax, [DI]
	jb noCollision
	mov al, [SI+1]
	xor ah, ah
	add ax, [DI+2]
	cmp ax, [BX+2]
	jb noCollision
	mov al, [SI]
	xor ah, ah
	add ax, [DI]
	cmp ax, [BX]
	jb noCollision
collision:
	xor ax, ax
	add ax, 1
	ret
noCollision:
	xor ax, ax
	ret
collCheckHit ENDP
