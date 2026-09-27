;; ==========================================================
;; Prints a character to the console
;; IN:  E - the character
;; OUT:
;; MOD:
;; ==========================================================
bdos_print_char
    LD      C, F_CONSOLE_OUT
    CALL    BDOS

    RET
    