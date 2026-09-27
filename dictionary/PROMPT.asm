;; ==========================================================
;; Outputs the input prompt
;; IN:  -
;; OUT: -
;; MOD: DE, BC
;; ==========================================================
PROMPT
    .local
    LD      DE, INPUT_PROMPT                ; content
    LD      BC, INPUT_PROMPT_LEN            ; length
    CALL    push_string

    CALL    DOT

    RET

INPUT_PROMPT     DEFM    "> "

INPUT_PROMPT_LEN .equ    $ - INPUT_PROMPT
    .endlocal
    