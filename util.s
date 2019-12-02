; common routines, no origin here so they can be included wherever needed
; the screen memory is fixed at $8000, however.


;
; Create display list of 40x24 mode 4 lines
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
; Create display list of 40x24 mode 4 lines in 6 bands labeled A - F
;
init_static_screen_mode4_6_bands
        ; load display list & fill with test data
        lda #<dlist_static_mode4
        sta SDLSTL
        lda #>dlist_static_mode4
        sta SDLSTL+1
        jsr fillscreen_static_6_bands
        lda #$f0        ; turn on DLI bit for 3rd $70 (8 blank lines)
        sta dlist_static_mode4 + 2
        lda #$84        ; turn on DLI bit for 5 mode lines, 4 lines apart
        sta dlist_static_mode4 + 8
        sta dlist_static_mode4 + 12
        sta dlist_static_mode4 + 16
        sta dlist_static_mode4 + 20
        sta dlist_static_mode4 + 24
        rts

;
; Create display list of 40x24 mode 4 lines in 12 bands labeled A - L
;
init_static_screen_mode4_12_bands
        ; load display list & fill with test data
        lda #<dlist_static_mode4
        sta SDLSTL
        lda #>dlist_static_mode4
        sta SDLSTL+1
        jsr fillscreen_static_12_bands
        lda #$f0        ; turn on DLI bit for 3rd $70 (8 blank lines)
        sta dlist_static_mode4 + 2
        lda #$84        ; turn on DLI bit for 5 mode lines, 2 lines apart
        sta dlist_static_mode4 + 6
        sta dlist_static_mode4 + 8
        sta dlist_static_mode4 + 10
        sta dlist_static_mode4 + 12
        sta dlist_static_mode4 + 14
        sta dlist_static_mode4 + 16
        sta dlist_static_mode4 + 18
        sta dlist_static_mode4 + 20
        sta dlist_static_mode4 + 22
        sta dlist_static_mode4 + 24
        sta dlist_static_mode4 + 26
        rts

;
; table of band centers in PMG coords
;
center_pmg_y_6_bands
        .byte 40, 72, 104, 136, 168, 190

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
;
; fill 24 lines of 40 bytes with test pattern for 6 bands
;
fillscreen_static_6_bands
        ldy #0
?loop   lda #$41
        sta $8000,y
        sta $8028,y
        sta $8050,y
        sta $8078,y
        lda #$a2
        sta $80a0,y
        sta $80c8,y
        sta $80f0,y
        sta $8118,y
        lda #$43
        sta $8140,y
        sta $8168,y
        sta $8190,y
        sta $81b8,y
        lda #$a4
        sta $81e0,y
        sta $8208,y
        sta $8230,y
        sta $8258,y
        lda #$45
        sta $8280,y
        sta $82a8,y
        sta $82d0,y
        sta $82f8,y
        lda #$a6
        sta $8320,y
        sta $8348,y
        sta $8370,y
        sta $8398,y
        iny
        cpy #40
        bcc ?loop
        rts

;
; fill 24 lines of 40 bytes with test pattern for 12 bands
;
fillscreen_static_12_bands
        ldy #0
?loop   lda #$41
        sta $8000,y
        sta $8028,y
        lda #$a2
        sta $8050,y
        sta $8078,y
        lda #$43
        sta $80a0,y
        sta $80c8,y
        lda #$a4
        sta $80f0,y
        sta $8118,y
        lda #$45
        sta $8140,y
        sta $8168,y
        lda #$a6
        sta $8190,y
        sta $81b8,y
        lda #$47
        sta $81e0,y
        sta $8208,y
        lda #$a8
        sta $8230,y
        sta $8258,y
        lda #$49
        sta $8280,y
        sta $82a8,y
        lda #$aa
        sta $82d0,y
        sta $82f8,y
        lda #$4b
        sta $8320,y
        sta $8348,y
        lda #$ac
        sta $8370,y
        sta $8398,y
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
