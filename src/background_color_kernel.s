; Written in 2019 by Rob McMullen, https://playermissile.com/dli_tutorial/
; Copyright and related rights waived via CC0: https://creativecommons.org/publicdomain/zero/1.0/
        *= $3000

.include "hardware.s"


init
        jsr init_static_screen_modeE_kernel
        ldx #>dli
        ldy #<dli
        jsr init_dli

        jmp forever

dli     pha             ; using all registers
        txa
        pha
        tya
        pha

        ldy #192
        sta WSYNC       ; initialize to near beginning of first scan line of interest
?loop   lda #90         ; set background color
        sta COLBK
        nop             ; wait for some time
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        lda #70         ; after 1st copy is drawn but before electron beam
        sta COLBK
        dey
        sta WSYNC
        bne ?loop

        lda #0
        sta COLBK

?done   pla             ; restore all registers
        tay
        pla
        tax
        pla
        rti             ; always end DLI with RTI!


.include "util.s"
.include "util_dli.s"
.include "util_bitmap.s"

; tell DOS where to run the program when loaded
        * = $2e0
        .word init
