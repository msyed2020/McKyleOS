ORG 0x7C00 
BITS 16 ; We want to specify 16 bit code

; This program has been tested on a Cruzer Glide USB stick, and can
; be booted from the BIOS of a given computer once it is booted in Real
; Mode

; Suggested resource is Ralf Brown's Interrupt List. Would be attached
; to repository but unfortunately file size is too large

init:
    jmp short crossover
    nop

times 33 db 0

crossover:
    jmp 0:start_program

; interr_zero: ; IVT proof of concept
;     mov ah, 0eh
;     mov al, 'L'
;     mov bx, 0x00
;     int 0x10
;     iret

start_program:
    cli

    mov ax, 0x00
    mov es, ax
    mov ds, ax
    mov ss, ax
    mov sp, 0x7C00

    sti

    ; READING FROM THE HARD DISK via CHS
    mov ah, 2 ; This reads from the sector command
    mov al, 1 ; Chooses one sector to read from
    mov ch, 0 ; Cylinder low of 8 bits
    mov cl, 2 ; Read of the sector 2
    mov dh, 0 ; CHS Head number/mark

    mov bx, buffer_dest

    int 0x13 ; Interrupt for hard disk

    ;mov word[ss:0x00], interr_zero ; IVT proof of concept
    ;mov word[ss:0x02], 0x7C0

    ;int 0 ; you can also store 0x00 in a register and divide by zero to call the exception
    ; and summon the aforementioned function

    jc error_occur

    mov si, buffer_dest
    call print_whole ; Assuming this buffer works and allocates space correctly, the test.txt from the
    ; hard disk should load

    jmp $

initialize_gdt:

gdt_null: ; initialize 64 null bits, use if necessary
    dd 0x0
    dd 0x0

gdt_code:
    ; point to this function via CS register
    dw 0xFFFF ; Limit this segment to 0->15 bits
    dw 0 ; Base of the first 0->15 bits
    db 0 ; Base of 16->23 bits (different register used for the next byte)
    ; Keep in mind, 1 byte == 8 bits (The byte ate (8), then it had bit)
    db 0x9a ; Access byte (refer to OSDev Wiki on GDT)
    db 11001111b ; High 4 bit flags, along with low 4 bit flags
    db 0 ; Base of 24->31 bits, which represents the next byte

gdt_actual_data:
    ; point to this function via DS, SS, ES, FS, GS registers
    dw 0xFFFF 
    dw 0 
    db 0
    db 0x92 ; Change access byte flag
    db 11001111b
    db 0

end_gdt:

gdt_descriptor_loader:
    dw end_gdt - initialize_gdt - 1
    dd initialize_gdt 

error_occur:
    mov si, error_msg
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

error_msg:
    db 'Failed to load sector', 0


times 510-($ - $$) db 0 ; run 510 times, initializing in the db register 1 byte assigned to 0. $ represents the current iteration, $$ the first, and
; therefore ($ - $$) is the difference between the current byte and the beginning byte */
dw 0xAA55 ; as x86 is little endian in nature, this will actually be read as 55AA ; represents execution of the code 

buffer_dest: