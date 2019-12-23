; Written in 2019 by Rob McMullen, https://playermissile.com/dli_tutorial/
; Copyright and related rights waived via CC0: https://creativecommons.org/publicdomain/zero/1.0/
        *= $3000

.include "hardware.s"

num_dli_bands = 12

band_index = $80


init
        jsr init_font
        jsr init_static_screen_mode4_12_bands
        ldx #>dli_band
        ldy #<dli_band
        jsr init_dli
        ldx #>vbi
        ldy #<vbi
        jsr init_vbi
        jsr init_pmg
        jsr init_demo_pmg
        jmp forever

.include "util.s"
.include "util_dli.s"
.include "util_vbi.s"
.include "util_pmg.s"
.include "util_multiplex_pmg.s"
.include "util_font.s"

; set up demo: initialize player pos, velocity in bands
init_demo_pmg
        ldx #0
        stx band_dli_index

        ; initialize random player X positions
?loop   lda RANDOM
        and #$1f
        adc #$30
        sta bandp0_x,x
        lda RANDOM
        and #$1f
        adc #$50
        sta bandp1_x,x
        lda RANDOM
        and #$1f
        adc #$70
        sta bandp2_x,x
        lda RANDOM
        and #$1f
        adc #$90
        sta bandp3_x,x

        ; initialize X velocity to 2 going right and 2 left
        lda #1
        sta bandp1_dx,x ; to the right
        sta bandp3_dx,x
        lda #$ff
        sta bandp0_dx,x ; to the left
        sta bandp2_dx,x ; to the left

        ; initialize random player colors per band
        lda RANDOM
        ora #$07        ; not too dark
        sta bandp0_color,x
        lda RANDOM
        ora #$07        ; not too dark
        sta bandp1_color,x
        lda RANDOM
        ora #$07
        sta bandp2_color,x
        lda RANDOM
        ora #$07
        sta bandp3_color,x

        ; initialize random player sizes per band
        lda RANDOM
        tay
        and #$03
        sta bandp0_size,x
        tya
        lsr a
        lsr a
        and #$03
        sta bandp1_size,x
        tya
        lsr a
        lsr a
        and #$03
        sta bandp2_size,x
        tya
        lsr a
        lsr a
        and #$03
        sta bandp3_size,x

        inx
        cpx #num_dli_bands
        bcs ?done
        jmp ?loop
?done   rts


; calculate new positions of players in all bands
vbi     ldx #0
?move   lda bandp0_x,x  ; update X coordinate
        clc             ;   by adding velocity.
        adc bandp0_dx,x ;   Note that velocity of $ff
        sta bandp0_x,x  ;   is same as -1
        cmp #$30        ; check left edge
        bcs ?right      ; if >=, it is still in playfield
        lda #1          ; nope, <, so make velocity positive
        sta bandp0_dx,x
        bne ?cont
?right  cmp #$c0        ; check right edge
        bcc ?cont       ; if <, it is still in playfield
        lda #$ff        ; nope, >=, so make velocity negative
        sta bandp0_dx,x
?cont   inx             ; next player
        cpx #num_dli_bands * 4 ; loop through 12 bands * 4 players each
        bcc ?move

        lda #$ff        ; initialize band index to get ready for band A
        sta band_dli_index
        jmp XITVBV      ; always exit deferred VBI with jump here

; same DLI routine is used for each band, the band_dli_index is used to set
; player information for the appropriate band
dli_band
        pha             ; using A & X
        txa
        pha
        inc band_dli_index ; increment band index, VBI initialized to $ff,
        ldx band_dli_index ;   so will become 0 for band A

        ; control band X positions of players
        lda bandp0_x,x  ; x position of player 0 in this band
        sta HPOSP0
        lda bandp0_color,x ; color of player 0 for this band
        sta COLPM0
        lda bandp0_size,x ; size of player 0 for this band
        sta SIZEP0

        lda bandp1_x,x  ; as above, but for players 1 - 3
        sta HPOSP1
        lda bandp1_color,x
        sta COLPM1
        lda bandp1_size,x
        sta SIZEP1

        lda bandp2_x,x
        sta HPOSP2
        lda bandp2_color,x
        sta COLPM2
        lda bandp2_size,x
        sta SIZEP2

        lda bandp3_x,x
        sta HPOSP3
        lda bandp3_color,x
        sta COLPM3
        lda bandp3_size,x
        sta SIZEP3

?done   pla             ; restore A & X
        tax
        pla
        rti             ; always end DLI with RTI!

.include "font_data_antic4.s"

; tell DOS where to run the program when loaded
        * = $2e0
        .word init
