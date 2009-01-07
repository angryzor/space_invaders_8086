INCLUDE keycodes.asm


SendCmd     proc    near
        push    ds
        push    bx
        push    cx
        mov bx, ax      ;Save data byte

        mov bh, 3       ;Retry cnt.
RetryLp:    cli         ;Disable ints while accessing HW.

; Clear the Error, Acknowledge received, and resend received flags
; in KbdFlags4

        and KbdFlags4, 4fh

; Wait until the 8042 is done processing the current command.

        xor cx, cx          ;Allow 65,536 times thru loop.
Wait4Empty: in  al, 64h         ;Read keyboard status register.
        test    al, 10b         ;Input buffer full?
        loopnz  Wait4Empty      ;If so, wait until empty.

; Okay, send the data to port 60h

        mov al, bl
        out 60h, al
        sti             ;Allow interrupts now.

; Wait for the arrival of an acknowledgement from the keyboard ISR:

        xor cx, cx          ;Wait a long time, if need be.
Wait4Ack:   
        test KbdFlags4, 10h  ;Acknowledge received bit.
        jnz GotAck
        loop Wait4Ack
        dec bh          ;Do a retry on this guy.
        jne RetryLp

; If the operation failed after 3 retries, set the error bit and quit.

        or  KbdFlags4, 80h  ;Set error bit.
GotAck:     
        pop cx
        pop bx
        pop ds
        ret
SendCmd endp



SetCmd proc near uses cx ax
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

keybInterruptHandler proc far uses ds ax bx cx ; al ah cl ch ;COMMENTED OUT BY: angryzor; REASON: AX consists of AL and AH, CX consists of CL and CH
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
        mov cl,bKeybInputBufferHiBound
        inc cl
        cmp cl,bKeybInputBufferLoBound
        jz QuitInt9
        ;ok buffer not full, insert al and increment keybbufback
        mov bx,offset bKeybInputBuffer
        mov cl,bKeybInputBufferHiBound
        xor ch,ch
        add bx,cx
        mov byte ptr [bx],al
        inc bKeybInputBufferHiBound
bufferfull:                 ;Put in type ahead buffer.
QuitInt9:   
        mov al, 0AEh        ;Reenable the keyboard
        call SetCmd
        mov al, 20h         ;Send EOI (end of interrupt)
        out 20h, al         ; to the 8259A PIC.
        iret
keybInterruptHandler endp

keybInterruptInstall PROC NEAR uses ax bx dx es ds
;	mov bp,sp			;COMMENTED OUT BY: angryzor; REASON: unnecessary, no stack passed arguments used
    ;Saving old interrupt handler
    mov ah,35h ;Dos function 35h
    mov al,09h ;Interrupt source = 9 = Keyboard
    int 21h
    mov word ptr OldIntHandler,bx
    mov word ptr OldIntHandler+2,es
    ;Set new interrupt handler
    mov dx,seg keybInterruptHandler
    mov ds,dx
    mov dx,keybInterruptHandler
    mov ah,25h ;Dos function 25h
    mov al,09h ;Source 9 = Keyboard
    int 21h
    ret
keybInterruptInstall ENDP

keybInterruptUninstall PROC NEAR uses ax dx ds
;	mov bp,sp			;COMMENTED OUT BY: angryzor; REASON: unnecessary, no stack passed arguments used
    ;Reset old handler
    mov dx,word ptr OldIntHandler
    mov ax,word ptr OldIntHandler+2
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
	xor dx, dx
	mov dl, cl
	add bx, dx
	xor ax, ax
	mov al, [bx]						; move from correct index
	
	checkArrowKey:
		cmp ax, cKeyArrowDown				; check if arrow key indicator
		jnz short continue
		
		mov byte ptr bKeybNextIsArrow, 1	; in that case, set this and move up
		jmp continue_loop
	
		continue:
			xor dh, dh
			mov dl, byte ptr bKeybNextIsArrow	; check if "next is arrow" flag is set
			cmp dx, 1
			jz short processArrowKey
			cmp ax, cKeySpaceDown
			jz labelKeySpaceDown
			cmp ax, cKeySpaceUp
			jz labelKeySpaceUp
			cmp ax, cKeyXUp
			jz exitGame
			jmp labelError		; should never happen

		

		processArrowKey:
			mov byte ptr bKeybNextIsArrow, 0  ; reset arrow flag
			cmp ax, cKeyLeftDown
			jz labelKeyLeftDown
			cmp ax, cKeyRightDown
			jz labelKeyRightDown
			cmp ax, cKeyLeftUp
			jz labelKeyLeftUp
			cmp ax, cKeyRightUp
			jz labelKeyRightUp
			jmp labelError		; should never happen
			
continue_loop:
	inc cl
	jmp a_loop
	
labelKeyLeftDown:
	procKeyLeftDown
	jmp continue_loop
labelKeyRightDown:
	procKeyRightDown
	jmp continue_loop
labelKeySpaceDown:
	procKeySpaceDown
	jmp continue_loop
labelKeyLeftUp:
	procKeyLeftUp
	jmp continue_loop
labelKeyRightUp:
	procKeyRightUp
	jmp continue_loop
labelKeySpaceUp:
	procKeySpaceUp
	jmp continue_loop
labelError:
	jmp continue_loop		; ignore errors for now
	
keybProcessExit:
	mov bKeybInputBufferLoBound, cl ; Store the circular buffer's lower bound
;	mov bKeybInputBufferHiBound, ch ; Store the circular buffer's high bound
	ret
keybBufferProcess ENDP
