        *= $3000

.include "hardware.s"

delay_frames = 5
start_dli_line = 4

; zero page variables
stickctr = $80
dli_line = $81
last_dli_line = $82

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

        ; load deferred VBI address
        lda #7
        ldx #>vbi
        ldy #<vbi
        jsr SETVBV

        ; start initial DLI in middle
        lda #start_dli_line
        sta dli_line
        lda #0
        sta last_dli_line
        jsr move_dli_line

        ; activate display list interrupt
        lda #NMIEN_VBI | NMIEN_DLI
        sta NMIEN

forever
        jmp forever

vbi     lda STICK0      ; check stick
        cmp #$f         ; centered => exit
        beq ?reset_ctr
        inc stickctr    ; delay counter so DLI doesn't change too fast
        lda stickctr
        cmp #delay_frames
        bcc ?done
        lda STICK0      ; ah, if only we had more registers
        cmp #$e         ; moving up?
        bne ?down
?up     dec dli_line    ; yep, move DLI to earlier in display list
        bpl ?up_ok      ; unless we're off the top, then reset to end
        lda #dlist_line_lookup_count - 1
        sta dli_line
?up_ok  jsr move_dli_line ; modify the display list
        jmp ?reset_ctr

?down   cmp #$d         ; moving down?
        bne ?done
        inc dli_line    ; yep, move DLI later in display list
        lda dli_line    ; unless were past the end, then reset to top
        cmp #dlist_line_lookup_count
        bcc ?dn_ok
        lda #0
        sta dli_line
?dn_ok  jsr move_dli_line ; modify the display list

?reset_ctr
        lda #0          ; reset stick counter to wait for next valid input
        sta stickctr
?done   jmp XITVBV      ; always exit deferred VBI with jump here

move_dli_line
        ldx last_dli_line ; get line number on screen of old DLI
        lda dlist_line_lookup,x ; get offset into display list of that line number
        tax
        lda dlist_first,x ; remove DLI bit
        and #$7f
        sta dlist_first,x
        ldx dli_line    ; get line number on screen of new DLI
        stx last_dli_line ; remember
        lda dlist_line_lookup,x ; get offset into display list of that line number
        tax
        lda dlist_first,x ; set DLI bit
        ora #$80
        sta dlist_first,x
        rts


dli     pha             ; save A & X registers to stack
        txa
        pha
        ldx #8          ; make 8 color changes
        lda #$a         ; initial color
        sta WSYNC       ; first WSYNC gets us to start of scan line we want
?loop   sta COLBK       ; change background color
        clc
        adc #$10        ; change color value, luminance remains the same
        dex             ; update iteration count
        sta WSYNC       ; make it the color change last for one scan line
        bne ?loop       ; sta doesn't affect processor flags so we are still checking result of dex
        lda #$00        ; reset background color to black
        sta COLBK
        pla             ; restore X & A registers from stack
        tax
        pla
        rti

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
        .byte $70
dlist_first
        .byte $70,$70
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
dlist_last
        .byte $44,$00,$57
        .byte $41,<dlist,>dlist

dlist_line_lookup
        .byte 0, 1, 2, 5, 8, 11, 14, 17, 20, 23, 26, 29, 32, 35, 38, 41, 44, 47, 50, 53, 56, 59, 62, 65, 68, 71
dlist_line_lookup_last
dlist_line_lookup_count = dlist_line_lookup_last - dlist_line_lookup
