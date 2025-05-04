; Z80 Assembly - Exchange, Block Transfer and Search Group Instructions Testing
; This file contains tests for the Z80 Exchange, Block Transfer and Search Group instructions:
;   1. EX DE, HL - Exchange the contents of DE and HL register pairs
;   2. EX AF, AF' - Exchange the contents of AF and AF' register pairs
;   3. EXX - Exchange BC, DE, HL with BC', DE', HL'
;   4. EX (SP), HL - Exchange HL with the contents of (SP) and (SP+1)
;   5. EX (SP), IX - Exchange IX with the contents of (SP) and (SP+1)
;   6. EX (SP), IY - Exchange IY with the contents of (SP) and (SP+1)
;   7. LDI - Load and Increment
;   8. LDIR - Load and Increment with Repeat
;   9. LDD - Load and Decrement
;  10. LDDR - Load and Decrement with Repeat
;  11. CPI - Compare and Increment
;  12. CPIR - Compare and Increment with Repeat
;  13. CPD - Compare and Decrement
;  14. CPDR - Compare and Decrement with Repeat

    DEVICE NOSLOT64K
    SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION

    org 0       ; Program starts at address 0 in memory

main:
    ld sp, stack_top  ; Initialize stack pointer
    
    ; ========= TEST 1: EX DE, HL =========
    ; Operation: DE ↔ HL
    ; Description: The 2-byte contents of register pairs DE and HL are exchanged
    
    ; Example from documentation:
    ; "If register pair DE contains 2822h and register pair HL contains 499Ah, then upon the
    ; execution of an EX DE, HL instruction, register pair DE contains 499Ah and register pair
    ; HL contains 2822h."
    
    ; Setup for our example
    ld de, 2822h      ; DE = 2822h (10274) as per the example
    ld hl, 499Ah      ; HL = 499Ah (18842) as per the example
    ex de, hl         ; Exchange the contents of DE and HL
    
    ; Final register state:
    ; DE = 499Ah (18842) - was previously in HL
    ; HL = 2822h (10274) - was previously in DE
    ; Condition bits: Not affected
    
    ; ========= TEST 2: EX AF, AF' =========
    ; Operation: AF ↔ AF'
    ; Description: The 2-byte contents of the register pairs AF and AF' are exchanged
    
    ; Example from documentation:
    ; "If register pair AF contains 9900h and register pair AF′ contains 5944h, the contents of
    ; AF are 5944h and the contents of AF′ are 9900h upon execution of the EX AF, AF′
    ; instruction."
    
    ; Setup for our example
    ; First, set AF to a known value
    ld a, 99h              ; A = 99h (153) as per the example
    xor a                  ; Set zero flag (and reset others)
    add a, 99h             ; A = 99h again, flags cleared
    push af                ; Save AF on stack
    
    ; Next, set AF' to a known value (can only be done indirectly)
    ld a, 59h              ; A = 59h (89) as per the example
    or 44h                 ; A = 5Dh (93), set some flags
    ex af, af'             ; Move A and flags to AF'
    
    ; Now restore AF from the stack
    pop af                 ; Restore AF to the value we saved (99h with cleared flags)
    
    ; Perform the exchange
    ex af, af'             ; Exchange AF and AF'
    
    ; Final register state:
    ; A = 59h (89) approximately (with some flags set)- was previously in AF'
    ; AF' now contains 99h (153) with different flags - was previously in AF
    ; Condition bits: Not affected directly, but flags are part of what's exchanged
    
    ; ========= TEST 3: EXX =========
    ; Operation: (BC) ↔ (BC′), (DE) ↔ (DE'), (HL) ↔ (HL′)
    ; Description: Each 2-byte value in register pairs BC, DE, and HL is exchanged with the 2-byte value in
    ; BC', DE', and HL', respectively
    
    ; Example from documentation:
    ; "If register pairs BC, DE, and HL contain 445Ah, 3DA2h, and 8859h, respectively, and
    ; register pairs BC', DE', and HL' contain 0988h, 9300h, and 00E7h, respectively, then
    ; upon the execution of an EXX instruction, BC contains 0988h; DE contains 9300h; HL
    ; contains 00E7h; BC' contains 445Ah; DE' contains 3DA2h; and HL' contains 8859h."
    
    ; Setup for our example
    ld bc, 445Ah           ; BC = 445Ah (17498) as per the example
    ld de, 3DA2h           ; DE = 3DA2h (15778) as per the example
    ld hl, 8859h           ; HL = 8859h (34905) as per the example
    
    ; Exchange with shadow registers
    exx                    ; Move BC, DE, HL to shadow registers
    
    ; Now set the main registers to the alternate values
    ld bc, 0988h           ; BC = 0988h (2440) as per the example
    ld de, 9300h           ; DE = 9300h (37632) as per the example
    ld hl, 00E7h           ; HL = 00E7h (231) as per the example
    
    ; Perform the exchange
    exx                    ; Exchange BC, DE, HL with BC', DE', HL'
    
    ; Now the registers should contain the values from the shadow registers
    ; Final register state:
    ; BC = 0988h (2440) - from shadow registers
    ; DE = 9300h (37632) - from shadow registers
    ; HL = 00E7h (231) - from shadow registers
    ; BC' = 445Ah (17498) - from main registers
    ; DE' = 3DA2h (15778) - from main registers
    ; HL' = 8859h (34905) - from main registers
    ; Condition bits: Not affected
    
    ; ========= TEST 4: EX (SP), HL =========
    ; Operation: H ↔ (SP+1), L ↔ (SP)
    ; Description: The low-order byte contained in register pair HL is exchanged with the contents of the
    ; memory address specified by the contents of register pair SP (Stack Pointer), and the high-
    ; order byte of HL is exchanged with the next highest memory address (SP+1)
    
    ; Example from documentation:
    ; "If the HL register pair contains 7012h, the SP register pair contains 8856h, the memory
    ; location 8856h contains byte 11h, and memory location 8857h contains byte 22h, then
    ; the instruction EX (SP), HL results in the HL register pair containing number 2211h,
    ; memory location 8856h containing byte 12h, memory location 8857h containing byte
    ; 70h and Stack Pointer containing 8856h."
    
    ; Setup for our example
    ld a, 11h                  ; Load immediate value 11h into register A
    ld (stack_data), a         ; Store the value of register A into memory location stack_data
    ld a, 22h                  ; Load immediate value 22h into register A
    ld (stack_data+1), a       ; Store the value of register A into memory location stack_data+1
    ld hl, 7012h               ; HL = 7012h (28690) as per the example
    ld sp, stack_data          ; SP points to our data
    
    ; Perform the exchange
    ex (sp), hl                ; Exchange HL with (SP) and (SP+1)
    
    ; Final state:
    ; HL = 2211h (8721) - from memory at stack_data+1 and stack_data
    ; memory at stack_data = 12h (18) - from L
    ; memory at stack_data+1 = 70h (112) - from H
    ; SP = stack_data (unchanged)
    ; Condition bits: Not affected
    
    ; Restore stack pointer
    ld sp, stack_top
    
    ; ========= TEST 5: EX (SP), IX =========
    ; Operation: IXH ↔ (SP+1), IXL ↔ (SP)
    ; Description: The low-order byte in Index Register IX is exchanged with the contents of the
    ; memory address specified by the contents of register pair SP (Stack Pointer), and the high-
    ; order byte of IX is exchanged with the next highest memory address (SP+1)
    
    ; Example from documentation:
    ; "If Index Register IX contains 3988h, the SP register pair Contains 0100h, memory loca-
    ; tion 0100h contains byte 90h, and memory location 0101h contains byte 48h, then the
    ; instruction EX (SP), IX results in the IX register pair containing number 4890h, memory
    ; location 0100h containing 88h, memory location 0101h containing 39h, and the Stack
    ; Pointer containing 0100h."
    
    ; Setup for our example
    ld a, 90h                  ; Load immediate value 90h into register A
    ld (stack_data2), a        ; Store the value of register A into memory location stack_data2
    ld a, 48h                  ; Load immediate value 48h into register A
    ld (stack_data2+1), a      ; Store the value of register A into memory location stack_data2+1
    ld ix, 3988h               ; IX = 3988h (14728) as per the example
    ld sp, stack_data2         ; SP points to our data
    
    ; Perform the exchange
    ex (sp), ix                ; Exchange IX with (SP) and (SP+1)
    
    ; Final state:
    ; IX = 4890h (18576) - from memory at stack_data2+1 and stack_data2
    ; memory at stack_data2 = 88h (136) - from IXL
    ; memory at stack_data2+1 = 39h (57) - from IXH
    ; SP = stack_data2 (unchanged)
    ; Condition bits: Not affected
    
    ; Restore stack pointer
    ld sp, stack_top
    
    ; ========= TEST 6: EX (SP), IY =========
    ; Operation: IYH ↔ (SP+1), IYL ↔ (SP)
    ; Description: The low-order byte in Index Register IY is exchanged with the contents of the
    ; memory address specified by the contents of register pair SP (Stack Pointer), and the high-
    ; order byte of IY is exchanged with the next highest memory address (SP+1)
    
    ; Example from documentation:
    ; "If Index Register IY contains 3988h, the SP register pair contains 0100h, memory loca-
    ; tion 0100h contains byte 90h, and memory location 0101h contains byte 48h, then the
    ; instruction EX (SP), IY results in the IY register pair containing number 4890h, memory
    ; location 0100h containing 88h, memory location 0101h containing 39h, and the Stack
    ; Pointer containing 0100h."
    
    ; Setup for our example
    ld a, 90h                  ; Load immediate value 90h into register A
    ld (stack_data3), a        ; Store the value of register A into memory location stack_data3
    ld a, 48h                  ; Load immediate value 48h into register A
    ld (stack_data3+1), a      ; Store the value of register A into memory location stack_data3+1
    ld iy, 3988h               ; IY = 3988h (14728) as per the example
    ld sp, stack_data3         ; SP points to our data
    
    ; Perform the exchange
    ex (sp), iy                ; Exchange IY with (SP) and (SP+1)
    
    ; Final state:
    ; IY = 4890h (18576) - from memory at stack_data3+1 and stack_data3
    ; memory at stack_data3 = 88h (136) - from IYL
    ; memory at stack_data3+1 = 39h (57) - from IYH
    ; SP = stack_data3 (unchanged)
    ; Condition bits: Not affected
    
    ; Restore stack pointer
    ld sp, stack_top
    
    ; ========= TEST 7: LDI =========
    ; Operation: (DE) ← (HL), DE ← DE + 1, HL ← HL + 1, BC ← BC – 1
    ; Description: A byte of data is transferred from the memory location addressed by the contents of the
    ; HL register pair to the memory location addressed by the contents of the DE register pair.
    ; Then both these register pairs are incremented and the Byte Counter (BC) Register pair is decremented.
    
    ; Example from documentation:
    ; "If the HL register pair contains 1111h, memory location 1111h contains byte 88h, the DE
    ; register pair contains 2222h, the memory location 2222h contains byte 66h, and the BC
    ; register pair contains 7h, then the instruction LDI results in the following contents in register
    ; pairs and memory addresses:
    ; HL contains 1112h
    ; (1111h) contains 88h
    ; DE contains 2223h
    ; (2222h) contains 88h
    ; BC contains 6h"
    
    ; Setup for our example
    ld a, 88h                ; Set up source data
    ld (source_block), a     ; Store 88h at source memory location
    ld a, 66h                ; Different value for destination
    ld (dest_block), a       ; Store 66h at destination memory location
    
    ld hl, source_block      ; HL points to source data (like 1111h in example)
    ld de, dest_block        ; DE points to destination (like 2222h in example)
    ld bc, 7                 ; BC = 7 as per the example
    
    ; Perform the block transfer
    ldi                      ; Execute Load and Increment instruction
    
    ; Final state:
    ; HL = source_block + 1 (incremented)
    ; DE = dest_block + 1 (incremented)
    ; BC = 6 (decremented)
    ; memory at source_block = 88h (unchanged)
    ; memory at dest_block = 88h (copied from source_block)
    ; Condition bits: H and N reset, P/V set (since BC≠0)
    
    ; ========= TEST 8: LDIR =========
    ; Operation: repeat {(DE) ← (HL), DE ← DE + 1, HL ← HL + 1, BC ← BC – 1} while (BC ≠ 0)
    ; Description: This instruction transfers a byte of data from memory addressed by HL to memory
    ; addressed by DE. All three register pairs are updated and the operation repeats until BC = 0.
    
    ; Example from documentation:
    ; "The HL register pair contains 11111h, the DE register pair contains 2222h, the BC register
    ; pair contains 0003h, and memory locations contain the following data.
    ; (1111h) contains 88h    (2222h) contains 66h
    ; (1112h) contains 36h    (2223h) contains 59h
    ; (1113h) contains A5h    (2224h) contains C5h
    ; Upon the execution of an LDIR instruction, the contents of register pairs and memory
    ; locations now contain:
    ; HL contains 1114h, DE contains 2225h, BC contains 0000h
    ; (1111h) contains 88h    (2222h) contains 88h
    ; (1112h) contains 36h    (2223h) contains 36h
    ; (1113h) contains A5h    (2224h) contains A5h"
    
    ; Setup for our example
    ; First, prepare the source block with the example data
    ld a, 88h
    ld (source_block2), a
    ld a, 36h
    ld (source_block2+1), a
    ld a, 0A5h
    ld (source_block2+2), a
    
    ; Next, prepare the destination block with different values
    ld a, 66h
    ld (dest_block2), a
    ld a, 59h
    ld (dest_block2+1), a
    ld a, 0C5h
    ld (dest_block2+2), a
    
    ; Set up registers for the transfer
    ld hl, source_block2     ; HL points to source data
    ld de, dest_block2       ; DE points to destination 
    ld bc, 3                 ; BC = 3 bytes to transfer
    
    ; Perform the block transfer
    ldir                     ; Execute Load, Increment with Repeat instruction
    
    ; Final state:
    ; HL = source_block2 + 3 (incremented 3 times)
    ; DE = dest_block2 + 3 (incremented 3 times)
    ; BC = 0 (decremented to zero)
    ; memory at source_block2 = 88h, source_block2+1 = 36h, source_block2+2 = A5h (unchanged)
    ; memory at dest_block2 = 88h, dest_block2+1 = 36h, dest_block2+2 = A5h (copied from source)
    ; Condition bits: H and N reset, P/V reset (since BC=0)
    
    ; ========= TEST 9: LDD =========
    ; Operation: (DE) ← (HL), DE ← DE – 1, HL ← HL– 1, BC ← BC– 1
    ; Description: This instruction transfers a byte of data from memory addressed by HL to memory
    ; addressed by DE, then decrements all three register pairs.
    
    ; Example from documentation:
    ; "If the HL register pair contains 1111h, memory location 1111h contains byte 88h, the DE
    ; register pair contains 2222h, memory location 2222h contains byte 66h, and the BC register
    ; pair contains 7h, then instruction LDD results in the following contents in register
    ; pairs and memory addresses:
    ; HL contains 1110h
    ; (1111h) contains 88h
    ; DE contains 2221h
    ; (2222h) contains 88h
    ; BC contains 6h"
    
    ; Setup for our example
    ld a, 88h                ; Set up source data
    ld (source_block3), a    ; Store 88h at source memory location
    ld a, 66h                ; Different value for destination
    ld (dest_block3), a      ; Store 66h at destination memory location
    
    ld hl, source_block3     ; HL points to source data (like 1111h in example)
    ld de, dest_block3       ; DE points to destination (like 2222h in example)
    ld bc, 7                 ; BC = 7 as per the example
    
    ; Perform the block transfer
    ldd                      ; Execute Load and Decrement instruction
    
    ; Final state:
    ; HL = source_block3 - 1 (decremented)
    ; DE = dest_block3 - 1 (decremented)
    ; BC = 6 (decremented)
    ; memory at source_block3 = 88h (unchanged)
    ; memory at dest_block3 = 88h (copied from source_block3)
    ; Condition bits: H and N reset, P/V set (since BC≠0)
    
    ; ========= TEST 10: LDDR =========
    ; Operation: repeat {(DE) ← (HL), DE ← DE – 1, HL ← HL – 1, BC ← BC – 1} while (BC ≠ 0)
    ; Description: This instruction transfers a byte of data from memory addressed by HL to memory
    ; addressed by DE, updates all registers, and repeats until BC = 0.
    
    ; Example from documentation:
    ; "The HL register pair contains 1114h, the DE register pair contains 2225h, the BC register
    ; pair contains 0003h, and memory locations contain the following data.
    ; (1114h) contains A5h    (2225h) contains C5h
    ; (1113h) contains 36h    (2224h) contains 59h
    ; (1112h) contains 88h    (2223h) contains 66h
    ; Upon the execution of an LDDR instruction, the contents of the register pairs and memory
    ; locations now contain:
    ; HL contains 1111h, DE contains 2222h, BC contains 0000h
    ; (1114h) contains A5h    (2225h) contains A5h
    ; (1113h) contains 36h    (2224h) contains 36h
    ; (1112h) contains 88h    (2223h) contains 88h"
    
    ; Setup for our example
    ; First, prepare the source block with the example data
    ld a, 88h
    ld (source_block4), a
    ld a, 36h
    ld (source_block4+1), a
    ld a, 0A5h
    ld (source_block4+2), a
    
    ; Next, prepare the destination block with different values
    ld a, 66h
    ld (dest_block4), a
    ld a, 59h
    ld (dest_block4+1), a
    ld a, 0C5h
    ld (dest_block4+2), a
    
    ; Set up registers for the transfer
    ld hl, source_block4+2   ; HL points to the last byte of source data
    ld de, dest_block4+2     ; DE points to the last byte of destination
    ld bc, 3                 ; BC = 3 bytes to transfer
    
    ; Perform the block transfer
    lddr                     ; Execute Load, Decrement with Repeat instruction
    
    ; Final state:
    ; HL = source_block4 - 1 (decremented 3 times)
    ; DE = dest_block4 - 1 (decremented 3 times)
    ; BC = 0 (decremented to zero)
    ; memory at source_block4 = 88h, source_block4+1 = 36h, source_block4+2 = A5h (unchanged)
    ; memory at dest_block4 = 88h, dest_block4+1 = 36h, dest_block4+2 = A5h (copied from source)
    ; Condition bits: H and N reset, P/V reset (since BC=0)
    
    ; ========= TEST 11: CPI =========
    ; Operation: A – (HL), HL ← HL +1, BC ← BC – 1
    ; Description: The contents of the memory location addressed by the HL register is compared with the
    ; contents of the Accumulator. With a true compare, a condition bit is set. Then HL is incremented
    ; and the Byte Counter (register pair BC) is decremented.
    
    ; Example from documentation:
    ; "If the HL register pair contains 1111h, memory location 1111h contains 3Bh, the Accumulator
    ; contains 3Bh, and the Byte Counter contains 0001h. Upon the execution of a CPI
    ; instruction, the Byte Counter contains 0000h, the HL register pair contains 1112h, the Z
    ; flag in the F register is set, and the P/V flag in the F Register is reset. There is no effect on
    ; the contents of the Accumulator or to address 1111h."
    
    ; Setup for our example
    ld a, 3Bh              ; A = 3Bh (59) as per the example
    ld (compare_data), a   ; Store 3Bh at our test memory location
    ld hl, compare_data    ; HL points to our test data (like 1111h in example)
    ld bc, 1               ; BC = 1 as per the example (byte counter)
    
    ; Perform the compare
    cpi                    ; Compare A with (HL), then increment HL and decrement BC
    
    ; Final state:
    ; A = 3Bh (59) (unchanged)
    ; HL = compare_data + 1 (incremented)
    ; BC = 0 (decremented)
    ; memory at compare_data = 3Bh (unchanged)
    ; Condition bits:
    ; - Z flag is set (since A = (HL))
    ; - P/V flag is reset (since BC-1 = 0)
    ; - S flag is reset (since result is not negative)
    ; - H flag depends on the operation
    ; - N flag is set
    ; - C flag is not affected
    
    ; ========= TEST 12: CPIR =========
    ; Operation: A – (HL), HL ← HL+1, BC ← BC – 1
    ; Description: The contents of the memory location addressed by the HL register pair is compared with
    ; the contents of the Accumulator. During a compare operation, a condition bit is set. HL is
    ; incremented and the Byte Counter (register pair BC) is decremented. If decrementing
    ; causes BC to go to 0 or if A = (HL), the instruction is terminated. If BC is not 0 and A ≠
    ; (HL), the program counter is decremented by two and the instruction is repeated.
    
    ; Example from documentation:
    ; "If the HL register pair contains 1111h, the Accumulator contains F3h, the Byte Counter
    ; contains 0007h, and memory locations contain the following data.
    ; (1111h) contains 52h
    ; (1112h) contains 00h
    ; (1113h) contains F3h
    ; Upon the execution of a CPIR instruction, register pair HL contains 1114h, the Byte
    ; Counter contains 0004h, the P/V flag in the F Register is set, and the Z flag in the F Reg-
    ; ister is set."
    
    ; Setup for our example
    ; First, prepare the memory block with the example data
    ld a, 52h
    ld (search_block), a
    ld a, 00h
    ld (search_block+1), a
    ld a, 0F3h
    ld (search_block+2), a
    ld a, 0F3h               ; A = F3h as per the example (value to search for)
    ld hl, search_block      ; HL points to our search data (like 1111h in example)
    ld bc, 7                 ; BC = 7 as per the example (byte counter)
    
    ; Perform the compare and search
    cpir                     ; Compare and Increment with Repeat
    
    ; Final state:
    ; A = F3h (243) (unchanged)
    ; HL = search_block + 3 (pointing just after the matched byte)
    ; BC = 4 (decremented from 7 to 4 - 3 bytes were checked)
    ; Condition bits:
    ; - Z flag is set (since a match was found: A = F3h and memory also contains F3h)
    ; - P/V flag is set (since BC ≠ 0 after the operation)
    ; - S flag depends on the last comparison result
    ; - H flag depends on the operation
    ; - N flag is set
    ; - C flag is not affected
    
    ; ========= TEST 13: CPD =========
    ; Operation: A – (HL), HL ← HL – 1, BC ← BC – 1
    ; Description: The contents of the memory location addressed by the HL register pair is compared with
    ; the contents of the Accumulator. During a compare operation, a condition bit is set. The
    ; HL and Byte Counter (register pair BC) are decremented.
    
    ; Example from documentation:
    ; "If the HL register pair contains 1111h, memory location 1111h contains 3Bh, the Accumulator
    ; contains 3Bh, and the Byte Counter contains 0001h. Upon the execution of a
    ; CPD instruction, the Byte Counter contains 0000h, the HL register pair contains 1110h,
    ; the flag in the F Register is set, and the P/V flag in the F Register is reset. There is no
    ; effect on the contents of the Accumulator or address 1111h."
    
    ; Setup for our example
    ld a, 3Bh                  ; A = 3Bh (59) as per the example
    ld (compare_data2), a      ; Store 3Bh at our test memory location
    ld hl, compare_data2       ; HL points to our test data (like 1111h in example)
    ld bc, 1                   ; BC = 1 as per the example (byte counter)
    
    ; Perform the compare
    cpd                        ; Compare A with (HL), then decrement HL and decrement BC
    
    ; Final state:
    ; A = 3Bh (59) (unchanged)
    ; HL = compare_data2 - 1 (decremented)
    ; BC = 0 (decremented)
    ; memory at compare_data2 = 3Bh (unchanged)
    ; Condition bits:
    ; - Z flag is set (since A = (HL))
    ; - P/V flag is reset (since BC-1 = 0)
    ; - S flag is reset (since result is not negative)
    ; - H flag depends on the operation
    ; - N flag is set
    ; - C flag is not affected
    
    ; ========= TEST 14: CPDR =========
    ; Operation: A – (HL), HL ← HL – 1, BC ← BC – 1
    ; Description: The contents of the memory location addressed by the HL register pair is compared with
    ; the contents of the Accumulator. During a compare operation, a condition bit is set. The
    ; HL and Byte Counter (BC) Register pairs are decremented. If decrementing allows the BC
    ; to go to 0 or if A = (HL), the instruction is terminated. If BC is not 0 and A ≠ (HL), the
    ; program counter is decremented by two and the instruction is repeated.
    
    ; Example from documentation:
    ; "The HL register pair contains 1118h, the Accumulator contains F3h, the Byte Counter
    ; contains 0007h, and memory locations contain the following data.
    ; (1118h) contains 52h
    ; (1117h) contains 00h
    ; (1116h) contains F3h
    ; Upon the execution of a CPDR instruction, register pair HL contains 1115h, the Byte
    ; Counter contains 0004h, the P/V flag in the F Register is set, and the Z flag in the F Reg-
    ; ister is set."
    
    ; Setup for our example
    ; First, prepare the memory block with the example data
    ld a, 0F3h
    ld (reverse_search_block+2), a
    ld a, 00h
    ld (reverse_search_block+1), a
    ld a, 52h
    ld (reverse_search_block), a
    ld a, 0F3h               ; A = F3h as per the example (value to search for)
    ld hl, reverse_search_block+2  ; HL points to the last byte of our search data (like 1118h in example)
    ld bc, 7                 ; BC = 7 as per the example (byte counter)
    
    ; Perform the compare and search (backward)
    cpdr                     ; Compare and Decrement with Repeat
    
    ; Final state:
    ; A = F3h (243) (unchanged)
    ; HL = reverse_search_block+1 (pointing before the matched byte)
    ; BC = 4 (decremented from 7 to 4 - 3 bytes were checked)
    ; Condition bits:
    ; - Z flag is set (since a match was found: A = F3h and memory also contains F3h)
    ; - P/V flag is set (since BC ≠ 0 after the operation)
    ; - S flag depends on the last comparison result
    ; - H flag depends on the operation
    ; - N flag is set
    ; - C flag is not affected
    
    ; ========= END TEST AREA =========
    
    jr $          ; Infinite loop

; Data section
stack_data:      ; Memory location for EX (SP), HL test
    dw 0000h

stack_data2:     ; Memory location for EX (SP), IX test
    dw 0000h

stack_data3:     ; Memory location for EX (SP), IY test
    dw 0000h

; Data for the block transfer tests
source_block:    ; Source data for LDI test
    db 0

dest_block:      ; Destination area for LDI test
    db 0

source_block2:   ; Source data for LDIR test
    db 0, 0, 0   ; 3 bytes

dest_block2:     ; Destination area for LDIR test
    db 0, 0, 0   ; 3 bytes

source_block3:   ; Source data for LDD test
    db 0

dest_block3:     ; Destination area for LDD test
    db 0

source_block4:   ; Source data for LDDR test 
    db 0, 0, 0   ; 3 bytes

dest_block4:     ; Destination area for LDDR test
    db 0, 0, 0   ; 3 bytes

; Data for the compare tests
compare_data:   ; Data for CPI test
    db 0
compare_data2:  ; Data for CPD test
    db 0

; Data for the compare and search tests
search_block:    ; Data for CPIR test
    db 0, 0, 0   ; 3 bytes (will be filled with 52h, 00h, F3h)
reverse_search_block:  ; Data for CPDR test
    db 0, 0, 0   ; 3 bytes (will be filled with 52h, 00h, F3h)

stack_bottom:   ; 100 bytes of stack
    defs    100, 0
stack_top:
    END
