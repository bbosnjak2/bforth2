;; ==========================================================
;; Prints the initial greeting
;; IN:
;; OUT:
;; MOD:
;; ==========================================================
HELP_PROMPT_TEXT
    .local
    LD      DE, HELP_PROMPT_NL
    LD      BC, HELP_PROMPT_NL_LEN
    CALL    push_string

    RET

HELP_PROMPT_NL     DEFM    "Type 'help' for A list of commands.", 10, 0
HELP_PROMPT_NL_LEN .equ    $ - HELP_PROMPT_NL

    .endlocal
    