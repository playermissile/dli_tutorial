        *= $3000

.include "hardware.s"

; scratch

src = $b4
index1 = $ce

; players 0 and 1 are reserved for jumpman and shadow, respectively

init
        lda #<dlist
        sta sdlstl
        lda #>dlist
        sta sdlstl+1

        jsr fillscreen

forever
        jmp forever

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
        .byte $42,$00,$40
        .byte $42,$00,$41
        .byte $42,$00,$42
        .byte $42,$00,$43
        .byte $42,$00,$44
        .byte $42,$00,$45
        .byte $42,$00,$46
        .byte $42,$00,$47
        .byte $42,$00,$48
        .byte $42,$00,$49
        .byte $42,$00,$4a
        .byte $42,$00,$4b
        .byte $42,$00,$4c
        .byte $42,$00,$4d
        .byte $42,$00,$4e
        .byte $42,$00,$4f
        .byte $42,$00,$50
        .byte $42,$00,$51
        .byte $42,$00,$52
        .byte $42,$00,$53
        .byte $42,$00,$54
        .byte $42,$00,$55
        .byte $42,$00,$56
        .byte $42,$00,$57
        .byte $41,<dlist,>dlist
