INCLUDE dmactrlr.asm

wSBCBaseAddr = 220h

bCommandInput	= 42h
bCommandOutput	= 41h

makeBlasterHandler MACRO buffer, bufsize, sto_buf, sto_bufsize
soundBlasterHandler PROC FAR
	mov di, next_bufpart
	mov si, next_sto_bufpart
	mov ax, seg buffer
	mov es, ax
	assume es:seg buffer
	mov ax, seg sto_buf
	mov ds, ax
	assume ds:seg sto_buf
	
	mov cx, bufsize/4
	cld
	rep movsb
	mov ax, @DATA
	mov ds, ax
	assume DS:@DATA
	
	cmp di, bufsize
	jnz noChangeBufPos
	mov di, 0
noChangeBufPos:
	cmp si, sto_bufsize
	jnz noChangeStoBufPos
	mov si, 0
noChangeStoBufPos:
	mov next_bufpart, di
	mov next_sto_bufpart, si
;	mov al, 1
;	mov blaster_passed, al
	iret
soundBlasterHandler ENDP
ENDM
	

soundBlasterInit MACRO buffer, bufsize

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
	
	cli
	dmaDisableChannel
	dmaSetMode cDemandMode + cAddressIncrement + cAutoInitialization + cWriteTransfer + cChannel15
	dmaClearFlipFlop
	dmaSetAddress buffer, 1
	dmaSetLength bufsize
	sti
	dmaEnableChannel
	
	;reset sblaster DSP
	mov dx, wSBCBaseAddr
	add dx, 6
	
	mov al, 1
	out dx, al
	sub al, al
	
	
	; set DSP transfer sampling rate
	mov dx, wSBCBaseAddr
	add dx, 0Ch
	mov al, bCommandOutput
	out dx, al
	mov al, 0ACh		; 44100 Hz    D:
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
