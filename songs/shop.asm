INCLUDE "macros.asm"

SECTION "Shop Theme", ROM0

SongShop::
	db TEMPO_100
	dw ShopCh1
	dw ShopCh2

ShopCh1::
    set_instrument TestInstrument
    note C5, 2
    note C5, 2
    note Eb5, 2
    note C5, 2
    rest 8
    set_instrument TestInstrument
    note G4, 2
    note F#4, 2
    note G4, 2
    note A4, 2
    note Bb4, 4
    note G4, 4
    db LOOP_TO_START

ShopCh2::
    set_instrument Staccato
    note C4, 2
    note C4, 2
    note Eb4, 2
    note C4, 2
    note Bb3, 2
    note C4, 2
    note C4, 2
    rest 2
    set_instrument Staccato
    note C4, 2
    note Eb4, 2
    note C4, 2
    note G4, 2
    note F#4, 2
    note F4, 2
    rest 2
    set_instrument Staccato
    note Eb4, 2
    db LOOP_TO_START

TestInstrument: instrument $80, $80
TestInstrument2: instrument $40, $80
Staccato: instrument $80, $94