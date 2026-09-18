;; ==================================================================
;; Extracts the token in CURRENT_INPUT, skipping leading whitespace,
;; and copying it to the CURRENT_TOKEN.
;; IN:  -
;; OUT: -
;; MOD: A, B, DE, HL
;; ==================================================================
parse_token:
    LD      IX, CURRENT_INPUT_LEN
    LD      IY, CURRENT_TOKEN_LEN

    LD      HL, CURRENT_TOKEN
    LD      BC, CURRENT_INPUT_MAX_LEN
    LD      A, 0x00
    LD      (IY), 0x00
    CALL    fill_memory

    LD      HL, (CURRENT_INPUT_POS)
    LD      DE, CURRENT_TOKEN

parse_token_skip_whitespace:
    LD      A, (IX + 1)                     ; CURRENT_INPUT_REMAINING_LEN
    OR      A
    JR      Z, parse_token_end_of_input

    LD      A, (HL)

    CALL    is_whitespace
    JR      NZ, parse_token_copy_token_loop

    INC     HL
    DEC     (IX + 1)                        ; CURRENT_INPUT_REMAINING_LEN

    JR      parse_token_skip_whitespace

parse_token_copy_token_loop:
    LD      (DE), A                         ; CURRENT_TOKEN
    INC     (IY)                            ; CURRENT_TOKEN_LEN

    INC     HL                              ; CURRENT_INPUT_POS
    DEC     (IX + 1)                        ; CURRENT_INPUT_REMAINING_LEN
    JR      Z, parse_token_end_of_token

    INC     DE                              ; CURRENT_TOKEN

    LD      A, (HL)                         ; load the next character
    CALL    is_whitespace
    JR      NZ, parse_token_copy_token_loop

parse_token_end_of_input:
parse_token_end_of_token:
    LD      (CURRENT_INPUT_POS), HL

parse_token_done:
    RET
    