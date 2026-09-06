;; ==========================================================
;; Loads the input buffer until CR is pressed or the buffer
;; is full.  clear_input_buffer is called first to clear the
;; buffer.
;; IN:  -
;; OUT: -
;; MOD: A, DE
;;
;; NOTE:  "IN B, (PORT)" and "OUT (PORT), B" are valid
;; documented Z80 instructions, but even when enabled the
;; assembler rejects them as invalid. As a result, the input
;; character has to be shuffled to/from B.
;; ==========================================================
load_input_buffer
    CALL    clear_input_buffer

    LD      DE, INPUT_BUFFER_SIZE
    LD      A, INPUT_BUFFER_MAX_LEN
    LD      (DE), A

    LD      C, $0A
    CALL    $0005

; echo a LF since BDOS doesn't
    LD      E, ASCII_LF
    LD      C, $02
    CALL    $0005

    RET
    