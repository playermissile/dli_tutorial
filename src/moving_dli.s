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
        jsr init_static_screen_mode4

        ; load display list interrupt address
        ldx #>dli
        ldy #<dli
        jsr init_dli

        ; load deferred vertical blank address
        ldx #>vbi
        ldy #<vbi
        jsr init_vbi

        ; start initial DLI in middle
        lda #start_dli_line
        sta dli_line
        lda #0
        sta last_dli_line
        jsr move_dli_line

        jmp forever

.include "util.s"
.include "util_dli.s"
.include "util_vbi.s"


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
        lda dlist_static_mode4,x ; remove DLI bit
        and #$7f
        sta dlist_static_mode4,x
        ldx dli_line    ; get line number on screen of new DLI
        stx last_dli_line ; remember
        lda dlist_line_lookup,x ; get offset into display list of that line number
        tax
        lda dlist_static_mode4,x ; set DLI bit
        ora #$80
        sta dlist_static_mode4,x
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

;dlist_static_mode4
;        .byte $70,$70,$70
;        .byte $44,$00,$80
;        .byte 4,4,4,4,4,4,4,4
;        .byte 4,4,4,4,4,4,4,4
;        .byte 4,4,4,4,4,4,4
;        .byte $41,<dlist_static_mode4,>dlist_static_mode4

dlist_line_lookup
        .byte 1, 2,
        .byte 3
        .byte 6, 7, 8, 9, 10, 11, 12, 13
        .byte 14, 15, 16, 17, 18, 19, 20, 21
        .byte 22, 23, 24, 25, 26, 27, 28
dlist_line_lookup_last
dlist_line_lookup_count = dlist_line_lookup_last - dlist_line_lookup

; tell DOS where to run the program when loaded
        * = $2e0
        .word init
