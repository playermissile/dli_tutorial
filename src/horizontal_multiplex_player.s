        *= $3000

.include "hardware.s"

num_dli_bands = 12

copy1 = $80
copy2 = $81
copy3 = $82


init
        ; load ANTIC 4/5 font
        jsr init_font

        ; load display list & fill with test data
        jsr init_static_screen_mode5_12_bands

        ; load display list interrupt address
        ldx #>dli
        ldy #<dli
        jsr init_dli

        ; load deferred vertical blank address
        ldx #>vbi
        ldy #<vbi
        jsr init_vbi

        jsr init_pmg

        ; move players 0, 1, and 2 slightly out of the way
        lda #$5c
        sta HPOSP0
        lda #$68
        sta HPOSP1
        lda #$c0
        sta HPOSP2

        jmp forever

.include "util.s"
.include "util_dli.s"
.include "util_vbi.s"
.include "util_pmg.s"
.include "util_font.s"

vbi     lda #68         ; reset position counters for each copy of player 3
        sta copy1
        lda #122
        sta copy2
        lda #156
        sta copy3
        jmp XITVBV      ; always exit deferred VBI with jump here

dli     pha             ; using A & X
        txa
        pha

        dec copy1       ; move copies to the left one color clock each scan line
        dec copy2
        sta WSYNC       ; skip rest of last line of DLI line
        dec copy3       ; not enough time to do all 3 decrements before 1st WSYNC
        ldx #14         ; prepare for 14 scan lines in the loop
        sta WSYNC       ; skip 1st line of mode 5 where ANTIC steals almost all cycles
?loop   lda #48         ; set initial position of player 3
        sta HPOSP3
        nop             ; we're still on the tail end of the prevous scan
        nop             ;   line, so we need to wait until the electron beam
        nop             ;   passes this first position before we set the
        nop             ;   next HPOS.
        nop
        nop
        lda copy1       ; can't place copies until after electron beam draws
        sta HPOSP3      ;   the player in the previous location. If you try
        lda copy2       ;   to move HPOSP3 too early, the previous location
        sta HPOSP3      ;   won't even get drawn. Too late, and it won't draw
        lda copy3       ;   anything in the current location.  It's a battle.
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

; tell DOS where to run the program when loaded
        * = $2e0
        .word init
