main: main.asm
	fasm main.asm arth

test: test.asm
	fasm test.asm
	ld test.o -o test

all: main.asm test.asm
	main test
