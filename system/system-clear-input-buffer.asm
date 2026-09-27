;; ==========================================================
;; Zeroes the input buffer
;; IN:  -
;; OUT: -
;; MOD: A, DE, HL, BC
;; ==========================================================
system_clear_input_buffer
    LD      HL, INPUT_BUFFER
    LD      BC, INPUT_BUFFER_MAX_LEN
    LD      A, 0x00

    CALL    system_fill_memory

    RET
    