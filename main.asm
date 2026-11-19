INCLUDE "hardware.inc"
INCLUDE "macros.asm"

SECTION "VBlank Interrupt", ROM0[$0040]
VBlankInterrupt:
    jp VBlankHandler

SECTION "VBlank Handler", ROM0
VBlankHandler:
    push af
    push de
    push hl

    call UpdateAudio

    pop hl
    pop de
    pop af

    reti

SECTION "Header", ROM0[$100]

	jp EntryPoint

	ds $150 - @, 0 ; make room for header

EntryPoint:
    .waitVBlank
    ld a, [rLY]
    cp 144
    jr c, .waitVBlank

	; Turn the LCD off
	ld a, 0
	ld [rLCDC], a

    ; Turn the LCD on
    ld a, LCDC_ON | LCDC_BG_ON | LCDC_OBJ_ON
    ld [rLCDC], a

    ; During the first (blank) frame, initialize display registers
    ld a, %11100100
    ld [rBGP], a

    ld a, %10000011
    ld [rAUDENA], a

    play_song SongBattle2

    ld a, IF_VBLANK
    ldh [rIE], a
    xor a
    ldh [rIF], a

    ei
Main::
    halt
    jr Main