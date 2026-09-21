;; ==========================================================
;; Pushes a string to the stack
;; IN:  DE = address of string.  Can include embedded ASCII
;;           control characters and VT-52 codes.
;;      BC = number of characters
;; OUT:
;; MOD: HL, DE, BC
;; ==========================================================
push_string:
    LD      HL, (STACK_POINTER)
    SBC     HL, BC

    DEC     HL                              ; 2 bytes for length
    DEC     HL
    DEC     HL                              ; 1 byte for type

    LD      (STACK_POINTER), HL

    LD      (HL), STACK_STRING_TYPE
    INC     HL

    LD      (HL), C
    INC     HL
    LD      (HL), B
    INC     HL

    EX      DE, HL
    LDIR

    RET
    