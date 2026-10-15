;; ==========================================================
;; Pops the top string from the stack.  Caller is responsible
;; for checking if the stack has a (string) value
;; IN:
;; OUT: BC - length
;;      HL - text
;; MOD:
;; ==========================================================
pop_string:
    LD      HL, (STACK_POINTER)
    INC     HL                              ; skip the type

    LD      BC, (HL)                        ; load the string length
    INC     HL
    INC     HL                              ; string address

    PUSH    HL                              ; store the address

    ADD     HL, BC                          ; calculate location after the string
    LD      (STACK_POINTER), HL             ; update the stack pointer

    POP     HL                              ; restore the string address

    RET
    