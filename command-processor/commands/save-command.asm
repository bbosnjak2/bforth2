;; ==================================================================
;; Saves the word list to a file
;; IN:  -
;; OUT: -
;; MOD: A, DE, HL, IX
;; ==================================================================
save_command:
    LD      DE, NOT_IMPLEMENTED_NL
    JP      print

    CALL    parse_file_name

    OR      A
    RET     NZ                              ; error

save_command_execute:
save_command_prepare_index:                 ; create index of word list entries
    LD      HL, (WORD_LIST_NEXT)            ; start the index where the next new word would go
    LD      DE, WORD_LIST_END               ; location of the end of the word list
    LD      (HL), DE                        ; write this end address as the first entry in the index

    LD      IX, (WORD_LIST_HEAD)            ; start IX at the head of the word list

    LD      A, (IX)
    OR      A
    JR      NZ, save_command_prepare_index_loop

    .local
    LD      DE, MESSAGE
    CALL    PRINT
    RET

MESSAGE DEFM    "Word list is empty.", 10, 0
    .endlocal

save_command_prepare_index_loop:
    LD      A, (IX + 0)                     ; load the length of the word
    OR      A                               ; if 0, then end of word list reached
    JR      Z, save_command_prepare_index_done

save_command_prepare_index_write_address:
    PUSH    IX                              ; copy the address of the word list entry into DE
    POP     DE

    INC     HL
    INC     HL
    LD      (HL), DE                        ; write the address of the word list entry to the index

    LD      DE, (IX + 1)                    ; load the address of the next word list entry
    PUSH    DE
    POP     IX                              ; copy it to IX

    JR      save_command_prepare_index_loop

save_command_prepare_index_done:
; HL now points to the last address in the index, the starting point for the write loop
    LD      D, H                            ; Set DE to point to the address after the index where the file output will be prepared
    LD      E, L
    INC     DE
    INC     DE

    PUSH    DE                              ; save DE (start of prepared file)

save_command_prepare_file_content_loop:
    LD      BC, (HL)                        ; load the address of the word list entry
    LD      IX, BC

    LD      A, (IX + 0)
    OR      A
    JR      Z, save_command_prepare_file_content_done

    PUSH    HL                              ; save HL

    LD      HL, (IX + 3)                    ; source address of the word, DE is the destination
    LD      B, 0x00
    LD      C, A                            ; number of characters

    LDIR                                    ; copy the word

    LD      A, ASCII_CR                     ; append the CRLF
    LD      (DE), A
    INC     DE
    LD      A, ASCII_LF
    LD      (DE), A
    INC     DE

    POP     HL                              ; restore HL

    DEC     HL                              ; back up to the previous index entry
    DEC     HL
    JR      save_command_prepare_file_content_loop

save_command_prepare_file_content_done:
    LD      A, 0x00                         ; append a null terminator
    LD      (DE), A

save_command_save:

    POP     HL                              ; load HL with the start of the file content (previously pushed from DE)

    CALL    save_file

    OR      A, 0
    JR      Z, save_command_succeeded

save_command_failed:
    .local
    LD      DE, MESSAGE
    CALL    PRINT
    RET

MESSAGE DEFM    "Save failed.", 10, 0
    .endlocal

save_command_succeeded:
    LD      DE, INPUT_OK_NL
    CALL    PRINT

    RET
    