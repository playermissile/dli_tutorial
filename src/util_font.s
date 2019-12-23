; Written in 2019 by Rob McMullen, https://playermissile.com/dli_tutorial/
; Copyright and related rights waived via CC0: https://creativecommons.org/publicdomain/zero/1.0/
; common routines, no origin here so they can be included wherever needed

;
; Font initialization, assuming font is named "font_data" and aligned at
; a page boundary
;
init_font
        lda #>font_data
        sta CHBAS
        rts
