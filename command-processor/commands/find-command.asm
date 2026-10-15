;; ==================================================================
;; Finds a word in the word list.
;; IN:  -
;; OUT: -
;; MOD: A, DE, HL, IX
;; ==================================================================
find_command:
    CALL    STACK_EMPTY
    OR      A
    RET     Z

    CALL    pop_string                      ; BC = length, HL = text

find_command_execute:
    LD      IX, (WORD_LIST_HEAD)

find_command_loop:
    LD      A, (IX + 0)                     ; load the length of the word
    OR      A                               ; if 0, then end of list reached
    JR      Z, find_command_word_not_found

    CP      C
    JR      NZ, find_command_next_word      ; different length, so on to the next one

    LD      DE, (IX + 3)                    ; the current word

    LD      B, C                            ; length is 1 byte, copy to B for the comparison

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
    LD      DE, (IX + 1)                    ; load the address of the next word
    PUSH    DE
    POP     IX                              ; update IX to point to the next word
    JR      find_command_loop

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
    CALL    OK

    RET
    