;; ==========================================================
;; Starts (or restarts) the system
;; IN:
;; OUT:
;; MOD:
;; ==========================================================
START:
    CALL    RESET_STACK
    CALL    CLEAR_SCREEN
    CALL    PRINT_GREETING

    RET
    