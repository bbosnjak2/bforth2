;; ==========================================================
;; Copies the input buffer to the current input, with null
;; termination
;; IN:  -
;; OUT: -
;; MOD: A, DE, HL, BC
;; ==========================================================
COPY_INPUT_TO_CURRENT_INPUT:
    LD      HL, INPUT_BUFFER
    LD      DE, CURRENT_INPUT
    LD      A, (INPUT_BUFFER_COUNT)

    OR      A                               ; skip if nothing was input
    JR      Z, COPY_INPUT_TO_CURRENT_INPUT_RESTORE_NULL

    LD      B, 0                            ; load BC with the number of bytes that were input
    LD      C, A

    LDIR

COPY_INPUT_TO_CURRENT_INPUT_RESTORE_NULL:
    LD      A, 0x00                         ; write terminating null
    LD      (DE), A

    RET
    