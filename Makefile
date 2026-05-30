main: main.asm src.sb
	fasm main.asm

test: test.asm src.sb
	fasm test.asm

all: main.asm test.asm src.sb
	main test
