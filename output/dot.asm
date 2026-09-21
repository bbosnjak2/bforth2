;; ==========================================================
;; Prints the string that is on the stack
;; IN:
;; OUT:
;; MOD:
;; ==========================================================
dot:
    LD      HL, (STACK_BASE)
    LD      DE, (STACK_POINTER)
    SBC     HL, DE
    JR      NZ, dot_push_terminator

    .local
    LD      DE, ERROR
    LD      C, $09
    JP      $0005

ERROR      DEFM    "Stack is empty.\n", "$"
    .endlocal

dot_push_terminator:
    .local
    LD      DE, TERMINATOR                  ; content
    LD      BC, 0x01                        ; length
    CALL    push_string
    JR      dot_concatenate

TERMINATOR DEFM    "$"
    .endlocal

dot_concatenate:
    CALL    stack_concatenate

dot_print:
    LD      DE, (STACK_POINTER)
    INC     DE                              ; type byte
    INC     DE                              ; length word
    INC     DE

    LD      C, $09                          ; invoke the CPM print method
    CALL    $0005

    CALL    pop_stack

    RET
    