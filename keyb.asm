keybInterruptHandler PROC FAR
	;some code
keybInterruptHandler ENDP

keybInterruptInstall PROC NEAR
	; some code
keybInterruptInstall ENDP

keybInterruptUninstall PROC NEAR
	; some code
keybInterruptUninstall ENDP

keybBufferProcess PROC NEAR
	mov bx, offset bKeybInputBuffer
	mov dl, bKeybInputBufferLoBound
	mov dh, bKeybInputBufferHiBound

	; some code
keybBufferProcess ENDP
