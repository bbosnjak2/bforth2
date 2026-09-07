;; ==================================================================
;; Adds a word to the word list.
;; IN:  -
;; OUT: -
;; MOD: A, DE, HL, IX
;; ==================================================================
add_command:
    LD      DE, NOT_IMPLEMENTED_NL
    JP      print

    CALL    parse_token

    LD      A, B                            ; check if a word was specified
    OR      A
    JR      Z, add_command_syntax_error

    LD      HL, (CURRENT_INPUT_POS)         ; check that no further input was specified
    LD      A, (HL)
    OR      A
    JR      NZ, add_command_syntax_error

add_command_write_word_text:
    LD      IX, (WORD_LIST_NEXT)

    LD      A, B                            ; write the number of characters (excludes the null terminator)
    LD      (IX + 0), A

    LD      HL, (WORD_LIST_HEAD)            ; write the new entry to point to the previous entry
    LD      (IX + 1), HL

    PUSH    BC                              ; save the number of characters value that's in B

    LD      HL, (WORD_LIST_NEXT)            ; location for the new word
    LD      DE, 5                           ; offset HL to the location to write the word itself
    ADD     HL, DE

    LD      (IX + 3), HL                    ; update the header with the location where the text will be copied to

    EX      DE, HL                          ; update DE to be the destination pointed to by HL
    LD      HL, CURRENT_TOKEN               ; HL is the source

    LD      C, B
    LD      B, 0x00
    INC     BC                              ; copy the null terminated, too

    LDIR                                    ; write the word, DE will be the new WORD_LIST_NEXT value

    POP     BC                              ; restore the number of characters value in B

add_command_update_word_list_pointers:
    LD      HL, (WORD_LIST_NEXT)            ; the head is now what was previously the next location
    LD      (WORD_LIST_HEAD), HL
    LD      (WORD_LIST_NEXT), DE            ; the next location is now where DE ended up

    JR      add_command_done

add_command_syntax_error:
    LD      DE, SYNTAX_ERROR_NL
    CALL    print

    RET

add_command_done:
    LD      DE, INPUT_OK_NL
    CALL    PRINT

    RET
    