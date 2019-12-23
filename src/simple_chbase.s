        *= $3000

.include "hardware.s"

num_bands = 3

band_index = $80


init
        ; load display list & fill with test data
        lda #<dlist_static
        sta SDLSTL
        lda #>dlist_static
        sta SDLSTL+1
        jsr fillscreen_test

        ; set the character set using the shadow register (CHBAS), not the
        ; hardware register (CHBASE). It will be reloaded every vertical blank
        ; to set the character set for the top of the screen.
        lda #$e0
        sta CHBAS

        ; load display list interrupt address
        ldx #>dli
        ldy #<dli
        jsr init_dli

        jmp forever

.include "util.s"
.include "util_dli.s"

dli     pha             ; only using A register, so save it to the stack
        lda #>font_data ; page number of new font data
        sta WSYNC       ; first WSYNC gets us to start of scan line we want
        sta CHBASE      ; store to hardware register to affect change immediately
        pla             ; restore A register from stack
        rti             ; always end DLI with RTI!

; mixed mode 2 and mode 4 display list
dlist_static
        .byte $70,$70,$70
        .byte $42,$00,$80
        .byte 2,2,2,2,2,2,2     ; first band has 8 lines of mode 2
        .byte 4,4,4,4,4,4,4,$84 ; 2nd band: 8 lines of mode 4 + DLI on last line
        .byte 4,4,4,4,4,4,4,4   ; 3rd band: 8 lines of mode 4
        .byte $41,<dlist_static,>dlist_static

;
; fill 24 lines of 40 bytes with test pattern for 3 bands
;
fillscreen_test
        ldy #0
        lda #$21
?loop   sta $8000,y
        sta $8028,y
        sta $8050,y
        sta $8078,y
        sta $80a0,y
        sta $80c8,y
        sta $80f0,y
        sta $8118,y
        sta $8140,y
        sta $8168,y
        sta $8190,y
        sta $81b8,y
        sta $81e0,y
        sta $8208,y
        sta $8230,y
        sta $8258,y
        sta $8280,y
        sta $82a8,y
        sta $82d0,y
        sta $82f8,y
        sta $8320,y
        sta $8348,y
        sta $8370,y
        sta $8398,y
        clc
        adc #1
        iny
        cpy #40
        bcc ?loop
        rts

.include "font_data_antic4.s"

; tell DOS where to run the program when loaded
        * = $2e0
        .word init
