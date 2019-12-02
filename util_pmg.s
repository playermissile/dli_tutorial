; useful player/missile routines, no origin here so they can be included
; wherever needed. The PMG memory is fixed at $7800, however.


;
; Initialize to single line players at $7800 with a default position and color.
;
init_pmg
        jsr testplayers_vertical
        lda #$3e        ; single line, both players & missiles
        sta SDMCTL      ; shadow of DMACTL
        lda #1          ; players in front of playfields
        sta GPRIOR      ; shadow of PRIOR
        lda #3          ; turn on missiles & players
        sta GRACTL      ; no shadow for this one
        lda #$78        ; high byte of player storage
        sta PMBASE      ; missiles = $7b00, player0 = $7c00

        lda #$a3        ; just some colors
        sta PCOLR0
        lda #$a7
        sta PCOLR1
        lda #$ab
        sta PCOLR2
        lda #$af
        sta PCOLR3

        lda #$40        ; just some positions
        sta HPOSP0
        lda #$80
        sta HPOSP1
        lda #$b0
        sta HPOSP2
        lda #$c0
        sta HPOSP3
        rts

;
; set up a full-height test pattern for player/missile graphics area
;
testplayers_vertical
        lda #$ff
        tay
        iny
?loop   sta $7b00,y     ; initialize entire player/missile area to FF
        sta $7c00,y
        sta $7d00,y
        sta $7e00,y
        sta $7f00,y
        iny
        bne ?loop

        lda #$68        ; 'M'
        ldx #$e1
        ldy #$7b        ; missiles
        jsr copy_glyph_to_player

        lda #$80        ; '0'
        ldx #$e0
        ldy #$7c        ; player 0
        jsr copy_glyph_to_player

        lda #$88        ; '1'
        ldx #$e0
        ldy #$7d        ; player 1
        jsr copy_glyph_to_player

        lda #$90        ; '0'
        ldx #$e0
        ldy #$7e        ; player 0
        jsr copy_glyph_to_player

        lda #$98        ; '1'
        ldx #$e0
        ldy #$7f        ; player 1
        jsr copy_glyph_to_player
        rts

;
; copy a glyph to the full height of the player, although skipping
; ever other vertical space to give the player some areas of $ff to
; show the full width
;
copy_glyph_to_player
        sta ?copy_src_smc+1
        stx ?copy_src_smc+2
        sty ?copy_dest_smc+2
        ldy #4
?copy_glyph_start
        ldx #0
?copy_src_smc
        lda $e000,x
        eor #$ff
?copy_dest_smc
        sta $7c00,y
        iny
        inx
        cpx #8
        bcc ?copy_src_smc
        tya
        clc
        adc #8
        tay
        bcc ?copy_glyph_start
        rts

;
; band data for players. Uses constant num_dli_bands to reserve memory
;

band_dli_index .byte 0  ; current band being processed by DLI

; player X positions in band. X position of zero means the player is inactive
; and won't be drawn in the band.
bandp0_x = *
        * = * + num_dli_bands

bandp1_x = *
        * = * + num_dli_bands

bandp2_x = *
        * = * + num_dli_bands

bandp3_x = *
        * = * + num_dli_bands

; player X velocity (delta X) in band
bandp0_dx = *
        * = * + num_dli_bands

bandp1_dx = *
        * = * + num_dli_bands

bandp2_dx = *
        * = * + num_dli_bands

bandp3_dx = *
        * = * + num_dli_bands

; player Y positions in band
bandp0_y = *
        * = * + num_dli_bands

bandp1_y = *
        * = * + num_dli_bands

bandp2_y = *
        * = * + num_dli_bands

bandp3_y = *
        * = * + num_dli_bands


; player Y velocity (delta Y) in band
bandp0_dy = *
        * = * + num_dli_bands

bandp1_dy = *
        * = * + num_dli_bands

bandp2_dy = *
        * = * + num_dli_bands

bandp3_dy = *
        * = * + num_dli_bands

; player last Y position in band for erasing old player
bandp0_y_old = *
        * = * + num_dli_bands

bandp1_y_old = *
        * = * + num_dli_bands

bandp2_y_old = *
        * = * + num_dli_bands

bandp3_y_old = *
        * = * + num_dli_bands

; player color in band
bandp0_color = *
        * = * + num_dli_bands

bandp1_color = *
        * = * + num_dli_bands

bandp2_color = *
        * = * + num_dli_bands

bandp3_color = *
        * = * + num_dli_bands

; player width in band
bandp0_size = *
        * = * + num_dli_bands

bandp1_size = *
        * = * + num_dli_bands

bandp2_size = *
        * = * + num_dli_bands

bandp3_size = *
        * = * + num_dli_bands

; player state (anything with bit 7 set means don't draw)
bandp0_state = *
        * = * + num_dli_bands

bandp1_state = *
        * = * + num_dli_bands

bandp2_state = *
        * = * + num_dli_bands

bandp3_state = *
        * = * + num_dli_bands
