;; ==================================================================
;; Adds a word to the word list.
;; IN:  -
;; OUT: -
;; MOD: A, DE, HL, IX
;; ==================================================================
add_command:
    CALL    STACK_EMPTY
    OR      A
    RET     Z

    LD      HL, (STACK_POINTER)
    INC     HL
    LD      BC, (HL)                        ; len
    INC     HL
    INC     HL                              ; word

add_command_write_word_text:
    PUSH    HL                              ; source text

    LD      IX, (WORD_LIST_NEXT)

    LD      A, C                            ; write the number of characters (excludes the null terminator)
    LD      (IX + 0), A

    LD      HL, (WORD_LIST_HEAD)            ; write the new entry to point to the previous entry
    LD      (IX + 1), HL

    LD      HL, (WORD_LIST_NEXT)            ; location for the new word
    LD      DE, 5                           ; offset HL to the location to write the word itself
    ADD     HL, DE

    LD      (IX + 3), HL                    ; update the header with the location where the text will be copied to

    EX      DE, HL                          ; update DE to be the destination pointed to by HL
    POP     HL                              ; HL is the source, BC still contains the count

    LDIR                                    ; write the word, DE will be the new WORD_LIST_NEXT value

add_command_update_word_list_pointers:
    LD      HL, (WORD_LIST_NEXT)            ; the head is now what was previously the next location
    LD      (WORD_LIST_HEAD), HL
    LD      (WORD_LIST_NEXT), DE            ; the next location is now where DE ended up

add_command_done:
    CALL    pop_stack

    CALL    OK

    RET
    