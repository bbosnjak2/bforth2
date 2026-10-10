;; ==================================================================
;; Searches for the command identified by the token on the stack.
;; If found, the token is popped and the command address pushed to the
;; CPU stack and Z is true.  If not found, the token is untouched and
;; NZ is true.
;;
;; IN:  -
;; OUT: -
;; MOD:
;; ==========================================================
SEARCH:
    LD      IX, COMMAND_LIST
    LD      IY, (STACK_POINTER)
    LD      BC, (IY + 1)

SEARCH_check_command:
    LD      A, (IX + COMMAND_KEYWORD_LEN)
    OR      A                               ; if 0, then end of list reached
    JR      Z, SEARCH_not_found

    CP      C                               ; if the length differs, move to the next command
    JR      NZ, SEARCH_next_command

SEARCH_compare:
    LD      HL, (IX + COMMAND_KEYWORD)
    LD      BC, (IY + 1)                    ; number of characters

    PUSH    IY
    POP     DE
    INC     DE                              ; stack entry type
    INC     DE                              ; stack entry length
    INC     DE                              ; result is the address of the token text on the stack

SEARCH_compare_loop:
    LD      A, (DE)
    CP      (HL)
    JR      Z, SEARCH_compare_next_character

SEARCH_next_command:
    LD      HL, (IX + COMMAND_NEXT_COMMAND)
    PUSH    HL
    POP     IX
    JR      SEARCH_check_command

SEARCH_compare_next_character:
    INC     HL
    INC     DE
    DEC     BC                              ; move to next character

    LD      A, B
    OR      C
    JR      NZ, SEARCH_compare_loop

SEARCH_found:                               ; all characters have matched
    CALL    pop_stack                       ; consume the token

    LD      HL, (IX + COMMAND_METHOD_ADDRESS) ; put the command address on the stack

    POP     DE                              ; get the return address
    PUSH    HL                              ; push the command address
    PUSH    DE                              ; push the return address back

    LD      A, $00
    OR      A                               ; clears the Z flag (means found)

    RET

SEARCH_not_found:
    LD      A, $01
    OR      A                               ; sets the Z flag

    RET
    