        *= $3000

.include "hardware.s"

init
        jsr init_static_screen_mode4
        lda dlist_static_mode4 + 10
        ora #$80
        sta dlist_static_mode4 + 10
        lda dlist_static_mode4 + 20
        ora #$80
        sta dlist_static_mode4 + 20
        jsr init_dli
        jsr init_vbi
        jmp forever

.include "common.s"

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
