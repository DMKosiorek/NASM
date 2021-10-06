mov ah, 0x0e
mov al, 65          ; Char 65 is 'A'
int 0x10

alphabet:
    add al, 33      ; Becomes char 92, or 'a'
    int 0x10
    sub al, 32
    inc al
    cmp al, 'Z' + 1
    je exit         ; When the char value in al
                    ; is past the final letter of
                    ; the alphabet, 'Z', jump to
                    ; 'exit'...
    int 0x10

    jmp alphabet    ; ... else continue looping
exit:
    jmp $

times 510-($-$$) db 0
db 0x55, 0xaa