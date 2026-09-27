;; ==========================================================
;; Pushes welcome text onto the stack
;; IN:
;; OUT:
;; MOD:
;; ==========================================================
WELCOME_TEXT
    .local
    LD      DE, TEXT_GREETING_NL
    LD      BC, TEXT_GREETING_NL_LEN
    CALL    push_string

    RET

TEXT_GREETING_NL     DEFM    "Welcome to bforth2", 10
TEXT_GREETING_NL_LEN .equ    $ - TEXT_GREETING_NL

    .endlocal
    