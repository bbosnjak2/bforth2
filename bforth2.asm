    org     $0100

main_entry:
    CALL    START


main_prompt_input_echo_loop:
    CALL    PROMPT
    CALL    system_load_input_buffer
    CALL    system_copy_input_to_current_input

; LD      A, (CURRENT_INPUT)
; OR      A
; CALL    NZ, process_current_input

    JR      main_prompt_input_echo_loop

main_done:
    RET

    .include "bdos/bdos.constants.asm"
    .include "bdos/bdos-line-input.asm"
    .include "bdos/bdos-print-char.asm"
    .include "bdos/bdos-print-string.asm"

    .include "constants/ascii.asm"
    .include "constants/text.asm"

    .include "util/is-whitespace.asm"
    .include "util/parse-file-name.asm"
    .include "util/load-file-prepare.asm"
    .include "util/load-file-fetch.asm"
    .include "util/save-file.asm"
    .include "util/skip-whitespace.asm"
    .include "util/to-uppercase.asm"
    .include "command-processor/command-list.asm"

    .include "dictionary/CLEAR-SCREEN.asm"
    .include "dictionary/DOT.asm"
    .include "dictionary/HELP-PROMPT-TEXT.asm"
    .include "dictionary/PRINT-GREETING.asm"
    .include "dictionary/PROMPT.asm"
    .include "dictionary/RESET-STACK.asm"
    .include "dictionary/START.asm"
    .include "dictionary/WELCOME-TEXT.asm"

    .include "output/print.cpm.asm"
    .include "output/print-char.cpm.asm"

    .include "system/system-clear-input-buffer.asm"
    .include "system/system-copy-input-buffer-to-current-input.asm"
    .include "system/system-fill-memory.asm"
    .include "system/system-load-input-buffer.asm"

    .include "stack/data-types.asm"
    .include "stack/push-string.asm"
    .include "stack/pop-stack.asm"
    .include "stack/stack-concatenate.asm"

    .include "command-processor/process-current-input.asm"
    .include "command-processor/parse-token.asm"
    .include "command-processor/commands/help-command.asm"
    .include "command-processor/commands/add-command.asm"
    .include "command-processor/commands/find-command.asm"
    .include "command-processor/commands/remove-command.asm"
    .include "command-processor/commands/dump-command.asm"
    .include "command-processor/commands/checkpoint-command.asm"
    .include "command-processor/commands/rollback-command.asm"
    .include "command-processor/commands/clear-command.asm"
    .include "command-processor/commands/load-command.asm"
    .include "command-processor/commands/save-command.asm"
    .include "command-processor/commands/quit-command.asm"

DATA_BASE                   DEFL    $

STACK_BASE                  DEFW    0
STACK_POINTER               DEFW    0

INPUT_BUFFER_MAX_LEN        equ     80d
INPUT_BUFFER_SIZE           DEFB    0
INPUT_BUFFER_COUNT          DEFB    0
INPUT_BUFFER                DEFS    (CURRENT_INPUT_MAX_LEN + 1), 0 ; null-terminated

CURRENT_INPUT_MAX_LEN       equ     INPUT_BUFFER_MAX_LEN
CURRENT_INPUT               DEFS    (CURRENT_INPUT_MAX_LEN), 0
CURRENT_INPUT_LEN           DEFB    0
CURRENT_INPUT_REMAINING_LEN DEFB    0
CURRENT_INPUT_POS           DEFW    0

CURRENT_TOKEN_LEN           DEFB    0
CURRENT_TOKEN               DEFS    (CURRENT_INPUT_MAX_LEN), 0

PARSED_FILE_NAME            DEFS    8, 0
PARSED_FILE_EXT             DEFS    3, 0

LOAD_FILE_BUFFER            DEFS    128,0
LOAD_FILE_BUFFER_POS        DEFW    0

; this must be the last one:
WORD_LIST_HEAD:             DEFW    WORD_LIST_END   ; points to the last word added
WORD_LIST_NEXT:             DEFW    WORD_LIST_END + 1 ; points to where the next new word will be stored

; Structure:
;LENGTH: DEFB    3
;NEXT:   DEFW    WORD_LIST_END
;THIS:   DEFW    WORD
;WORD:   DEFM    "Abc", 0

WORD_LIST_CHECKPOINT_HEAD:  DEFW    0x0000
WORD_LIST_CHECKPOINT_NEXT:  DEFW    0x0000

WORD_LIST_END:              DEFB    0
    