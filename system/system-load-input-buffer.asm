;; ==========================================================
;; Loads the input buffer until CR is pressed or the buffer
;; is full.  clear_input_buffer is called first to clear the
;; buffer.
;; IN:  -
;; OUT: -
;; MOD: A, DE
;; ==========================================================
system_load_input_buffer
    CALL    system_clear_input_buffer

    LD      DE, INPUT_BUFFER_SIZE
    LD      A, INPUT_BUFFER_MAX_LEN
    LD      (DE), A

    CALL    bdos_line_input

; echo a LF since BDOS doesn't
    LD      E, ASCII_LF
    CALL    bdos_print_char

    RET
    