INCLUDE dmactrlr.asm

wSBCBaseAddr = 220h

bCommandInput	= 42h
bCommandOutput	= 41h

makeBlasterHandler MACRO buffer, bufsize, h
soundBlasterHandler PROC FAR USES AX BX CX DX DS
; have our own read file here. we need speed optimizations
;	mov ax, next_sto_bufpart
;	add ax, 1
;	mov next_sto_bufpart, ax
;	mov test_1, ax

;	mov ah, 02h
	;mov dl, 42h
	;int 21h

	mov ah, 03fh				; read command
	mov bx, h				; file handle
	mov dx, seg buffer			; buffer
	mov ds, dx
	ASSUME DS:seg buffer
	mov dx, next_bufpart
	mov cx, bufsize/2				; read size
	int 21h
	
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
	
	cmp ax, cx				; check for eof
	je short exitISR
EOF:
	fileSeekStart h, 0, 0, exitISR
	
exitISR:
	mov dx, next_bufpart
	add dx, bufsize/2
	cmp dx, (offset buffer + bufsize)
	
	jl EOIs
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
