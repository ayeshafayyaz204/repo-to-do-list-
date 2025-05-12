org 100h
jmp main

; Data Section (same as previous)
prompt_menu db 'To-Do List Menu:', 0Dh, 0Ah
            db '1. Add Task', 0Dh, 0Ah
            db '2. List Tasks', 0Dh, 0Ah
            db '3. Exit', 0Dh, 0Ah
            db 'Choice: $'

max_tasks equ 10
task_length equ 50
num_tasks db 0
tasks times max_tasks * task_length db '$'

add_prompt db 0Dh, 0Ah, 'Enter task: $'
full_msg db 0Dh, 0Ah, 'Task list is full!$'
no_tasks_msg db 0Dh, 0Ah, 'No tasks to display.$'
task_list_header db 0Dh, 0Ah, 'Tasks:', 0Dh, 0Ah, '$'

input_buffer db 50
             db 0
             times 50 db 0

task_num_buffer db '00: $'
crlf db 0Dh, 0Ah, '$'

; Code Section (modified jumps)
main:
    mov dx, prompt_menu
    mov ah, 09h
    int 21h

    mov ah, 01h
    int 21h

    ; Restructured conditional jumps
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
    jmp main

add_task:
    mov al, [num_tasks]
    cmp al, max_tasks
    jb .not_full
    mov dx, full_msg
    mov ah, 09h
    int 21h
    jmp main

.not_full:
    mov dx, add_prompt
    mov ah, 09h
    int 21h

    mov dx, input_buffer
    mov ah, 0Ah
    int 21h

    mov si, input_buffer + 1
    mov cl, [si]
    mov ch, 0
    inc si
    add si, cx
    mov byte [si], '$'

    mov al, [num_tasks]
    mov bl, task_length
    mul bl
    mov di, tasks
    add di, ax
    mov si, input_buffer + 2
    mov cl, [input_buffer + 1]
    mov ch, 0
    rep movsb

    inc byte [num_tasks]
    jmp main

list_tasks:
    mov al, [num_tasks]
    cmp al, 0
    jne .has_tasks
    mov dx, no_tasks_msg
    mov ah, 09h
    int 21h
    jmp main

.has_tasks:
    mov dx, task_list_header
    mov ah, 09h
    int 21h

    mov cl, 0
.task_loop:
    cmp cl, [num_tasks]
    jae .done

    mov al, cl
    inc al
    mov ah, 0
    mov bl, 10
    div bl
    add ax, 3030h
    cmp al, '0'
    jne .two_digits
    mov al, ' '
.two_digits:
    mov [task_num_buffer], al
    mov [task_num_buffer+1], ah

    mov dx, task_num_buffer
    mov ah, 09h
    int 21h

    mov al, cl
    mov bl, task_length
    mul bl
    mov si, tasks
    add si, ax
    mov dx, si
    mov ah, 09h
    int 21h

    mov dx, crlf
    mov ah, 09h
    int 21h

    inc cl
    jmp .task_loop

.done:
    jmp main

exit:
    mov ax, 4C00h
    int 21h