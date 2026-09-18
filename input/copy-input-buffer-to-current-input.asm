;; ==========================================================
;; Copies the input buffer to the current input
;; IN:  -
;; OUT: -
;; MOD: A, DE, HL, BC
;; ==========================================================
copy_input_to_current_input:
    LD      HL, CURRENT_INPUT
    LD      BC, CURRENT_INPUT_MAX_LEN
    LD      A, 0x00
    CALL    fill_memory

    LD      IX, CURRENT_INPUT_LEN

    LD      HL, INPUT_BUFFER                ; source
    LD      DE, CURRENT_INPUT               ; destination
    LD      (CURRENT_INPUT_POS), DE

    LD      A, (INPUT_BUFFER_COUNT)         ; count

    LD      B, 0x00
    LD      C, A
    LD      (IX), C                         ; CURRENT_INPUT_LEN
    LD      (IX+1), C                       ; CURRENT_INPUT_REMAINING_LEN

    OR      A                               ; skip if nothing was input
    JR      Z, copy_input_to_current_input_done

    LDIR                                    ; copy

copy_input_to_current_input_done:
    RET
    