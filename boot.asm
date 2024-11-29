ORG 0 
BITS 16 ; We want to specify 16 bit code

start_program:
    cli
    mov ax, 0x7C0
    mov es, ax
    mov ds, ax
    sti
    mov si, msg
    call print_whole

    jmp $ ; keep looping in the same current area, until all assembling for bytes is done, then we can finally execute the dw command

print_whole: ; prints whole string given in msg
.loop:
    lodsb ; this function actually points to the next letter in the string and selects it
    cmp al, 0
    je .finito
    call print_individual
    jmp .loop
.finito:
    ret

print_individual:
    mov ah, 0eh ; Provide BIOS routine to print a letter
    int 0x10
    ret

msg:
    db 'McKyle OS', 0

times 510-($ - $$) db 0 ; run 510 times, initializing in the db register 1 byte assigned to 0. $ represents the current iteration, $$ the first, and
; therefore ($ - $$) is the difference between the current byte and the beginning byte */
dw 0xAA55 ; as x86 is little endian in nature, this will actually be read as 55AA ; represents execution of the code 

