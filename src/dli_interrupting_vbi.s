        *= $3000

.include "hardware.s"

temp_color = $80

init
        ; load display list & fill with test data
        jsr init_static_screen_mode4

        ; set DLI on the last blank line before first mode 4 line
        lda #$f0
        sta dlist_static_mode4+2

        ; load display list interrupt address
        ldx #>dli
        ldy #<dli
        jsr init_dli

        ; load deferred vertical blank address
        ldx #>vbi
        ldy #<vbi
        jsr init_vbi

        jmp forever

.include "util.s"
.include "util_dli.s"
.include "util_vbi.s"

; simple vertical blank that changes background color as fast as it can
; so we can see where it is when it gets interrupted
vbi     lda VCOUNT
        bne vbi         ; just wait for top of screen

        ldx #0
?top    inx             ; on top of screen
        stx COLBK
        lda VCOUNT
        cmp #50         ; work until 100th scan line
        bcc ?top

        lda #0          ; reset background color to zero
        sta COLBK
        jmp XITVBV


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

; tell DOS where to run the program when loaded
        * = $2e0
        .word init
