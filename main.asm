INCLUDE "hardware.inc"

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

    ld a, 15             ; 60 BPM = 1 beat per second = 4 16th notes per second (15 VBlank cycles per 16th note)
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

    cp $FF
    jr z, RestartCH1Loop

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

    cp $FF
    jr z, RestartCH2Loop

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

    jr Main
RestartCH1Loop:
    ld a, LOW(Channel1)
    ld [wChannel1Pointer], a
    jr HandleTick.nextNote
RestartCH2Loop:
    ld a, LOW(Channel2)
    ld [wChannel2Pointer], a
    jr HandleTick.ch2NextNote

SECTION "Vars", WRAM0
wTickRate:: db           ; every X VBlank cycles, handle a tick (1/16th note)
wCounter:: db            ; counts down VBlank cycles until next tick
wCh1TicksToHold:: db     ; counts down ticks to keep playing this note until the next one
wCh2TicksToHold:: db
wChannel1Pointer:: db    ; tracks what note is currently playing
wChannel2Pointer:: db

SECTION "Music", ROM0
Channel1:: ALIGN 8          ; aligned so I only need one 8-bit register to track song position
    db HIGH(C4), LOW(C4), 2 ; song format: each note is 3 bytes (2 for pitch, 1 for length - which is number
    ;db HIGH(D4), LOW(D4), 1 ; of 16th notes to hold for, so '4' is a whole note, '2' is an eighth note, etc.)
    db HIGH(E4), LOW(E4), 2 ; once the program hits $FF it loops back to the beginning
    ;db HIGH(F4), LOW(F4), 1
    db HIGH(G4), LOW(G4), 2
    ;db HIGH(F4), LOW(F4), 1
    db HIGH(E4), LOW(E4), 2
    ;db HIGH(D4), LOW(D4), 1
    db $FF ; end

    ds $F3 ; hack to make RGBDS not complain about Channel2 not being aligned...I know it's bad, just wanted to test stuff
Channel2:: ALIGN 8
    db HIGH(C5), LOW(C5), 4
    db HIGH(G5), LOW(G5), 4
    ;db HIGH(C5), LOW(C5), 2
    ;db HIGH(G5), LOW(G5), 2
    db $FF ; end

; note frequencies
DEF G3 EQU $C782
DEF A3 EQU $5883
DEF B3 EQU $DA83
DEF C4 EQU $1684
DEF D4 EQU $8384
DEF E4 EQU $E584
DEF F4 EQU $1185
DEF G4 EQU $6385
DEF C5 EQU $0B86
DEF E5 EQU $7286
DEF G5 EQU $B286