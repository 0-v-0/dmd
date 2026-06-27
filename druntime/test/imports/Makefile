TESTS := bug17452 bug18193

include ../common.mak

$(ROOT)/%.done: %.d $(DMD_DEP)
	@echo Testing $*
	$(COMPILE.d) -deps=$@ -version=Shared -o- $<
