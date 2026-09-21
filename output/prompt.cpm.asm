;; ==========================================================
;; Outputs the input prompt
;; IN:  -
;; OUT: -
;; MOD: DE, BC
;; ==========================================================
prompt
    .local
    LD      DE, INPUT_PROMPT                ; content
    LD      BC, 0x02                        ; length
    CALL    push_string

    CALL    dot

    RET

INPUT_PROMPT        DEFM    "> "
    .endlocal
    