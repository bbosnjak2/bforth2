;; ==========================================================
;; Outputs a NEWLINE
;; IN:  -
;; OUT: -
;; MOD: DE, BC
;; ==========================================================
NEWLINE
    .local
    LD      DE, NEWLINE                     ; content
    LD      BC, NEWLINE_LEN                 ; length
    CALL    push_string

    CALL    DOT

    RET

NEWLINE     DEFM    ASCII_LF
NEWLINE_LEN .equ    $ - NEWLINE
    .endlocal
    