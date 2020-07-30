SRC	= setup.pas
BIN	= setup
FPC	= fpc

FLAGS			= -Sc -Sg -Sh -Si -XX -MObjFPC 
FLAGS_DEBUG		= -O1 -Sa -gs -dMEMCHECK -gl -dDEBUG
FLAGS_RELEASE		= -O3 -Xs -CX

release: FLAGS += $(FLAGS_RELEASE)
release: $(BIN)

debug:  FLAGS += $(FLAGS_DEBUG)
debug: $(BIN)


$(BIN):
	$(FPC) $(SRC) $(LIBS)  $(FLAGS) -o$(BIN)
	
clean:
	rm *.o $(BIN)
