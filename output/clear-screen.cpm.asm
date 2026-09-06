;; ==========================================================
;; Clears the screen
;; IN:  -
;; OUT: -
;; MOD: C, E
;; ==========================================================
clear_screen
    LD      DE, CLEAR_SCREEN_SEQ
    LD      C, $09
    CALL    $0005

    RET

CLEAR_SCREEN_SEQ    DEFL    $
    .byte   27
    .ascii  "[2J"
    .byte   27
    .ascii  "[H"
    .ascii  "$"
    