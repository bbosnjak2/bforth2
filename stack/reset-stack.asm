;; ==========================================================
;; Resets the stack
;; IN:
;; OUT:
;; MOD:
;; ==========================================================
reset_stack:
    LD      HL, 0                           ; effectively load the SP value into HL
    ADD     HL, SP                          ; SP is from top of memory

    LD      BC, 0x0400                      ; allow 1K space for the stack
    SBC     HL, BC

    LD      (STACK_BASE), HL
    LD      (STACK_POINTER), HL

    RET
    