;; ==========================================================
;; Pops the top item from the stack
;; IN:
;; OUT:
;; MOD:
;; ==========================================================
pop_stack:
    LD      HL, (STACK_BASE)
    LD      DE, (STACK_POINTER)
    SBC     HL, DE
    JR      NZ, pop_stack_execute

    .local
    LD      DE, ERROR
    LD      C, $09
    JP      $0005

ERROR               DEFM    "Stack is empty.\n", "$"
    .endlocal

pop_stack_execute:
    LD      HL, (STACK_POINTER)
    INC     HL                              ; skip the type

    LD      BC, (HL)                        ; load the string length
    INC     HL
    INC     HL

    ADD     HL, BC                          ; calculate location after the string

    LD      (STACK_POINTER), HL             ; update the stack pointer

    RET
    