;; ==================================================================
;; Parses the initial token in CURRENT_INPUT as the command and
;; executes it if identified otherwise returns.  The executed command
;; will also return.
;; IN:  -
;; OUT: B  = number of characters
;;      HL = address of first non-COMMAND
;;           character in CURRENT_INPUT
;; MOD: A, B, DE, HL
;; ==================================================================
process_current_input:

    LD      HL, CURRENT_INPUT
    LD      (CURRENT_INPUT_POS), HL         ; initialize the position at the start

    CALL    parse_token                     ; parse command (copy to CURRENT_TOKEN, upper-case it, determine length)

    LD      HL, CURRENT_TOKEN
    CALL    to_uppercase

    CALL    find_command_method_address

    JR      Z, process_current_input_command_recognized

process_current_input_command_not_recognized:
    LD      DE, CURRENT_TOKEN
    CALL    print
    LD      DE, INPUT_NOT_RECOGNIZED_NL
    CALL    print
    RET

process_current_input_command_recognized:
; execute command if found (JP (HL), target will RET)
    JP      HL

process_current_input_done:
    RET

    .include "find-command-method-address.asm"
    