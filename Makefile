make:
	rgbasm -o main.o main.asm
	rgblink -o sound-test.gb main.o -n sound-test.sym
	rgbfix -v -p 0xFF sound-test.gb