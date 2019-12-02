        *= $3000

.include "hardware.s"

temp_color = $80

init
        ; load display list & fill with test data
        jsr init_dli_screen_mode4

        ; load display list interrupt address
        ldx #>dli
        ldy #<dli
        jsr init_dli
        jmp forever

dli     pha             ; save A & X registers to stack
        txa
        pha
        ldx #16         ; make 16 color changes
        lda #$a         ; initial color
        sta WSYNC       ; first WSYNC gets us to start of scan line we want
?loop   sta COLBK       ; change background color
        clc
        adc #$10        ; change color value, luminance remains the same
        dex             ; update iteration count
        sta WSYNC       ; make it the color change last ...
        sta WSYNC       ;   for two scan lines
        bne ?loop       ; sta doesn't affect processor flags so we are still checking result of dex
        lda #$00        ; reset background color to black
        sta COLBK
        pla             ; restore X & A registers from stack
        tax
        pla
        rti             ; always end DLI with RTI!

.include "util.s"
.include "util_dli.s"
