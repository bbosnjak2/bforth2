;; ==========================================================
;; Prints the string that is on the stack
;; IN:  DE - location of $-delimited string
;; OUT:
;; MOD:
;; ==========================================================
bdos_print_string
    LD      C, F_PRINT_STRING               ; invoke the CPM print method
    CALL    BDOS

    RET
    