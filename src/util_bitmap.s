; common routines, no origin here so they can be included wherever needed
; the screen memory is fixed at $8000, however.


;
; Create display list of 160x192 mode E lines
;
init_static_screen_modeE_kernel
        ; load display list & fill with test data
        lda #<dlist_static_modeE
        sta SDLSTL
        lda #>dlist_static_modeE
        sta SDLSTL+1
        lda #$f0        ; turn on DLI bit for 3rd $70 (8 blank lines)
        sta dlist_static_modeE + 2
        rts

; display list can't cross a 1K boundary, so place it to start on a 1K boundary
; $7800 is defined as the start of the PMG memory area, but the first 3 pages
; aren't used by GTIA so we'll stuff our display lists there

        * = $7800

; mode E standard display list
dlist_static_modeE
        .byte $70,$70,$70
        .byte $4e,$00,$80
        .byte $e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e
        .byte $e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e
        .byte $e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e
        .byte $e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e
        .byte $e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e
        .byte $e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e
        .byte $4e,$00,$8f
        .byte $e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e
        .byte $e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e
        .byte $e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e
        .byte $e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e
        .byte $e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e
        .byte $e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e,$e
        .byte $41,<dlist_static_modeE,>dlist_static_modeE
