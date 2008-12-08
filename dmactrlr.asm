; DMA channel 5
; Ports
cDMAAddressPort = 0C4h
cDMACountPort	= 0C6h
cDMAPagePort	= 08Bh
cWriteModePort	= 0D6h
cSingleMaskPort = 0D4h
cClrBytePtr		= 0D8h

;Modes
cDemandMode			= 00000000y
cSingleMode			= 01000000y
cBlockMode			= 10000000y
cCascadeMode		= 11000000y

cAddressIncrement	= 00000000y
cAddressDecrement	= 00100000y

cSingleCycle		= 00000000y
cAutoInitialization	= 00010000y

cVerifyTransfer		= 00000000y
cWriteTransfer		= 00000100y
cReadTransfer		= 00001000y
cIllegalTransfer	= 00001100y

cChannel04			= 00000000y
cChannel15			= 00000001y
cChannel26			= 00000010y
cChannel37			= 00000011y

cMaskEnableChannel						= 00000001y
cMaskDisableChannel						= 00000101y

dmaSetMode MACRO mode
	mov al, mode
	out cWriteModePort, al
ENDM

dmaEnableChannel MACRO
	mov al, cMaskEnableChannel
	out cSingleMaskPort, al
ENDM

dmaDisableChannel MACRO
	mov al, cMaskDisableChannel
	out cSingleMaskPort, al
ENDM

dmaClearFlipFlop MACRO
	mov al, 0
	out cClrBytePtr, al
ENDM

dmaSetLength MACRO bufsize
	mov ax, bufsize
	dec ax ; not sure if this is necessary
	out cDMACountPort, al
	xchg al, ah
	out cDMACountPort, al
ENDM

dmaSetAddress MACRO buffer, transfer16
    ; calculate physical address... wondering if this can be done faster... this looks waay to unperformant
	xor ax, ax
	xor cx, cx
	mov cl, 4
	mov bx, seg buffer
	mov al, bh
	shl bx, cl
	shr ax, cl
	
	mov dx, offset buffer
	
	add bx, dx
	jnc dmaSetAddrNoCarry1
	add ax, 1
dmaSetAddrNoCarry1:
	; physical address is now <lower 4 bits of AX><BX>
	out cDMAPagePort, al ; output the page
	; apparently, for some reason we have to shift right 1 when doing 16bit transfers
IF transfer16
	shr bx, 1
	shr ax, 1
	jnc dmaSetAddrNoCarry2
	add bx, 1000000000000000y
dmaSetAddrNoCarry2:
ENDIF
	mov ax, bx
	out cDMAAddressPort, al
	xchg al, ah
	out cDMAAddressPort, al
ENDM
