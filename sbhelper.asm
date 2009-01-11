sbHelpLoadFiles PROC NEAR USES AX DX
	fileOpenForReading soundFile1FN, soundFile1, endLoad
	fileSeekStart soundFile1, 0, 44, endLoad
	fileRead soundFile1, sbBuf, cSBBufSize, endLoad, endLoad
endLoad:
	ret
sbHelpLoadFiles ENDP

sbHelpUnLoadFiles PROC NEAR USES AX DX
	fileClose soundFile1, endUnLoad
endUnLoad:
	ret
sbHelpUnLoadFiles ENDP

