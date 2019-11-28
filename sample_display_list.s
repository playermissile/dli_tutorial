        *= $3000

.include "hardware.s"


init
        ; load display list & fill with test data
        lda #<dlist
        sta sdlstl
        lda #>dlist
        sta sdlstl+1

forever
        jmp forever

dlist
        .byte $70,$70,$70  ; 24 blank lines
        .byte $46,$00,$40  ; Mode 6 + LMS, setting screen memory to $4000
        .byte 6            ; Mode 6
        .byte $70          ; 8 blank lines
        .byte 7,7,7,7,7    ; 5 lines of Mode 7
        .byte $70          ; 8 blank lines
        .byte 2            ; single line of Mode 2
        .byte $70,$70,$70  ; 24 blank lines
        .byte 2,4          ; Mode 2 followed by mode 4
        .byte $70          ; 8 blank lines
        .byte 2,5          ; Mode 2 followed by mode 5
        .byte $41,<dlist,>dlist ; JVB, restart same display list on next frame

        *= $4000

        ;       01234567890123456789
        .sbyte "   player"
        .byte $4f ; slash using lower-case color
        .sbyte           "missile   "
        .sbyte "  podcast presents  "

        .sbyte +$c0, "    THE ADVANCED    "
        .sbyte +$c0, "    CRASH COURSE    "
        .sbyte +$c0, "         ON         "
        .sbyte +$c0, "    DISPLAY LIST    "
        .sbyte +$c0, "     INTERRUPTS     "

        ;       0123456789012345678901234567890123456789
        .sbyte " Available at http://playermissile.com  "

        .sbyte " Here's some ANTIC mode 4:              "
        .sbyte "0123456789012345678901234567890123456789"

        .sbyte " And here's some ANTIC mode 5:          "
        .sbyte "0123456789012345678901234567890123456789"
