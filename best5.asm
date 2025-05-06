org 0x100
bits 16

section .text
start:
    ; Initialize segments for .COM file
    mov ax, cs
    mov ds, ax
    mov es, ax
    jmp main_loop  ; Skip over data declarations

; ----------- Data Section -----------
menu_msg      db '1. Add task', 0Dh, 0Ah
              db '2. List tasks', 0Dh, 0Ah
              db '3. Exit', 0Dh, 0Ah
              db 'Choice: $'
prompt_task   db 0Dh, 0Ah, 'Enter task: $'
tasks         db '$'        ; Task storage
times 1023   db 0          ; 1024 total bytes for tasks
task_end     dw tasks+1    ; Pointer to end of tasks

; Input buffer structure
input_max     db 50
input_len     db 0
input_buf     times 51 db 0

; ----------- Main Program -----------
main_loop:
    ; Show menu
    mov ah, 09h
    mov dx, menu_msg
    int 21h

    ; Get user choice
    mov ah, 01h
    int 21h

    cmp al, '1'
    je add_task
    cmp al, '2'
    je list_tasks
    cmp al, '3'
    je exit
    jmp main_loop

add_task:
    ; Show task prompt
    mov ah, 09h
    mov dx, prompt_task
    int 21h

    ; Read task input
    mov ah, 0Ah
    mov dx, input_max
    int 21h

    ; Skip empty input
    cmp byte [input_len], 0
    je main_loop

    ; Store task in memory
    mov si, input_buf
    mov di, [task_end]
    mov cx, 0
    mov cl, [input_len]
    rep movsb

    ; Add CR/LF and terminator
    mov byte [di], 0Dh
    inc di
    mov byte [di], 0Ah
    inc di
    mov byte [di], '$'
    inc di

    ; Update task end pointer
    mov [task_end], di
    jmp main_loop

list_tasks:
    ; Display all tasks
    mov ah, 09h
    mov dx, tasks
    int 21h

    ; Wait for key press
    mov ah, 08h
    int 21h
    jmp main_loop

exit:
    ; Exit to DOS
    mov ax, 4C00h
    int 21h