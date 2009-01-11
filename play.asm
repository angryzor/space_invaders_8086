drawVolumeBar PROC NEAR USES SI DX CX
;	mov si, offset sbBuf
;	mov dh, [si]
;	mov dl, [si+1]
;	cmp dx, 0
;	jns short noneg
;	neg dx
;noneg:
;	mov cl, 7
;	shr dx, cl
	mov ax, seg sbBuf
	mov es, ax
	mov si, offset sbBuf
	
	xor ax, ax
	mov cx, 5511
loopa:
	mov bx, [si]
	cmp bx, 0
	jns short noneg
	neg bx
noneg:
	sar ax, 1
	sar bx, 1
	add ax, bx
	add si, 4
	loop loopa
	
	mov cl, 7
	shr ax, cl
	mov dx, ax

	displayHelpersDebugDrawHorizontalLineW dx, 1
	ret
drawVolumeBar ENDP
