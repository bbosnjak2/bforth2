;; ==========================================================
;; Outputs the OK response
;; IN:  -
;; OUT: -
;; MOD: DE, BC
;; ==========================================================
OK
    .local
    LD      DE, OK_PROMPT                   ; content
    LD      BC, OK_PROMPT_LEN               ; length
    CALL    push_string

    CALL    DOT

    RET

OK_PROMPT     DEFM    "ok", ASCII_LF

OK_PROMPT_LEN .equ    $ - OK_PROMPT
    .endlocal
    