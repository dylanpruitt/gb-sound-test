INCLUDE "constants.inc"

; shortcut to write note data to ROM
; @param 1: note pitch (use one from constants.inc)
; @param 2: length in 16th notes (16th note=1, 8th note=2, quarter note=4, etc.)
MACRO note
	db HIGH(\1), LOW(\1), \2
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