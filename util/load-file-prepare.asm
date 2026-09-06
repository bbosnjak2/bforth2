;; ===============================================================
;; Prepares to load from file.
;; IN:  -
;; OUT: A - 0 on success, 1 on error
;; MOD:
;; ===============================================================
load_file_prepare:
load_file_prepare_initialize:
    LD      HL, load_file_FCB               ; reset the FCB
    LD      BC, load_file_FCB_size
    LD      A, 0
    CALL    fill_memory

    LD      HL, PARSED_FILE_NAME            ; set the file name
    LD      DE, load_file_FCB_NAME
    LD      BC, 0x0008
    LDIR

    LD      HL, PARSED_FILE_EXT             ; set the file extension
    LD      DE, load_file_FCB_EXT
    LD      BC, 0x0003
    LDIR

    LD      C, F_DMA                        ; Set the DMA buffer address
    LD      DE, LOAD_FILE_BUFFER
    CALL    BDOS

load_file_prepare_open:
    LD      C, F_OPEN
    LD      DE, load_file_FCB
    CALL    BDOS

    CP      0xFF
    JR      NZ, load_file_prepare_success

load_file_prepare_error:
    .local
    LD      DE, MESSAGE
    CALL    print

    LD      A, 1
    RET

MESSAGE                        DEFM    "File open failed.  Ensure name of file on disk is uppercase.", 10, 0
    .endlocal

load_file_prepare_success:
    LD      A, 0
    RET

load_file_FCB:                 DEFB    00h             ; 00h = Default logged drive
load_file_FCB_NAME:            DEFS    8               ; 8-character file name (padded with spaces)
load_file_FCB_EXT:             DEFS    3               ; 3-character extension
load_file_FCB_EX:              DEFB    00h             ; Current extent (always set to 0)
                               DEFB    00h, 00h                        ; Reserved bytes
load_file_FCB_RC:              DEFB    00h             ; Record count
                               DEFS    16                              ; Disk allocation map (filled by BDOS)
load_file_FCB_CR:              DEFB    00h             ; Current record (always set to 0)
load_file_FCB_RREC:            DEFS    3               ; Random record pointer
load_file_FCB_size             equ     $ - load_file_FCB
load_file_prepare_write_buffer DEFS    128d ; the write buffer
    