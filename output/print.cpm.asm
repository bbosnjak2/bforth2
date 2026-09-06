;; ==========================================================
;; Types a null-terminated string
;; IN:  DE=address of null-terminated string.  Can include
;;      embedded ASCII control characters and VT-52 codes.
;; OUT: -
;; MOD: C, A, HL, DE
;; ==========================================================
print:
    LD      A, (DE)
    OR      A
    RET     Z                               ; nothing to print

    LD      A, $00                          ; null terminator
    LD      H, D                            ; copy the start address in HL
    LD      L, E

print_find_null_terminator_loop:
    CPI                                     ; compare (HL) to a null terminator
    JR      NZ, print_find_null_terminator_loop

    DEC     HL                              ; replace the null with the CPM terminator
    LD      A, '$'
    LD      (HL), A

    PUSH    HL                              ; cache the address of the end of the string

    LD      C, $09                          ; invoke the CPM print method
    CALL    $0005

    POP     HL                              ; restore HL and put the null terminator back
    LD      A, $00
    LD      (HL), A

    RET
    