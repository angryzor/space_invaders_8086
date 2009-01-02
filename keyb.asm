
SetCmd proc near uses cx al
		push ax 	;Save command value.
        cli         ;Critical region, no ints now. (Clear Interrupt Flag)

; Wait until the 8042 is done processing the current command.

        xor cx, cx      ;Allow 65,536 times thru loop.
Wait4Empty: in  al, 64h     ;Read keyboard status register.
        test    al, 10b     ;Input buffer full? (Input Buffer Status (1= full, 0 = empty))
        loopnz  Wait4Empty  ;If so, wait until empty.
; Okay, send the command :
        pop ax      ;Retrieve command.
        out 64h, al
        sti         ;Okay, ints can happen again. (Set Interrupt Flag)
        ret
SetCmd      endp

keybinterrupthandler proc far uses ds ax bx cx ; al ah cl ch ;COMMENTED OUT BY: angryzor; REASON: AX consists of AL and AH, CX consists of CL and CH
        mov ax,@data
        mov ds,ax
        
        mov al, 0ADh        ;Disable keyboard
        call SetCmd
        cli                 ;Disable interrupts. interrupts reenabled when flags are popped
        xor cx, cx
Wait4Data:  in  al, 64h     ;Read kbd status port.
        test    al, 10b     ;Data in buffer? (Input Buffer Status (1= full, 0 = empty))
        loopz   Wait4Data   ;Wait until data available.
        in  al, 60h         ;Get keyboard data.
        
;        if debug			; COMMENTED OUT BY: angryzor; REASON: completely unnecessary, we don't even have a printint/crlf function -_-'
;        xor ah,ah
;        push ax
;        call printint
;        printcrlf
;        endif
        
        cmp al, 0EEh        ;Echo response?
        je  QuitInt9
        cmp al, 0FAh        ;Acknowledge?
        jne NotAck
        or  KbdFlags4, 10h  ;Set ack bit.
        jmp QuitInt9

NotAck: cmp al, 0FEh        ;Resend command?
        jne NotResend       
        or  KbdFlags4, 20h  ;Set resend bit.
        jmp QuitInt9

NotResend: 
        ;if buffer not full, write scan code in dl to buffer 
        mov cl,keybbufback
        inc cl
        cmp cl,keybbuffront
        jz QuitInt9
        ;ok buffer not full, insert al and increment keybbufback
        mov bx,offset keybbuf
        mov cl,keybbufback
        xor ch,ch
        add bx,cx
        mov byte ptr [bx],al
        inc keybbufback
bufferfull:                 ;Put in type ahead buffer.
QuitInt9:   
        mov al, 0AEh        ;Reenable the keyboard
        call SetCmd

        mov al, 20h         ;Send EOI (end of interrupt)
        out 20h, al         ; to the 8259A PIC.
        iret
keybinterrupthandler endp

keybInterruptInstall PROC NEAR uses bp ax bx dx es ds
;	mov bp,sp			;COMMENTED OUT BY: angryzor; REASON: unnecessary, no stack passed arguments used
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
;	mov bp,sp			;COMMENTED OUT BY: angryzor; REASON: unnecessary, no stack passed arguments used
    ;Reset old handler
    mov dx,word ptr OldIntHandler
    mov ax,word ptr OldhIntHandler+2
    mov ds,ax
    mov ah,25h ;Dos function 25h
    mov al,09h ;Keyboard
    int 21h
    ret
keybInterruptUninstall ENDP

keybBufferProcess PROC NEAR USES AX BX CX DX
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
			jz short processArrowKey
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
