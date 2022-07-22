[org 0x7C00]                ; Set origin of memory adressing
mov bx, prompt

print_prompt:
    mov ah, 0x0e            ; Switch to teletype mode
    mov al, [bx]            ; Moves the current character that bx is pointed to into al
    cmp al, 0               ; Checks if the null character has been reached
    je print_prompt_end     ; Jumps to the 'print_prompt_end' label if above condition is true
    int 0x10                ; Prints current al character
    inc bx                  ; Increment bx pointer to get to the next string character
    jmp print_prompt        ; Loops back to the start of this label
print_prompt_end:

mov bx, 0                   ; Resets bx to 0

get_input:
    mov ah, 0               ; Switch to input mode
    int 0x16                ; Waits for user key press
    cmp al, 0x0d            ; Checks if the 'enter' key was pressed
    je get_input_end        ; Jumps to the 'get_input_end' label if above condition is true
    cmp bx, 15              ; Sees if more text than the buffer can handle has been inputed
                            ; bx is compared to the buffer size - 1 since a null terminating character
                            ; is added to the buffer after the input is gathered
    je print_buffer_overflow_warning_init
    mov [buffer + bx], al   ; Moves al to the buffer
    inc bx                  ; Increment bx pointer to get to the next position in the buffer
    mov ah, 0x0e            ; Switch to teletype mode
    int 0x10
    jmp get_input
get_input_end:

; Warning is skipped if the input fits the buffer
jmp print_buffer_overflow_warning_end

print_buffer_overflow_warning_init:
    mov bx, buffer_overflow_warning
    ; Moves to the start of a new line
    mov ah, 0x0e
    mov al, byte 0x0A
    int 0x10
    mov al, byte 0x0D
    int 0x10

print_buffer_overflow_warning:
    mov ah, 0x0e
    mov al, [bx]
    cmp al, 0
    je end                  ; Goes to end of program
    int 0x10
    inc bx
    jmp print_buffer_overflow_warning
print_buffer_overflow_warning_end:

mov al, 0                   ; Sets al to null character
mov [buffer + bx], al       ; Adds null character to end of buffer

; Moves to the start of a new line
mov ah, 0x0e
mov al, byte 0x0A
int 0x10
mov al, byte 0x0D
int 0x10

mov bx, ending_message

print_ending_message:
    mov ah, 0x0e
    mov al, [bx]
    cmp al, 0
    je print_ending_message_end
    int 0x10
    inc bx
    jmp print_ending_message
print_ending_message_end:

mov bx, buffer

print_input:
    mov ah, 0x0e
    mov al, [bx]
    cmp al, 0
    je print_input_end
    int 0x10
    inc bx
    jmp print_input
print_input_end:

end:

jmp $

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