; common routines, no origin here so they can be included wherever needed

;
; Font initialization, assuming font is named "font_data" and aligned at
; a page boundary
;
init_font
        lda #>font_data
        sta CHBAS
        rts
