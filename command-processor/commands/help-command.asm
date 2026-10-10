;; ==================================================================
;; Displays help.
;; IN:  -
;; OUT: -
;; MOD: A, DE, HL, IX
;; ==================================================================
help_command:
    .local
    LD      IX, COMMAND_LIST

help_command_loop:
    LD      A, (IX + COMMAND_KEYWORD_LEN)
    OR      A                               ; if 0, then end of list reached
    JR      Z, help_command_done

    LD      DE, (IX + COMMAND_SYNTAX)
    LD      C, (IX + COMMAND_KEYWORD_LEN)
    LD      B, 0x00
    CALL    push_string

    PUSH    IX                              ; DOT uses IX
    CALL    DOT

    LD      DE, HELP_SYNTAX_DESCRIPTION_DELIMITER
    LD      BC, HELP_SYNTAX_DESCRIPTION_DELIMITER_LEN
    CALL    push_string

    CALL    DOT
    POP     IX

    LD      DE, (IX + COMMAND_DESCRIPTION)
    LD      BC, (IX + COMMAND_DESCRIPTION_LEN)
    CALL    push_string

    PUSH    IX                              ; DOT uses IX
    CALL    DOT

    CALL    NEWLINE
    POP     IX

help_command_next_command:
    LD      HL, (IX + COMMAND_NEXT_COMMAND)
    PUSH    HL
    POP     IX
    JR      help_command_loop

help_command_done:
    CALL    OK

    RET

HELP_SYNTAX_DESCRIPTION_DELIMITER     DEFM    " - "
HELP_SYNTAX_DESCRIPTION_DELIMITER_LEN .equ    $ - HELP_SYNTAX_DESCRIPTION_DELIMITER
    .endlocal
    