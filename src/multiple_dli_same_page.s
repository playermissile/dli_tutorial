        *= $3000

.include "hardware.s"

init
        ; load display list & fill with test data
        jsr init_static_screen_mode4

        ; add DLI bit to two lines
        lda #$84
        sta dlist_static_mode4 + 10
        sta dlist_static_mode4 + 20

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

        *= (* & $ff00) + 256 ; next page boundary

dli     pha             ; only using A register, so save it to the stack
        lda #$55        ; new background color
        sta WSYNC       ; first WSYNC gets us to start of scan line we want
        sta COLBK       ; change background color
        lda #<dli2      ; point to second DLI
        sta VDSLST
        pla             ; restore A register from stack
        rti             ; always end DLI with RTI!

dli2    pha             ; only using A register, so save it to the stack
        lda #$88        ; new background color
        sta WSYNC       ; first WSYNC gets us to start of scan line we want
        sta COLBK       ; change background color
        pla             ; restore A register from stack
        rti             ; always end DLI with RTI!


vbi     lda #<dli       ; set DLI pointer to first in chain
        sta VDSLST
        lda #>dli
        sta VDSLST+1
        jmp XITVBV      ; always exit deferred VBI with jump here

; tell DOS where to run the program when loaded
        * = $2e0
        .word init
