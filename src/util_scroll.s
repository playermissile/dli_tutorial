; common routines, no origin here so they can be included wherever needed
; the screen memory is fixed at $8000, however.


;
; Create display list of 40x24 mode 4 lines
;
init_screen_parallax
        ; load display list & fill with test data
        lda #<dlist_parallax_mode4
        sta SDLSTL
        lda #>dlist_parallax_mode4
        sta SDLSTL+1
        jsr fillscreen_parallax
        rts

;
; fill 24 pages with test pattern
;
fillscreen_parallax
        ldy #0
?loop   lda #$41
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

        lda #$a2
        sta $8a00,y
        sta $8b00,y

        lda #$43
        sta $8c00,y
        sta $8d00,y
        sta $8e00,y
        sta $8f00,y

        lda #$a4
        sta $9000,y
        sta $9100,y
        sta $9200,y
        sta $9300,y
        sta $9400,y
        sta $9500,y
        sta $9600,y
        sta $9700,y
        iny
        bne ?loop
        rts


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
dlist_parallax_mode4
        .byte $70,$70,$70       ; region A: no scrolling
        .byte $54,$00,$80
        .byte $54,$00,$81
        .byte $54,$00,$82
        .byte $54,$00,$83
        .byte $54,$00,$84
        .byte $54,$00,$85
        .byte $54,$00,$86
        .byte $54,$00,$87
        .byte $54,$00,$88
        .byte $d4,$00,$89
dlist_parallax_region_b
        .byte $54,$00,$8a       ; region B: 1/4 as much scrolling as D
        .byte $d4,$00,$8b
dlist_parallax_region_c
        .byte $54,$00,$8c       ; region C: 1/2 as much scrolling as D
        .byte $54,$00,$8d
        .byte $54,$00,$8e
        .byte $d4,$00,$8f
dlist_parallax_region_d
        .byte $54,$00,$90       ; region D: all the scrolling
        .byte $54,$00,$91
        .byte $54,$00,$92
        .byte $54,$00,$93
        .byte $54,$00,$94
        .byte $54,$00,$95
        .byte $54,$00,$96
        .byte $54,$00,$97
        .byte $41,<dlist_parallax_mode4,>dlist_parallax_mode4

dlist_parallax_mode4_row1_offset
        .byte 12*3+1,14*3+1,18*3+1
dlist_parallax_mode4_row2_offset
        .byte 13*3+1,15*3+1,19*3+1
dlist_parallax_mode4_row3_offset
        .byte 0,16*3+1,20*3+1
dlist_parallax_mode4_row4_offset
        .byte 0,17*3+1,21*3+1
dlist_parallax_mode4_row5_offset
        .byte 0,0,22*3+1
dlist_parallax_mode4_row6_offset
        .byte 0,0,23*3+1
dlist_parallax_mode4_row7_offset
        .byte 0,0,24*3+1
dlist_parallax_mode4_row8_offset
        .byte 0,0,25*3+1
