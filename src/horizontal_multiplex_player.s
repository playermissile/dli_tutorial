        *= $3000

.include "hardware.s"

num_dli_bands = 12

band_index = $80


init
        jsr init_font
        jsr init_static_screen_mode5_12_bands
        ldx #>dli
        ldy #<dli
        jsr init_dli
        jsr init_pmg

        ; move players 1 and 2 slightly out of the way
        lda #$70
        sta HPOSP1
        lda #$c0
        sta HPOSP2

        jmp forever

.include "util.s"
.include "util_dli.s"
.include "util_pmg.s"
.include "util_font.s"

dli
        pha             ; using A & X
        txa
        pha

        sta WSYNC       ; skip rest of last line of DLI line
        ldx #14
        sta WSYNC       ; skip 1st line of mode 5 where ANTIC steals almost all cycles
?loop   lda #48         ; set initial position of 1st copy of player 3
        sta HPOSP3
        nop             ; wait until 1st copy is drawn
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        lda #90         ; after 1st copy is drawn but before electron beam
        sta HPOSP3      ;   has passed the place we want for 2nd copy, set that position
        lda #130        ; similar for 3rd and 4th copies
        sta HPOSP3
        lda #170
        sta HPOSP3
        dex
        beq ?done
        sta WSYNC
        bne ?loop

?done   pla             ; restore A & X
        tax
        pla
        rti             ; always end DLI with RTI!

.include "font_data_antic4.s"
