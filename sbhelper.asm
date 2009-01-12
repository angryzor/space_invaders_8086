sbHelpLoadFiles MACRO
	fileOpenForReading soundFile1FN, soundFile1, noLoadWAVFile
	fileSeekStart soundFile1, 0, 44, noLoadWAVFile
	fileRead soundFile1, sbBuf, cSBBufSize, noLoadWAVFile, noLoadWAVFile
ENDM

sbHelpUnLoadFiles PROC NEAR USES AX DX
	fileClose soundFile1, endUnLoad
endUnLoad:
	ret
sbHelpUnLoadFiles ENDP

