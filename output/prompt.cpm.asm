;; ==========================================================
;; Outputs the input prompt
;; IN:  -
;; OUT: -
;; MOD: DE
;; ==========================================================
prompt
    LD      DE, INPUT_PROMPT_SP
    CALL    print

    RET
    