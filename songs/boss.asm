INCLUDE "macros.asm"

SECTION "Boss Theme", ROM0

SongBattle2::
	db TEMPO_150
	dw BossCh1
	dw BossCh2

BossCh1::
    set_instrument TestInstrument
    play_section .section1
    play_section .section1
    play_section .section2
    play_section .section2
    db LOOP_TO_START

    .section1
    note G5, 8
    note Bb5, 8
    note A5, 16
    db SECTION_END
    .section2
    note G5, 1
    note F#5, 1
    note G5, 1
    note A5, 1
    note Bb5, 8
    note F#5, 2
    note G5, 2
    note A5, 4
    note Bb5, 4
    note C6, 4
    note A5, 4
    db SECTION_END

BossCh2::
	set_instrument Staccato
    play_section .section1
    play_section .section1
    play_section .section2
    play_section .section2
    db LOOP_TO_START

    .section1
    note G3, 2
    note Bb3, 2
    note C#4, 2
    note Bb3, 2
    note G3, 2
    note Bb3, 2
    note C#4, 2
    note Bb3, 2
    note G3, 2
    note Bb3, 2
    note C#4, 2
    note Bb3, 2
    note G3, 2
    note Bb3, 2
    note F4, 2
    note E4, 2
    db SECTION_END
    .section2
    note Eb4, 2
    note G4, 2
    note G3, 2
    note G4, 2
    note G3, 2
    note Bb3, 2
    note G3, 2
    note D4, 2
    note Eb4, 2
    note C4, 2
    note D4, 2
    note Bb3, 2
    note C4, 2
    note Bb3, 2
    note A3, 4
    db SECTION_END

TestInstrument: instrument $80, $80
TestInstrument2: instrument $40, $80
Staccato: instrument $80, $94