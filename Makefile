SBLIBSOURCES=sblasdat.asm sblaster.asm
SBTESTMAIN=sbtest.asm 
MAIN=spacei.asm
ASMSOURCES=DATA.asm dmactrlr.asm fileio.asm gdata.asm graphhlp.asm graphics.asm keycodes.asm sprites.asm stdout.asm $(SBLIBSOURCES) $(MAIN)


all: debug
	
debug: $(ASMSOURCES)
	@ml /W3 /Zi /nologo $(MAIN)
	
release: $(ASMSOURCES)
	@ml /W3 /nologo $(MAIN)
	
sbd: $(SBLIBSOURCES) $(SBTESTMAIN)
	@ml /W3 /Zi /nologo $(SBTESTMAIN)
	
sb: $(SBLIBSOURCES) $(SBTESTMAIN)
	@ml /W3 /nologo $(SBTESTMAIN)

#sbc: sbd
#	@sbtest.exe

list: $(ASMSOURCES)
	@ml /W3 /Fl /Zi /nologo $(MAIN)
	
check: debug
	@spacei.exe
