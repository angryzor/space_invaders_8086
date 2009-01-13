

; proc collCheckHit
; @param ES:SI: ptr to monster sprite
;                DS:DI: ptr to ship/monster position
;                DS:BX: ptr to bullet position
; @destroys: /
; @result: FLAGS: NZ if collision, Z if no collision
; @desc: Checks for a collision between a sprite and a bullet. 
; @use: Needed for checking if a bullet hit a monster, or if "their" bullet hit the ship
collCheckHit PROC NEAR USES AX
; 	 Original way of thinking:
;	Two rectangles, one defined by	([BX],[BX+2]);([BX]+3,[BX]+5)
;	and the other defined by			([DI],[DI+2]);([DI]+[SI],[DI+2]+[SI+2])
;	collide when the following expression holds:
;	!((([BX+2]+5) < [DI+2]) || 	
;	  (([BX]+3) < [DI]) ||
;	  ([BX+2] > ([DI+2]+[SI+2])) ||
;	  ([BX] > ([DI]+[SI])))
;
;	this translates (via logical equalities) to
;
;	(([BX+2]+5) >= [DI+2]) && 
;	(([BX]+3) >= [DI]) &&
;	([BX+2] <= ([DI+2]+[SI+2])) &&
;	([BX] <= ([DI]+[SI]))
;
;	or, efficiently in ASM:
;
;	if (([BX+2]+5) < [DI+2])  	it doesn't collide, so get out of here
;	if (([BX]+3) < [DI])          	"    "              "        "   "     "    "      "
;	if ([BX+2] > ([DI+2]+[SI+2]))	"    "              "        "   "     "    "      "
;	if ([BX] > ([DI]+[SI]))		"    "              "        "   "     "    "      "
; 	i.e. the &&'s are implemented "lazy"
	  
	mov ax, [BX+2]	; ([BX+2]
	add ax, 5		;    +5)
	cmp ax, [DI+2]	;    compare to [DI+2]
	jb noCollision	; if < , it doesn't collide, so get out of here
	mov ax, [BX]	; ([BX]
	add ax, 3		;    +3)
	cmp ax, [DI]	; compare to [DI]
	jb noCollision	; if < , it doesn't collide, so get out of here
	mov ax, [SI+2]	; ([SI+2]
	add ax, [DI+2]	;    + [DI+2])
	cmp ax, [BX+2]	; compare to [BX+2]
	jb noCollision	; if < , it doesn't collide, so get out of here
	mov ax, [SI]	; ([SI]
	add ax, [DI]	;    + [DI])
	cmp ax, [BX]	; compare to [BX]
	jb noCollision	; if < , it doesn't collide, so get out of here
collision:
	xor ax, ax		; simple pair of instructions that
	add ax, 1		; clear the Z flag
	ret
noCollision:
	xor ax, ax		; simple instruction that sets the Z flag
	ret
collCheckHit ENDP
