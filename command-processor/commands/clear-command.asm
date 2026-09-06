;; ==================================================================
;; Clears all the words from the word list.
;; IN:  -
;; OUT: -
;; MOD: A, DE, HL, IX
;; ==================================================================
clear_command:
    LD      HL, (CURRENT_INPUT_POS)         ; check that no further input was specified
    LD      A, (HL)
    OR      A
    JR      Z, clear_command_execute

clear_command_syntax_error:
    LD      DE, SYNTAX_ERROR_NL
    CALL    print

    RET

clear_command_execute:
    LD      IX, WORD_LIST_HEAD
    LD      HL, WORD_LIST_END
    LD      (IX), HL

    LD      IX, WORD_LIST_NEXT
    INC     HL
    LD      (IX), HL

clear_command_done:
    LD      DE, INPUT_OK_NL
    CALL    PRINT

    RET
    