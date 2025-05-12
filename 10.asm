org 0x100
bits 16

section .text
start:
    mov ax, cs
    mov ds, ax
    mov es, ax
    jmp main_loop

; ----------- Data Section -----------
menu_msg      db '1. Add task', 0Dh, 0Ah
              db '2. List tasks', 0Dh, 0Ah
              db '3. Exit', 0Dh, 0Ah
              db 'Choice: $'
prompt_full   db 0Dh, 0Ah, 'Task list full!$'
prompt_empty  db 0Dh, 0Ah, 'No tasks!$'
prompt_task   db 0Dh, 0Ah, 'Enter task: $'

tasks         db '$'
times 1023   db 0
task_end     dw tasks+1

input_max     db 50
input_len     db 0
input_buf     times 51 db 0

num_buffer    db '00: $'
crlf          db 0Dh, 0Ah, '$'

; ----------- Main Program -----------
main_loop:
    ; Show menu
    mov ah, 09h
    mov dx, menu_msg
    int 21h

    ; Get choice
    mov ah, 01h
    int 21h

    ; Restructured jumps
    cmp al, '1'
    jne .not1
    jmp add_task
.not1:
    cmp al, '2'
    jne .not2
    jmp list_tasks
.not2:
    cmp al, '3'
    jne .not3
    jmp exit
.not3:
    jmp main_loop

add_task:
    ; Space check
    mov ax, [task_end]
    sub ax, tasks
    cmp ax, 50*10
    jb .space_ok
    mov dx, prompt_full
    mov ah, 09h
    int 21h
    jmp main_loop

.space_ok:
    ; Show prompt
    mov dx, prompt_task
    mov ah, 09h
    int 21h

    ; Read input
    mov dx, input_max
    mov ah, 0Ah
    int 21h

    ; Process input
    movzx si, byte [input_len]
    mov byte [input_buf+si], '$'

    ; Store task
    mov di, [task_end]
    mov si, input_buf
    mov cx, 50
    rep movsb

    ; Update pointer
    add word [task_end], 50
    jmp main_loop

list_tasks:
    ; Check empty
    mov ax, [task_end]
    sub ax, tasks
    jz .empty

    ; Task counter
    xor dx, dx
    mov cx, 50
    div cx
    mov cx, ax
    mov si, tasks
    mov bl, 1

.task_loop:
    ; Format number
    mov al, bl
    xor ah, ah
    mov dl, 10
    div dl
    add ax, 3030h
    cmp al, '0'
    jne .twodig
    mov al, ' '
.twodig:
    mov [num_buffer], al
    mov [num_buffer+1], ah

    ; Show number
    mov dx, num_buffer
    mov ah, 09h
    int 21h

    ; Show task
    mov dx, si
    int 21h

    ; Newline
    mov dx, crlf
    int 21h

    ; Next task
    add si, 50
    inc bl
    loop .task_loop

    jmp main_loop

.empty:
    mov dx, prompt_empty
    mov ah, 09h
    int 21h
    jmp main_loop

exit:
    mov ax, 4C00h
    int 21h