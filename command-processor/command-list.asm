COMMAND_LIST     DEFL    $

COMMAND_NEXT_COMMAND = 0
COMMAND_KEYWORD_LEN = COMMAND_NEXT_COMMAND + 2
COMMAND_KEYWORD = COMMAND_KEYWORD_LEN + 1
COMMAND_SYNTAX = COMMAND_KEYWORD + 2
COMMAND_DESCRIPTION = COMMAND_SYNTAX + 2
COMMAND_DESCRIPTION_LEN = COMMAND_DESCRIPTION + 2
COMMAND_METHOD_ADDRESS = COMMAND_DESCRIPTION_LEN + 2

HELP_COMMAND_DEF:
    .local
                 DEFW    ADD_COMMAND_DEF                 ; next command
                 DEFB    4                               ; keyword length
                 DEFW    KEYWORD
                 DEFW    SYNTAX
                 DEFW    DESCRIPTION
                 DEFW    DESCRIPTION_LEN
                 DEFW    help_command

KEYWORD:         DEFM    "HELP"
SYNTAX:          DEFM    "HELP"
DESCRIPTION:     DEFM    "List available commands."
DESCRIPTION_LEN  .equ    $ - DESCRIPTION
    .endlocal

ADD_COMMAND_DEF:
    .local
                 DEFW    FIND_COMMAND_DEF                ; next command
                 DEFB    3                               ; keyword length
                 DEFW    KEYWORD
                 DEFW    SYNTAX
                 DEFW    DESCRIPTION
                 DEFW    DESCRIPTION_LEN
                 DEFW    add_command

KEYWORD:         DEFM    "ADD"
SYNTAX:          DEFM    "ADD <word>"
DESCRIPTION:     DEFM    "Adds A word to the word list."
DESCRIPTION_LEN  .equ    $ - DESCRIPTION
    .endlocal

FIND_COMMAND_DEF:
    .local
                 DEFW    REMOVE_COMMAND_DEF              ; next command
                 DEFB    4                               ; keyword length
                 DEFW    KEYWORD
                 DEFW    SYNTAX
                 DEFW    DESCRIPTION
                 DEFW    DESCRIPTION_LEN
                 DEFW    find_command

KEYWORD:         DEFM    "FIND"
SYNTAX:          DEFM    "FIND <word>"
DESCRIPTION:     DEFM    "Find A word in the word list."
DESCRIPTION_LEN  .equ    $ - DESCRIPTION
    .endlocal

REMOVE_COMMAND_DEF:
    .local
                 DEFW    DUMP_COMMAND_DEF                ; next command
                 DEFB    6                               ; keyword length
                 DEFW    KEYWORD
                 DEFW    SYNTAX
                 DEFW    DESCRIPTION
                 DEFW    DESCRIPTION_LEN
                 DEFW    remove_command

KEYWORD:         DEFM    "REMOVE"
SYNTAX:          DEFM    "REMOVE"
DESCRIPTION:     DEFM    "Remove the last added word from the word list."
DESCRIPTION_LEN  .equ    $ - DESCRIPTION
    .endlocal

DUMP_COMMAND_DEF:
    .local
                 DEFW    CHECKPOINT_COMMAND_DEF          ; next command
                 DEFB    4                               ; keyword length
                 DEFW    KEYWORD
                 DEFW    SYNTAX
                 DEFW    DESCRIPTION
                 DEFW    DESCRIPTION_LEN
                 DEFW    dump_command

KEYWORD:         DEFM    "DUMP"
SYNTAX:          DEFM    "DUMP"
DESCRIPTION:     DEFM    "Dump the word list."
DESCRIPTION_LEN  .equ    $ - DESCRIPTION
    .endlocal

CHECKPOINT_COMMAND_DEF:
    .local
                 DEFW    ROLLBACK_COMMAND_DEF            ; next command
                 DEFB    10                              ; keyword length
                 DEFW    KEYWORD
                 DEFW    SYNTAX
                 DEFW    DESCRIPTION
                 DEFW    DESCRIPTION_LEN
                 DEFW    checkpoint_command

KEYWORD:         DEFM    "CHECKPOINT"
SYNTAX:          DEFM    "CHECKPOINT"
DESCRIPTION:     DEFM    "Store the current word list checkpoint."
DESCRIPTION_LEN  .equ    $ - DESCRIPTION
    .endlocal

ROLLBACK_COMMAND_DEF:
    .local
                 DEFW    LOAD_COMMAND_DEF                ; next command
                 DEFB    8                               ; keyword length
                 DEFW    KEYWORD
                 DEFW    SYNTAX
                 DEFW    DESCRIPTION
                 DEFW    DESCRIPTION_LEN
                 DEFW    rollback_command

KEYWORD:         DEFM    "ROLLBACK"
SYNTAX:          DEFM    "ROLLBACK"
DESCRIPTION:     DEFM    "Rollback to the current checkpoint."
DESCRIPTION_LEN  .equ    $ - DESCRIPTION
    .endlocal

LOAD_COMMAND_DEF:
    .local
                 DEFW    SAVE_COMMAND_DEF                ; next command
                 DEFB    4                               ; keyword length
                 DEFW    KEYWORD
                 DEFW    SYNTAX
                 DEFW    DESCRIPTION
                 DEFW    DESCRIPTION_LEN
                 DEFW    load_command

KEYWORD:         DEFM    "LOAD"
SYNTAX:          DEFM    "LOAD <filename>"
DESCRIPTION:     DEFM    "Load A word list from A file."
DESCRIPTION_LEN  .equ    $ - DESCRIPTION
    .endlocal

SAVE_COMMAND_DEF:
    .local
                 DEFW    CLEAR_COMMAND_DEF               ; next command
                 DEFB    4                               ; keyword length
                 DEFW    KEYWORD
                 DEFW    SYNTAX
                 DEFW    DESCRIPTION
                 DEFW    DESCRIPTION_LEN
                 DEFW    save_command

KEYWORD:         DEFM    "SAVE"
SYNTAX:          DEFM    "SAVE <filename>"
DESCRIPTION:     DEFM    "Save the word list to A file."
DESCRIPTION_LEN  .equ    $ - DESCRIPTION
    .endlocal

CLEAR_COMMAND_DEF:
    .local
                 DEFW    QUIT_COMMAND_DEF                ; next command
                 DEFB    5                               ; keyword length
                 DEFW    KEYWORD
                 DEFW    SYNTAX
                 DEFW    DESCRIPTION
                 DEFW    DESCRIPTION_LEN
                 DEFW    clear_command

KEYWORD:         DEFM    "CLEAR"
SYNTAX:          DEFM    "CLEAR"
DESCRIPTION:     DEFM    "Clear the word list."
DESCRIPTION_LEN  .equ    $ - DESCRIPTION
    .endlocal

QUIT_COMMAND_DEF:
    .local
                 DEFW    COMMAND_LIST_END                ; next command
                 DEFB    4                               ; keyword length
                 DEFW    KEYWORD
                 DEFW    SYNTAX
                 DEFW    DESCRIPTION
                 DEFW    DESCRIPTION_LEN
                 DEFW    quit_command                    ; method address

KEYWORD:         DEFM    "QUIT"
SYNTAX:          DEFM    "QUIT"
DESCRIPTION:     DEFM    "Exit the program."
DESCRIPTION_LEN  .equ    $ - DESCRIPTION
    .endlocal

COMMAND_LIST_END DEFW    0
                 DEFB    0

;    { "add", "add <word>", "Add a word to the word list.", addCommand },
;    { "find", "find <word>", "Find a word in the word list.", findCommand },
;    { "remove", "remove", "Remove the last added word from the word list.", removeCommand },
;    { "dump", "dump", "Dump the word list.", dumpCommand },
;    { "clear", "clear", "Clear the word list.", clearCommand },
;    { "checkpoint", "checkpoint", "Store the current word list checkpoint.", checkpointCommand },
;    { "rollback", "rollback", "Rollback to the current checkpoint.", rollbackCommand },
;    { "save", "save <file name>", "Save the word list to a file.", saveCommand },
;    { "load", "load <file name>", "Load and append words from a file.", loadCommand },
    