;; ==================================================================
;; Finds the command in CURRENT_COMMAND in the command list.
;; IN:  B  = number of characters in the command
;; OUT: HL = address of command method
;;      Z = set if command found (NZ if not found)
;; MOD: A, C, HL, DE, IX
;; ==========================================================
find_command_method_address:

    LD      IX, COMMAND_LIST

find_command_method_address_check_command:
    LD      A, (IX + COMMAND_KEYWORD_LEN)
    OR      A                               ; if 0, then end of list reached
    JR      Z, find_command_method_address_not_found

    CP      B                               ; if the length differs, move to the next command
    JR      NZ, find_command_method_address_next_command

find_command_method_address_compare:
    LD      HL, (IX + COMMAND_KEYWORD)
    LD      DE, CURRENT_TOKEN
    LD      C, B                            ; number of characters

find_command_method_address_compare_loop:
    LD      A, (DE)
    CP      (HL)
    JR      Z, find_command_method_address_compare_next_character

find_command_method_address_next_command:
    LD      HL, (IX + COMMAND_NEXT_COMMAND)
    PUSH    HL
    POP     IX
    JR      find_command_method_address_check_command

find_command_method_address_compare_next_character:
    INC     HL
    INC     DE
    DEC     C                               ; move to next character
    JR      NZ, find_command_method_address_compare_loop

find_command_method_address_found:          ; all characters have matched
    LD      HL, (IX + COMMAND_METHOD_ADDRESS)
    LD      A, $00
    OR      A                               ; clears the Z flag
    RET

find_command_method_address_not_found:
    LD      A, $01
    OR      A                               ; sets the Z flag

    RET
    