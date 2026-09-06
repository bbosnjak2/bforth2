;; ==================================================================
;; Restores the word list head to the checkpoint position.
;; IN:  -
;; OUT: -
;; MOD: A, DE, HL, IX
;; ==================================================================
rollback_command:
    LD      HL, (CURRENT_INPUT_POS)         ; check that no further input was specified
    LD      A, (HL)
    OR      A
    JR      NZ, rollback_command_syntax_error

    LD      A, 0                            ; check if a checkpoint has been set (i.e., it's non-zero)

    LD      HL, WORD_LIST_CHECKPOINT_HEAD
    OR      A, (HL)
    JR      NZ, rollback_command_execute

    INC     HL
    OR      A, (HL)
    JR      Z, rollback_command_no_checkpoint

rollback_command_execute:
    LD      HL, (WORD_LIST_CHECKPOINT_HEAD)
    LD      (WORD_LIST_HEAD), HL
    LD      HL, (WORD_LIST_CHECKPOINT_NEXT)
    LD      (WORD_LIST_NEXT), HL

    LD      HL, 0x000                       ; clear the checkpoint
    LD      (WORD_LIST_CHECKPOINT_HEAD), HL
    LD      (WORD_LIST_CHECKPOINT_NEXT), HL

    JR      rollback_command_done

rollback_command_no_checkpoint:
    .local
    LD      DE, MESSAGE
    CALL    print
    RET

MESSAGE:            DEFM    "No checkpoint set.", 10, 0
    .endlocal

rollback_command_syntax_error:
    LD      DE, SYNTAX_ERROR_NL
    CALL    print

    RET

rollback_command_done:
    LD      DE, INPUT_OK_NL
    CALL    PRINT

    RET
    