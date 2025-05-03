; Z80 Assembly - 8-Bit Load Group Instructions Testing
; This file contains tests for the Z80 8-bit load group instructions:
;   1. LD r, r' - Register to register transfer
;   2. LD r, n  - Load immediate value into register
;   3. LD r, (HL) - Load register from memory pointed by HL
;   4. LD r, (IX+d) - Load register from memory with indexed addressing
;   5. LD r, (IY+d) - Load register from memory with IY indexed addressing
;   6. LD (HL), r - Store register to memory pointed by HL
;   7. LD (IX+d), r - Store register to memory with indexed addressing
;   8. LD (IY+d), r - Store register to memory with IY indexed addressing
;   9. LD (HL), n - Store immediate value to memory pointed by HL
;  10. LD (IX+d), n - Store immediate value to memory with IX indexed addressing
;  11. LD (IY+d), n - Store immediate value to memory with IY indexed addressing
;  12. LD A, (BC) - Load Accumulator from memory pointed by BC
;  13. LD A, (DE) - Load Accumulator from memory pointed by DE
;  14. LD A, (nn) - Load Accumulator from direct memory address
;  15. LD (BC), A - Store Accumulator to memory pointed by BC
;  16. LD (DE), A - Store Accumulator to memory pointed by DE
;  17. LD (nn), A - Store Accumulator to direct memory address
;  18. LD A, I - Load Accumulator from Interrupt Vector Register
;  19. LD A, R - Load Accumulator from Memory Refresh Register
;  20. LD I, A - Load Interrupt Vector Register from Accumulator
;  21. LD R, A - Load Memory Refresh Register from Accumulator

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
    
    ; ========= TEST 5: LD r, (IY+d) =========
    ; Operation: r ← (IY+d)
    ; Description: The contents of memory at address (IY+d) are loaded to register r
    
    ; Example from documentation:
    ; "If Index Register IY contains the number 25AFh, the instruction LD B, (IY+19h) allows
    ; the calculation of the sum 25AFh + 19h, which points to memory location 25C8h. 
    ; If this address contains byte 39h, the instruction results in Register B also containing 39h."
    
    ; Setup for our example
    ld iy, indexed_data_base  ; IY = address of our data array
    ld b, (iy+2)              ; Load the value at (IY+2) into register B
    
    ; Final register state:
    ; IY = indexed_data_base
    ; B = 39h (57) - loaded from memory at address (IY+2)
    
    ; ========= TEST 6: LD (HL), r =========
    ; Operation: (HL) ← r
    ; Description: The contents of register r are loaded to the memory location specified by HL
    
    ; Example from documentation:
    ; "If the contents of register pair HL specify memory location 2146h and Register B contains
    ; byte 29h, then upon the execution of an LD (HL), B instruction, memory address 2146h
    ; also contains 29h."
    
    ; Setup for our example
    ld b, 40h               ; B = 40h (64) as per the example
    ld hl, memory_location  ; HL points to our test memory location
    ld (hl), b              ; Store B's value (40h) into memory at address in HL
    
    ; Final state:
    ; B = 40h (64)
    ; HL = memory_location
    ; memory at address memory_location = 40h (64) - copied from register B
    
    ; ========= TEST 7: LD (IX+d), r =========
    ; Operation: (IX+d) ← r
    ; Description: The contents of register r are loaded to memory at address (IX+d)
    
    ; Example from documentation:
    ; "If the C register contains byte 1Ch, and Index Register IX contains 3100h, then the
    ; instruction LD (IX + 6h), C performs the sum 3100h + 6h and loads 1Ch to memory
    ; location 3106h."
    
    ; Setup for our example
    ld c, 1Ch                 ; C = 1Ch (28) as per the example
    ld ix, memory_array       ; IX points to our test memory array
    ld (ix+6), c              ; Store C's value (1Ch) into memory at address (IX+6)
    
    ; Final state:
    ; C = 1Ch (28)
    ; IX = memory_array
    ; memory at address (memory_array+6) = 1Ch (28) - copied from register C
    
    ; ========= TEST 8: LD (IY+d), r =========
    ; Operation: (IY+d) ← r
    ; Description: The contents of register r are loaded to memory at address (IY+d)
    
    ; Example from documentation:
    ; "If the C register contains byte 48h, and Index Register IY contains 2A11h, then the
    ; instruction LD (IY + 4h), C performs the sum 2A11h + 4h, and loads 48h to memory
    ; location 2A15."
    
    ; Setup for our example
    ld c, 48h                 ; C = 48h (72) as per the example
    ld iy, memory_array       ; IY points to our test memory array
    ld (iy+4), c              ; Store C's value (48h) into memory at address (IY+4)
    
    ; Final state:
    ; C = 48h (72)
    ; IY = memory_array
    ; memory at address (memory_array+4) = 48h (72) - copied from register C
    
    ; ========= TEST 9: LD (HL), n =========
    ; Operation: (HL) ← n
    ; Description: The immediate value n is loaded to the memory address specified by HL
    
    ; Example from documentation:
    ; "If the HL register pair contains 4444h, the instruction LD (HL), 28h results in the memory
    ; location 4444h containing byte 28h."
    
    ; Setup for our example
    ld hl, memory_location2   ; HL points to our test memory location
    ld (hl), 28h              ; Store immediate value 28h into memory at address in HL
    
    ; Final state:
    ; HL = memory_location2
    ; memory at address memory_location2 = 28h (40) - immediate value stored in memory
    
    ; ========= TEST 10: LD (IX+d), n =========
    ; Operation: (IX+d) ← n
    ; Description: The immediate value n is loaded to memory at address (IX+d)
    
    ; Example from documentation:
    ; "If Index Register IX contains the number 219Ah, then upon execution of an LD (IX+5h),
    ; 5Ah instruction, byte 5Ah is contained in memory address 219Fh."
    
    ; Setup for our example
    ld ix, memory_array       ; IX points to our test memory array
    ld (ix+5), 5Ah            ; Store immediate value 5Ah into memory at address (IX+5)
    
    ; Final state:
    ; IX = memory_array
    ; memory at address (memory_array+5) = 5Ah (90) - immediate value stored in memory
    
    ; ========= TEST 11: LD (IY+d), n =========
    ; Operation: (IY+d) ← n
    ; Description: The immediate value n is loaded to memory at address (IY+d)
    
    ; Example from documentation:
    ; "If Index Register IY contains the number A940h, the instruction LD (IY+10h), 97h
    ; results in byte 97h in memory location A950h."
    
    ; Setup for our example
    ld iy, memory_array       ; IY points to our test memory array
    ld (iy+8), 97h            ; Store immediate value 97h into memory at address (IY+8)
    
    ; Final state:
    ; IY = memory_array
    ; memory at address (memory_array+8) = 97h (151) - immediate value stored in memory
    
    ; ========= TEST 12: LD A, (BC) =========
    ; Operation: A ← (BC)
    ; Description: The contents of the memory location specified by the BC register pair are loaded to the Accumulator
    
    ; Example from documentation:
    ; "If the BC register pair contains the number 4747h, and memory address 4747h contains
    ; byte 12h, then the instruction LD A, (BC) results in byte 12h in Register A."
    
    ; Setup for our example
    ld bc, bc_data      ; BC points to our test data
    ld a, (bc)          ; Load contents of memory at address in BC into A
    
    ; Final register state:
    ; BC = bc_data (points to our test data)
    ; A = 12h (18) - loaded from memory at address bc_data
    
    ; ========= TEST 13: LD A, (DE) =========
    ; Operation: A ← (DE)
    ; Description: The contents of the memory location specified by the DE register pair are loaded to the Accumulator
    
    ; Example from documentation:
    ; "If the DE register pair contains the number 30A2h and memory address 30A2h contains
    ; byte 47h, then the instruction LD A, (DE) results in byte 47h in Register A."
    
    ; Setup for our example
    ld de, de_data      ; DE points to our test data
    ld a, (de)          ; Load contents of memory at address in DE into A
    
    ; Final register state:
    ; DE = de_data (points to our test data)
    ; A = 47h (71) - loaded from memory at address de_data
    
    ; ========= TEST 14: LD A, (nn) =========
    ; Operation: A ← (nn)
    ; Description: The contents of the memory location specified by the immediate address nn are loaded to the Accumulator
    
    ; Example from documentation:
    ; "If nn contains 8832h and memory address 8832h contains byte 04h, then upon the execution
    ; of an LD A, (nn) instruction, the 04h byte is in the Accumulator."
    
    ; Setup for our example
    ld a, (direct_address)    ; Load contents of memory at the direct address into A
    
    ; Final register state:
    ; A = 04h (4) - loaded from memory at direct address direct_address
    
    ; ========= TEST 15: LD (BC), A =========
    ; Operation: (BC) ← A
    ; Description: The contents of the Accumulator are loaded to the memory location specified by the BC register pair
    
    ; Example from documentation:
    ; "If the Accumulator contains 7Ah and the BC register pair contains 1212h the instruction
    ; LD (BC), A results in 7Ah in memory location 1212h."
    
    ; Setup for our example
    ld a, 7Ah                 ; Load 7Ah into Accumulator
    ld bc, bc_data_out        ; BC points to our output location
    ld (bc), a                ; Store A's value (7Ah) into memory at address in BC
    
    ; Final state:
    ; A = 7Ah (122)
    ; BC = bc_data_out
    ; memory at address bc_data_out = 7Ah (122) - copied from Accumulator
    
    ; ========= TEST 16: LD (DE), A =========
    ; Operation: (DE) ← A
    ; Description: The contents of the Accumulator are loaded to the memory location specified by the DE register pair
    
    ; Example from documentation:
    ; "If register pair DE contains 1128h and the Accumulator contains byte A0h, then the execution
    ; of a LD (DE), A instruction results in A0h being stored in memory location 1128h."
    
    ; Setup for our example
    ld a, 0A0h                ; Load A0h into Accumulator
    ld de, de_data_out        ; DE points to our output location
    ld (de), a                ; Store A's value (A0h) into memory at address in DE
    
    ; Final state:
    ; A = A0h (160)
    ; DE = de_data_out
    ; memory at address de_data_out = A0h (160) - copied from Accumulator
    
    ; ========= TEST 17: LD (nn), A =========
    ; Operation: (nn) ← A
    ; Description: The contents of the Accumulator are loaded to the memory address specified by the immediate address nn
    
    ; Example from documentation:
    ; "If the Accumulator contains byte D7h, then executing an LD (3141h), A instruction
    ; results in D7h in memory location 3141h."
    
    ; Setup for our example
    ld a, 0D7h                ; Load D7h into Accumulator
    ld (direct_address_out), a ; Store A's value (D7h) to the direct memory address
    
    ; Final state:
    ; A = D7h (215)
    ; memory at address direct_address_out = D7h (215) - copied from Accumulator
    
    ; ========= TEST 18: LD A, I =========
    ; Operation: A ← I
    ; Description: The contents of the Interrupt Vector Register I are loaded to the Accumulator
    
    ; For this test, we first need to set the I register to a known value
    ld a, 55h              ; Load 55h into A first
    ld i, a                ; Transfer from A to I (this is the proper way to set I)
    ld a, 00h              ; Clear A to show the effect
    ld a, i                ; Load I register contents into Accumulator
    
    ; Final state:
    ; I = 55h (85)
    ; A = 55h (85) - copied from I register
    ; Flags affected:
    ; - S is set if I is negative, otherwise reset
    ; - Z is set if I is 0, otherwise reset
    ; - H is reset
    ; - P/V contains contents of IFF2
    ; - N is reset
    ; - C is not affected
    
    ; ========= TEST 19: LD A, R =========
    ; Operation: A ← R
    ; Description: The contents of Memory Refresh Register R are loaded to the Accumulator
    
    ; Note: We can't directly set the R register as it's automatically incremented 
    ; during instruction fetches. We can only read its current value.
    ld a, r                ; Load R register contents into Accumulator
    
    ; Final state:
    ; A = current value of R register (which changes during program execution)
    ; Flags affected:
    ; - S is set if R is negative, otherwise reset
    ; - Z is set if R is 0, otherwise reset
    ; - H is reset
    ; - P/V contains contents of IFF2
    ; - N is reset
    ; - C is not affected
    
    ; ========= TEST 20: LD I, A =========
    ; Operation: I ← A
    ; Description: The contents of the Accumulator are loaded to the Interrupt Vector Register I
    
    ; We've already used this instruction in TEST 18, but let's demonstrate it more explicitly
    ld a, 0AAh              ; Load AAh into A 
    ld i, a                 ; Transfer from A to I
    
    ; To verify it worked
    ld a, 00h               ; Clear A
    ld a, i                 ; Load I back into A (should now contain AAh)
    
    ; Final state:
    ; A = AAh (170) - copied back from I to verify
    ; I = AAh (170) - copied from A
    ; Condition bits: Not affected by LD I, A (but are affected by the subsequent LD A, I)
    
    ; ========= TEST 21: LD R, A =========
    ; Operation: R ← A
    ; Description: The contents of the Accumulator are loaded to the Memory Refresh Register R
    
    ; Example implementation
    ld a, 0BBh              ; Load BBh into A 
    ld r, a                 ; Transfer from A to R
    
    ; To verify it worked (although the R register keeps changing)
    ld a, 00h               ; Clear A
    ld a, r                 ; Load R back into A (may not be exactly BBh due to auto-increment)
    
    ; Final state:
    ; A = value read from R (may not match what we loaded due to auto-increment)
    ; R = value loaded from A, but will keep changing as instructions are fetched
    ; Condition bits: Not affected by LD R, A
    
    ; ========= END TEST AREA =========
    
    ; Program halt
    jr $          ; Infinite loop

; Data section
test_data:
    db 58h        ; This represents our test data at memory location pointed by HL

bc_data:
    db 12h        ; This represents our test data at memory location pointed by BC

de_data:
    db 47h        ; This represents our test data at memory location pointed by DE

direct_address:
    db 04h        ; This represents our test data at a direct memory address for TEST 14

direct_address_out:
    db 00h        ; Output location for TEST 17

bc_data_out:
    db 00h        ; Output location for TEST 15

de_data_out:
    db 00h        ; Output location for TEST 16

indexed_data_base:
    db 00h        ; Base address (IX+0 or IY+0)
    db 39h        ; This represents the byte at (IX+1)
    db 39h        ; This represents the byte at (IY+2), matching the example

memory_location:
    db 00h        ; This represents a memory location for TEST 6

memory_location2:
    db 00h        ; This represents a memory location for TEST 9

memory_array:
    db 00h, 01h, 02h, 03h     ; The first 4 bytes of our memory array
    db 00h                    ; Location at +4 for TEST 8
    db 00h                    ; Location at +5 for TEST 10
    db 00h                    ; Location at +6 for TEST 7
    db 00h                    ; Location at +7
    db 00h                    ; Location at +8 for TEST 11
    db 00h, 00h               ; Additional space

stack_bottom:   ; 100 bytes of stack
    defs    100, 0
stack_top:
    END