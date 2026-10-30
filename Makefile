make:
	rgbasm -o main.o main.asm
	rgbasm -o macros.o macros.asm
	rgblink -o sound-test.gb main.o macros.o -n sound-test.sym
	rgbfix -v -p 0xFF sound-test.gb