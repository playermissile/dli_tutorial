; Written in 2019 by Rob McMullen, https://playermissile.com/dli_tutorial/
; Copyright and related rights waived via CC0: https://creativecommons.org/publicdomain/zero/1.0/
; data structures for multiplexing players across DLIs
;
; The constant num_dli_bands must be declared before including this file!
; It should be a positive integer containing the number of vertical bands
; used in the playfield; that is, the number of times a player is reused in
; different vertical positions on screen.


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
