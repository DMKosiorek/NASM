[org 0x7C00]                        ; Set origin of memory adressing

mov bx, prompt                      ; Moves 'prompt' into bx
call print                          ; Calls 'print' function which returns here wehn finished

mov bx, 0                           ; Resets bx to 0
call get_input

; Warning is skipped if the input fits the buffer
jmp print_buffer_overflow_warning_end

print_buffer_overflow_warning:
    mov bx, buffer_overflow_warning
    call new_line
    call print
    je end
print_buffer_overflow_warning_end:

mov bx, ending_message

call new_line
call print

mov bx, buffer

call print

end:

jmp $

new_line:
    ; Moves to the start of a new line
    mov ah, 0x0e
    mov al, byte 0x0A
    int 0x10
    mov al, byte 0x0D
    int 0x10

    ret

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

get_input:
    get_input_interior:
        mov ah, 0                   ; Switch to input mode
        int 0x16                    ; Waits for user key press
        cmp al, 0x0d                ; Checks if the 'enter' key was pressed
        je get_input_interior_end   ; Jumps to the 'get_input_interior_end' label if above condition is true
        cmp bx, 15                  ; Sees if more text than the buffer can handle has been inputed
                                    ; bx is compared to the buffer size - 1 since a null terminating character
                                    ; is added to the buffer after the input is gathered
        je print_buffer_overflow_warning
        mov [buffer + bx], al       ; Moves al to the buffer
        inc bx                      ; Increment bx pointer to get to the next position in the buffer
        mov ah, 0x0e                ; Switch to teletype mode
        int 0x10
        jmp get_input_interior
    get_input_interior_end:

    mov al, 0                       ; Sets al to null character
    mov [buffer + bx], al           ; Adds null character to end of buffer

    ret

prompt:
    db "> ", 0

ending_message:
    db "You typed: ", 0

buffer_overflow_warning:
    db "You have inputed too much text!", 0

buffer:
    times 16 db 0           ; Define an empty string of size 16

times 510-($-$$) db 0
db 0x55, 0xaa