; Z80 Assembly - Instruction Testing Template
; Current tests: 
;   1. LD r, r' - Register to register transfer
;   2. LD r, n  - Load immediate value into register
;   3. LD r, (HL) - Load register from memory pointed by HL
;   4. LD r, (IX+d) - Load register from memory with indexed addressing

    DEVICE NOSLOT64K
    SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION

    org 0       ; Program starts at address 0 in memory

main:
    ld sp, stack_top  ; Initialize stack pointer
    
    ; ========= TEST 1: LD r, r' =========
    ; Operation: r ← r'
    ; Description: The contents of any register r' are loaded to any other register r
    
    ; Example from documentation:
    ; "If the H Register contains the number 8Ah, and the E register contains 10h, 
    ; the instruction LD H, E results in both registers containing 10h."
    
    ld h, 8Ah     ; H = 8Ah (138)
    ld e, 10h     ; E = 10h (16)
    ld h, e       ; H = 10h (16) - copied from E
    
    ; Final register state:
    ; E = 10h (16), H = 10h (16) - both contain 10h as per the example
    
    ; ========= TEST 2: LD r, n =========
    ; Operation: r ← n
    ; Description: The 8-bit integer n is loaded to any register r
    
    ; Example from documentation:
    ; "Upon the execution of an LD E, A5h instruction, Register E contains A5h."
    
    ld e, 0A5h    ; E = A5h (165) - immediate value loaded into E
    
    ; Final register state:
    ; E = A5h (165) - as per the example in the instruction documentation
    
    ; ========= TEST 3: LD r, (HL) =========
    ; Operation: r ← (HL)
    ; Description: The 8-bit contents of memory location (HL) are loaded to register r
    
    ; Example from documentation:
    ; "If register pair HL contains the number 75A1h, and memory address 75A1h 
    ; contains byte 58h, the execution of LD C, (HL) results in 58h in Register C."
    
    ; First, we need to put some data in memory
    ld hl, test_data  ; Point HL to our test data location
    ld c, (hl)        ; Load contents of memory at address in HL into C
    
    ; Final register state:
    ; HL = test_data (points to our test data)
    ; C = 58h (88) - loaded from memory at address test_data
    
    ; ========= TEST 4: LD r, (IX+d) =========
    ; Operation: r ← (IX+d)
    ; Description: The contents of memory at address (IX+d) are loaded to register r
    
    ; Example from documentation:
    ; "If Index Register IX contains the number 25AFh, the instruction LD B, (IX+19h) allows
    ; the calculation of the sum 25AFh + 19h, which points to memory location 25C8h. 
    ; If this address contains byte 39h, the instruction results in Register B also containing 39h."
    
    ; Setup for our example
    ld ix, indexed_data_base  ; IX = address of our data array
    ld b, (ix+1)              ; Load the value at (IX+1) into register B
    
    ; Final register state:
    ; IX = indexed_data_base
    ; B = 39h (57) - loaded from memory at address (IX+1)
    
    ; ========= END TEST AREA =========
    
    ; Program halt
    jr $          ; Infinite loop

; Data section
test_data:
    db 58h        ; This represents our test data at memory location pointed by HL

indexed_data_base:
    db 00h        ; Base address (IX+0)
    db 39h        ; This represents the byte at (IX+1), matching the example
    db 00h        ; Additional data

stack_bottom:   ; 100 bytes of stack
    defs    100, 0
stack_top:
    END