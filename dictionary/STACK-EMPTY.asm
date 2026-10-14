;; ==========================================================
;; Checks if the stack is empty, printing an error message if
;; so and sets the Z flag.  Otherwise clears the Z flag.
;; IN:
;; OUT:
;; MOD:
;; ==========================================================
STACK_EMPTY:
    .local
    LD      HL, (STACK_POINTER)
    LD      DE, (STACK_BASE)

    SCF
    CCF
    SBC     HL, DE

    LD      A, H
    OR      L

    RET     NZ

    LD      DE, ERROR
    LD      BC, ERROR_LEN
    CALL    push_string

    CALL    DOT

    XOR     A                               ; set the Z flag

    RET

ERROR     DEFM    "?Stack empty", ASCII_LF
ERROR_LEN .equ    $ - ERROR
    .endlocal
    