;; ==================================================================
;; Signals that the app should end.  This is done by updating the
;; CURRENT_INPUT to be empty.
;; IN:  -
;; OUT: B  = number of characters
;;      HL = address of first non-COMMAND
;;           character in CURRENT_INPUT
;; MOD: A, B, DE, HL
;; ==========================================================
quit_command:
    LD      HL, (CURRENT_INPUT_POS)         ; check that no further input was specified
    LD      A, (HL)
    OR      A
    JR      Z, quit_command_execute

quit_command_syntax_error:
    LD      DE, SYNTAX_ERROR_NL
    CALL    print

    RET

quit_command_execute:
    POP     HL
    JP      main_done
    