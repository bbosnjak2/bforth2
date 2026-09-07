;; ==================================================================
;; Loads a word list from a file, with the expectation of one word
;; per line ending with CRLF
;; IN:  -
;; OUT: -
;; MOD: A, DE, HL, IX
;; ==================================================================
load_command:
    LD      DE, NOT_IMPLEMENTED_NL
    JP      print

    CALL    parse_file_name

    OR      A
    JP      NZ, load_command_failed         ; error

load_command_execute:
    CALL    load_file_prepare
    OR      A
    JP      NZ, load_command_failed         ; error

load_command_fetch_first_buffer:
    CALL    load_file_fetch

    OR      A                               ; check if nothing loaded
    JP      NZ, load_command_EOF

    LD      A, (LOAD_FILE_BUFFER)

    OR      A                               ; check if first character is a null
    JP      Z, load_command_EOF

    CP      ASCII_EOF                       ; check if first character is EOF
    JP      Z, load_command_EOF

    LD      HL, LOAD_FILE_BUFFER            ; start of source, DE points to INPUT_BUFFER after "ADD "
    LD      (LOAD_FILE_BUFFER_POS), HL

load_command_load_word:
    CALL    load_command_initialize_input_buffer

    LD      B, 0x04                         ; input buffer content length - length of "ADD "

load_command_load_word_loop:
    PUSH    DE
    LD      DE, LOAD_FILE_BUFFER_POS
    LD      HL, (LOAD_FILE_BUFFER_POS)
    SBC     HL, DE
    POP     DE

    JR      NZ, load_command_load_word_loop_continue

load_command_load_fetch_next_buffer:
    EXX
    CALL    load_file_fetch
    PUSH    AF
    EXX
    POP     AF

    OR      A                               ; check if nothing loaded
    JP      NZ, load_command_EOF

    LD      A, (LOAD_FILE_BUFFER)

    OR      A                               ; check if first character is a null
    JP      Z, load_command_EOF

    CP      ASCII_EOF                       ; check if first character is EOF
    JP      Z, load_command_EOF

    LD      HL, LOAD_FILE_BUFFER            ; start of source, DE points to INPUT_BUFFER after "ADD "
    LD      (LOAD_FILE_BUFFER_POS), HL

load_command_load_word_loop_continue:
    LD      A, B
    CP      CURRENT_INPUT_MAX_LEN + 1       ; accommodate reading of EOF/null terminator
    JR      Z, load_command_input_too_long

    LD      HL, (LOAD_FILE_BUFFER_POS)

    LD      A, (HL)                         ; load character from file

    OR      A                               ; null terminator
    JR      Z, load_command_load_word_done

    CP      ASCII_EOF                       ; end of file
    JR      Z, load_command_load_word_done

    CP      ASCII_CR                        ; end of line is marked by CRLF
    JR      NZ, load_command_load_word_copy_char

    INC     HL
    LD      (LOAD_FILE_BUFFER_POS), HL

    LD      A, (HL)

    CP      ASCII_LF
    JR      NZ, load_command_load_word_invalid_line_ending

    INC     HL
    LD      (LOAD_FILE_BUFFER_POS), HL

    JR      load_command_load_word_done

load_command_load_word_copy_char:
    LD      (DE), A                         ; copy the character to the input buffer

    INC     DE                              ; move to the next
    INC     HL
    LD      (LOAD_FILE_BUFFER_POS), HL
    INC     B

    JR      load_command_load_word_loop

load_command_load_word_done:
    LD      A, B

    CP      4                               ; length of "ADD ", i.e. blank line
    JR      Z, load_command_EOF

    LD      (INPUT_BUFFER_COUNT), A

    LD      DE, INPUT_BUFFER                ; echo it
    CALL    print

    LD      A, ASCII_LF
    CALL    print_char

load_command_execute_add_command:
    EXX

    CALL    COPY_INPUT_TO_CURRENT_INPUT
    CALL    NZ, process_current_input

    EXX

    JR      load_command_load_word

load_command_input_too_long:
    .local
    LD      DE, ERROR
    CALL    print
    RET
ERROR   DEFM    'Line too long.',0
    .endlocal

load_command_load_word_invalid_line_ending:
    .local
    LD      DE, ERROR
    CALL    print
    RET
ERROR   DEFM    'Invalid line ending',0
    .endlocal

load_command_failed:
    RET

load_command_EOF:
load_command_succeeded:

    RET

load_command_initialize_input_buffer:
    CALL    clear_input_buffer

load_command_add_keyword_to_input_buffer:
    .local
    LD      HL, KEYWORD
    LD      DE, INPUT_BUFFER
    LD      BC, 0x0004
    LDIR

    RET
KEYWORD DEFM    "ADD "
    .endlocal
    