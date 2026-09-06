;; ===============================================================
;; Converts a null-terminated string to uppercase in situ.
;; IN:  HL - start address
;; OUT: HL - original start address
;; MOD:
;; ===============================================================
to_uppercase:
    PUSH    HL                              ; cache the starting address

to_uppercase_loop:
    LD      A, (HL)
    OR      A
    JR      Z, to_uppercase_done

to_uppercase_process_character:
    CP      ASCII_FIRST_NON_CONTROL         ; first non-control character
    JR      C, to_uppercase_next_character

    CP      ASCII_A_LOWER                   ; check if less than "a"
    JR      C, to_uppercase_next_character

    CP      ASCII_Z_LOWER_PLUS_ONE          ; check if greater than "z"
    JR      NC, to_uppercase_next_character

    RES     5, A                            ; uppercase the character
    LD      (HL), A

to_uppercase_next_character:
    INC     HL
    JR      to_uppercase_loop

to_uppercase_done:
    POP     HL                              ; restore the starting address
    RET
    