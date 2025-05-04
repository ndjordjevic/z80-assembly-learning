; Z80 Assembly - Bit Manipulation Group Instructions Testing
; This file contains tests for the Z80 Bit Manipulation Group instructions:
;   1. BIT b, r - Test bit b in register r
;   2. BIT b, (HL) - Test bit b in memory location (HL)
;   3. BIT b, (IX+d) - Test bit b in memory location (IX+d)
;   4. BIT b, (IY+d) - Test bit b in memory location (IY+d)
;   5. SET b, r - Set bit b in register r to 1
;   6. SET b, (HL) - Set bit b in memory location (HL) to 1
;   7. SET b, (IX+d) - Set bit b in memory location (IX+d) to 1
;   8. SET b, (IY+d) - Set bit b in memory location (IY+d) to 1
;   9. RES b, r - Reset bit b in register r to 0
;  10. RES b, (HL) - Reset bit b in memory location (HL) to 0
;  11. RES b, (IX+d) - Reset bit b in memory location (IX+d) to 0
;  12. RES b, (IY+d) - Reset bit b in memory location (IY+d) to 0

    DEVICE NOSLOT64K
    SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION

    org 0       ; Program starts at address 0 in memory

main:
    ld sp, stack_top  ; Initialize stack pointer
    
    ; ========= TEST 1: BIT b, r - Test bit b in register r =========
    ; Operation: Z ← rb
    ; Description: This instruction tests bit b in register r and sets the Z flag accordingly.
    ; The bit tested is specified by the values 0 to 7 for b, where b=0 is the least significant bit.
    ; Registers can be any of B, C, D, E, H, L, or A.
    
    ; Example from documentation:
    ; "If bit 2 in Register B contains 0, then upon the execution of a BIT 2, B instruction,
    ; the Z flag in the F Register contains 1, and bit 2 in Register B remains at 0."
    
    ; ===== TEST 1.1: BIT b, r with bit reset (Z flag set) =====
    ld b, 11110011b   ; B = F3h (11110011) - bit 2 is 0
    bit 2, b         ; Test bit 2 (should set Z flag since bit 2 is 0)
    
    ; Final register state:
    ; B = F3h (11110011) - unchanged
    ; Condition bits:
    ; - S is unknown
    ; - Z is set (bit 2 is 0)
    ; - H is set
    ; - P/V is unknown
    ; - N is reset
    ; - C is not affected
    
    ; ===== TEST 1.2: BIT b, r with bit set (Z flag reset) =====
    ld c, 00000100b   ; C = 04h (00000100) - bit 2 is 1
    bit 2, c         ; Test bit 2 (should reset Z flag since bit 2 is 1)
    
    ; Final register state:
    ; C = 04h (00000100) - unchanged
    ; Condition bits:
    ; - S is unknown
    ; - Z is reset (bit 2 is 1)
    ; - H is set
    ; - P/V is unknown
    ; - N is reset
    ; - C is not affected
    
    ; ===== TEST 1.3: BIT b, r with various bits =====
    ; Test bit 0 (LSB)
    ld d, 11111110b   ; D = FEh (11111110) - bit 0 is 0
    bit 0, d         ; Test bit 0 (should set Z flag)
    
    ld d, 00000001b   ; D = 01h (00000001) - bit 0 is 1
    bit 0, d         ; Test bit 0 (should reset Z flag)
    
    ; Test bit 7 (MSB)
    ld e, 01111111b   ; E = 7Fh (01111111) - bit 7 is 0
    bit 7, e         ; Test bit 7 (should set Z flag)
    
    ld e, 10000000b   ; E = 80h (10000000) - bit 7 is 1
    bit 7, e         ; Test bit 7 (should reset Z flag)
    
    ; Testing with H register
    ld h, 10101010b   ; H = AAh (10101010) - alternating bits
    bit 0, h         ; Test bit 0 (should set Z flag)
    bit 1, h         ; Test bit 1 (should reset Z flag)
    bit 2, h         ; Test bit 2 (should set Z flag)
    bit 3, h         ; Test bit 3 (should reset Z flag)
    
    ; Testing with L register
    ld l, 01010101b   ; L = 55h (01010101) - alternating bits
    bit 0, l         ; Test bit 0 (should reset Z flag)
    bit 1, l         ; Test bit 1 (should set Z flag)
    bit 2, l         ; Test bit 2 (should reset Z flag)
    bit 3, l         ; Test bit 3 (should set Z flag)
    
    ; Testing with A register
    ld a, 11001100b   ; A = CCh (11001100)
    bit 0, a         ; Test bit 0 (should set Z flag)
    bit 2, a         ; Test bit 2 (should reset Z flag)
    bit 4, a         ; Test bit 4 (should reset Z flag)
    bit 6, a         ; Test bit 6 (should reset Z flag)
    
    ; ========= TEST 2: BIT b, (HL) - Test bit b in memory location (HL) =========
    ; Operation: Z ← (HL)b
    ; Description: This instruction tests bit b in the memory location specified by 
    ; the contents of the HL register pair and sets the Z flag accordingly.
    
    ; Example from documentation:
    ; "If the HL register pair contains 4444h, and bit 4 in the memory location 444h contains 1,
    ; then upon the execution of a BIT 4, (HL) instruction, the Z flag in the F Register contains
    ; 0, and bit 4 in memory location 4444h remains at 1."
    
    ; ===== TEST 2.1: BIT b, (HL) with bit set (Z flag reset) =====
    ld a, 00010000b   ; A = 10h (00010000) - bit 4 is 1, other bits are 0
    ld (bit_hl_data), a  ; Store the test value in memory
    ld hl, bit_hl_data   ; HL points to our test memory location
    bit 4, (hl)      ; Test bit 4 (should reset Z flag since bit 4 is 1)
    
    ; Final memory state:
    ; Memory at bit_hl_data = 10h (00010000) - unchanged
    ; Condition bits:
    ; - S is unknown
    ; - Z is reset (bit 4 is 1)
    ; - H is set
    ; - P/V is unknown
    ; - N is reset
    ; - C is not affected
    
    ; ===== TEST 2.2: BIT b, (HL) with bit reset (Z flag set) =====
    ld a, 11101111b   ; A = EFh (11101111) - bit 4 is 0, other bits are 1
    ld (bit_hl_data), a  ; Store the test value in memory
    ld hl, bit_hl_data   ; HL points to our test memory location
    bit 4, (hl)      ; Test bit 4 (should set Z flag since bit 4 is 0)
    
    ; Final memory state:
    ; Memory at bit_hl_data = EFh (11101111) - unchanged
    ; Condition bits:
    ; - S is unknown
    ; - Z is set (bit 4 is 0)
    ; - H is set
    ; - P/V is unknown
    ; - N is reset
    ; - C is not affected
    
    ; ===== TEST 2.3: BIT b, (HL) with various bits =====
    ; Test bit 0 (LSB)
    ld a, 11111110b   ; A = FEh (11111110) - bit 0 is 0
    ld (bit_hl_data), a  ; Store the test value in memory
    bit 0, (hl)      ; Test bit 0 (should set Z flag)
    
    ld a, 00000001b   ; A = 01h (00000001) - bit 0 is 1
    ld (bit_hl_data), a  ; Store the test value in memory
    bit 0, (hl)      ; Test bit 0 (should reset Z flag)
    
    ; Test bit 7 (MSB)
    ld a, 01111111b   ; A = 7Fh (01111111) - bit 7 is 0
    ld (bit_hl_data), a  ; Store the test value in memory
    bit 7, (hl)      ; Test bit 7 (should set Z flag)
    
    ld a, 10000000b   ; A = 80h (10000000) - bit 7 is 1
    ld (bit_hl_data), a  ; Store the test value in memory
    bit 7, (hl)      ; Test bit 7 (should reset Z flag)
    
    ; ========= TEST 3: BIT b, (IX+d) - Test bit b in memory location (IX+d) =========
    ; Operation: Z ← (IX+d)b
    ; Description: This instruction tests bit b in the memory location specified by the contents
    ; of register pair IX combined with the two's complement displacement d and sets the Z flag accordingly.
    
    ; Example from documentation:
    ; "If Index Register IX contains 2000h and bit 6 in memory location 2004h contains 1, then
    ; upon the execution of a BIT 6, (IX+4h) instruction, the Z flag in the F Register contains a
    ; 0 and bit 6 in memory location 2004h still contains a 1."
    
    ; ===== TEST 3.1: BIT b, (IX+d) with bit set (Z flag reset) =====
    ld a, 01000000b   ; A = 40h (01000000) - bit 6 is 1, other bits are 0
    ld (bit_ix_base+4), a  ; Store the test value at IX+4 offset
    ld ix, bit_ix_base     ; IX points to our base address
    bit 6, (ix+4)      ; Test bit 6 (should reset Z flag since bit 6 is 1)
    
    ; Final memory state:
    ; Memory at bit_ix_base+4 = 40h (01000000) - unchanged
    ; Condition bits:
    ; - S is unknown
    ; - Z is reset (bit 6 is 1)
    ; - H is set
    ; - P/V is unknown
    ; - N is reset
    ; - C is not affected
    
    ; ===== TEST 3.2: BIT b, (IX+d) with bit reset (Z flag set) =====
    ld a, 10111111b   ; A = BFh (10111111) - bit 6 is 0, other bits are 1
    ld (bit_ix_base+4), a  ; Store the test value at IX+4 offset
    bit 6, (ix+4)      ; Test bit 6 (should set Z flag since bit 6 is 0)
    
    ; Final memory state:
    ; Memory at bit_ix_base+4 = BFh (10111111) - unchanged
    ; Condition bits:
    ; - S is unknown
    ; - Z is set (bit 6 is 0)
    ; - H is set
    ; - P/V is unknown
    ; - N is reset
    ; - C is not affected
    
    ; ===== TEST 3.3: BIT b, (IX+d) with negative displacement =====
    ld a, 00001000b   ; A = 08h (00001000) - bit 3 is 1, other bits are 0
    ld (bit_ix_base-2), a  ; Store the test value at IX-2 offset
    bit 3, (ix-2)      ; Test bit 3 (should reset Z flag since bit 3 is 1)
    
    ld a, 11110111b   ; A = F7h (11110111) - bit 3 is 0, other bits are 1
    ld (bit_ix_base-2), a  ; Store the test value at IX-2 offset
    bit 3, (ix-2)      ; Test bit 3 (should set Z flag since bit 3 is 0)
    
    ; ========= TEST 4: BIT b, (IY+d) - Test bit b in memory location (IY+d) =========
    ; Operation: Z ← (IY+d)b
    ; Description: This instruction tests bit b in the memory location specified by the contents
    ; of register pair IY combined with the two's complement displacement d and sets the Z flag accordingly.
    
    ; Example from documentation:
    ; "If Index Register contains 2000h and bit 6 in memory location 2004h contains a 1, then
    ; upon the execution of a BIT 6, (IY+4h) instruction, the Z flag and the F Register still contains
    ; a 0, and bit 6 in memory location 2004h still contains a 1."
    
    ; ===== TEST 4.1: BIT b, (IY+d) with bit set (Z flag reset) =====
    ld a, 01000000b   ; A = 40h (01000000) - bit 6 is 1, other bits are 0
    ld (bit_iy_base+4), a  ; Store the test value at IY+4 offset
    ld iy, bit_iy_base     ; IY points to our base address
    bit 6, (iy+4)      ; Test bit 6 (should reset Z flag since bit 6 is 1)
    
    ; Final memory state:
    ; Memory at bit_iy_base+4 = 40h (01000000) - unchanged
    ; Condition bits:
    ; - S is unknown
    ; - Z is reset (bit 6 is 1)
    ; - H is set
    ; - P/V is unknown
    ; - N is reset
    ; - C is not affected
    
    ; ===== TEST 4.2: BIT b, (IY+d) with bit reset (Z flag set) =====
    ld a, 10111111b   ; A = BFh (10111111) - bit 6 is 0, other bits are 1
    ld (bit_iy_base+4), a  ; Store the test value at IY+4 offset
    bit 6, (iy+4)      ; Test bit 6 (should set Z flag since bit 6 is 0)
    
    ; Final memory state:
    ; Memory at bit_iy_base+4 = BFh (10111111) - unchanged
    ; Condition bits:
    ; - S is unknown
    ; - Z is set (bit 6 is 0)
    ; - H is set
    ; - P/V is unknown
    ; - N is reset
    ; - C is not affected
    
    ; ===== TEST 4.3: BIT b, (IY+d) with negative displacement =====
    ld a, 00001000b   ; A = 08h (00001000) - bit 3 is 1, other bits are 0
    ld (bit_iy_base-2), a  ; Store the test value at IY-2 offset
    bit 3, (iy-2)      ; Test bit 3 (should reset Z flag since bit 3 is 1)
    
    ld a, 11110111b   ; A = F7h (11110111) - bit 3 is 0, other bits are 1
    ld (bit_iy_base-2), a  ; Store the test value at IY-2 offset
    bit 3, (iy-2)      ; Test bit 3 (should set Z flag since bit 3 is 0)
    
    ; ========= TEST 5: SET b, r - Set bit b in register r to 1 =========
    ; Operation: rb ← 1
    ; Description: Bit b in register r (any of registers B, C, D, E, H, L, or A) is set.
    
    ; Example from documentation:
    ; "Upon the execution of a SET 4, A instruction, bit 4 in Register A is set."
    
    ; ===== TEST 5.1: SET b, r - Set bit in register =====
    ld a, 00000000b   ; A = 00h (00000000) - all bits are 0
    set 4, a         ; Set bit 4 in register A
    
    ; Final register state:
    ; A = 10h (00010000) - bit 4 is now 1
    ; No condition bits are affected
    
    ; ===== TEST 5.2: SET b, r with various registers and bits =====
    ; Test with B register (bit 0 - LSB)
    ld b, 11111110b   ; B = FEh (11111110) - bit 0 is 0
    set 0, b         ; Set bit 0 in register B
    ; B is now FFh (11111111)
    
    ; Test with C register (bit 7 - MSB)
    ld c, 01111111b   ; C = 7Fh (01111111) - bit 7 is 0
    set 7, c         ; Set bit 7 in register C
    ; C is now FFh (11111111)
    
    ; Test with D register (bit already set)
    ld d, 00001000b   ; D = 08h (00001000) - bit 3 is 1
    set 3, d         ; Set bit 3 in register D (should have no effect)
    ; D remains 08h (00001000)
    
    ; Test with E register (multiple bits)
    ld e, 00000000b   ; E = 00h (00000000) - all bits are 0
    set 1, e         ; Set bit 1 in register E
    set 3, e         ; Set bit 3 in register E
    set 5, e         ; Set bit 5 in register E
    set 7, e         ; Set bit 7 in register E
    ; E is now AAh (10101010)
    
    ; Test with H register (all bits)
    ld h, 00000000b   ; H = 00h (00000000) - all bits are 0
    set 0, h         ; Set all bits in register H
    set 1, h
    set 2, h
    set 3, h
    set 4, h
    set 5, h
    set 6, h
    set 7, h
    ; H is now FFh (11111111)
    
    ; Test with L register (alternating bits)
    ld l, 01010101b   ; L = 55h (01010101)
    set 0, l         ; Set even-numbered bits
    set 2, l
    set 4, l
    set 6, l
    ; L is now FFh (11111111)
    
    ; ========= TEST 6: SET b, (HL) - Set bit b in memory location (HL) to 1 =========
    ; Operation: (HL)b ← 1
    ; Description: Bit b in the memory location addressed by the contents of register pair HL is set.
    
    ; Example from documentation:
    ; "If the HL register pair contains 3000h, then upon the execution of a SET 4, (HL) instruction,
    ; bit 4 in memory location 3000h is 1."
    
    ; ===== TEST 6.1: SET b, (HL) - Set bit in memory =====
    ld a, 00000000b           ; A = 00h (00000000) - all bits are 0
    ld (set_hl_data), a       ; Store the test value in memory
    ld hl, set_hl_data        ; HL points to our test memory location
    set 4, (hl)              ; Set bit 4 in memory location (HL)
    
    ; Final memory state:
    ; Memory at set_hl_data = 10h (00010000) - bit 4 is now 1
    ; No condition bits are affected
    
    ; ===== TEST 6.2: SET b, (HL) with various bits =====
    ; Test with bit 0 (LSB)
    ld a, 11111110b           ; A = FEh (11111110) - bit 0 is 0
    ld (set_hl_data), a       ; Store the test value in memory
    set 0, (hl)              ; Set bit 0 in memory location (HL)
    ; Memory now contains FFh (11111111)
    
    ; Test with bit 7 (MSB)
    ld a, 01111111b           ; A = 7Fh (01111111) - bit 7 is 0
    ld (set_hl_data), a       ; Store the test value in memory
    set 7, (hl)              ; Set bit 7 in memory location (HL)
    ; Memory now contains FFh (11111111)
    
    ; Test with bit already set
    ld a, 00001000b           ; A = 08h (00001000) - bit 3 is 1
    ld (set_hl_data), a       ; Store the test value in memory
    set 3, (hl)              ; Set bit 3 in memory location (HL) (should have no effect)
    ; Memory remains 08h (00001000)
    
    ; Test with multiple bits
    ld a, 00000000b           ; A = 00h (00000000) - all bits are 0
    ld (set_hl_data), a       ; Store the test value in memory
    set 1, (hl)              ; Set multiple bits in memory location (HL)
    set 3, (hl)
    set 5, (hl)
    set 7, (hl)
    ; Memory now contains AAh (10101010)
    
    ; ========= TEST 7: SET b, (IX+d) - Set bit b in memory location (IX+d) to 1 =========
    ; Operation: (IX+d)b ← 1
    ; Description: Bit b in the memory location addressed by the sum of the contents of 
    ; the IX register pair and the two's complement integer d is set.
    
    ; Example from documentation:
    ; "If the index register contains 2000h, then upon the execution of a SET 0, (IX + 3h)
    ; instruction, bit 0 in memory location 2003h is 1."
    
    ; ===== TEST 7.1: SET b, (IX+d) - Set bit in memory with positive displacement =====
    ld a, 11111110b           ; A = FEh (11111110) - bit 0 is 0
    ld (set_ix_base+3), a     ; Store the test value at IX+3 offset
    ld ix, set_ix_base        ; IX points to our base address
    set 0, (ix+3)            ; Set bit 0 in memory location (IX+3)
    
    ; Final memory state:
    ; Memory at set_ix_base+3 = FFh (11111111) - bit 0 is now 1
    ; No condition bits are affected
    
    ; ===== TEST 7.2: SET b, (IX+d) - Set bit in memory with negative displacement =====
    ld a, 01111111b           ; A = 7Fh (01111111) - bit 7 is 0
    ld (set_ix_base-2), a     ; Store the test value at IX-2 offset
    set 7, (ix-2)            ; Set bit 7 in memory location (IX-2)
    
    ; Final memory state:
    ; Memory at set_ix_base-2 = FFh (11111111) - bit 7 is now 1
    ; No condition bits are affected
    
    ; ===== TEST 7.3: SET b, (IX+d) with various bits =====
    ; Test with bit already set
    ld a, 00001000b           ; A = 08h (00001000) - bit 3 is 1
    ld (set_ix_base+5), a     ; Store the test value at IX+5 offset
    set 3, (ix+5)            ; Set bit 3 in memory location (IX+5) (should have no effect)
    ; Memory at IX+5 remains 08h (00001000)
    
    ; Test with multiple bits
    ld a, 00000000b           ; A = 00h (00000000) - all bits are 0
    ld (set_ix_base+7), a     ; Store the test value at IX+7 offset
    set 1, (ix+7)            ; Set multiple bits in memory location (IX+7)
    set 3, (ix+7)
    set 5, (ix+7)
    set 7, (ix+7)
    ; Memory at IX+7 now contains AAh (10101010)
    
    ; ========= TEST 8: SET b, (IY+d) - Set bit b in memory location (IY+d) to 1 =========
    ; Operation: (IY + d) b ← 1
    ; Description: Bit b in the memory location addressed by the sum of the contents of 
    ; the IY register pair and the two's complement displacement d is set.
    
    ; Example from documentation:
    ; "If Index Register IY contains 2000h, then upon the execution of a Set 0, (IY+3h) 
    ; instruction, bit 0 in memory location 2003h is 1."
    
    ; ===== TEST 8.1: SET b, (IY+d) - Set bit in memory with positive displacement =====
    ld a, 11111110b           ; A = FEh (11111110) - bit 0 is 0
    ld (set_iy_base+3), a     ; Store the test value at IY+3 offset
    ld iy, set_iy_base        ; IY points to our base address
    set 0, (iy+3)            ; Set bit 0 in memory location (IY+3)
    
    ; Final memory state:
    ; Memory at set_iy_base+3 = FFh (11111111) - bit 0 is now 1
    ; No condition bits are affected
    
    ; ===== TEST 8.2: SET b, (IY+d) - Set bit in memory with negative displacement =====
    ld a, 01111111b           ; A = 7Fh (01111111) - bit 7 is 0
    ld (set_iy_base-2), a     ; Store the test value at IY-2 offset
    set 7, (iy-2)            ; Set bit 7 in memory location (IY-2)
    
    ; Final memory state:
    ; Memory at set_iy_base-2 = FFh (11111111) - bit 7 is now 1
    ; No condition bits are affected
    
    ; ===== TEST 8.3: SET b, (IY+d) with various bits =====
    ; Test with bit already set
    ld a, 00001000b           ; A = 08h (00001000) - bit 3 is 1
    ld (set_iy_base+5), a     ; Store the test value at IY+5 offset
    set 3, (iy+5)            ; Set bit 3 in memory location (IY+5) (should have no effect)
    ; Memory at IY+5 remains 08h (00001000)
    
    ; Test with multiple bits
    ld a, 00000000b           ; A = 00h (00000000) - all bits are 0
    ld (set_iy_base+7), a     ; Store the test value at IY+7 offset
    set 1, (iy+7)            ; Set multiple bits in memory location (IY+7)
    set 3, (iy+7)
    set 5, (iy+7)
    set 7, (iy+7)
    ; Memory at IY+7 now contains AAh (10101010)
    
    ; ========= TEST 9: RES b, r - Reset bit b in register r to 0 =========
    ; Operation: rb ← 0
    ; Description: Bit b in register r (any of registers B, C, D, E, H, L, or A) is reset.
    
    ; Example from documentation:
    ; "Upon the execution of a RES 6, D instruction, bit 6 in register D is reset."
    
    ; ===== TEST 9.1: RES b, r - Reset bit in register =====
    ld d, 11111111b   ; D = FFh (11111111) - all bits are 1
    res 6, d         ; Reset bit 6 in register D
    
    ; Final register state:
    ; D = BFh (10111111) - bit 6 is now 0
    ; No condition bits are affected
    
    ; ===== TEST 9.2: RES b, r with various registers and bits =====
    ; Test with B register (bit 0 - LSB)
    ld b, 11111111b   ; B = FFh (11111111) - all bits are 1
    res 0, b         ; Reset bit 0 in register B
    ; B is now FEh (11111110)
    
    ; Test with C register (bit 7 - MSB)
    ld c, 11111111b   ; C = FFh (11111111) - all bits are 1
    res 7, c         ; Reset bit 7 in register C
    ; C is now 7Fh (01111111)
    
    ; Test with D register (bit already reset)
    ld d, 11110111b   ; D = F7h (11110111) - bit 3 is 0
    res 3, d         ; Reset bit 3 in register D (should have no effect)
    ; D remains F7h (11110111)
    
    ; Test with E register (multiple bits)
    ld e, 11111111b   ; E = FFh (11111111) - all bits are 1
    res 1, e         ; Reset bit 1 in register E
    res 3, e         ; Reset bit 3 in register E
    res 5, e         ; Reset bit 5 in register E
    res 7, e         ; Reset bit 7 in register E
    ; E is now 55h (01010101)
    
    ; Test with H register (all bits)
    ld h, 11111111b   ; H = FFh (11111111) - all bits are 1
    res 0, h         ; Reset all bits in register H
    res 1, h
    res 2, h
    res 3, h
    res 4, h
    res 5, h
    res 6, h
    res 7, h
    ; H is now 00h (00000000)
    
    ; Test with L register (alternating bits)
    ld l, 11111111b   ; L = FFh (11111111)
    res 0, l         ; Reset even-numbered bits
    res 2, l
    res 4, l
    res 6, l
    ; L is now 55h (01010101)
    
    ; Test with A register
    ld a, 10101010b   ; A = AAh (10101010)
    res 1, a         ; Reset odd-numbered bits (already reset)
    res 3, a
    res 5, a
    res 7, a
    ; A remains AAh (10101010)
    
    ; ========= TEST 10: RES b, (HL) - Reset bit b in memory location (HL) to 0 =========
    ; Operation: (HL)b ← 0
    ; Description: Bit b in the memory location addressed by the contents of 
    ; register pair HL is reset.
    
    ; ===== TEST 10.1: RES b, (HL) - Reset bit in memory =====
    ld a, 11111111b           ; A = FFh (11111111) - all bits are 1
    ld (res_hl_data), a       ; Store the test value in memory
    ld hl, res_hl_data        ; HL points to our test memory location
    res 4, (hl)              ; Reset bit 4 in memory location (HL)
    
    ; Final memory state:
    ; Memory at res_hl_data = EFh (11101111) - bit 4 is now 0
    ; No condition bits are affected
    
    ; ===== TEST 10.2: RES b, (HL) with various bits =====
    ; Test with bit 0 (LSB)
    ld a, 11111111b           ; A = FFh (11111111) - all bits are 1
    ld (res_hl_data), a       ; Store the test value in memory
    res 0, (hl)              ; Reset bit 0 in memory location (HL)
    ; Memory now contains FEh (11111110)
    
    ; Test with bit 7 (MSB)
    ld a, 11111111b           ; A = FFh (11111111) - all bits are 1
    ld (res_hl_data), a       ; Store the test value in memory
    res 7, (hl)              ; Reset bit 7 in memory location (HL)
    ; Memory now contains 7Fh (01111111)
    
    ; Test with bit already reset
    ld a, 11110111b           ; A = F7h (11110111) - bit 3 is 0
    ld (res_hl_data), a       ; Store the test value in memory
    res 3, (hl)              ; Reset bit 3 in memory location (HL) (should have no effect)
    ; Memory remains F7h (11110111)
    
    ; Test with multiple bits
    ld a, 11111111b           ; A = FFh (11111111) - all bits are 1
    ld (res_hl_data), a       ; Store the test value in memory
    res 1, (hl)              ; Reset multiple bits in memory location (HL)
    res 3, (hl)
    res 5, (hl)
    res 7, (hl)
    ; Memory now contains 55h (01010101)
    
    ; ========= TEST 11: RES b, (IX+d) - Reset bit b in memory location (IX+d) to 0 =========
    ; Operation: (IX+d)b ← 0
    ; Description: Bit b in the memory location addressed by the sum of the contents of 
    ; the IX register pair and the two's complement integer d is reset.
    
    ; ===== TEST 11.1: RES b, (IX+d) - Reset bit in memory with positive displacement =====
    ld a, 11111111b           ; A = FFh (11111111) - all bits are 1
    ld (res_ix_base+3), a     ; Store the test value at IX+3 offset
    ld ix, res_ix_base        ; IX points to our base address
    res 0, (ix+3)            ; Reset bit 0 in memory location (IX+3)
    
    ; Final memory state:
    ; Memory at res_ix_base+3 = FEh (11111110) - bit 0 is now 0
    ; No condition bits are affected
    
    ; ===== TEST 11.2: RES b, (IX+d) - Reset bit in memory with negative displacement =====
    ld a, 11111111b           ; A = FFh (11111111) - all bits are 1
    ld (res_ix_base-2), a     ; Store the test value at IX-2 offset
    res 7, (ix-2)            ; Reset bit 7 in memory location (IX-2)
    
    ; Final memory state:
    ; Memory at res_ix_base-2 = 7Fh (01111111) - bit 7 is now 0
    ; No condition bits are affected
    
    ; ===== TEST 11.3: RES b, (IX+d) with various bits =====
    ; Test with bit already reset
    ld a, 11110111b           ; A = F7h (11110111) - bit 3 is 0
    ld (res_ix_base+5), a     ; Store the test value at IX+5 offset
    res 3, (ix+5)            ; Reset bit 3 in memory location (IX+5) (should have no effect)
    ; Memory at IX+5 remains F7h (11110111)
    
    ; Test with multiple bits
    ld a, 11111111b           ; A = FFh (11111111) - all bits are 1
    ld (res_ix_base+7), a     ; Store the test value at IX+7 offset
    res 1, (ix+7)            ; Reset multiple bits in memory location (IX+7)
    res 3, (ix+7)
    res 5, (ix+7)
    res 7, (ix+7)
    ; Memory at IX+7 now contains 55h (01010101)
    
    ; ========= TEST 12: RES b, (IY+d) - Reset bit b in memory location (IY+d) to 0 =========
    ; Operation: (IY+d)b ← 0
    ; Description: Bit b in the memory location addressed by the sum of the contents of 
    ; the IY register pair and the two's complement displacement d is reset.
    
    ; ===== TEST 12.1: RES b, (IY+d) - Reset bit in memory with positive displacement =====
    ld a, 11111111b           ; A = FFh (11111111) - all bits are 1
    ld (res_iy_base+3), a     ; Store the test value at IY+3 offset
    ld iy, res_iy_base        ; IY points to our base address
    res 0, (iy+3)            ; Reset bit 0 in memory location (IY+3)
    
    ; Final memory state:
    ; Memory at res_iy_base+3 = FEh (11111110) - bit 0 is now 0
    ; No condition bits are affected
    
    ; ===== TEST 12.2: RES b, (IY+d) - Reset bit in memory with negative displacement =====
    ld a, 11111111b           ; A = FFh (11111111) - all bits are 1
    ld (res_iy_base-2), a     ; Store the test value at IY-2 offset
    res 7, (iy-2)            ; Reset bit 7 in memory location (IY-2)
    
    ; Final memory state:
    ; Memory at res_iy_base-2 = 7Fh (01111111) - bit 7 is now 0
    ; No condition bits are affected
    
    ; ===== TEST 12.3: RES b, (IY+d) with various bits =====
    ; Test with bit already reset
    ld a, 11110111b           ; A = F7h (11110111) - bit 3 is 0
    ld (res_iy_base+5), a     ; Store the test value at IY+5 offset
    res 3, (iy+5)            ; Reset bit 3 in memory location (IY+5) (should have no effect)
    ; Memory at IY+5 remains F7h (11110111)
    
    ; Test with multiple bits
    ld a, 11111111b           ; A = FFh (11111111) - all bits are 1
    ld (res_iy_base+7), a     ; Store the test value at IY+7 offset
    res 1, (iy+7)            ; Reset multiple bits in memory location (IY+7)
    res 3, (iy+7)
    res 5, (iy+7)
    res 7, (iy+7)
    ; Memory at IY+7 now contains 55h (01010101)
    
    ; ========= END TEST AREA =========
    
    jr $          ; Infinite loop

; Data section
bit_hl_data:    ; Data for BIT (HL) test
    db 0

bit_ix_base:    ; Base address for BIT (IX+d) test
    defs 10, 0   ; Reserve 10 bytes for IX tests

bit_iy_base:    ; Base address for BIT (IY+d) test
    defs 10, 0   ; Reserve 10 bytes for IY tests

set_hl_data:    ; Data for SET (HL) test
    db 0

set_ix_base:    ; Base address for SET (IX+d) test
    defs 10, 0   ; Reserve 10 bytes for IX tests

set_iy_base:    ; Base address for SET (IY+d) test
    defs 10, 0   ; Reserve 10 bytes for IY tests

res_hl_data:    ; Data for RES (HL) test
    db 0

res_ix_base:    ; Base address for RES (IX+d) test
    defs 10, 0   ; Reserve 10 bytes for IX tests

res_iy_base:    ; Base address for RES (IY+d) test
    defs 10, 0   ; Reserve 10 bytes for IY tests

stack_bottom:   ; 100 bytes of stack
    defs 100, 0
stack_top:
    END
