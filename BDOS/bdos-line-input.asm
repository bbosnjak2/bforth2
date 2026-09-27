;; ==========================================================
;; Inputs a line of text from the console
;; IN:
;; OUT:
;; MOD:
;; ==========================================================
bdos_line_input
    LD      C, F_READ_CONSOLE_BUFFER
    CALL    BDOS

    RET
    