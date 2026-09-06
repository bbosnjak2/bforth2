;; ==================================================================
;; Dumps a listing of all the words in the word list.
;; IN:  -
;; OUT: -
;; MOD: A, DE, HL, IX
;; ==================================================================
dump_command:
    LD      HL, (CURRENT_INPUT_POS)         ; check that no further input was specified
    LD      A, (HL)
    OR      A
    JR      Z, dump_command_execute

dump_command_syntax_error:
    LD      DE, SYNTAX_ERROR_NL
    CALL    print

    RET

dump_command_execute:
    LD      IX, (WORD_LIST_HEAD)

dump_command_loop:
    LD      A, (IX + 0)                     ; load the length of the word
    OR      A                               ; if 0, then end of list reached
    JR      Z, dump_command_done

    LD      E, (IX + 3)                     ; print out the word
    LD      D, (IX + 4)
    CALL    print

    LD      DE, NEW_LINE
    CALL    print

dump_command_next_command:
    LD      E, (IX + 1)                     ; load the address of the next word and put it on the stack
    LD      D, (IX + 2)
    PUSH    DE
    POP     IX                              ; next word
    JR      dump_command_loop

dump_command_done:
    LD      DE, INPUT_OK_NL
    CALL    PRINT

    RET
    