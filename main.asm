INCLUDE "hardware.inc"
INCLUDE "macros.asm"

SECTION "Header", ROM0[$100]

	jp EntryPoint

	ds $150 - @, 0 ; make room for header

EntryPoint::
	; Do not turn the LCD off outside of VBlank
WaitVBlank:
	ld a, [rLY]
	cp 144
	jp c, WaitVBlank

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

    ld a, TEMPO_180
    ld [wTickRate], a
    ld a, 0
    ld [wCounter], a
    ld [wCh1TicksToHold], a
    ld [wCh2TicksToHold], a
    ld a, HIGH(BattleCh1)
    ld [wChannel1Pointer], a
    ld a, LOW(BattleCh1)
    ld [wChannel1Pointer+1], a
    ld a, HIGH(BattleCh2)
    ld [wChannel2Pointer], a
    ld a, LOW(BattleCh2)
    ld [wChannel2Pointer+1], a

Main::
    ld a, [rLY]
    cp 144
    jr nc, Main
WaitVBlank2:
    ld a, [rLY]
    cp 144
    jr c, WaitVBlank2

    ld a, [wCounter] ; wait for tick
    cp 0
    jr z, HandleTick

    dec a
    ld [wCounter], a

    jr Main
HandleTick:
    ld a, [wTickRate]
    ld [wCounter], a

    .ch1
    ld a, [wCh1TicksToHold] ; hold a note until it's done playing, then read+play next note
    cp 0
    jr z, .nextNote
    dec a
    ld [wCh1TicksToHold], a
    jr .ch2

    .nextNote
    load_ptr_to_hl wChannel1Pointer
    ld a, [hli]

    cp LOOP_TO_START
    jr z, RestartCH1Loop
    cp SET_INSTRUMENT
    jp z, SetCH1Instrument
    cp SECTION_END
    jp z, EndCH1Section
    cp JUMP_TO_SECTION
    jp z, JumpToCH1Section

    add a ; double note value in a - dw is 2 bytes so this increments by 2 bytes

    ld de, NotePeriods ; set de to point to note period address
    ld e, a

    ld a, [de]
    ldh [rAUD1HIGH], a    ; load note pitch to registers
    inc e
    ld a, [de]
    ldh [rAUD1LOW], a

    ld a, [hli]
    ld [wCh1TicksToHold], a ; load notes to hold

    ld a, h
    ld [wChannel1Pointer], a ; update channel 1 pointer
    ld a, l
    ld [wChannel1Pointer+1], a ; update channel 1 pointer

    ld a, [wCh1TicksToHold]
    dec a
    ld [wCh1TicksToHold], a

    .ch2
    ld a, [wCh2TicksToHold] ; hold a note until it's done playing, then read+play next note
    cp 0
    jr z, .ch2NextNote
    dec a
    ld [wCh2TicksToHold], a
    jr Main

    .ch2NextNote
    load_ptr_to_hl wChannel2Pointer
    ld a, [hli]

    cp LOOP_TO_START
    jr z, RestartCH2Loop
    cp SET_INSTRUMENT
    jr z, SetCH2Instrument
    cp SECTION_END
    jp z, EndCH2Section
    cp JUMP_TO_SECTION
    jp z, JumpToCH2Section

    add a ; double note value in a - dw is 2 bytes so this increments by 2 bytes

    ld de, NotePeriods ; set de to point to note period address
    ld e, a

    ld a, [de]
    ldh [rAUD2HIGH], a    ; load note pitch to registers
    inc e
    ld a, [de]
    ldh [rAUD2LOW], a

    ld a, [hli]
    ld [wCh2TicksToHold], a ; load notes to hold

    ld a, h
    ld [wChannel2Pointer], a ; update channel 1 pointer
    ld a, l
    ld [wChannel2Pointer+1], a ; update channel 1 pointer

    ld a, [wCh2TicksToHold]
    dec a
    ld [wCh2TicksToHold], a

    jp Main
RestartCH1Loop:
    ld a, HIGH(Channel1)
    ld [wChannel1Pointer], a
    ld a, LOW(Channel1)
    ld [wChannel1Pointer+1], a
    jp HandleTick.nextNote
RestartCH2Loop:
    ld a, HIGH(Channel2)
    ld [wChannel2Pointer], a
    ld a, LOW(Channel2)
    ld [wChannel2Pointer+1], a
    jr HandleTick.ch2NextNote
SetCH1Instrument:
    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld d, a
    ; update channel pointer
    ld a, h
    ld [wChannel1Pointer], a
    ld a, l
    ld [wChannel1Pointer+1], a

    ; set length/envelope from instrument settings
    ld l, e
    ld h, d
    ld a, [hli]
    ldh [rAUD1LEN], a
    ld a, [hli]
    ldh [rAUD1ENV], a

    jp HandleTick.nextNote
SetCH2Instrument:
    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld d, a
    ; update channel pointer
    ld a, h
    ld [wChannel2Pointer], a
    ld a, l
    ld [wChannel2Pointer+1], a

    ; set length/envelope from instrument settings
    ld l, e
    ld h, d
    ld a, [hli]
    ldh [rAUD2LEN], a
    ld a, [hli]
    ldh [rAUD2ENV], a

    jp HandleTick.ch2NextNote
JumpToCH1Section:
    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld d, a

    ld a, h
    ld [wChannel1TmpPtr], a
    ld a, l
    ld [wChannel1TmpPtr+1], a

    ld a, d
    ld [wChannel1Pointer], a
    ld a, e
    ld [wChannel1Pointer+1], a
    jp HandleTick.nextNote
JumpToCH2Section:
    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld d, a

    ld a, h
    ld [wChannel2TmpPtr], a
    ld a, l
    ld [wChannel2TmpPtr+1], a

    ld a, d
    ld [wChannel2Pointer], a
    ld a, e
    ld [wChannel2Pointer+1], a
    jp HandleTick.nextNote
EndCH1Section:
    load_ptr_to_hl wChannel1TmpPtr

    ld a, h
    ld [wChannel1Pointer], a
    ld a, l
    ld [wChannel1Pointer+1], a
    jp HandleTick.nextNote
EndCH2Section:
    load_ptr_to_hl wChannel2TmpPtr

    ld a, h
    ld [wChannel2Pointer], a
    ld a, l
    ld [wChannel2Pointer+1], a
    jp HandleTick.nextNote

SECTION "Vars", WRAM0
wTickRate:: db           ; every X VBlank cycles, handle a tick (1/16th note)
wCounter:: db            ; counts down VBlank cycles until next tick
wCh1TicksToHold:: db     ; counts down ticks to keep playing this note until the next one
wCh2TicksToHold:: db
wChannel1Pointer:: dw    ; tracks what note is currently playing
wChannel1TmpPtr:: dw     ; tracks position in song when wChannel1Ptr jumps to a section
wChannel2Pointer:: dw
wChannel2TmpPtr:: dw

SECTION "Music", ROM0
Channel1:
    play_section .section1
    play_section .section1
    play_section .section2
    play_section .section1
    db LOOP_TO_START

    .section1
    note C4, 1 ; song format: each note is 2 bytes (1 for pitch, 1 for length - which is number
    note E4, 1 ; of 16th notes to hold for, so '4' is a whole note, '2' is an eighth note, etc.)
    note G4, 1 ; once the program hits $FF it loops back to the beginning
    note E4, 1
    note B3, 1
    note E4, 1
    note G4, 1
    note E4, 1
    db SECTION_END

    .section2

    note A3, 1
    note E4, 1
    note G4, 1
    note E4, 1
    note B3, 1
    note E4, 1
    note G4, 1
    note E4, 1
    db SECTION_END

Channel2:

    note C5, 4
    note G5, 4
    note C5, 4
    note G5, 4
    db $FF ; end

BattleCh1:
    set_instrument TestInstrument
    play_section .section1
    play_section .section1
    play_section .section1
    play_section .section2
    play_section .section1
    play_section .section1
    play_section .section1
    play_section .section2
    play_section .section3
    db LOOP_TO_START

    .section1
    note G5, 6
    note A5, 6
    note Bb5, 8

    note G5, 4
    note A5, 4
    note Bb5, 4
    db SECTION_END
    .section2
    note G5, 6
    note D6, 6
    note C6, 4
    note G5, 4
    note F#5, 4
    note G5, 4
    note A5, 4
    db SECTION_END
    .section3
    note Bb5, 6
    note C6, 6
    note D6, 8
    note Bb5, 4
    note C6, 4
    note D6, 4
    note C6, 6
    note F6, 6
    note Eb6, 8
    note D6, 2
    note Eb6, 2
    note F6, 2
    note Eb6, 2
    note D6, 2
    note Eb6, 2
    note Eb6, 6
    note D6, 6
    note C6, 4
    note Eb6, 6
    note D6, 6
    note C6, 4
    note Bb5, 6
    note C6, 6
    note D6, 4
    note Bb5, 4
    note A5, 4
    note G5, 4
    note F#5, 4
    db SECTION_END

BattleCh2:
    set_instrument TestInstrument
    play_section .section1
    play_section .section2
    play_section .section1
    play_section .section3
    play_section .section4
    play_section .section1
    play_section .section2
    play_section .section1
    play_section .section3
    play_section .section4
    play_section .section5
    play_section .section3
    play_section .section3
    play_section .section6
    db LOOP_TO_START

    ; section 1
    .section1
    note G3, 2
    note G4, 2
    note G3, 2
    note G4, 2
    note G3, 2
    note G4, 2
    note G3, 2
    note G4, 2
    note G3, 2
    note G4, 2

    note G3, 4
    note A3, 4
    note Bb3, 4
    db SECTION_END
    .section2
    note A3, 2
    note A4, 2
    note A3, 2
    note A4, 2
    note A3, 2
    note A4, 2
    note Bb3, 2
    note Bb4, 2
    note Bb3, 2
    note Bb4, 2
    note C4, 2
    note Bb3, 2
    note A3, 2
    note G3, 2
    note A3, 2
    note Bb3, 2
    db SECTION_END
    .section3
    note C4, 2
    note C5, 2
    note C4, 2
    note C5, 2
    note C4, 2
    note C5, 2
    note C4, 2
    note C5, 2
    db SECTION_END
    .section4
    note C4, 2
    note C5, 2
    note D5, 2
    note A4, 2
    note F#4, 2
    note D4, 2
    note A3, 2
    note F#3, 2
    db SECTION_END
    .section5
    note F3, 4
    note Bb3, 4
    note Eb4, 4
    note G3, 6
    note C4, 6
    note F4, 8
    note G3, 4
    note C4, 4
    note F4, 4
    note A3, 6
    note Eb4, 6
    note D4, 4
    note Bb3, 4
    db SECTION_END
    .section6
    note Bb3, 2
    note Bb4, 2
    note C4, 2
    note Bb3, 2
    note A3, 4
    note Bb3, 4
    note Bb3, 2
    note Bb4, 2
    note D5, 2
    note A4, 2
    note F#4, 2
    note D4, 2
    note A3, 2
    note F#3, 2
    db SECTION_END

TestInstrument: instrument $80, $80
TestInstrument2: instrument $40, $80
Staccato: instrument $80, $94