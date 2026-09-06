;; ===============================================================
;; Saves prepared content to a file.
;; IN:  HL - the start of null-terminated content
;; OUT: A - 0 on success, 1 on error
;; MOD:
;; ===============================================================
save_file:
save_file_initialize:
    LD      (save_file_content), HL

    LD      HL, save_file_FCB               ; reset the FCB
    LD      BC, save_file_FCB_size
    LD      A, 0
    CALL    fill_memory

    LD      HL, PARSED_FILE_NAME            ; set the file name
    LD      DE, save_file_FCB_NAME
    LD      BC, 0x0008
    LDIR

    LD      HL, PARSED_FILE_EXT             ; set the file extension
    LD      DE, save_file_FCB_EXT
    LD      BC, 0x0003
    LDIR

save_file_write:
    LD      C, F_DMA                        ; Set the DMA buffer address
    LD      DE, save_file_write_buffer
    CALL    BDOS

    LD      C, F_DELETE                     ; Delete any existing file with the same name first (Optional but recommended)
    LD      DE, save_file_FCB
    CALL    BDOS                            ; ignore a delete error (e.g., file doesn't exist)

    LD      C, F_MAKE                       ; Create the new file entry in the directory
    LD      DE, save_file_FCB
    CALL    BDOS
    INC     A
    JR      Z, save_file_error              ; Exit if file could not be created

save_file_fill_buffer:
    LD      HL, save_file_write_buffer      ; blank out the buffer
    LD      BC, 128d
    LD      A, ASCII_EOF
    CALL    fill_memory

    LD      HL, (save_file_content)         ; initialize pointers
    LD      DE, save_file_write_buffer
    LD      C, 128

save_file_fill_buffer_loop:
    LD      A, (HL)
    OR      A
    JR      Z, save_file_fill_buffer_done   ; null terminator found - write the final buffer and close out

    LD      (DE), A                         ; copy the character and move to the next one

    INC     HL
    INC     DE
    DEC     C

    JR      NZ, save_file_fill_buffer_loop  ; until buffer filled

    LD      (save_file_content), HL         ; update the pointer for the next buffer write

    LD      C, F_WRITE                      ; Write the current buffer to the file
    LD      DE, save_file_FCB
    CALL    BDOS
    OR      A
    JR      NZ, save_file_error             ; Error if A is not 00h (e.g. disk full)

    JR      save_file_fill_buffer           ; start the next buffer

save_file_fill_buffer_done:
    LD      C, F_WRITE                      ; Write the buffer to the file
    LD      DE, save_file_FCB
    CALL    BDOS
    OR      A
    JR      NZ, save_file_error             ; Error if A is not 00h (e.g. disk full)

    LD      C, F_CLOSE                      ; close the file
    LD      DE, save_file_FCB
    CALL    BDOS
    OR      A
    JR      NZ, save_file_error             ; Error if file could not be closed

    JR      save_file_success

save_file_error:
    .local
    LD      DE, MESSAGE
    CALL    print

    LD      A, 1
    RET

MESSAGE                DEFM    "Save failed.", 10, 0
    .endlocal

save_file_success:
    LD      A, 0
    RET

save_file_content:     DEFW    0x0000          ; address of the content
save_file_FCB:         DEFB    00h             ; 00h = Default logged drive
save_file_FCB_NAME:    DEFS    8               ; 8-character file name (padded with spaces)
save_file_FCB_EXT:     DEFS    3               ; 3-character extension
save_file_FCB_EX:      DEFB    00h             ; Current extent (always set to 0)
                       DEFB    00h, 00h                        ; Reserved bytes
save_file_FCB_RC:      DEFB    00h             ; Record count
                       DEFS    16                              ; Disk allocation map (filled by BDOS)
save_file_FCB_CR:      DEFB    00h             ; Current record (always set to 0)
save_file_FCB_RREC:    DEFS    3               ; Random record pointer
save_file_FCB_size     equ     $ - save_file_FCB
save_file_write_buffer DEFS    128d         ; the write buffer
    