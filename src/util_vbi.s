; Written in 2019 by Rob McMullen, https://playermissile.com/dli_tutorial/
; Copyright and related rights waived via CC0: https://creativecommons.org/publicdomain/zero/1.0/
; common routines, no origin here so they can be included wherever needed


;
; Initialize deferred vertical blank
;
init_vbi
        ; load deferred VBI address
        lda #7
        jsr SETVBV
        rts
