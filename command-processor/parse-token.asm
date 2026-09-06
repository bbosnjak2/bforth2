;; ==================================================================
;; Extracts the token in CURRENT_INPUT, skipping leading whitespace,
;; and copying it to the CURRENT_TOKEN, null-terminated.  The B
;; register contains the number of characters (i.e. excludes the null
;; terminator).
;; IN:  -
;; OUT: B  = number of characters
;;      HL = address of first non-token
;;           character in CURRENT_INPUT
;; MOD: A, B, DE, HL
;; ==================================================================
parse_token:

    LD      HL, (CURRENT_INPUT_POS)
    LD      DE, CURRENT_TOKEN
    LD      B, $00                          ; number of characters in the token

    CALL    skip_whitespace

parse_token_copy_token_loop:
    LD      A, (HL)                         ; A contains the character
    OR      A
    JR      Z, parse_token_end_of_input

    CALL    is_whitespace                   ; check if this is a whitespace (Z for true)
    JR      Z, parse_token_end_of_token

parse_token_copy_character:
    LD      (DE), A

    INC     B
    INC     HL
    INC     DE

    JR      parse_token_copy_token_loop

parse_token_end_of_input:
parse_token_end_of_token:
    LD      A, $00
    LD      (DE), A                         ; add null terminator

    CALL    skip_whitespace                 ; advance the current input pos to the next non-whitespace character
    LD      (CURRENT_INPUT_POS), HL

parse_token_done:
    RET
    