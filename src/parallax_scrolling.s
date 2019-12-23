; Written in 2019 by Rob McMullen, https://playermissile.com/dli_tutorial/
; Copyright and related rights waived via CC0: https://creativecommons.org/publicdomain/zero/1.0/
.include "hardware.s"

num_dli_bands = 3

        *= $80

band_dli_index = *
        * = * + 1
band_course = *
        * = * + num_dli_bands
band_hscrol_frac = *
        * = * + num_dli_bands
band_hscrol = *
        * = * + num_dli_bands
band_hscrol_frac_delta = *
        * = * + num_dli_bands

        * = $3000

init
        jsr init_font
        jsr init_screen_parallax

        lda #0
        sta band_dli_index
        sta band_hscrol_frac
        sta band_hscrol_frac+1
        sta band_hscrol_frac+2
        sta band_hscrol
        sta band_hscrol+1
        sta band_hscrol+2

        ; set up initial scrolling speeds
        lda #128
        sta band_hscrol_frac_delta+2
        lda #64
        sta band_hscrol_frac_delta+1
        lda #32
        sta band_hscrol_frac_delta

        ldx #>dli_band
        ldy #<dli_band
        jsr init_dli
        ldx #>vbi
        ldy #<vbi
        jsr init_vbi
        jmp forever

.include "util.s"
.include "util_dli.s"
.include "util_vbi.s"
.include "util_scroll.s"
.include "util_font.s"



; calculate new scrolling positions of bands
vbi     ldx #2
?move   lda band_hscrol_frac,x  ; update scrolling position fraction
        clc                     ;   by adding velocity fraction.
        adc band_hscrol_frac_delta,x
        sta band_hscrol_frac,x
        lda band_hscrol,x       ; update scrolling position whole number
        adc #0
        sta band_hscrol,x
        cmp #4          ; 4 color clocks in Antic 4; check if need a course
        bcc ?nope       ;   scroll

        ; course scroll needed, chech which region
        cpx #0
        bne ?ckb
        jsr course_scroll_b
        bcc ?next       ; CLC in subroutine to allow branch

?ckb    cpx #1
        bne ?chc
        jsr course_scroll_c
        bcc ?next       ; CLC in subroutine to allow branch

?chc    jsr course_scroll_d

?next   lda #0          ; reset HSCROL for this band
        sta band_hscrol,x

?nope   dex
        bpl ?move

        lda #$ff        ; initialize band index to get ready for the first
        sta band_dli_index ;   DLI which affects band B

        lda #0          ; always reset HSCROL to zero for top of new screen
        sta HSCROL

        jmp XITVBV      ; always exit deferred VBI with jump here

course_scroll_b
        dec dlist_parallax_region_b+1
        dec dlist_parallax_region_b+4
        clc
        rts

course_scroll_c
        dec dlist_parallax_region_c+1
        dec dlist_parallax_region_c+4
        dec dlist_parallax_region_c+7
        dec dlist_parallax_region_c+10
        clc
        rts

course_scroll_d
        dec dlist_parallax_region_d+1
        dec dlist_parallax_region_d+4
        dec dlist_parallax_region_d+7
        dec dlist_parallax_region_d+10
        dec dlist_parallax_region_d+13
        dec dlist_parallax_region_d+16
        dec dlist_parallax_region_d+19
        dec dlist_parallax_region_d+22
        clc
        rts


; same DLI routine is used for each band, the band_dli_index is used to;
; determine which band we're in
dli_band
        pha             ; using A & X
        txa
        pha
        inc band_dli_index ; increment band index, VBI initialized to $ff,
        ldx band_dli_index ;   so will be 0 for band B (band A doesn't scroll!)

        lda band_hscrol,x ; change HSCROL for this band
        sta HSCROL

?done   pla             ; restore A & X
        tax
        pla
        rti             ; always end DLI with RTI!

.include "font_data_antic4.s"

; tell DOS where to run the program when loaded
        * = $2e0
        .word init
