; Written in 2019 by Rob McMullen, https://playermissile.com/dli_tutorial/
; Copyright and related rights waived via CC0: https://creativecommons.org/publicdomain/zero/1.0/
        *= $3000

.include "hardware.s"

num_bands = 3

band_index = $80


init
        ; load ANTIC 4 font
        jsr init_font

        ; load display list & fill with test data
        jsr init_static_screen_mode4_3_bands

        ; load display list interrupt address
        ldx #>dli
        ldy #<dli
        jsr init_dli

        ; load deferred vertical blank address
        ldx #>vbi
        ldy #<vbi
        jsr init_vbi

        jsr init_pmg

        jmp forever

.include "util.s"
.include "util_dli.s"
.include "util_vbi.s"
.include "util_pmg.s"
.include "util_font.s"

vbi     lda #<dli       ; set DLI pointer to first in chain
        sta VDSLST
        lda #>dli
        sta VDSLST+1
        lda #$40        ; set player positions and sizes ...
        sta HPOSP0      ;   for the top of the screen
        lda #$60
        sta HPOSP1
        lda #$80
        sta HPOSP2
        lda #$a0
        sta HPOSP3
        lda #0
        sta SIZEP0
        sta SIZEP1
        sta SIZEP2
        sta SIZEP3
        jmp XITVBV      ; always exit deferred VBI with jump here

        *= (* & $ff00) + 256 ; next page boundary

dli     pha             ; only using A register, so save it to the stack
        lda #$30        ; change position and sizes of players
        sta HPOSP0
        lda #$40
        sta HPOSP1
        lda #$50
        sta HPOSP2
        lda #$60
        sta HPOSP3
        lda #1
        sta SIZEP0
        sta SIZEP1
        sta SIZEP2
        sta SIZEP3
        lda #<dli2      ; point to second DLI
        sta VDSLST
        pla             ; restore A register from stack
        rti             ; always end DLI with RTI!

dli2    pha             ; only using A register, so save it to the stack
        lda #$40        ; change position and sizes of players
        sta HPOSP0
        lda #$70
        sta HPOSP1
        lda #$90
        sta HPOSP2
        lda #$b0
        sta HPOSP3
        lda #3
        sta SIZEP0
        sta SIZEP1
        sta SIZEP2
        sta SIZEP3
        pla             ; restore A register from stack
        rti             ; always end DLI with RTI!

.include "font_data_antic4.s"

; tell DOS where to run the program when loaded
        * = $2e0
        .word init
