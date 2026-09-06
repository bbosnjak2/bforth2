;; ===============================================================
;; Advances HL to the first non-whitespace character or a null
;; terminator
;; IN:  HL - starting address
;; OUT: HL - address of first non-whitespace character or a null
;;           terminator
;; MOD: A, HL, flags
;; ===============================================================
skip_whitespace:
skip_whitespace_loop:
    LD      A, (HL)                         ; A contains the character
    OR      A                               ; check for null terminator
    JR      Z, skip_whitespace_done

    CALL    is_whitespace                   ; check if this is a whitespace (Z for true)
    JR      NZ, skip_whitespace_done

    INC     HL
    JR      skip_whitespace_loop

skip_whitespace_done:
    RET
    