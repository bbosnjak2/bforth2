;; ==================================================================
;; Removes the last added word from the word list.
;; IN:  -
;; OUT: -
;; MOD: A, DE, HL, IX
;; ==================================================================
remove_command:
    LD      DE, NOT_IMPLEMENTED_NL
    JP      print

    LD      HL, (CURRENT_INPUT_POS)         ; check that no further input was specified
    LD      A, (HL)
    OR      A
    JR      NZ, remove_command_syntax_error

    LD      HL, (WORD_LIST_HEAD)
    LD      A, (HL)
    OR      A
    JR      Z, remove_command_word_list_is_empty

remove_command_execute:
    LD      (WORD_LIST_NEXT), HL            ; the previous word becomes the head

    LD      IX, WORD_LIST_HEAD
    LD      HL, (IX+1)                      ; HL = address of previous word
    LD      (WORD_LIST_HEAD), HL

    JR      remove_command_done

remove_command_syntax_error:
    LD      DE, SYNTAX_ERROR_NL
    CALL    print

    RET

remove_command_word_list_is_empty:
    .local
    LD      DE, MESSAGE
    CALL    PRINT
    JP      find_command_done

MESSAGE             DEFM    "Word list is empty.", 10, 0
    .endlocal

remove_command_done:
    LD      DE, INPUT_OK_NL
    CALL    PRINT

    RET
    