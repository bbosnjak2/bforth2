;; ==================================================================
;; Dumps a listing of all the words in the word list.
;; IN:  -
;; OUT: -
;; MOD: A, DE, HL, IX
;; ==================================================================
dump_command:
    LD      IX, (WORD_LIST_HEAD)

dump_command_loop:
    LD      A, (IX)                         ; load the length of the word
    OR      A                               ; if 0, then end of list reached
    JR      Z, dump_command_done

    PUSH    IX                              ; save IX

    LD      C, A                            ; length
    LD      B, 0x00
    LD      DE, (IX + 3)                    ; text
    CALL    push_string

    CALL    DOT

    CALL    NEWLINE

dump_command_next_command:
    POP     IX                              ; restore IX

    LD      DE, (IX + 1)                    ; load the address of the next word and put it on the stack
    PUSH    DE
    POP     IX                              ; next word
    JR      dump_command_loop

dump_command_done:
    RET
    