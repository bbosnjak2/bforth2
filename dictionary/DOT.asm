;; ==========================================================
;; Prints the string that is on the stack
;; IN:
;; OUT:
;; MOD:
;; ==========================================================
DOT
    LD      HL, (STACK_BASE)
    LD      DE, (STACK_POINTER)
    SBC     HL, DE
    JR      NZ, DOT_push_terminator

    .local
    LD      DE, ERROR
    LD      C, $09
    JP      $0005

ERROR      DEFM    "Stack is empty.\n", "$"
    .endlocal

DOT_push_terminator:
    .local
    LD      DE, TERMINATOR                  ; content
    LD      BC, 0x01                        ; length
    CALL    push_string
    JR      DOT_concatenate

TERMINATOR DEFM    "$"
    .endlocal

DOT_concatenate:
    CALL    stack_concatenate

DOT_print:
    LD      DE, (STACK_POINTER)
    INC     DE                              ; type byte
    INC     DE                              ; length word
    INC     DE

    CALL    bdos_print_string

    CALL    pop_stack

    RET
    