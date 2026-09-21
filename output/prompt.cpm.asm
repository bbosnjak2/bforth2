;; ==========================================================
;; Outputs the input prompt
;; IN:  -
;; OUT: -
;; MOD: DE, BC
;; ==========================================================
prompt
    .local
    LD      DE, INPUT_PROMPT                ; content
    LD      BC, INPUT_PROMPT_LEN            ; length
    CALL    push_string

    CALL    dot

    RET

INPUT_PROMPT     DEFM    "> "

INPUT_PROMPT_LEN .equ    $ - INPUT_PROMPT
    .endlocal
    