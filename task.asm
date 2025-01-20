masm
model small
.data
filename db 'search.txt',0
point_fname dd  filename
handle dw 0

buffer db 1 dup(0)
newline db 13, 10, '$'
space db ' $'

temp db ?

sentence_num dw 1
word_pos dw 1
index db 0
word_match_found db 0

sentences dw 0
dots_arr db 100 dup(0)
current_dots dw 0
dashes_arr db 100 dup(0)
current_dashes dw 0
excls_arr db 100 dup(0)
current_excls dw 0
ques_arr db 100 dup(0)
current_ques dw 0
commas_arr db 100 dup(0)
current_commas dw 0

p_sent db 1
p_word db 1

isMult db 0

word_buffer db 25 dup(0)
word_length dw 0

input db 100 dup(0)

sentence_msg db "Row: $"
word_pos_msg db "Position: $"
error_msg db "There is an error!$"
result_msg db 'Match found in sentence $'
tst db " - $"

choice_msg db "Enter: $", 0
zeroth_msg db "Press 0 to exit the program!$", 0
first_msg db "Press 1 for number of sentences!$", 0
second_msg db "Press 2 for searching!$", 0
third_msg db "  Press 1 to search word$", 0
fourth_msg db "  Press 2 to search punctuation$", 0

sentences_msg db "Sentences in this file: $", 0
total_msg db "Total: $"
tryagain_msg db "Try again!$"

current_word db 50 dup(0)

.stack 8192
.code
.386
main:
    mov ax,@data 
    mov ds,ax
    
    ;open the file
    mov al, 02h
    lds dx, point_fname
    mov ah, 3dh
    int 21h
    jc top_error
    mov handle, ax
    
read_char:
    mov bx, handle
    lea dx, buffer
    mov cx, 1
    mov ah, 3fh
    int 21h
    jc top_error ; error in reading
    
    or ax, ax
    jz end_file
    
    ; determine char
    mov al, buffer[0] ; load char for ifs
    
    cmp al, 0Ah
    je addSent
    cmp al, ' '
    je next_pos
    
    cmp al, '.'
    je addDots    
    cmp al, '?'
    je addQs    
    cmp al, '-'
    je addDashes    
    cmp al, '!'
    je addExs   
    cmp al, ','
    je addCommas 
    
    mov isMult, 0
    jmp read_char
    
next_pos:
    inc p_word
    jmp read_char
    
addSent:
    inc p_sent
    mov p_word, 1
    
    jmp read_char
    
addDots:
    mov al, isMult
    cmp al, 1
    je s_p
    
    inc sentences
s_p:
    lea di, dots_arr
    add di, current_dots
    mov al, p_sent
    mov [di], al
    inc current_dots
    mov al, p_word
    mov [di + 1], al
    inc current_dots
    
    mov isMult, 1
    
    jmp read_char
    
addQs:
    inc sentences
    lea di, ques_arr
    add di, current_ques
    mov al, p_sent
    mov [di], al
    inc current_ques
    mov al, p_word
    mov [di + 1], al
    inc current_ques

    jmp read_char
    
addDashes:
    lea di, dashes_arr
    add di, current_dashes
    mov al, p_sent
    mov [di], al
    inc current_dashes
    mov al, p_word
    mov [di + 1], al
    inc current_dashes
    
    jmp read_char
    
addExs:
    inc sentences
    lea di, excls_arr
    add di, current_excls
    mov al, p_sent
    mov [di], al
    inc current_excls
    mov al, p_word
    mov [di + 1], al
    inc current_excls
    
    jmp read_char
    
addCommas:
    lea di, commas_arr
    add di, current_commas
    mov al, p_sent
    mov [di], al
    inc current_commas
    mov al, p_word
    mov [di + 1], al
    inc current_commas
    
    jmp read_char
    
input_loop:
    mov ah, 09h
    lea dx, zeroth_msg
    int 21h
    
    mov ah, 09h
    lea dx, newline
    int 21h
    
    mov ah, 09h
    lea dx, first_msg
    int 21h
    
    mov ah, 09h
    lea dx, newline
    int 21h
    
    mov ah, 09h
    lea dx, second_msg
    int 21h
    
    mov ah, 02h
    mov dl, 10
    int 21h
    mov dl, 13
    int 21h
    
    mov ah, 09h
    lea dx, choice_msg
    int 21h
    
    ; read a digit
    mov ah, 01h
    int 21h
    
    cmp al, '3'
    jg false_input
    
    cmp al, '0'
    jl false_input
    
    cmp al, '0'
    je finish
    
    cmp al, '1'
    je one_loop
    
    cmp al, '2'
    je two_loop
    
top_error:
    mov ah, 09h
    lea dx, error_msg
    int 21h
    jmp top_close_file
top_close_file:   
    mov bx, handle
    mov ah, 3eh
    int 21h
    jmp input_loop
finish:
    mov bx, handle
    mov ah, 3eh
    int 21h
    mov ax,4c00h
    int 21h 
end_file:
    ;inc sentences
    jmp top_close_file
    
false_input:
    mov ah, 09h
    lea dx, newline
    int 21h
    mov ah, 09h
    lea dx, tryagain_msg
    int 21h
    mov ah, 09h
    lea dx, newline
    int 21h
    
    jmp input_loop
one_loop:
    ; print the number of sentences
    mov ah, 09h
    lea dx, newline
    int 21h
    
    mov ah, 09h
    lea dx, sentences_msg
    int 21h
    
    mov ax, sentences
    call display_number
    
    mov ah, 09h
    lea dx, newline
    int 21h

    jmp input_loop
    
two_loop:
    mov ah, 09h
    lea dx, newline
    int 21h
    
    mov ah, 09h
    lea dx, third_msg
    int 21h
    
    mov ah, 09h
    lea dx, newline
    int 21h
    
    mov ah, 09h
    lea dx, fourth_msg
    int 21h
    
    mov ah, 09h
    lea dx, newline
    int 21h
    
    mov ah, 09h
    lea dx, choice_msg
    int 21h
    
    mov ah, 01h
    int 21h
    
    cmp al, '1'
    jl two_loop
    
    cmp al, '2'
    jg two_loop
    
    cmp al, '1'
    je read_w
    
    cmp al, '2'
    je read_p
    
read_p:
    mov ah, 02h
    mov dl, 10
    int 21h
    mov dl, 13
    int 21h
    
    mov ah, 09h
    lea dx, choice_msg
    int 21h
    
    mov ah, 01h
    int 21h
    
    mov bl, al
    mov ah, 02h
    mov dl, 20h
    int 21h
    mov al, bl
      
    cmp al, '.'
    je disp_dots
    
    cmp al, ','
    je disp_cs
    
    cmp al, '!'
    je disp_excs
    
    cmp al, '?'
    je disp_qs
    
    cmp al, '-'
    je disp_dashes
    
    jmp input_loop
    
disp_dots:
    lea si, dots_arr
    mov cx, current_dots
    cmp cx, 0
    je l_ed
    shr cx, 1
    call print_array
    
l_ed:
    mov ah, 09h
    lea dx, total_msg
    int 21h
    mov ax, current_dots
    shr ax, 1
    call display_number
    jmp print_nl
disp_cs:
    lea si, commas_arr
    mov cx, current_commas
    cmp cx, 0
    je l_ec
    shr cx, 1
    call print_array
l_ec:
    mov ah, 09h
    lea dx, total_msg
    int 21h
    mov ax, current_commas
    shr ax, 1
    call display_number
    jmp print_nl
disp_excs:
    lea si, excls_arr
    mov cx, current_excls
    cmp cx, 0
    je l_es
    shr cx, 1  
    call print_array
    
l_es:
    mov ah, 09h
    lea dx, total_msg
    int 21h
    mov ax, current_excls
    shr ax, 1
    call display_number
    jmp print_nl
disp_qs:
    lea si, ques_arr
    mov cx, current_ques
    cmp cx, 0
    je l_qs
    shr cx, 1
    call print_array
    
l_qs:
    mov ah, 09h
    lea dx, total_msg
    int 21h
    mov ax, current_ques
    shr ax, 1
    call display_number
    jmp print_nl
    
disp_dashes:
    lea si, dashes_arr
    mov cx, current_dashes
    cmp cx, 0
    je l_ds
    shr cx, 1
    call print_array
    
l_ds:
    mov ah, 09h
    lea dx, total_msg
    int 21h
    mov ax, current_dashes
    shr ax, 1
    call display_number
    jmp print_nl
    
print_nl:
    mov ah, 09h
    lea dx, newline
    int 21h
    jmp input_loop
    
read_w:
    mov ah, 09h
    lea dx, newline
    int 21h
    
    mov ah, 09h
    lea dx, choice_msg
    int 21h
    
    lea di, word_buffer
    mov cx, 0
    
read_loop:
    mov ah, 01h
    int 21h
    
    mov [di], al
    cmp al, 13
    je done_reading
    inc di
    inc cx
    cmp cx, 25
    je done_reading
    
    jmp read_loop
    
closer_input:
    mov sentence_num, 1
    mov word_pos, 1
    
    mov ah, 09h
    lea dx, total_msg
    int 21h
    
    xor ah, ah
    mov al, word_match_found
    call display_number
    
    mov ah, 09h
    lea dx, newline
    int 21h
    
    mov word_match_found, 0
    
    jmp input_loop
done_reading:
    mov word_length, cx
    
    mov al, '$'
    mov [di], al
open_file:
    mov al, 02h
    lds dx, point_fname
    mov ah, 3dh
    int 21h
    jc error
    mov handle, ax
    
read_file:    
    mov bx, handle
    lea dx, buffer
    mov cx, 1
    mov ah, 3fh
    int 21h
    jc error
    
    or ax, ax
    jz closer_input
    
    mov al, buffer[0]
   
    cmp al, 0dh
    je end_word
    cmp al, 0ah
    je new_sentence
    cmp al, ' '
    je end_word
    cmp al, '.'
    je end_word
    cmp al, '-'
    je end_word
    cmp al, '?'
    je end_word
    cmp al, '!'
    je end_word
    cmp al, ','
    je end_word
    
    mov temp, al
    call store_char
    
    jmp read_file
store_char:
    lea di, current_word
    mov al, index
    xor ah, ah
    add di, ax
    mov al, temp
    mov [di], al
    inc index
    
    jmp read_file    
new_sentence:
    inc sentence_num
    mov word_pos, 1
    jmp end_word
error:
    mov ah, 09h
    lea dx, error_msg
    int 21h
    jmp close_file
close_file:    
    mov bx, handle
    mov ah, 3eh
    int 21h
exit:
    mov ax,4c00h
    int 21h 
    
end_word:
    mov al, index
    cmp index, 1
    jl read_file
    
    lea di, current_word
    mov al, index
    xor ah, ah
    add di, ax
    mov al, '$'
    mov [di], al

    call compare_words
    cmp al, 1
    je record_match
    
    mov index, 0
    inc word_pos
    jmp read_file 
    
record_match:
    inc word_match_found
    
    mov ah, 09h
    lea dx, sentence_msg
    int 21h
    
    mov ax, sentence_num
    call display_number
    
    lea dx, space
    mov ah, 09h
    int 21h
    
    mov ah, 09h
    lea dx, word_pos_msg
    int 21h
    
    xor ax, ax
    mov ax, word_pos    
    call display_number
    
    mov ah, 09h
    lea dx, newline
    int 21h
    
    mov index, 0
    inc word_pos
    jmp read_file
    
print_array:
    mov ah, 09h
    lea dx, newline
    int 21h
pr_loop:
    mov ah, 09h
    lea dx, sentence_msg
    int 21h
    
    mov al, [si]
    xor ah, ah
    call display_number
    
    lea dx, space
    mov ah, 09h
    int 21h
    
    mov ah, 09h
    lea dx, word_pos_msg
    int 21h
    
    xor ah, ah
    mov al, [si + 1]
    call display_number
    
    mov ah, 09h
    lea dx, newline
    int 21h
    
    add si, 2
    loop pr_loop
    
    ret
compare_words:    
    lea si, current_word
    lea di, word_buffer
compare_loop:     
    mov bl, [si]
    mov bh, [di]
    cmp bl, bh
    jne not_equal
    cmp bl, '$'
    je words_equal
    inc di
    inc si
    jmp compare_loop
not_equal:
    xor al, al
    ret
words_equal:
    mov al, 1
    ret 
    
display_number:
    push ax
    push bx
    push cx
    push dx
    mov cx, 10
    xor bx, bx
convert_digit:
    xor dx, dx
    div cx
    add dl, '0'
    push dx
    inc bx
    or ax, ax
    jnz convert_digit
print_digits:
    pop dx
    mov ah, 02h
    int 21h
    dec bx
    jnz print_digits
    pop dx
    pop cx
    pop bx
    pop ax
    ret 

end main