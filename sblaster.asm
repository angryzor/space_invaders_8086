INCLUDE dmactrlr.asm

wSBCBaseAddr = 220h

bCommandInput	= 42h
bCommandOutput	= 41h

makeBlasterHandler MACRO buffer, bufsize, sto_buf, sto_bufsize
soundBlasterHandler PROC FAR
;	strOutM now
;	mov ax, next_bufpart
;	add ax, 5
;	mov next_bufpart, ax
;IF 0
	mov di, next_bufpart
	add si, next_sto_bufpart
	mov ax, seg buffer
	mov es, ax
	assume es:seg buffer
	mov ax, seg sto_buf
	mov ds, ax
	assume ds:seg sto_buf
	
	mov cx, bufsize/2
	cld
	rep movsb
	mov ax, @DATA
	mov ds, ax
	assume DS:@DATA
	
	cmp di, (offset buffer + bufsize)
	jl short noChangeBufPos
	mov di, offset buffer
noChangeBufPos:
	cmp si, (offset sto_buf + sto_bufsize)
	jl short noChangeStoBufPos
	mov si, offset sto_buf
noChangeStoBufPos:
	mov next_bufpart, di
	mov next_sto_bufpart, si
;	mov al, 1
;	mov blaster_passed, al
;ENDIF
	mov dx, wSBCBaseAddr+0Fh
	in al, dx
	mov al, 20h
	out 20h, al
	iret
soundBlasterHandler ENDP
ENDM
	

soundBlasterInit MACRO buffer, bufsize, sto_buf
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
	
	mov next_bufpart, offset buffer
	mov next_sto_bufpart, offset sto_buf
ENDM
