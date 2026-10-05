;; ==================================================================
;; Extracts the token in CURRENT_INPUT, skipping leading whitespace,
;; and pushing it to the stack.  If no token is found then the stack
;; entry will have zero length.
;; IN:  -
;; OUT: -
;; MOD:
;; ==================================================================
TOKEN:
    LD      IX, CURRENT_INPUT_LEN
    LD      IY, CURRENT_TOKEN_LEN

    LD      HL, CURRENT_TOKEN
    LD      BC, CURRENT_INPUT_MAX_LEN
    LD      A, 0x00
    LD      (IY), 0x00
    CALL    system_fill_memory

    LD      HL, (CURRENT_INPUT_POS)
    LD      DE, CURRENT_TOKEN

TOKEN_skip_whitespace:
    LD      A, (IX + 1)                     ; CURRENT_INPUT_REMAINING_LEN
    OR      A
    JR      Z, TOKEN_end_of_input

    LD      A, (HL)

    CALL    is_whitespace
    JR      NZ, TOKEN_copy_token_loop

    INC     HL
    DEC     (IX + 1)                        ; CURRENT_INPUT_REMAINING_LEN

    JR      TOKEN_skip_whitespace

TOKEN_copy_token_loop:
    LD      (DE), A                         ; CURRENT_TOKEN
    INC     (IY)                            ; CURRENT_TOKEN_LEN

    INC     HL                              ; CURRENT_INPUT_POS
    DEC     (IX + 1)                        ; CURRENT_INPUT_REMAINING_LEN
    JR      Z, TOKEN_end_of_token

    INC     DE                              ; CURRENT_TOKEN

    LD      A, (HL)                         ; load the next character
    CALL    is_whitespace
    JR      NZ, TOKEN_copy_token_loop

TOKEN_end_of_input:
TOKEN_end_of_token:
    LD      (CURRENT_INPUT_POS), HL

TOKEN_done:
    LD      C, (IY)                         ; CURRENT_INPUT_LEN
    LD      B, 0
    LD      DE, CURRENT_TOKEN
    CALL    push_string

    RET

CURRENT_TOKEN_LEN DEFB    0
CURRENT_TOKEN     DEFS    (CURRENT_INPUT_MAX_LEN), 0
    