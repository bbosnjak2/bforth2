;; ==========================================================
;; Types a null-terminated string
;; IN:  A - character.  Can include
;;      embedded ASCII control characters and VT-52 codes.
;; OUT: -
;; MOD: C, E
;; ==========================================================
print_char:
    LD      E, A
    LD      C, F_CONSOLE_OUT
    CALL    BDOS

    RET
    