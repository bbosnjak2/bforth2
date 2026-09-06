COMMAND_LIST     DEFL    $

COMMAND_NEXT_COMMAND = 0
COMMAND_KEYWORD_LEN = COMMAND_NEXT_COMMAND + 2
COMMAND_KEYWORD = COMMAND_KEYWORD_LEN + 1
COMMAND_SYNTAX = COMMAND_KEYWORD + 2
COMMAND_DESCRIPTION = COMMAND_SYNTAX + 2
COMMAND_METHOD_ADDRESS = COMMAND_DESCRIPTION + 2

HELP_COMMAND_DEF:
    .local
                 DEFW    ADD_COMMAND_DEF                 ; next command
                 DEFB    4                               ; keyword length
                 DEFW    KEYWORD
                 DEFW    SYNTAX
                 DEFW    DESCRIPTION
                 DEFW    help_command

KEYWORD:         DEFM    "HELP"
SYNTAX:          DEFM    "help", 0
DESCRIPTION:     DEFM    "List available commands.", 0
    .endlocal

ADD_COMMAND_DEF:
    .local
                 DEFW    FIND_COMMAND_DEF                ; next command
                 DEFB    3                               ; keyword length
                 DEFW    KEYWORD
                 DEFW    SYNTAX
                 DEFW    DESCRIPTION
                 DEFW    add_command

KEYWORD:         DEFM    "ADD"
SYNTAX:          DEFM    "add <word>", 0
DESCRIPTION:     DEFM    "Adds A word to the word list.", 0
    .endlocal

FIND_COMMAND_DEF:
    .local
                 DEFW    REMOVE_COMMAND_DEF              ; next command
                 DEFB    4                               ; keyword length
                 DEFW    KEYWORD
                 DEFW    SYNTAX
                 DEFW    DESCRIPTION
                 DEFW    find_command

KEYWORD:         DEFM    "FIND"
SYNTAX:          DEFM    "find <word>", 0
DESCRIPTION:     DEFM    "Find A word in the word list.", 0
    .endlocal

REMOVE_COMMAND_DEF:
    .local
                 DEFW    DUMP_COMMAND_DEF                ; next command
                 DEFB    6                               ; keyword length
                 DEFW    KEYWORD
                 DEFW    SYNTAX
                 DEFW    DESCRIPTION
                 DEFW    remove_command

KEYWORD:         DEFM    "REMOVE"
SYNTAX:          DEFM    "remove", 0
DESCRIPTION:     DEFM    "Remove the last added word from the word list.", 0
    .endlocal

DUMP_COMMAND_DEF:
    .local
                 DEFW    CHECKPOINT_COMMAND_DEF          ; next command
                 DEFB    4                               ; keyword length
                 DEFW    KEYWORD
                 DEFW    SYNTAX
                 DEFW    DESCRIPTION
                 DEFW    dump_command

KEYWORD:         DEFM    "DUMP"
SYNTAX:          DEFM    "dump", 0
DESCRIPTION:     DEFM    "Dump the word list.", 0
    .endlocal

CHECKPOINT_COMMAND_DEF:
    .local
                 DEFW    ROLLBACK_COMMAND_DEF            ; next command
                 DEFB    10                              ; keyword length
                 DEFW    KEYWORD
                 DEFW    SYNTAX
                 DEFW    DESCRIPTION
                 DEFW    checkpoint_command

KEYWORD:         DEFM    "CHECKPOINT"
SYNTAX:          DEFM    "checkpoint", 0
DESCRIPTION:     DEFM    "Store the current word list checkpoint.", 0
    .endlocal

ROLLBACK_COMMAND_DEF:
    .local
                 DEFW    LOAD_COMMAND_DEF                ; next command
                 DEFB    8                               ; keyword length
                 DEFW    KEYWORD
                 DEFW    SYNTAX
                 DEFW    DESCRIPTION
                 DEFW    rollback_command

KEYWORD:         DEFM    "ROLLBACK"
SYNTAX:          DEFM    "rollback", 0
DESCRIPTION:     DEFM    "Rollback to the current checkpoint.", 0
    .endlocal

LOAD_COMMAND_DEF:
    .local
                 DEFW    SAVE_COMMAND_DEF                ; next command
                 DEFB    4                               ; keyword length
                 DEFW    KEYWORD
                 DEFW    SYNTAX
                 DEFW    DESCRIPTION
                 DEFW    load_command

KEYWORD:         DEFM    "LOAD"
SYNTAX:          DEFM    "load <filename>", 0
DESCRIPTION:     DEFM    "Load A word list from A file.", 0
    .endlocal

SAVE_COMMAND_DEF:
    .local
                 DEFW    CLEAR_COMMAND_DEF               ; next command
                 DEFB    4                               ; keyword length
                 DEFW    KEYWORD
                 DEFW    SYNTAX
                 DEFW    DESCRIPTION
                 DEFW    save_command

KEYWORD:         DEFM    "SAVE"
SYNTAX:          DEFM    "save <filename>", 0
DESCRIPTION:     DEFM    "Save the word list to A file.", 0
    .endlocal

CLEAR_COMMAND_DEF:
    .local
                 DEFW    QUIT_COMMAND_DEF                ; next command
                 DEFB    5                               ; keyword length
                 DEFW    KEYWORD
                 DEFW    SYNTAX
                 DEFW    DESCRIPTION
                 DEFW    clear_command

KEYWORD:         DEFM    "CLEAR"
SYNTAX:          DEFM    "clear", 0
DESCRIPTION:     DEFM    "Clear the word list.", 0
    .endlocal

QUIT_COMMAND_DEF:
    .local
                 DEFW    COMMAND_LIST_END                ; next command
                 DEFB    4                               ; keyword length
                 DEFW    KEYWORD
                 DEFW    SYNTAX
                 DEFW    DESCRIPTION
                 DEFW    quit_command                    ; method address

KEYWORD:         DEFM    "QUIT"
SYNTAX:          DEFM    "quit", 0
DESCRIPTION:     DEFM    "Exit the program.", 0
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
    