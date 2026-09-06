;; ==================================================================
;; Parses the next available token as a file name
;; IN:  -
;; OUT: A - 0 on success, non-zero on error
;; MOD: A, DE, HL, IX
;; ==================================================================
parse_file_name:
    CALL    parse_token

    LD      A, B                            ; check if a word was specified
    OR      A
    JR      Z, parse_file_name_syntax_error

    LD      HL, (CURRENT_INPUT_POS)         ; check that no further input was specified
    LD      A, (HL)
    OR      A
    JR      NZ, parse_file_name_syntax_error

parse_file_name_initialize:
    LD      HL, PARSED_FILE_NAME            ; initialize the results to fill with spaces
    LD      A, ASCII_SPACE
    LD      BC, 0x000B                      ; 8 + 3
    CALL    fill_memory

    LD      HL, CURRENT_TOKEN
    CALL    TO_UPPERCASE
    LD      DE, PARSED_FILE_NAME
    LD      C, 0x00

parse_file_name_parse_filename_loop:
    LD      A, (HL)                         ; load a character

    OR      A                               ; check for null terminator
    JR      Z, parse_file_name_invalid_filename ; null terminator found before "."

    CP      ASCII_PERIOD
    JR      Z, parse_file_name_parse_filename_period_found

    LD      (DE), A

    INC     HL
    INC     DE
    INC     C

    LD      A, C
    CP      0x09                            ; max file name length (without extension) is 8
    JR      NC, parse_file_name_invalid_filename

    JR      parse_file_name_parse_filename_loop

parse_file_name_parse_filename_period_found:
    LD      A, C                            ; check if filename is blank
    OR      A
    JR      Z, parse_file_name_invalid_filename

parse_file_name_parse_extension:
    INC     HL
    LD      DE, PARSED_FILE_EXT
    LD      C, 0x00

parse_file_name_parse_extension_loop:
    LD      A, (HL)

    OR      A
    JR      Z, parse_file_name_parse_extension_done

    LD      (DE), A

    INC     HL
    INC     DE
    INC     C

    LD      A, C
    CP      0x04                            ; max file extension is 3
    JR      NC, parse_file_name_invalid_filename

    JR      parse_file_name_parse_extension_loop

parse_file_name_parse_extension_done:
    LD      A, C                            ; check if extension is blank
    OR      A
    JR      Z, parse_file_name_invalid_filename

    LD      A, 0x00                         ; success
    RET

parse_file_name_syntax_error:
    LD      DE, SYNTAX_ERROR_NL
    CALL    print

    LD      A, 0x01                         ; error
    RET

parse_file_name_invalid_filename:
    .local
    LD      DE, MESSAGE
    CALL    PRINT

    LD      A, 0x01                         ; error
    RET

MESSAGE             DEFM    "Invalid file name.", 10, 0
    .endlocal
    