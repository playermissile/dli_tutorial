; Written in 2019 by Rob McMullen, https://playermissile.com/dli_tutorial/
; Copyright and related rights waived via CC0: https://creativecommons.org/publicdomain/zero/1.0/
        *= $3000

.include "hardware.s"


init
        ; load display list & fill with test data
        jsr init_dli_screen_mode4

        ; load display list interrupt address
        ldx #>dli
        ldy #<dli
        jsr init_dli

        jmp forever

.include "util.s"
.include "util_dli.s"

dli     pha             ; only using A register, so save old value to the stack
        lda #$7a        ; new background color
        sta COLBK       ; store it in the hardware register
        pla             ; restore the A register
        rti             ; always end DLI with RTI!

; tell DOS where to run the program when loaded
        * = $2e0
        .word init
