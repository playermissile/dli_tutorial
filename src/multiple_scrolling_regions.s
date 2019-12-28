; Written in 2019 by Rob McMullen, https://playermissile.com/scrolling_tutorial/
; Copyright and related rights waived via CC0: https://creativecommons.org/publicdomain/zero/1.0/
        *= $3000

.include "hardware.s"

delay = 5               ; number of VBLANKs between scrolling updates
vert_scroll_max = 8     ; ANTIC mode 4 has 8 scan lines
horz_scroll_max = 4     ; ANTIC mode 4 has 4 color clocks

delay_count = $80       ; counter for scrolling updates
tmp_counter = $81       ; counter for use in loops

; two bytes per variable, one per region
vert_scroll = $90       ; variable used to store VSCROL value
horz_scroll = $92       ; variable used to store HSCROL value
scroll_dy = $a2         ; down = 1, up=$ff, no movement = 0
scroll_dx = $a4         ; right = 1, left=$ff, no movement = 0

init    lda #0          ; initialize horizontal scrolling value
        sta horz_scroll
        sta horz_scroll+1
        sta HSCROL      ; initialize hardware register

        lda #0          ; initialize vertical scrolling value
        sta vert_scroll
        sta vert_scroll+1
        sta VSCROL      ; initialize hardware register

        lda #1
        sta scroll_dx
        lda #$ff
        sta scroll_dy
        sta scroll_dx+1
        lda #1
        sta scroll_dy+1

        lda #delay      ; number of VBLANKs to wait
        sta delay_count

        jsr init_font

        lda #<dlist
        sta SDLSTL
        lda #>dlist
        sta SDLSTL+1

        ; load display list interrupt address
        lda #<dli
        sta VDSLST
        lda #>dli
        sta VDSLST+1

        ; load deferred vertical blank address
        ldx #>vbi
        ldy #<vbi
        lda #7
        jsr SETVBV

        ; activate display list interrupt
        lda #NMIEN_VBI | NMIEN_DLI
        sta NMIEN

        jsr fillscreen_test_pattern
        lda #$80
        ldx #$38        ; 56 pages; bytes $8000 - $b7ff
        jsr label_pages

forever jmp forever


vbi     dec delay_count ; wait for number of VBLANKs before updating
        bne ?exit       ;   fine/coarse scrolling

        ldx #0          ; process upper region
        jsr process_movement ; update scrolling position
        inx             ; process lower region
        jsr process_movement ; update scrolling position

        lda #delay      ; reset counter
        sta delay_count

        ; every VBI have to set the scrolling registers for the upper
        ; region, otherwise the registers will still be set to the values
        ; for the lower region that were handled in the DLI
?exit   lda horz_scroll
        sta HSCROL
        lda vert_scroll
        sta VSCROL
        jmp XITVBV      ; exit VBI through operating system routine


process_movement
        lda scroll_dx,x ; check horizontal scrolling
        beq ?updown     ; zero means no movement, move on to vert
        bmi ?left1      ; bit 7 set ($ff) means left
        jsr fine_scroll_right ; otherwise, it's right
        jmp ?updown
?left1  jsr fine_scroll_left

?updown lda scroll_dy,x ; check vertical scrolling
        beq ?done       ; zero means no movement, we're done
        bmi ?up1        ; bit 7 set ($ff) means up
        jsr fine_scroll_down ; otherwise, it's down
        jmp ?done
?up1    jsr fine_scroll_up
?done   rts


; HORIZONTAL SCROLLING

; scroll one color clock right and check if at HSCROL limit, returns
; HSCROL value in A
fine_scroll_right
        dec horz_scroll,x
        lda horz_scroll,x
        bpl ?done       ; if non-negative, still in the middle of the character
        jsr coarse_scroll_right ; wrapped to $ff, do a coarse scroll...
        lda #horz_scroll_max-1  ;  ...followed by reseting the HSCROL register
        sta horz_scroll,x
?done   rts

; move viewport one byte to the right by pointing each display list start
; address to one byte higher in memory
coarse_scroll_right
        lda #12         ; 12 lines to modify
        sta tmp_counter
        lda #1          ; dlist_upper_region+1 is low byte of address
        cpx #0
        beq ?start
        lda #(1+36+1)   ; dlist_upper_region+1+36+1 is dlist_region2+1
?start  stx ?smc_savex+1 ; save X register using self-modifying code
        tax
?loop   inc dlist_upper_region,x
        inx             ; skip to next low byte which is 3 bytes away
        inx
        inx
        dec tmp_counter
        bne ?loop
?smc_savex ldx #$ff
        rts

; scroll one color clock left and check if at HSCROL limit, returns
; HSCROL value in A
fine_scroll_left
        inc horz_scroll,x
        lda horz_scroll,x
        cmp #horz_scroll_max ; check to see if we need to do a coarse scroll
        bcc ?done       ; nope, still in the middle of the character
        jsr coarse_scroll_left ; yep, do a coarse scroll...
        lda #0          ;  ...followed by reseting the HSCROL register
        sta horz_scroll,x
?done   rts

; move viewport one byte to the left by pointing each display list start
; address to one byte lower in memory
coarse_scroll_left
        lda #12         ; 12 lines to modify
        sta tmp_counter
        lda #1          ; dlist_upper_region+1 is low byte of address
        cpx #0
        beq ?start
        lda #(1+36+1)   ; dlist_upper_region+1+36+1 is dlist_region2+1
?start  stx ?smc_savex+1 ; save X register using self-modifying code
        tax
?loop   dec dlist_upper_region,x
        inx             ; skip to next low byte which is 3 bytes away
        inx
        inx
        dec tmp_counter
        bne ?loop
?smc_savex ldx #$ff
        rts


; VERTICAL SCROLLING

; scroll one scan line up and check if at VSCROL limit, returns
; VSCROL value in A
fine_scroll_up
        dec vert_scroll,x
        lda vert_scroll,x
        bpl ?done       ; if non-negative, still in the middle of the character
        jsr coarse_scroll_up   ; wrapped to $ff, do a coarse scroll...
        lda #vert_scroll_max-1 ;  ...followed by reseting the vscroll register
        sta vert_scroll,x
?done   rts

; move viewport one line up by pointing display list start address
; to the address one page earlier in memory
coarse_scroll_up
        lda #12         ; 12 lines to modify
        sta tmp_counter
        lda #2          ; dlist_upper_region+2 is high byte of address
        cpx #0
        beq ?start
        lda #(2+36+1)   ; dlist_upper_region+2+36+1 is dlist_region2+2
?start  stx ?smc_savex+1 ; save X register using self-modifying code
        tax
?loop   dec dlist_upper_region,x
        inx             ; skip to next low byte which is 3 bytes away
        inx
        inx
        dec tmp_counter
        bne ?loop
?smc_savex ldx #$ff
        rts

; scroll one scan line down and check if at VSCROL limit, returns
; VSCROL value in A
fine_scroll_down
        inc vert_scroll,x
        lda vert_scroll,x
        cmp #vert_scroll_max ; check to see if we need to do a coarse scroll
        bcc ?done       ; nope, still in the middle of the character
        jsr coarse_scroll_down ; yep, do a coarse scroll...
        lda #0          ;  ...followed by reseting the vscroll register
        sta vert_scroll,x
?done   rts

; move viewport one line down by pointing display list start address
; to the address one page later in memory
coarse_scroll_down
        lda #12         ; 12 lines to modify
        sta tmp_counter
        lda #2          ; dlist_upper_region+2 is high byte of address
        cpx #0
        beq ?start
        lda #(2+36+1)   ; dlist_upper_region+2+36+1 is dlist_region2+2
?start  stx ?smc_savex+1 ; save X register using self-modifying code
        tax
?loop   inc dlist_upper_region,x
        inx             ; skip to next low byte which is 3 bytes away
        inx
        inx
        dec tmp_counter
        bne ?loop
?smc_savex ldx #$ff
        rts


dli     pha             ; only using A register, so save old value to the stack
        lda horz_scroll+1 ; lower region HSCROL value
        sta HSCROL      ; store in hardware register
        lda vert_scroll+1 ; lower region VSCROL value
        sta VSCROL      ; initialize hardware register
        pla             ; restore the A register
        rti             ; always end DLI with RTI!


; one page per line, used for full 2d fine scrolling. Start visible region
; in middle of each page so it can scroll either right or left immediately
; without having to check for a border
dlist   .byte $70,$70,$70

dlist_upper_region
        .byte $74,$70,$90       ; 12 lines in region, VSCROLL + HSCROLL
        .byte $74,$70,$91
        .byte $74,$70,$92
        .byte $74,$70,$93
        .byte $74,$70,$94
        .byte $74,$70,$95
        .byte $74,$70,$96
        .byte $74,$70,$97
        .byte $74,$70,$98
        .byte $74,$70,$99
        .byte $74,$70,$9a
        .byte $54,$70,$9b       ; last line in scrolling region, HSCROLL only

        .byte $80               ; one blank line + DLI

dlist_lower_region
        .byte $74,$70,$90       ; 12 lines in region, VSCROLL + HSCROLL
        .byte $74,$70,$91
        .byte $74,$70,$92
        .byte $74,$70,$93
        .byte $74,$70,$94
        .byte $74,$70,$95
        .byte $74,$70,$96
        .byte $74,$70,$97
        .byte $74,$70,$98
        .byte $74,$70,$99
        .byte $74,$70,$9a
        .byte $54,$70,$9b       ; last line in scrolling region, HSCROLL only

        .byte $41,<dlist,>dlist ; JVB ends display list


.include "util_font.s"
.include "util_scroll.s"
.include "font_data_antic4.s"

; tell DOS where to run the program when loaded
        * = $2e0
        .word init
