;; ===============================================================
;; Reads the next 128 byte block from the file into the
;; LOAD_FILE_BUFFER
;; IN:  -
;; OUT: A - 0 on success, 1 on EOF
;; MOD:
;; ===============================================================
load_file_fetch:
load_file_fetch_initialize:
    LD      HL, LOAD_FILE_BUFFER            ; reset the buffer
    LD      BC, 128d
    LD      A, 0
    CALL    fill_memory

load_file_fetch_read:
    LD      C, F_READ
    LD      DE, load_file_FCB
    CALL    BDOS

load_file_fetch_done:
    RET
    