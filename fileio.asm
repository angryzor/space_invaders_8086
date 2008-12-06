; macro fileOpenForReading
; @destroys: DX, AX
; @param filename: the name of the file you want to read
; @param handle: a piece of memory that will hold the file handle
; @param terminator: label to jump to on errors
; @returns: /
; @desc: opens a file for reading
fileOpenForReading MACRO filename, handle, terminator
	mov dx, offset filename
	
	mov ax, 03d00h				; open file for reading
	int 21h
	
	jc terminator	
	mov handle, ax
ENDM

; macro fileRead
; @destroys: AX, BX, CX, DX
; @param handle: the file handle
; @param buffer: a piece of memory (NEAR or FAR) that will hold the file's data.
; @param EOF: label to jump to on EOF (End Of File)
; @param terminator: label to jump to on errors
; @returns: /
; @desc: reads from a file to memory
fileRead MACRO handle, buffer, rsize, EOF, terminator
	mov ah, 03fh				; read command
	mov bx, handle				; file handle
	mov dx, seg buffer			; buffer
	mov ds, dx
	ASSUME DS:seg buffer
	mov dx, offset buffer
	mov cx, rsize				; read size
	int 21h
	
	jnc fileReadCleanExit
	
	mov dx, @DATA			; reset seg
	mov ds, dx
	ASSUME DS:@DATA
	jmp terminator				; can't open file. terminate
fileReadCleanExit:
	mov dx, @DATA			; reset seg
	mov ds, dx
	ASSUME DS:@DATA
	
	cmp ax, cx				; check for eof
	jne EOF
	
ENDM

; macro fileClose
; @destroys: AX, BX
; @param handle: the file handle
; @param terminator: label to jump to on errors
; @returns: /
; @desc: closes a file
fileClose MACRO handle, terminator
	mov bx, handle
	mov ah, 3eh
	int 21h
	jc terminator
ENDM
