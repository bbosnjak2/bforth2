;; ==========================================================
;; Prints the initial greeting
;; IN:
;; OUT:
;; MOD:
;; ==========================================================
print_greeting
    .local
    LD      DE, TEXT_GREETING_NL
    LD      BC, TEXT_GREETING_NL_LEN
    CALL    push_string
    CALL    dot

    LD      DE, HELP_PROMPT_NL
    LD      BC, HELP_PROMPT_NL_LEN
    CALL    push_string
    CALL    dot
    RET

TEXT_GREETING_NL     DEFM    "Welcome to bforth2", 10
TEXT_GREETING_NL_LEN .equ    $ - TEXT_GREETING_NL
HELP_PROMPT_NL       DEFM    "Type 'help' for A list of commands.", 10, 0
HELP_PROMPT_NL_LEN   .equ    $ - HELP_PROMPT_NL

    .endlocal
    