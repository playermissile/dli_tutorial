; Written in 2019 by Rob McMullen, https://playermissile.com/dli_tutorial/
; Copyright and related rights waived via CC0: https://creativecommons.org/publicdomain/zero/1.0/
        *= $3000

.include "hardware.s"

start_color = $80
text_color = $36

init    lda #1
        sta start_color
        lda #$text_color
        sta COLOR0

        ; load display list with test data
        lda #<dlist
        sta sdlstl
        lda #>dlist
        sta sdlstl+1

        ; load display list interrupt address
        ldx #>dli
        ldy #<dli
        jsr init_dli

forever jmp forever

dlist   .byte $70,$70,$70,$70,$70,$70  ; 48 blank lines
        .byte $46,<text,>text ; Mode 6 + LMS, setting screen memory to text
        .byte 6            ; Mode 6
        .byte $70,$70      ; 16 blank lines
        .byte 7,7,7        ; 3 lines of Mode 7
        .byte $70          ; 8 blank lines
        .byte $f0          ; 8 blank lines + DLI on last scan line
        .byte 7,7          ; 2 lines of Mode 7
        .byte $41,<dlist,>dlist ; JVB, restart same display list on next frame

text    ;       01234567890123456789
        .sbyte "   player"
        .byte $4f ; slash using lower-case color
        .sbyte           "missile   "
        .sbyte "  podcast presents  "

        .sbyte +$c0, "    ATARI  8-BIT    "
        .sbyte +$c0, "    DISPLAY LIST    "
        .sbyte +$c0, "     INTERRUPTS     "

        .sbyte "   A COMPLETE(ISH)  "
        .sbyte "      TUTORIAL      "

.include "util_dli.s"

dli     pha             ; save A & X registers to stack
        txa
        pha
        ldx #32         ; make 32 color changes
        lda start_color ; initial color
        sta WSYNC       ; first WSYNC gets us to start of scan line we want
?loop   sta COLPF0      ; change text color for UPPERCASE characters in gr2
        clc
        adc #$1         ; change color value, making brighter
        dex             ; update iteration count
        sta WSYNC       ; sta doesn't affect processor flags
        bne ?loop       ; we are still checking result of dex
        lda #text_color ; reset text color to normal color
        sta COLPF0
        dec start_color ; change starting color for next time
        pla             ; restore X & A registers from stack
        tax
        pla
        rti             ; always end DLI with RTI!

; tell DOS where to run the program when loaded
        * = $2e0
        .word init
