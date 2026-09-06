;; ==================================================================
;; Creates a checkpoint of the head of the word list.
;; IN:  -
;; OUT: -
;; MOD: A, DE, HL, IX
;; ==================================================================
checkpoint_command:
    LD      HL, (CURRENT_INPUT_POS)         ; check that no further input was specified
    LD      A, (HL)
    OR      A
    JR      Z, checkpoint_command_execute

checkpoint_command_syntax_error:
    LD      DE, SYNTAX_ERROR_NL
    CALL    print

    RET

checkpoint_command_execute:
    LD      HL, (WORD_LIST_HEAD)
    LD      (WORD_LIST_CHECKPOINT_HEAD), HL
    LD      HL, (WORD_LIST_NEXT)
    LD      (WORD_LIST_CHECKPOINT_NEXT), HL

checkpoint_command_done:
    LD      DE, INPUT_OK_NL
    CALL    PRINT

    RET
    