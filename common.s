; common routines, no origin here so they can be included wherever needed
; the screen memory is fixed at $8000, however.


;
; Create display list of 40x24 mode 2 lines
;
init_static_screen_bands
        ; load display list & fill with test data
        lda #<dlist_static_bands
        sta SDLSTL
        lda #>dlist_static_bands
        sta SDLSTL+1
        jsr fillscreen_static
        jsr fillscreen_bands
        rts
;
; Create display list of 40x24 mode 4 lines
;
init_static_screen_mode4
        ; load display list & fill with test data
        lda #<dlist_static_mode4
        sta SDLSTL
        lda #>dlist_static_mode4
        sta SDLSTL+1
        jsr fillscreen_static
        rts

;
; Load DLI address and set NMIEN
;
init_dli
        ; load display list interrupt address
        lda #<dli
        sta VDSLST
        lda #>dli
        sta VDSLST+1

        ; activate display list interrupt
        lda #NMIEN_VBI | NMIEN_DLI
        sta NMIEN
        rts

;
; Initialize deferred vertical blank
;
init_vbi
        ; load deferred VBI address
        lda #7
        ldx #>vbi
        ldy #<vbi
        jsr SETVBV
        rts

;
; Loop forever
;
forever
        jmp forever

;
; fill 24 lines of 40 bytes with test pattern
;
fillscreen_static
        ldy #0
?loop   tya
        sta $8000,y
        sta $8028,y
        sta $8050,y
        sta $8078,y
        sta $80a0,y
        sta $80c8,y
        sta $80f0,y
        sta $8118,y
        sta $8140,y
        sta $8168,y
        sta $8190,y
        sta $81b8,y
        sta $81e0,y
        sta $8208,y
        sta $8230,y
        sta $8258,y
        sta $8280,y
        sta $82a8,y
        sta $82d0,y
        sta $82f8,y
        sta $8320,y
        sta $8348,y
        sta $8370,y
        sta $8398,y
        iny
        cpy #40
        bcc ?loop
        rts

fillscreen_bands
        ldy #0
?loop   lda #33
        sta $8050,y
        lda #34
        sta $8168,y
        lda #35
        sta $8280,y
        iny
        cpy #40
        bcc ?loop
        rts

dlist_static_bands
        .byte $70,$70,$70
        .byte $44,$00,$80,4,6,6,4,4
        .byte 4,4,4,4,6,6,4,4,4,4
        .byte 4,4,6,6,4,4
        .byte $41,<dlist_static_bands,>dlist_static_bands

dlist_static_mode4
        .byte $70,$70,$70
        .byte $44,$00,$80
        .byte 4,4,4,4,4,4,4,4
        .byte 4,4,4,4,4,4,4,4
        .byte 4,4,4,4,4,4,4
        .byte $41,<dlist_static_mode4,>dlist_static_mode4

;
; fill 32 pages with test pattern
;
fillscreen_scroll
        ldy #0
?loop   tya
        sta $8000,y
        sta $8100,y
        sta $8200,y
        sta $8300,y
        sta $8400,y
        sta $8500,y
        sta $8600,y
        sta $8700,y
        sta $8800,y
        sta $8900,y
        sta $8a00,y
        sta $8b00,y
        sta $8c00,y
        sta $8d00,y
        sta $8e00,y
        sta $8f00,y
        sta $9000,y
        sta $9100,y
        sta $9200,y
        sta $9300,y
        sta $9400,y
        sta $9500,y
        sta $9600,y
        sta $9700,y
        sta $9800,y
        sta $9900,y
        sta $9a00,y
        sta $9b00,y
        sta $9c00,y
        sta $9d00,y
        sta $9e00,y
        sta $9f00,y
        iny
        bne ?loop
        rts

; one page per line, used for horizontal scrolling
dlist_scroll_mode4
        .byte $70,$70,$70
        .byte $44,$00,$80
        .byte $44,$00,$81
        .byte $44,$00,$82
        .byte $44,$00,$83
        .byte $44,$00,$84
        .byte $44,$00,$85
        .byte $44,$00,$86
        .byte $44,$00,$87
        .byte $44,$00,$88
        .byte $44,$00,$89
        .byte $44,$00,$8a
        .byte $84,$00,$8b
        .byte 0,
        .byte $44,$00,$80
        .byte $44,$00,$81
        .byte $44,$00,$82
        .byte $44,$00,$83
        .byte $44,$00,$84
        .byte $44,$00,$85
        .byte $44,$00,$86
        .byte $44,$00,$87
        .byte $44,$00,$88
        .byte $44,$00,$89
        .byte $44,$00,$8a
        .byte $44,$00,$8b
        .byte $41,<dlist_scroll_mode4,>dlist_scroll_mode4


;
; player/missile utilities
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

        lda #$30        ; just some positions
        sta HPOSP0
        lda #$20
        sta HPOSP1
        lda #$d0
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

