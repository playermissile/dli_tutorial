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
        sta WSYNC       ; any value saved to WSYNC will trigger the pause
        sta COLBK       ; store it in the hardware register
        pla             ; restore the A register
        rti             ; always end DLI with RTI!
