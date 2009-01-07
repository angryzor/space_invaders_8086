

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
	  
	mov ax, [BX+1]
	add ax, 4
	cmp ax, [DI+1]
	jl noCollision
	mov ax, [BX+2]
	add ax, 2
	cmp ax, [DI]
	jl noCollision
	mov ax, [DI+1]
	add ax, [SI+1]
	cmp [BX+1], ax
	jl noCollision
	mov ax, [DI]
	add ax, [SI]
	cmp [BX], ax
	jl noCollision
collision:
	xor ax, ax
	add ax, 1
	ret
noCollision:
	xor ax, ax
	ret
collCheckHit ENDP
