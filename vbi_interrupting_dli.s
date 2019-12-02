        *= $3000

.include "hardware.s"

temp_color = $80

init
        ; load display list & fill with test data
        lda #<dlist
        sta sdlstl
        lda #>dlist
        sta sdlstl+1
        jsr fillscreen

        ; load display list interrupt address
        lda #<dli
        sta VDSLST
        lda #>dli
        sta VDSLST+1

        ; activate display list interrupt
        lda #NMIEN_VBI | NMIEN_DLI
        sta NMIEN

forever
        jmp forever

dli     pha             ; save A & X registers to stack
        txa
        pha
        ldx #64         ; make 64 color changes
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

fillscreen
        ldy #0
        ldx #24
        lda #$40
        sta ?loop_smc+2
?loop   tya
?loop_smc sta $4000,y
        iny
        bne ?loop
        inc ?loop_smc+2
        dex
        bne ?loop
        rts

dlist ; one page per line, will be used for horizontal scrolling eventually
        .byte $70,$70,$70
        .byte $44,$00,$40
        .byte $44,$00,$41
        .byte $44,$00,$42
        .byte $44,$00,$43
        .byte $44,$00,$44
        .byte $44,$00,$45
        .byte $44,$00,$46
        .byte $44,$00,$47
        .byte $44,$00,$48
        .byte $44,$00,$49
        .byte $44,$00,$4a
        .byte $44,$00,$4b
        .byte $44,$00,$4c
        .byte $44,$00,$4d
        .byte $44,$00,$4e
        .byte $44,$00,$4f
        .byte $44,$00,$50
        .byte $44,$00,$51
        .byte $44,$00,$52
        .byte $44,$00,$53
        .byte $44,$00,$54
        .byte $44,$00,$55
        .byte $44,$00,$56
        .byte $c4,$00,$57
        .byte $41,<dlist,>dlist
