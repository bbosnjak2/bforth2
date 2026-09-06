
;; ===============================================================
;; Determines if the character in A is whitespace (NZ for false,
;; Z for true)
;; IN:  A  - character
;; OUT: Z flag
;; MOD: flags
;; ===============================================================
is_whitespace:
    CP      A, ASCII_SPACE
    RET     Z

    CP      A, ASCII_TAB
    RET     Z

    CP      A, ASCII_CR
    RET     Z

    CP      A, ASCII_LF
    RET     Z

    CP      A, ASCII_FF
    RET     Z

    CP      A, ASCII_VT
    RET     Z

    RET
    