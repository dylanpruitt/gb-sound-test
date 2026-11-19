make:
	rgbasm -o main.o main.asm
	rgbasm -o engine.o engine.asm
	rgbasm -o macros.o macros.asm
	rgbasm -o notes.o notes.asm
	rgbasm -o boss.o songs/boss.asm
	rgbasm -o shop.o songs/shop.asm
	rgblink -o sound-test.gb main.o engine.o macros.o notes.o shop.o boss.o -n sound-test.sym
	rgbfix -v -p 0xFF sound-test.gb