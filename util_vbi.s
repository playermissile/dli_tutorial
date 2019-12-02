; common routines, no origin here so they can be included wherever needed


;
; Initialize deferred vertical blank
;
init_vbi
        ; load deferred VBI address
        lda #7
        jsr SETVBV
        rts
