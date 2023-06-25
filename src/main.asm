; since the BIOS loads the first boot sector into the RAM at 0x7c00 address, 
;we add 0x7c00 as the origin to tell the program 
;to offset everything from this address
org 0x7c00   
bits 16

startmain:
    jmp main


; print string pointed by ds:si
print:
    push si
    push ax


; loops until 0 (null byte) is read
.loop:
    lodsb   ;loads next character from ds:si into al and increaments si
    or al, al   ; zero flag is set if al is 0 
    jz .done    ;jumps if zero flag is set
   
   ; set up for calling BIOS interrupt for video
    mov ah, 0x0e    ; 0x0e to print a character in TTY mode
    mov bh, 0x00    ; page 0
    int 0x10        ; invoking the interrupt 0x10 (video)

    jmp .loop


.done:
    pop ax
    pop si
    ret

main:

    ; initializing data segments
    mov ax, 0
    mov ds, ax 
    mov es, ax

    ; making the stack point to the starting address of OS (0x7c00)
    mov ss, ax
    mov sp, 0x7c00

    ; print the initial OS text

    ;moving the parameter (os text) into si and calling the print function 
    mov si, os_text
    call print

    hlt

.halt:
    jmp .halt


os_text: db "OwlOS 1.0", 0xA, 0 ;text to display intially [0xa for newline]

;the boot sector is of 512 bytes
; the last two bytes of the sector should contain the 55 AA signature (0xAA55 due to little endianess)
; making everything 0 upto 510th byte of the sector , starting from the end of our program
times 510-($-$$) db 0   ; $ = current address, $$ = segment address, $-$$ = length of our code
dw 0xAA55   ; writing 55 AA word into the last 2 bytes of the sector