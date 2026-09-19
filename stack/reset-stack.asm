;; ==========================================================
;; Resets the stack
;; IN:
;; OUT:
;; MOD:
;; ==========================================================
reset_stack:
    LD      HL, (0x0006)                    ; top of TPA(transient program area) / start of BDOS
    LD      (STACK_BASE), HL
    LD      (STACK_POINTER), HL

    RET
    