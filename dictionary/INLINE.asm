;; ==========================================================
;; Prompts the user to input a line of text.  The line is
;; stored in the CURRENT_INPUT buffer.
;; IN:
;; OUT:
;; MOD:
;; ==========================================================
INLINE:
    CALL    PROMPT
    CALL    system_load_input_buffer
    CALL    system_copy_input_to_current_input

    RET
    