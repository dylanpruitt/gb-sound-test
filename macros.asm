INCLUDE "constants.inc"

; shortcut to write note data to ROM
; @param 1: note pitch (use one from constants.inc)
; @param 2: length in 16th notes (16th note=1, 8th note=2, quarter note=4, etc.)
MACRO note
	db \1, \2
ENDM

; @param 1: length
; @param 2: envelope
MACRO instrument
	db \1, \2
ENDM

; @param 1: pointer to instrument (created with above macro)
MACRO set_instrument
	db SET_INSTRUMENT
	dw \1
ENDM

; @param 1: address of section to play
MACRO play_section
	db JUMP_TO_SECTION
	dw \1
ENDM

; @param 1: address of song to play
MACRO play_song
	ld hl, \1
	ld a, [hli]
	; initialize tick vars
    ld [wTickRate], a
    ld a, 0
    ld [wCounter], a
    ld [wCh1TicksToHold], a
    ld [wCh2TicksToHold], a
    ; set channel pointers
    ld a, [hli]
    ld [wChannel1Pointer+1], a
    ld [wChannel1StartPointer+1], a
    ld a, [hli]
    ld [wChannel1Pointer], a
    ld [wChannel1StartPointer], a
    ld a, [hli]
    ld [wChannel2Pointer+1], a
    ld [wChannel2StartPointer+1], a
    ld a, [hli]
    ld [wChannel2Pointer], a
    ld [wChannel2StartPointer], a
ENDM

; @param 1: address of pointer to load to HL (1st byte is high/h, 2nd byte is low/l)
MACRO load_ptr_to_hl
	ld a, [\1]
    ld h, a
    ld a, [\1+1]
    ld l, a
ENDM