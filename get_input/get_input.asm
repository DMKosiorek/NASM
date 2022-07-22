[org 0x7C00]                        ; Set origin of memory adressing

; Makes whatever is in 'prompt' the chars to print
mov bx, prompt                      ; Moves 'prompt' into bx
call print                          ; Calls 'print' function which returns here when finished

call get_input                      ; Get input from the user

mov bx, ending_message
call print_nl                       ; Displays the ending message on a new line

mov bx, buffer
call print                          ; Displays what the user inputed

end:

jmp $

; Moves to the start of a new line
nl:
    mov ah, 0x0e
    mov al, byte 0x0A
    int 0x10
    mov al, byte 0x0D
    int 0x10

    ret

; Displays whatever is currently in bx
print:
    mov ah, 0x0e                    ; Switch to teletype mode
    print_interior:
        mov al, [bx]                ; Moves the current character that bx is pointed to into al
        cmp al, 0                   ; Checks if the null character has been reached
        je print_interior_end       ; Jumps to the 'print_interior_end' label if above condition is true
        int 0x10                    ; Prints current al character
        inc bx                      ; Increment bx pointer to get to the next string character
        jmp print_interior          ; Loops back to the start of this label
    print_interior_end:

    ret

; Prints whatever is currently in bx at the start of a new line
print_nl:
    call nl
    call print

    ret

; Gets input from the user, with a max input char size of what the buffer is
get_input:
    mov bx, 0                       ; Resets bx to 0
    jmp get_input_interior

    del_prev_char:
        cmp bx, 0                   ; Checks if bx is already pointing to the start of hte buffer
        je get_input_interior       ; Jumps to 'get_input_interior' since there is nothing that needs to be deleted
                                    ; if above cmp is true
        mov ah, 0x0e                ; Switch to teletype mode
        mov al, byte 0x08           ; Backspace
        int 0x10                    ; Print cursor moving back one space
        mov al, 0x20                ; Move 'Space' ascii char to al
        int 0x10                    ; Print al
        mov al, byte 0x08
        int 0x10
        dec bx                      ; Decrement bx since there the current item in the char has been freed

    get_input_interior:
        mov ah, 0                   ; Switch to input mode
        int 0x16                    ; Waits for user key press
        cmp al, 0x0d                ; Checks if carriage return
        je get_input_interior_end   ; Jumps to the 'get_input_interior_end' label if above condition is true
        cmp bx, 15                  ; Sees if more text than the buffer can handle has been inputed
                                    ; bx is compared to the buffer size - 1 since a null terminating character
                                    ; is added to the buffer after the input is gathered
        je print_buffer_overflow_warning
        cmp al, 0x08
        je del_prev_char            ; If backspace was pressed, remove last inputed char and remove char from buffer
        mov [buffer + bx], al       ; Moves al to the buffer
        inc bx                      ; Increment bx pointer to get to the next position in the buffer
        mov ah, 0x0e                ; Switch to teletype mode
        int 0x10
        jmp get_input_interior
    get_input_interior_end:

    ; Warning is skipped if the input fits the buffer
    jmp print_buffer_overflow_warning_end

    print_buffer_overflow_warning:
        mov bx, buffer_overflow_warning
        call nl
        call print
        je end
    print_buffer_overflow_warning_end:

    mov al, 0                       ; Sets al to null character
    mov [buffer + bx], al           ; Adds null character to end of buffer

    ret

prompt:
    db "> ", 0

ending_message:
    db "You typed: ", 0

buffer_overflow_warning:
    db "Error: Input text buffer overflow (max: 15 chars, 16 w/ null term)", 0

buffer:
    times 16 db 0                   ; Define an empty string of size 16

times 510-($-$$) db 0
db 0x55, 0xaa