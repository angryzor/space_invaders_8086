; Include the sound blaster data
INCLUDE sblasdat.asm

; Include the keyboard data
INCLUDE keybdata.asm

; Include the game data
INCLUDE gamedata.asm

; Include the graphics data. This  one is last because it also defines FARDATA and otherwise the data below would be in that FARDATA, instead of the DATA segment
INCLUDE gdata.asm
