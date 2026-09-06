;; ===============================================================
;; Fills a block of memory with a byte
;; IN:  A  - byte
;;      HL - start address
;;      BC - number of bytes
;; OUT: HL - address of last byte filled
;;      DE - address of first byte following the last byte filled
;;      BC - 0x00
;; MOD: DE, HL, BC
;; ===============================================================
fill_memory:
    LD      (HL), A                         ; set the first location
    DEC     BC

    LD      D, H                            ; set the next location as the destination
    LD      E, L
    INC     DE

    LDIR                                    ; fill location, increment address, decrement counter

    RET
    