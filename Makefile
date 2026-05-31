main: main.asm src.sb
	fasm main.asm

test: test.asm src.sb
	fasm test.asm
	ld test.o -o test

all: main.asm test.asm src.sb
	main test
