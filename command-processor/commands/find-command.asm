;; ==================================================================
;; Finds a word in the word list.
;; IN:  -
;; OUT: -
;; MOD: A, DE, HL, IX
;; ==================================================================
find_command:
    LD      DE, NOT_IMPLEMENTED_NL
    JP      print

    CALL    parse_token

    LD      A, B                            ; check if a word was specified
    OR      A
    JR      Z, find_command_syntax_error

    LD      HL, (CURRENT_INPUT_POS)         ; check that no further input was specified
    LD      A, (HL)
    OR      A
    JR      NZ, find_command_syntax_error

find_command_execute:
    LD      IX, (WORD_LIST_HEAD)

find_command_loop:
    LD      A, (IX + 0)                     ; load the length of the word
    OR      A                               ; if 0, then end of list reached
    JR      Z, find_command_word_not_found

    CP      B
    JR      NZ, find_command_next_word      ; different length, so on to the next one

    LD      HL, CURRENT_TOKEN               ; the word to find
    LD      E, (IX + 3)                     ; the current word
    LD      D, (IX + 4)

    LD      C, B                            ; the number of characters
find_command_loop_match_character:
    LD      A, (DE)
    CP      (HL)
    JR      NZ, find_command_next_word

    INC     HL
    INC     DE

    DEC     B
    JR      NZ, find_command_loop_match_character

    JR      find_command_word_found

find_command_next_word:
    LD      E, (IX + 1)                     ; load the address of the next word
    LD      D, (IX + 2)
    PUSH    DE
    POP     IX                              ; update IX to point to the next word
    JR      find_command_loop

find_command_syntax_error:
    LD      DE, SYNTAX_ERROR_NL
    CALL    print

    RET

find_command_word_found
    .local
    LD      DE, MESSAGE
    CALL    PRINT
    JP      find_command_done

MESSAGE DEFM    "Word found.", 10, 0
    .endlocal

find_command_word_not_found
    .local
    LD      DE, MESSAGE
    CALL    PRINT
    JP      find_command_done

MESSAGE DEFM    "Word not found.", 10, 0
    .endlocal

find_command_done:
    LD      DE, INPUT_OK_NL
    CALL    PRINT

    RET
    