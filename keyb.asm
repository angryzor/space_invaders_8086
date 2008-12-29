
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
	mov cl, bKeybInputBufferLoBound ; The circular buffer's lower bound
	mov ch, bKeybInputBufferHiBound ; The circular buffer's high bound

a_loop:
checkEmpty:
	cmp cl, ch				; See if cl == ch and stop if true
	jz keybProcessExit		;
	
processThis:
	mov bx, offset bKeybInputBuffer		; set base
	mov ax, [bx+cl]						; move from correct index
	
	checkArrowKey:
		cmp ax, cKeyArrowDown				; check if arrow key indicator
		jnz short continue
		
		mov byte ptr bKeybNextIsArrow, 1	; in that case, set this and move up
		jmp continue_loop
	
		continue:
			mov dx, byte ptr bKeybNextIsArrow	; check if "next is arrow" flag is set
			cmp dx, 1
			jz processArrowKey
			cmp ax, cKeySpaceDown
			jz labelKeySpaceDown
			cmp ax, cKeyLeftUp
			jz labelKeyLeftUp
			cmp ax, cKeyRightUp
			jz labelKeyRightUp
			cmp ax, cKeySpaceUp
			jz labelKeySpaceUp
			jmp labelError		; should never happen

		

		processArrowKey:
			mov byte ptr bKeybNextIsArrow, 0  ; reset arrow flag
			cmp ax, cKeyLeftDown
			jz labelKeyLeftDown
			cmp ax, cKeyRightDown
			jz labelKeyRightDown
			jmp labelError		; should never happen
			
continue_loop:
	inc cl
	jmp a_loop
	
labelKeyLeftDown:
	call procKeyLeftDown
	jmp continue_loop
labelKeyRightDown:
	call procKeyRightDown
	jmp continue_loop
labelKeySpaceDown:
	call procKeySpaceDown
	jmp continue_loop
labelKeyLeftUp:
	call procKeyLeftUp
	jmp continue_loop
labelKeyRightUp:
	call procKeyRightUp
	jmp continue_loop
labelKeySpaceUp:
	call procKeySpaceUp
	jmp continue_loop
labelError:
	jmp continue_loop		; ignore errors for now
	
keybProcessExit:
	mov bKeybInputBufferLoBound, cl ; Store the circular buffer's lower bound
	mov bKeybInputBufferHiBound, ch ; Store the circular buffer's high bound
	ret
keybBufferProcess ENDP
