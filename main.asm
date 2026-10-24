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
    ld [wNotesToHold], a
    ld a, LOW(Channel1)
    ld [wChannel1Pointer], a
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

    ld a, [wNotesToHold] ; hold a note until it's done playing, then read+play next note
    cp 0
    jr z, .nextNote
    dec a
    ld [wNotesToHold], a
    jr Main

    .nextNote
    ld h, HIGH(Channel1)
    ld a, [wChannel1Pointer]
    ld l, a
    ld a, [hli]

    cp $FF
    jr z, RestartLoop

    ldh [rAUD1LOW], a    ; load note pitch to registers
    ld a, [hli]
    ldh [rAUD1HIGH], a

    ld a, [hli]
    ld [wNotesToHold], a ; load notes to hold

    ld a, l
    ld [wChannel1Pointer], a ; update channel 1 pointer

    jr HandleTick
RestartLoop:
    ld a, LOW(Channel1)
    ld [wChannel1Pointer], a
    jr HandleTick

SECTION "Vars", WRAM0
wTickRate:: db           ; every X VBlank cycles, handle a tick (1/16th note)
wCounter:: db            ; counts down VBlank cycles until next tick
wNotesToHold:: db        ; counts down ticks to keep playing this note until the next one
wChannel1Pointer:: db    ; tracks what note is currently playing

SECTION "Music", ROM0
Channel1:: ALIGN 8          ; aligned so I only need one 8-bit register to track song position
    db HIGH(C4), LOW(C4), 4 ; song format: each note is 3 bytes (2 for pitch, 1 for length - which is number
    db HIGH(G4), LOW(G4), 4 ; of 16th notes to hold for, so '4' is a whole note, '2' is an eighth note, etc.)
    db HIGH(F4), LOW(F4), 1 ; once the program hits $FF it loops back to the beginning
    db HIGH(E4), LOW(E4), 1
    db HIGH(D4), LOW(D4), 1
    db HIGH(E4), LOW(E4), 1
    db HIGH(D4), LOW(D4), 2
    db HIGH(G3), LOW(G3), 2
    db HIGH(A3), LOW(A3), 2
    db HIGH(B3), LOW(B3), 2
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