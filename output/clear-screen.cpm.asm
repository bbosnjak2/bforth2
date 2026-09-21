;; ==========================================================
;; Clears the screen
;; IN:  -
;; OUT: -
;; MOD: C, E
;; ==========================================================
clear_screen
    .local
    LD      DE, CLEAR_SCREEN_SEQ            ; content
    LD      BC, CLEAR_SCREEN_SEQ_LEN        ; length
    CALL    push_string

    CALL    dot

    RET

CLEAR_SCREEN_SEQ     DEFL    $
    .byte   27
    .ascii  "[2J"
    .byte   27
    .ascii  "[H"

CLEAR_SCREEN_SEQ_LEN .equ    $ - CLEAR_SCREEN_SEQ
    .endlocal
    