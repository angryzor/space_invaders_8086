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

; macro dmaSetMode
; @destroys: AL
; @result: /
; @desc: Set the DMA "mode".
dmaSetMode MACRO mode
	mov al, mode
	out cWriteModePort, al
ENDM

; macro dmaEnableChannel
; @destroys: AL
; @result: /
; @desc: Enable the DMA channel 5.
dmaEnableChannel MACRO
	mov al, cMaskEnableChannel
	out cSingleMaskPort, al
ENDM

; macro dmaDisableChannel
; @destroys: AL
; @result: /
; @desc: Disable the DMA channel 5.
dmaDisableChannel MACRO
	mov al, cMaskDisableChannel
	out cSingleMaskPort, al
ENDM

; macro dmaClearFlipFlop
; @destroys: AL
; @result: /
; @desc: Clears te DMA flip-flop...
dmaClearFlipFlop MACRO
	mov al, 0
	out cClrBytePtr, al
ENDM

; macro dmaSetLength
; @destroys: AL
; @result: /
; @desc: Tell the DMA controller the size of the data in the memory. YOU NEED TO PASS THE SIZE IN WORDS TO THIS MACRO FOR 16-bit TRANSFERS!!!
dmaSetLength MACRO bufsize
	mov ax, bufsize
	dec ax ; not sure if this is necessary
	out cDMACountPort, al
	xchg al, ah
	out cDMACountPort, al
ENDM

; macro dmaSetAddress
; @destroys: AL
; @result: /
; @desc: Tells the DMA controller the address of the data. All data needs to be on the same physical page (block of 64kB)
dmaSetAddress MACRO buffer, transfer16
    ; calculate physical address... wondering if this can be done faster... this looks waay to unperformant
	xor ax, ax									; clear AX
	xor cx, cx									; clear CX
	mov cl, 4									; We want to shift 4 bits (see further)
	mov bx, seg buffer							; we need the segment to calculate the physical address!    Assume it is  01010101 01010101b
	mov al, bh									; We want to shift the segment 4 bits to the left, then add it to the offset. However, then of course it doesn't fit in our 16bit register
												; (which is why segmentation even exists).  We put the upper byte of our segment in AL. (AX = 00000000 01010101b)
	shl bx, cl									; Shift BX 4 bits to the left (as we would normally do to calculate the phys address, however now we have saved the upper 4 bits) (BX = 01010101 01010000b)
	shr ax, cl									; Now, we have saved 8 bits, which is 4 too much, so we shift 4 times to the right (AX = 00000000 00000101b)
	
	mov dx, offset buffer						; now we're going to add the buffer offset to get the actual physical memory address
	
	add bx, dx									; just add it to BX
	adc ax, 0									; now add the carry bit to AX

	; physical address is now <lower 4 bits of AX><BX>
	out cDMAPagePort, al 						; output the physical page. this just happens to be just what's inside AL
	; apparently, for some reason we have to shift right 1 when doing 16bit transfers
IF transfer16
	shr bx, 1
	shr ax, 1
	jnc dmaSetAddrNoCarry2						; don't forget the bit that fell off when doing the shr on AX
	add bx, 1000000000000000y
dmaSetAddrNoCarry2:
ENDIF
	mov ax, bx									; output the address to the DMA controller's address port
	out cDMAAddressPort, al
	xchg al, ah
	out cDMAAddressPort, al
ENDM
