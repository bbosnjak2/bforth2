;; ==================================================================
;; Displays help.
;; IN:  -
;; OUT: -
;; MOD: A, DE, HL, IX
;; ==================================================================
help_command:
    LD      HL, (CURRENT_INPUT_POS)         ; check that no further input was specified
    LD      A, (HL)
    OR      A
    JR      Z, help_command_execute

help_command_syntax_error:
    LD      DE, SYNTAX_ERROR_NL
    CALL    print

    RET

help_command_execute:
    LD      IX, COMMAND_LIST

help_command_loop:
    LD      A, (IX + COMMAND_KEYWORD_LEN)
    OR      A                               ; if 0, then end of list reached
    JR      Z, help_command_done

    LD      DE, (IX + COMMAND_SYNTAX)
    CALL    print

    LD      DE, HELP_SYNTAX_DESCRIPTION_DELIMITER
    CALL    print

    LD      DE, (IX + COMMAND_DESCRIPTION)
    CALL    print

    LD      DE, NEW_LINE
    CALL    print

help_command_next_command:
    LD      HL, (IX + COMMAND_NEXT_COMMAND)
    PUSH    HL
    POP     IX
    JR      help_command_loop

help_command_done:
    LD      DE, INPUT_OK_NL
    CALL    PRINT

    RET
    