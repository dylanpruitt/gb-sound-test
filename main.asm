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

    ld a, TEMPO_60
    ld [wTickRate], a
    ld a, 0
    ld [wCounter], a
    ld [wCh1TicksToHold], a
    ld [wCh2TicksToHold], a
    ld a, LOW(Channel1)
    ld [wChannel1Pointer], a
    ld a, LOW(Channel2)
    ld [wChannel2Pointer], a

    ld a, $80
    ldh [rAUD2LEN], a
    ld a, $80
    ldh [rAUD2ENV], a

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
    ld h, HIGH(Channel1)
    ld a, [wChannel1Pointer]
    ld l, a
    ld a, [hli]

    cp LOOP_TO_START
    jr z, RestartCH1Loop
    cp SET_INSTRUMENT
    jr z, SetCH1Instrument

    ldh [rAUD1LOW], a    ; load note pitch to registers
    ld a, [hli]
    ldh [rAUD1HIGH], a

    ld a, [hli]
    ld [wCh1TicksToHold], a ; load notes to hold

    ld a, l
    ld [wChannel1Pointer], a ; update channel 1 pointer

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
    ld h, HIGH(Channel2)
    ld a, [wChannel2Pointer]
    ld l, a
    ld a, [hli]

    cp LOOP_TO_START
    jr z, RestartCH2Loop
    cp SET_INSTRUMENT
    jr z, SetCH2Instrument

    ldh [rAUD2LOW], a    ; load note pitch to registers
    ld a, [hli]
    ldh [rAUD2HIGH], a

    ld a, [hli]
    ld [wCh2TicksToHold], a ; load notes to hold

    ld a, l
    ld [wChannel2Pointer], a ; update channel 2 pointer

    ld a, [wCh2TicksToHold]
    dec a
    ld [wCh2TicksToHold], a

    jp Main
RestartCH1Loop:
    ld a, LOW(Channel1)
    ld [wChannel1Pointer], a
    jr HandleTick.nextNote
RestartCH2Loop:
    ld a, LOW(Channel2)
    ld [wChannel2Pointer], a
    jr HandleTick.ch2NextNote
SetCH1Instrument:
    ld h, HIGH(Channel1)
    ld a, [wChannel1Pointer]
    inc a
    ld l, a
    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld d, a
    ; update channel pointer
    ld a, l
    ld [wChannel1Pointer], a

    ; set length/envelope from instrument settings
    ld l, e
    ld h, d
    ld a, [hli]
    ldh [rAUD1LEN], a
    ld a, [hli]
    ldh [rAUD1ENV], a

    jp HandleTick.nextNote
SetCH2Instrument:
    ld h, HIGH(Channel2)
    ld a, [wChannel2Pointer]
    inc a
    ld l, a
    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld d, a
    ; update channel pointer
    ld a, l
    ld [wChannel2Pointer], a

    ; set length/envelope from instrument settings
    ld l, e
    ld h, d
    ld a, [hli]
    ldh [rAUD2LEN], a
    ld a, [hli]
    ldh [rAUD2ENV], a

    jp HandleTick.nextNote

SECTION "Vars", WRAM0
wTickRate:: db           ; every X VBlank cycles, handle a tick (1/16th note)
wCounter:: db            ; counts down VBlank cycles until next tick
wCh1TicksToHold:: db     ; counts down ticks to keep playing this note until the next one
wCh2TicksToHold:: db
wChannel1Pointer:: db    ; tracks what note is currently playing
wChannel2Pointer:: db

SECTION "Music", ROM0
Channel1::
    set_instrument TestInstrument
    note C4, 1 ; song format: each note is 3 bytes (2 for pitch, 1 for length - which is number
    note E4, 1 ; of 16th notes to hold for, so '4' is a whole note, '2' is an eighth note, etc.)
    note G4, 1 ; once the program hits $FF it loops back to the beginning
    note E4, 1
    note C4, 1
    note E4, 1
    note G4, 1
    note E4, 1
    note B3, 1
    note E4, 1
    note G4, 1
    note E4, 1
    note B3, 1
    note E4, 1
    note G4, 1
    note E4, 1
    note A3, 1
    note E4, 1
    note G4, 1
    note E4, 1
    note A3, 1
    note E4, 1
    note G4, 1
    note E4, 1
    note B3, 1
    note E4, 1
    note G4, 1
    note E4, 1
    note B3, 1
    note E4, 1
    note G4, 1
    note E4, 1
    db $FF ; end

Channel2::
    set_instrument TestInstrument
    note C5, 4
    note G5, 4
    set_instrument TestInstrument2
    note C5, 4
    note G5, 4
    db $FF ; end

TestInstrument:: instrument $80, $87
TestInstrument2:: instrument $40, $40