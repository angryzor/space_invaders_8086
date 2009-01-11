INCLUDE dmactrlr.asm

wSBCBaseAddr = 220h

bCommandInput	= 42h
bCommandOutput	= 41h

print macro character
    mov ah,02h
    mov dl,character
    int 21h
endm

printcrlf macro
    mov ah,02h
    mov dl,0Ah
    int 21h
    mov ah,02h
    mov dl,0Dh
    int 21h
endm
printint proc near ;near procedure
    ;save dynamic link
    push bp
    ;update bp
    mov bp,sp
    ;save context
    push ax
    push bx
    push dx
    push si
    ;load param in bx
    mov bx,[bp+4] ;near proc, one word return address
    ;handle special case of zero
    test bx,0FFFFh
    jnz printint_nonzero
    mov ah,02h
    mov dl,'0'
    int 21h
    jmp printint_done
printint_nonzero:
    ;handle special case of -32768
    cmp bx,-32768
    jnz printint_notintmin
    mov ah,09h
    mov dx,offset maxint
    int 21h
    jmp printint_done
printint_notintmin:
    ;print sign
    test bx,8000h
    jz printint_positive
    ;if negative,print sign and invert
    ;print sign (int 21h, function 02h)
    mov ah,02
    mov dl,'-'
    int 21h
    ;invert sign of bx
    neg bx
printint_positive:
    ;from now on bx is positive
    ;determine largest power of ten smaller than bx
    ;init si to point to first element of powersoften array
    mov si,offset powersoften
    ; while bx<[si] increment si C: while(bx<powersoften[si]) si++
printint_nextpoweroften:
    cmp bx,[si]
    jge printint_powerfound
    add si,2    
    jmp printint_nextpoweroften
printint_powerfound:
    ;ok now print digits
    mov ax,bx
    cwd ;sign extend to DX:AX (32-bit)
    idiv word ptr [si]  ;divide DX:AX by current power of ten, result in AX, remainder in DX
    mov bx,dx  ;move remainder to bx
    mov ah,02h ;print al
    mov dl,al
    ;add 48 to convert to ascii
    add dl,48
    int 21h
    ;was this the last digit? i.e. [si]==1
    cmp word ptr [si],1
    je printint_done
    add si,2   ;increment si
    jmp printint_powerfound ;repeat for next digit
printint_done:
    ;restore context
    pop si
    pop dx
    pop bx
    pop ax
    ;restore bp
    pop bp
    ;return freeing param from stack (2 bytes)
    ret 2
printint endp

makeBlasterHandler MACRO buffer, bufsize, h, h2, numChannels, tmphalfbuf
soundBlasterHandler PROC FAR USES AX BX CX DX DS
	mov ah, 03fh				; read command
	mov bx, h				; file handle
	mov dx, seg buffer			; buffer
	mov ds, dx
	ASSUME DS:seg buffer
	mov dx, next_bufpart
	mov cx, bufsize/2				; read size
	int 21h
	
;; FOR 2 CHANNELS
;	mov bx, @DATA			; reset seg
;	mov ds, bx
;	ASSUME DS:@DATA
	mov ah, 03fh
	mov bx, h2
	mov cx, bufsize/2
;	mov dx, seg tmphalfbuf			; buffer
;	mov ds, dx
;	ASSUME DS:seg tmphalfbuf
	mov dx, offset tmphalfbuf
	int 21h
	
	mov dx, seg buffer
	mov es, dx
	mov si, next_bufpart
	mov di, offset tmphalfbuf

	mov cx, bufsize/2
mixLoop:
	mov ax, [si]
	mov bx, [di]
;	sar ax, 1
;	sar bx, 1
;	add ax, bx
	mov [si], bx
	add si, 2
	add di, 2
	dec cx
	jnz mixLoop
; END
	
	
;	jnc fileReadCleanExit
;	
;	mov dx, @DATA			; reset seg
;	mov ds, dx
;	ASSUME DS:@DATA
;	jmp exitISR				; can't open file. terminate
;fileReadCleanExit:
	mov bx, @DATA			; reset seg
	mov ds, bx
	ASSUME DS:@DATA
	
;	cmp ax, cx				; check for eof
;	je short exitISR
;EOF:
;	fileSeekStart h, 0, 0, exitISR
	
exitISR:
	mov dx, next_bufpart
	add dx, bufsize/2
	cmp dx, (offset buffer + bufsize)
	
	jb EOIs
	mov dx, offset buffer
EOIs:
	mov next_bufpart, dx
	mov dx, wSBCBaseAddr+0Fh
	in al, dx
	mov al, 20h
	out 20h, al
	iret
soundBlasterHandler ENDP
ENDM
	

soundBlasterInit MACRO buffer, bufsize
	mov next_bufpart, offset buffer
	;get old interrupt
	mov ah, 35h
	mov al, 0Fh
	int 21h
	mov ax, es
	mov old_IRQ7_seg, ax
	mov old_IRQ7_off, bx
	
	; hook up new interrupt handler
	mov ah, 25h
	mov al, 0Fh
	mov bx, seg soundBlasterHandler
	mov ds, bx
	assume DS:seg soundBlasterHandler
	mov dx, soundBlasterHandler
	int 21h
	mov bx, @DATA
	mov ds, bx
	assume DS:@DATA

	; enable IRQ7
	in al, 21h
	and al, 01111111y
	out 21h, al
	
	mov al, 0F3h
	mov dx, (wSBCBaseAddr + 0Ch)
	out dx, al
	
	cli
	dmaDisableChannel
	dmaSetMode cDemandMode + cAddressIncrement + cAutoInitialization + cWriteTransfer + cChannel15
	dmaClearFlipFlop
	dmaSetAddress buffer, 1
	dmaSetLength bufsize/2
	sti
	dmaEnableChannel
	
	;reset sblaster DSP
	mov dx, wSBCBaseAddr
	add dx, 6
	
	mov al, 1
	out dx, al
	
	xor al, al
delay:
	dec al
	jnz delay
	out dx, al
	
	xor cx, cx
TryContinue:
	mov dx, wSBCBaseAddr
	add dx, 0Eh
	
	in al, dx
	or al, al
	jns NextTry
	
	sub dx, 4
	in al, dx
	cmp al, 0AAh
	je Reset
NextTry:
	loop TryContinue
	strOutM now
Reset:

	
	; set DSP transfer sampling rate
	mov dx, wSBCBaseAddr
	add dx, 0Ch
	mov al, bCommandOutput
	out dx, al
	mov al, 0ACh		; 44100 Hz    D: (= 0AC44h)
	out dx, al
	mov al, 44h
	out dx, al
	
	mov al, 0B6h   ; 16bit out
	out dx, al
	mov al, 30h    ; 16bit stereo signed 
	out dx, al
	
	mov ax, bufsize/4
	out dx, al
	xchg al, ah
	out dx, al
	
ENDM


soundBlasterRelease MACRO
	mov dx, wSBCBaseAddr + 0Ch
	mov al, 0D9h
	out dx, al
	
	cli
	dmaDisableChannel

	; disable IRQ7
	in al, 21h
	or al, 10000000y
	out 21h, al
	sti

	mov ah, 25h
	mov al, 0Fh
	mov bx, old_IRQ7_seg
	mov dx, old_IRQ7_off
	mov ds, bx
	int 21h
	mov bx, @DATA
	mov ds, bx
ENDM
