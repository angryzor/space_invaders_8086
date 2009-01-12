timerhandler proc far USES DS AX
    cli
    mov ax,@DATA
    mov ds,ax
    add monstupdms,mspertick
	add spacetimems,mspertick
	sti
;    pushf
;	call far oldTimer
	iret
timerhandler endp

timerInstall PROC NEAR USES ES DS AX DX
	mov ah,35h 
    mov al,1Ch 
    int 21h
    mov word ptr oldTimer,bx
    mov word ptr oldTimer+2, es
	
    mov dx,seg timerhandler
    mov ds,dx
    mov dx,timerhandler
    mov ah,25h
    mov al,1Ch 
    int 21h

	ret
timerInstall ENDP

timerUninstall PROC NEAR USES AX DX

    mov dx,word ptr oldTimer+2
    mov ds,dx
    mov dx,word ptr oldTimer
    mov ah,25h
    mov al,1Ch 
    int 21h
	mov dx, @DATA
	mov ds, dx

	ret
timerUninstall ENDP
