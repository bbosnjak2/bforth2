;; ==================================================================
;; Examines the top of the stack and sets the Z flag if it is non-null
;; IN:  -
;; OUT: Z flag = set if not null, reset if null
;; MOD:
;; ==================================================================
CLEAR:
    LD      IX, (STACK_POINTER)

    LD      A, (IX +1)
    OR      (IX + 2)

    RET
    