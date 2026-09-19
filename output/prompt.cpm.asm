;; ==========================================================
;; Outputs the input prompt
;; IN:  -
;; OUT: -
;; MOD: DE, BC
;; ==========================================================
prompt
    .local
    LD      DE, INPUT_PROMPT
    LD      BC, 0x02
    CALL    push_string

    CALL    print

    RET

INPUT_PROMPT        DEFM    "> "
    .endlocal
    