# Z80 Audio Engine

This is a simple 2-channel audio engine I created for the Game Boy (to my knowledge, there isn't a tutorial on setting one up, so I made one from scratch).

### Limitations
This doesn't play noise/wave channels and is limited on music tempo - I was originally going to use Timer interrupts to set tempo more accurately, but was advised against it for a beginner project because it alters VBlank timing.

### Playing Songs

Before you can play a song, you need to define it in ROM data. There is an [example song](songs/boss.asm) in the repo that shows how this works in practice:

The first five bytes of a song contain the tick rate and pointers to the start of channel 1/channel 2 in ROM.

After that, you can write song data:
```asm
    note G5, 8 ; pitch + length (in 16th notes)
    set_instrument TestInstrument ; set pointer to instrument (length+envelope data)
    play_section .section1 ; set pointer to section (see below)

    ; sections are repeated notes, play_section lets you specify
    ; the section address (2 bytes) each time you need it instead of
    ; writing it out note-by-note each time.
    ; 
    ; they should end in db SECTION_END
    .section1
    note G5, 8
    note Bb5, 8
    note A5, 16
    db SECTION_END
```

Then, call the play_song macro like this:  
```play_song SongBattle2 ; pointer to song```

and run this code in the main loop during each VBlank:  
```asm
    ld a, [wCounter] ; wait for tick
    cp 0
    jr z, HandleTick

    dec a
    ld [wCounter], a
```