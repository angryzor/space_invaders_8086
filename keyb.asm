;Dit is data. Niet zeker dat het in deze file moet!
OldIntHandler dd ?

keybInterruptHandler PROC FAR
	;some code
keybInterruptHandler ENDP

keybInterruptInstall PROC NEAR uses bp ax bx dx es ds
    mov bp,sp
    ;Saving old interrupt handler
    mov ah,35h ;Dos function 35h
    mov al,09h ;Interrupt source = 9 = Keyboard
    int 21h
    mov word ptr OldIntHandler,bx
    mov word ptr OldIntHandler+2,es
    ;Set new interrupt handler
    mov dx,seg KeybInterruptHandler
    mov ds,dx
    mov dx,KeybInterruptHandler
    mov ah,25h ;Dos function 25h
    mov al,09h ;Source 9 = Keyboard
    int 21h
    ret
keybInterruptInstall ENDP

keybInterruptUninstall PROC NEAR uses bp ax dx ds
	mov bp,sp
    ;Reset old handler
    mov dx,word ptr OldIntHandler
    mov ax,word ptr OldhIntHandler+2
    mov ds,ax
    mov ah,25h ;Dos function 25h
    mov al,09h ;Keyboard
    int 21h
    ret
keybInterruptUninstall ENDP

keybBufferProcess PROC NEAR
	mov bx, offset bKeybInputBuffer
	mov dl, bKeybInputBufferLoBound
	mov dh, bKeybInputBufferHiBound

	; some code
keybBufferProcess ENDP
