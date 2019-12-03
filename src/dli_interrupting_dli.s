        *= $3000

.include "hardware.s"

temp_color = $80

init
        ; load display list & fill with test data
        jsr init_static_screen_mode4

        ; set DLI on 2nd and 4th mode 4 line
        lda #$84
        sta dlist_static_mode4_2nd_line
        sta dlist_static_mode4_4th_line

        ; load display list interrupt address
        ldx #>dli
        ldy #<dli
        jsr init_dli

        jmp forever

.include "util.s"
.include "util_dli.s"

dli     pha             ; save A & X registers to stack
        txa
        pha
        ldx #16         ; make 16 color changes
        lda #$5f        ; initial bright pink color
        sta WSYNC       ; first WSYNC gets us to start of scan line we want
?loop   sta COLBK       ; change background color
        sec
        sbc #1          ; make dimmer by decrementing luminance value
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
