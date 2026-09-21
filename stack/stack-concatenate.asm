;; ===============================================================
;; Concatenates the two strings on the stack, replacing them with
;; the concatenation
;; IN:
;; OUT:
;; MOD:
;; ===============================================================
stack_concatenate:
    LD      HL, (STACK_BASE)
    LD      DE, (STACK_POINTER)
    SBC     HL, DE
    JR      NZ, stack_concatenate_execute

    .local
    LD      DE, ERROR
    LD      C, $09
    JP      $0005

ERROR               DEFM    "Stack is empty.\n", "$"
    .endlocal

stack_concatenate_execute:
    LD      IX, (STACK_POINTER)             ; second string

    LD      HL, (STACK_POINTER)
    LD      BC, (IX + 1)                    ; string length
    ADD     HL, BC

    LD      BC, 0x0003                      ; header length
    ADD     HL, BC

    PUSH    HL
    POP     IY                              ; first string

; destination for new string (points to its end)
    LD      DE, (STACK_POINTER)
    DEC     DE

; copy the second word
    LD      BC, (IX + 1)                    ; count
    PUSH    IX                              ; source: needs to point to the last character
    POP     HL
    ADD     HL, BC
    INC     HL
    INC     HL

    LDDR                                    ; copy first word down.  DE is now the end location for the second word

; destination: the DE from previous LDDR
    LD      BC, (IY + 1)                    ; count
    PUSH    IY                              ; source:  needs to point to the last character
    POP     HL
    ADD     HL, BC
    INC     HL
    INC     HL

    LDDR                                    ; copy second word down

    INC     DE                              ; point to the start of the new string

    LD      HL, (IX + 1)
    LD      BC, (IY + 1)
    ADD     HL, BC
    LD      BC, HL                          ; combined length

    EXX
    CALL    pop_stack
    CALL    pop_stack
    EXX

    CALL    push_string

    RET
    