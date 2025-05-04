; Z80 Assembly - 8-Bit Arithmetic Group Instructions Testing
; This file contains tests for the Z80 8-Bit Arithmetic Group instructions:
;   1. ADD A, r - Add register to A
;   2. ADD A, n - Add immediate value to A
;   3. ADD A, (HL) - Add value at address in HL to A
;   4. ADD A, (IX+d) - Add value at address IX+d to A
;   5. ADD A, (IY+d) - Add value at address IY+d to A
;   6. ADC A, s - Add with carry
;   7. SUB s - Subtract from A
;   8. SBC A, s - Subtract with carry
;   9. AND s - Logical AND with A
;  10. OR s - Logical OR with A
;  11. XOR s - Logical XOR with A
;  12. CP s - Compare with A
;  13. INC r - Increment register
;  14. INC (HL) - Increment value at address in HL
;  15. INC (IX+d) - Increment value at address IX+d
;  16. INC (IY+d) - Increment value at address IY+d
;  17. DEC m - Decrement value

    DEVICE NOSLOT64K
    SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION

    org 0       ; Program starts at address 0 in memory

main:
    ld sp, stack_top  ; Initialize stack pointer
    
    ; ========= TEST 1: ADD A, r =========
    ; Operation: A ← A + r
    ; Description: The contents of register r are added to the contents of the Accumulator, and the result is
    ; stored in the Accumulator. The r symbol identifies the registers A, B, C, D, E, H, or L.
    
    ; Example from documentation:
    ; "If the Accumulator contains 44h and Register C contains 11h, then upon the execution of
    ; an ADD A, C instruction, the Accumulator contains 55h."
    
    ; Setup for our example
    ld a, 44h      ; A = 44h (68) as per the example
    ld c, 11h      ; C = 11h (17) as per the example
    add a, c       ; Add C to A and store in A
    
    ; Final register state:
    ; A = 55h (85) - result of adding 44h + 11h
    ; C = 11h (17) - unchanged
    ; Condition bits:
    ; - S is reset (result is positive)
    ; - Z is reset (result is not zero)
    ; - H is set (carry from bit 3: 4 + 1 = 5 with carry)
    ; - P/V is reset (no overflow)
    ; - N is reset
    ; - C is reset (no carry from bit 7)
    
    ; Test with other registers
    ld a, 10h      ; A = 10h
    ld b, 20h      ; B = 20h
    add a, b       ; A = A + B = 30h
    
    ld a, 0FFh     ; A = FFh (to test carry)
    ld d, 01h      ; D = 01h
    add a, d       ; A = A + D = 00h with carry
    
    ld a, 7Fh      ; A = 7Fh (to test overflow)
    ld e, 01h      ; E = 01h
    add a, e       ; A = A + E = 80h with overflow
    
    ld a, 88h      ; A = 88h (to test sign flag)
    ld h, 01h      ; H = 01h
    add a, h       ; A = A + H = 89h (negative result)
    
    ld a, 00h      ; A = 00h (to test zero flag)
    ld l, 00h      ; L = 00h
    add a, l       ; A = A + L = 00h (zero result)
    
    ; Testing ADD A, A
    ld a, 40h      ; A = 40h
    add a, a       ; A = A + A = 80h
    
    ; ========= TEST 2: ADD A, n =========
    ; Operation: A ← A + n
    ; Description: The n integer is added to the contents of the Accumulator, and the results are stored in the
    ; Accumulator.
    
    ; Example from documentation:
    ; "If the Accumulator contains 23h, then upon the execution of an ADD A, 33h instruction,
    ; the Accumulator contains 56h."
    
    ; Setup for our example
    ld a, 23h      ; A = 23h (35) as per the example
    add a, 33h     ; Add immediate value 33h (51) to A
    
    ; Final register state:
    ; A = 56h (86) - result of adding 23h + 33h
    ; Condition bits: 
    ; - S is reset (result is positive)
    ; - Z is reset (result is not zero)
    ; - H is set (carry from bit 3)
    ; - P/V is reset (no overflow)
    ; - N is reset
    ; - C is reset (no carry from bit 7)
    
    ; Additional tests with immediate values
    ld a, 0FFh     ; A = FFh (to test carry)
    add a, 01h     ; A = A + 01h = 00h with carry
    
    ld a, 7Fh      ; A = 7Fh (to test overflow)
    add a, 10h     ; A = A + 10h = 8Fh with overflow
    
    ld a, 0F0h     ; A = F0h (to test sign flag)
    add a, 20h     ; A = A + 20h = 10h (positive result with carry)
    
    ld a, 0FFh     ; A = FFh (to test zero flag)
    add a, 01h     ; A = A + 01h = 00h (zero result with carry)
    
    ; ========= TEST 3: ADD A, (HL) =========
    ; Operation: A ← A + (HL)
    ; Description: The byte at the memory address specified by the contents of the HL register pair is added
    ; to the contents of the Accumulator, and the result is stored in the Accumulator.
    
    ; Example from documentation:
    ; "If the Accumulator contains A0h, register pair HL contains 2323h, and memory location
    ; 2323h contains byte 08h, then upon the execution of an ADD A, (HL) instruction, the
    ; Accumulator contains A8h."
    
    ; Setup for our example
    ld a, 08h                 ; Set up test data
    ld (hl_data), a           ; Store 08h at our test memory location
    ld a, 0A0h                ; A = A0h (160) as per the example
    ld hl, hl_data            ; HL points to our test data (like 2323h in example)
    add a, (hl)               ; Add the byte at (HL) to A
    
    ; Final state:
    ; A = A8h (168) - result of adding A0h + 08h
    ; HL = address of hl_data (unchanged)
    ; Condition bits:
    ; - S is set (result is negative)
    ; - Z is reset (result is not zero)
    ; - H is reset (no carry from bit 3)
    ; - P/V is reset (no overflow)
    ; - N is reset
    ; - C is reset (no carry from bit 7)
    
    ; Additional tests with memory values
    ld a, 0FFh                ; Set up test data for carry test
    ld (hl_data), a
    ld a, 01h
    ld hl, hl_data
    add a, (hl)               ; A = 01h + FFh = 00h with carry
    
    ld a, 7Fh                 ; Set up test data for overflow test
    ld (hl_data), a
    ld hl, hl_data
    add a, (hl)               ; A = 7Fh + 7Fh = FEh with overflow
    
    ; ========= TEST 4: ADD A, (IX+d) =========
    ; Operation: A ← A + (IX+d)
    ; Description: The contents of the Index (register pair IX) Register is added to a two's complement dis-
    ; placement d to point to an address in memory. The contents of this address is then added to
    ; the contents of the Accumulator and the result is stored in the Accumulator.
    
    ; Example from documentation:
    ; "If the Accumulator contains 11h, Index Register IX contains 1000h, and memory location
    ; 1005h contains 22h, then upon the execution of an ADD A, (IX + 5h) instruction, the
    ; Accumulator contains 33h."
    
    ; Setup for our example
    ld a, 22h                  ; Set up test data
    ld (ix_base+5), a          ; Store 22h at ix_base+5
    ld a, 11h                  ; A = 11h (17) as per the example
    ld ix, ix_base             ; IX points to our base address (like 1000h in example)
    add a, (ix+5)              ; Add the byte at (IX+5) to A
    
    ; Final state:
    ; A = 33h (51) - result of adding 11h + 22h
    ; IX = ix_base (unchanged)
    ; Condition bits:
    ; - S is reset (result is positive)
    ; - Z is reset (result is not zero)
    ; - H is reset (no carry from bit 3)
    ; - P/V is reset (no overflow)
    ; - N is reset
    ; - C is reset (no carry from bit 7)
    
    ; Additional tests with indexed addressing
    ld a, 0FFh                 ; Set up test data for carry test
    ld (ix_base+10), a
    ld a, 01h
    add a, (ix+10)             ; A = 01h + FFh = 00h with carry
    
    ld a, 40h                  ; Set up test data for overflow test
    ld (ix_base-5), a          ; Test with negative offset
    ld a, 40h
    add a, (ix-5)              ; A = 40h + 40h = 80h with overflow
    
    ; ========= TEST 5: ADD A, (IY+d) =========
    ; Operation: A ← A + (IY+d)
    ; Description: The contents of the Index (register pair IY) Register is added to a two's complement dis-
    ; placement d to point to an address in memory. The contents of this address is then added to
    ; the contents of the Accumulator, and the result is stored in the Accumulator.
    
    ; Example from documentation:
    ; "If the Accumulator contains 11h, Index Register IY contains 1000h, and memory location
    ; 1005h contains 22h, then upon the execution of an ADD A, (IY + 5h) instruction, the
    ; Accumulator contains 33h."
    
    ; Setup for our example
    ld a, 22h                  ; Set up test data
    ld (iy_base+5), a          ; Store 22h at iy_base+5
    ld a, 11h                  ; A = 11h (17) as per the example
    ld iy, iy_base             ; IY points to our base address (like 1000h in example)
    add a, (iy+5)              ; Add the byte at (IY+5) to A
    
    ; Final state:
    ; A = 33h (51) - result of adding 11h + 22h
    ; IY = iy_base (unchanged)
    ; Condition bits:
    ; - S is reset (result is positive)
    ; - Z is reset (result is not zero)
    ; - H is reset (no carry from bit 3)
    ; - P/V is reset (no overflow)
    ; - N is reset
    ; - C is reset (no carry from bit 7)
    
    ; Additional tests with indexed addressing
    ld a, 0FFh                 ; Set up test data for carry test
    ld (iy_base+10), a
    ld a, 01h
    add a, (iy+10)             ; A = 01h + FFh = 00h with carry
    
    ld a, 40h                  ; Set up test data for overflow test
    ld (iy_base-5), a          ; Test with negative offset
    ld a, 40h
    add a, (iy-5)              ; A = 40h + 40h = 80h with overflow
    
    ; ========= TEST 6: ADC A, s =========
    ; Operation: A ← A + s + CY
    ; Description: The s operand, along with the Carry Flag (C in the F Register) is added to the contents of
    ; the Accumulator, and the result is stored in the Accumulator.
    ; The s operand can be any of: r, n, (HL), (IX+d), or (IY+d)
    
    ; Example from documentation:
    ; "If the Accumulator contents are 16h, the Carry Flag is set, the HL register pair contains
    ; 6666h, and address 6666h contains 10h, then upon the execution of an ADC A, (HL)
    ; instruction, the Accumulator contains 27h"
    
    ; ===== TEST 6.1: ADC A, r =====
    ; Test ADC A, r with various registers
    
    ; With carry reset
    scf             ; Set carry flag
    ccf             ; Complement carry flag (reset it)
    ld a, 23h       ; A = 23h
    ld b, 45h       ; B = 45h
    adc a, b        ; A = 23h + 45h + 0 = 68h
    
    ; With carry set
    scf             ; Set carry flag
    ld a, 23h       ; A = 23h
    ld c, 45h       ; C = 45h
    adc a, c        ; A = 23h + 45h + 1 = 69h
    
    ; Test with carry propagation
    scf             ; Set carry flag
    ld a, 0FFh      ; A = FFh (255)
    ld d, 00h       ; D = 00h
    adc a, d        ; A = FFh + 00h + 1 = 00h with carry
    
    ; Test with zero result
    scf             ; Set carry flag
    ld a, 0FEh      ; A = FEh (254)
    ld e, 01h       ; E = 01h
    adc a, e        ; A = FEh + 01h + 1 = 00h with carry and zero flag
    
    ; Test with overflow
    scf             ; Set carry flag
    ld a, 7Fh       ; A = 7Fh (127, largest positive 8-bit signed number)
    ld h, 00h       ; H = 00h
    adc a, h        ; A = 7Fh + 00h + 1 = 80h (-128 in two's complement) with overflow
    
    ; Test with ADC A, A
    scf             ; Set carry flag
    ld a, 80h       ; A = 80h
    adc a, a        ; A = 80h + 80h + 1 = 01h with carry
    
    ; ===== TEST 6.2: ADC A, n =====
    ; Test with immediate value
    
    ; Example with carry flag reset
    scf             ; Set carry flag
    ccf             ; Complement carry flag (reset it)
    ld a, 16h       ; A = 16h (22)
    adc a, 10h      ; A = 16h + 10h + 0 = 26h
    
    ; Example with carry flag set
    scf             ; Set carry flag
    ld a, 16h       ; A = 16h (22)
    adc a, 10h      ; A = 16h + 10h + 1 = 27h
    
    ; Test with carry propagation
    scf             ; Set carry flag
    ld a, 0FFh      ; A = FFh (255)
    adc a, 0FFh     ; A = FFh + FFh + 1 = FFh with carry
    
    ; Test with zero result
    ld a, 0FFh      ; A = FFh (255)
    scf             ; Set carry flag
    adc a, 00h      ; A = FFh + 00h + 1 = 00h with carry and zero flag
    
    ; ===== TEST 6.3: ADC A, (HL) =====
    ; This matches the example in the documentation
    ; "If the Accumulator contents are 16h, the Carry Flag is set, the HL register pair contains
    ; 6666h, and address 6666h contains 10h, then upon the execution of an ADC A, (HL)
    ; instruction, the Accumulator contains 27h"
    
    ; Setup for our example
    ld a, 10h                  ; Set up test data
    ld (adc_hl_data), a        ; Store 10h at our test memory location
    scf                        ; Set carry flag
    ld a, 16h                  ; A = 16h (22) as per the example
    ld hl, adc_hl_data         ; HL points to our test data (like 6666h in example)
    adc a, (hl)                ; Add with carry the byte at (HL) to A: A = 16h + 10h + 1 = 27h
    
    ; Test with carry propagation
    ld a, 0FFh                 ; Set up test data for carry test
    ld (adc_hl_data), a        ; Store FFh at memory location
    ld a, 00h                  ; A = 00h
    scf                        ; Set carry flag
    ld hl, adc_hl_data         ; HL points to our data
    adc a, (hl)                ; A = 00h + FFh + 1 = 00h with carry
    
    ; ===== TEST 6.4: ADC A, (IX+d) =====
    ; Similar to the ADC A, (HL) test but using IX+d addressing
    
    ; Setup for our example
    ld a, 10h                  ; Set up test data
    ld (adc_ix_base+5), a      ; Store 10h at adc_ix_base+5
    scf                        ; Set carry flag
    ld a, 16h                  ; A = 16h (22)
    ld ix, adc_ix_base         ; IX points to our base address
    adc a, (ix+5)              ; Add with carry: A = 16h + 10h + 1 = 27h
    
    ; Test with negative displacement
    ld a, 0FFh                 ; Set up test data
    ld (adc_ix_base-3), a      ; Store FFh at adc_ix_base-3
    ld a, 00h                  ; A = 00h
    scf                        ; Set carry flag
    adc a, (ix-3)              ; A = 00h + FFh + 1 = 00h with carry
    
    ; ===== TEST 6.5: ADC A, (IY+d) =====
    ; Similar to the ADC A, (IX+d) test but using IY+d addressing
    
    ; Setup for our example
    ld a, 10h                  ; Set up test data
    ld (adc_iy_base+5), a      ; Store 10h at adc_iy_base+5
    scf                        ; Set carry flag
    ld a, 16h                  ; A = 16h (22)
    ld iy, adc_iy_base         ; IY points to our base address
    adc a, (iy+5)              ; Add with carry: A = 16h + 10h + 1 = 27h
    
    ; Test with negative displacement
    ld a, 0FFh                 ; Set up test data
    ld (adc_iy_base-3), a      ; Store FFh at adc_iy_base-3
    ld a, 00h                  ; A = 00h
    scf                        ; Set carry flag
    adc a, (iy-3)              ; A = 00h + FFh + 1 = 00h with carry
    
    ; ========= TEST 7: SUB s =========
    ; Operation: A ← A - s
    ; Description: The s operand is subtracted from the contents of the Accumulator, and the result is stored
    ; in the Accumulator.
    ; The s operand can be any of: r, n, (HL), (IX+d), or (IY+d)
    
    ; Example from documentation:
    ; "If the Accumulator contents are 29h, and the D Register contains 11h, then upon the exe-
    ; cution of a SUB D instruction, the Accumulator contains 18h."
    
    ; ===== TEST 7.1: SUB r =====
    ; Test SUB r with various registers
    
    ; Example from documentation
    ld a, 29h       ; A = 29h (41) as per the example
    ld d, 11h       ; D = 11h (17) as per the example
    sub d           ; A = 29h - 11h = 18h
    
    ; Final register state:
    ; A = 18h (24) - result of subtracting 29h - 11h
    ; D = 11h (17) - unchanged
    ; Condition bits:
    ; - S is reset (result is positive)
    ; - Z is reset (result is not zero)
    ; - H is reset (no borrow from bit 4)
    ; - P/V is reset (no overflow)
    ; - N is set (subtraction performed)
    ; - C is reset (no borrow needed)
    
    ; Test with other registers
    ld a, 50h       ; A = 50h (80)
    ld b, 20h       ; B = 20h (32)
    sub b           ; A = 50h - 20h = 30h (48)
    
    ld a, 10h       ; A = 10h (16) (to test borrow/carry)
    ld c, 20h       ; C = 20h (32)
    sub c           ; A = 10h - 20h = F0h (-16) with borrow/carry
    
    ld a, 80h       ; A = 80h (128) (to test overflow)
    ld e, 01h       ; E = 01h (1)
    sub e           ; A = 80h - 01h = 7Fh (127) with overflow
    
    ld a, 01h       ; A = 01h (1) (to test sign flag)
    ld h, 02h       ; H = 02h (2)
    sub h           ; A = 01h - 02h = FFh (-1) (negative result)
    
    ld a, 05h       ; A = 05h (5) (to test zero flag)
    ld l, 05h       ; L = 05h (5)
    sub l           ; A = 05h - 05h = 00h (0) (zero result)
    
    ; Testing SUB A (subtract A from itself)
    ld a, 40h       ; A = 40h (64)
    sub a           ; A = 40h - 40h = 00h (0) (zero result)
    
    ; ===== TEST 7.2: SUB n =====
    ; Test with immediate value
    
    ld a, 29h       ; A = 29h (41)
    sub 11h         ; A = 29h - 11h = 18h (24)
    
    ; Test with borrow/carry
    ld a, 10h       ; A = 10h (16)
    sub 20h         ; A = 10h - 20h = F0h (-16) with borrow/carry
    
    ; Test with overflow
    ld a, 80h       ; A = 80h (128) (most negative value)
    sub 01h         ; A = 80h - 01h = 7Fh (127) (most positive value) with overflow
    
    ; Test with zero result
    ld a, 55h       ; A = 55h (85)
    sub 55h         ; A = 55h - 55h = 00h (0) (zero result)
    
    ; ===== TEST 7.3: SUB (HL) =====
    ; Test with memory operand
    
    ; Setup for our example
    ld a, 11h                 ; Set up test data
    ld (sub_hl_data), a       ; Store 11h at our test memory location
    ld a, 29h                 ; A = 29h (41)
    ld hl, sub_hl_data        ; HL points to our test data
    sub (hl)                  ; Subtract the byte at (HL) from A: A = 29h - 11h = 18h
    
    ; Test with borrow/carry
    ld a, 20h                 ; Set up new test data
    ld (sub_hl_data), a       ; Store 20h at our test memory location
    ld a, 10h                 ; A = 10h (16)
    ld hl, sub_hl_data        ; HL points to our test data
    sub (hl)                  ; A = 10h - 20h = F0h (-16) with borrow/carry
    
    ; Test with overflow
    ld a, 01h                 ; Set up new test data
    ld (sub_hl_data), a       ; Store 01h at our test memory location
    ld a, 80h                 ; A = 80h (128) (most negative value)
    ld hl, sub_hl_data        ; HL points to our test data
    sub (hl)                  ; A = 80h - 01h = 7Fh (127) (most positive value) with overflow
    
    ; ===== TEST 7.4: SUB (IX+d) =====
    ; Test with indexed addressing
    
    ; Setup for our example
    ld a, 11h                 ; Set up test data
    ld (sub_ix_base+5), a     ; Store 11h at sub_ix_base+5
    ld a, 29h                 ; A = 29h (41)
    ld ix, sub_ix_base        ; IX points to our base address
    sub (ix+5)                ; Subtract the byte at (IX+5) from A: A = 29h - 11h = 18h
    
    ; Test with negative displacement
    ld a, 20h                 ; Set up test data
    ld (sub_ix_base-3), a     ; Store 20h at sub_ix_base-3
    ld a, 10h                 ; A = 10h (16)
    sub (ix-3)                ; A = 10h - 20h = F0h (-16) with borrow/carry
    
    ; ===== TEST 7.5: SUB (IY+d) =====
    ; Test with indexed addressing
    
    ; Setup for our example
    ld a, 11h                 ; Set up test data
    ld (sub_iy_base+5), a     ; Store 11h at sub_iy_base+5
    ld a, 29h                 ; A = 29h (41)
    ld iy, sub_iy_base        ; IY points to our base address
    sub (iy+5)                ; Subtract the byte at (IY+5) from A: A = 29h - 11h = 18h
    
    ; Test with negative displacement
    ld a, 20h                 ; Set up test data
    ld (sub_iy_base-3), a     ; Store 20h at sub_iy_base-3
    ld a, 10h                 ; A = 10h (16)
    sub (iy-3)                ; A = 10h - 20h = F0h (-16) with borrow/carry
    
    ; ========= TEST 8: SBC A, s =========
    ; Operation: A ← A - s - CY
    ; Description: The s operand, along with the Carry flag (C in the F Register) is subtracted from the con-
    ; tents of the Accumulator, and the result is stored in the Accumulator.
    ; The s operand can be any of: r, n, (HL), (IX+d), or (IY+d)
    
    ; Example from documentation:
    ; "If the Accumulator contains 16h, the carry flag is set, the HL register pair contains 3433h,
    ; and address 3433h contains 05h, then upon the execution of an SBC A, (HL) instruction,
    ; the Accumulator contains 10h."
    
    ; ===== TEST 8.1: SBC A, r =====
    ; Test SBC A, r with various registers
    
    ; With carry reset
    scf             ; Set carry flag
    ccf             ; Complement carry flag (reset it)
    ld a, 25h       ; A = 25h (37)
    ld b, 15h       ; B = 15h (21)
    sbc a, b        ; A = 25h - 15h - 0 = 10h (16)
    
    ; With carry set
    scf             ; Set carry flag
    ld a, 25h       ; A = 25h (37)
    ld c, 14h       ; C = 14h (20)
    sbc a, c        ; A = 25h - 14h - 1 = 10h (16)
    
    ; Test with borrow propagation
    scf             ; Set carry flag
    ld a, 00h       ; A = 00h (0)
    ld d, 00h       ; D = 00h (0)
    sbc a, d        ; A = 00h - 00h - 1 = FFh (-1) with borrow
    
    ; Test with zero result
    scf             ; Set carry flag
    ld a, 11h       ; A = 11h (17)
    ld e, 10h       ; E = 10h (16)
    sbc a, e        ; A = 11h - 10h - 1 = 00h (0) with zero flag
    
    ; Test with overflow
    scf             ; Set carry flag
    ld a, 80h       ; A = 80h (-128, smallest negative 8-bit signed number)
    ld h, 7Fh       ; H = 7Fh (127)
    sbc a, h        ; A = 80h - 7Fh - 1 = 00h (0) (no overflow)
    
    ; Test with SBC A, A
    scf             ; Set carry flag
    ld a, 10h       ; A = 10h (16)
    sbc a, a        ; A = 10h - 10h - 1 = FFh (-1) with borrow
    
    ; ===== TEST 8.2: SBC A, n =====
    ; Test with immediate value
    
    ; Example with carry flag reset
    scf             ; Set carry flag
    ccf             ; Complement carry flag (reset it)
    ld a, 20h       ; A = 20h (32)
    sbc a, 10h      ; A = 20h - 10h - 0 = 10h (16)
    
    ; Example with carry flag set
    scf             ; Set carry flag
    ld a, 21h       ; A = 21h (33)
    sbc a, 10h      ; A = 21h - 10h - 1 = 10h (16)
    
    ; Test with borrow propagation
    scf             ; Set carry flag
    ld a, 00h       ; A = 00h (0)
    sbc a, 01h      ; A = 00h - 01h - 1 = FEh (-2) with borrow
    
    ; Test with zero result
    scf             ; Set carry flag
    ld a, 11h       ; A = 11h (17)
    sbc a, 10h      ; A = 11h - 10h - 1 = 00h (0) with zero flag
    
    ; ===== TEST 8.3: SBC A, (HL) =====
    ; This matches the example in the documentation
    ; "If the Accumulator contains 16h, the carry flag is set, the HL register pair contains 3433h,
    ; and address 3433h contains 05h, then upon the execution of an SBC A, (HL) instruction,
    ; the Accumulator contains 10h."
    
    ; Setup for our example
    ld a, 05h                  ; Set up test data
    ld (sbc_hl_data), a        ; Store 05h at our test memory location
    scf                        ; Set carry flag
    ld a, 16h                  ; A = 16h (22) as per the example
    ld hl, sbc_hl_data         ; HL points to our test data (like 3433h in example)
    sbc a, (hl)                ; Subtract with carry: A = 16h - 05h - 1 = 10h
    
    ; Test with borrow propagation
    ld a, 00h                  ; Set up test data for borrow test
    ld (sbc_hl_data), a        ; Store 00h at memory location
    ld a, 00h                  ; A = 00h
    scf                        ; Set carry flag
    ld hl, sbc_hl_data         ; HL points to our data
    sbc a, (hl)                ; A = 00h - 00h - 1 = FFh with borrow
    
    ; ===== TEST 8.4: SBC A, (IX+d) =====
    ; Similar to the SBC A, (HL) test but using IX+d addressing
    
    ; Setup for our example
    ld a, 05h                  ; Set up test data
    ld (sbc_ix_base+5), a      ; Store 05h at sbc_ix_base+5
    scf                        ; Set carry flag
    ld a, 16h                  ; A = 16h (22)
    ld ix, sbc_ix_base         ; IX points to our base address
    sbc a, (ix+5)              ; Subtract with carry: A = 16h - 05h - 1 = 10h
    
    ; Test with negative displacement
    ld a, 10h                  ; Set up test data
    ld (sbc_ix_base-3), a      ; Store 10h at sbc_ix_base-3
    scf                        ; Set carry flag
    ld a, 21h                  ; A = 21h (33)
    sbc a, (ix-3)              ; A = 21h - 10h - 1 = 10h
    
    ; ===== TEST 8.5: SBC A, (IY+d) =====
    ; Similar to the SBC A, (IX+d) test but using IY+d addressing
    
    ; Setup for our example
    ld a, 05h                  ; Set up test data
    ld (sbc_iy_base+5), a      ; Store 05h at sbc_iy_base+5
    scf                        ; Set carry flag
    ld a, 16h                  ; A = 16h (22)
    ld iy, sbc_iy_base         ; IY points to our base address
    sbc a, (iy+5)              ; Subtract with carry: A = 16h - 05h - 1 = 10h
    
    ; Test with negative displacement
    ld a, 10h                  ; Set up test data
    ld (sbc_iy_base-3), a      ; Store 10h at sbc_iy_base-3
    ld a, 21h                  ; A = 21h (33)
    scf                        ; Set carry flag
    sbc a, (iy-3)              ; A = 21h - 10h - 1 = 10h
    
    ; ========= TEST 9: AND s =========
    ; Operation: A ← A ∧ s
    ; Description: A logical AND operation is performed between the byte specified by the s operand and the
    ; byte contained in the Accumulator; the result is stored in the Accumulator.
    ; The s operand can be any of: r, n, (HL), (IX+d), or (IY+d)
    
    ; Example from documentation:
    ; "If Register B contains 7Bh (0111 1011) and the Accumulator contains C3h (1100 0011),
    ; then upon the execution of an AND B instruction, the Accumulator contains 43h (0100
    ; 0011)."
    
    ; ===== TEST 9.1: AND r =====
    ; Test AND r with various registers
    
    ; Example from documentation
    ld a, 0C3h      ; A = C3h (1100 0011) as per the example
    ld b, 7Bh       ; B = 7Bh (0111 1011) as per the example
    and b           ; A = A AND B = 43h (0100 0011)
    
    ; Final register state:
    ; A = 43h (0100 0011) - result of C3h AND 7Bh
    ; B = 7Bh (0111 1011) - unchanged
    ; Condition bits:
    ; - S is reset (result is positive)
    ; - Z is reset (result is not zero)
    ; - H is set (always set by AND)
    ; - P/V is reset (no parity)
    ; - N is reset
    ; - C is reset
    
    ; Test with other registers
    ld a, 0FFh      ; A = FFh (1111 1111)
    ld c, 55h       ; C = 55h (0101 0101)
    and c           ; A = FFh AND 55h = 55h (0101 0101)
    
    ld a, 0AAh      ; A = AAh (1010 1010)
    ld d, 55h       ; D = 55h (0101 0101)
    and d           ; A = AAh AND 55h = 00h (zero result)
    
    ld a, 80h       ; A = 80h (1000 0000) (to test sign flag)
    ld e, 80h       ; E = 80h (1000 0000)
    and e           ; A = 80h AND 80h = 80h (negative result)
    
    ld a, 0F0h      ; A = F0h (1111 0000)
    ld h, 0Fh       ; H = 0Fh (0000 1111)
    and h           ; A = F0h AND 0Fh = 00h (zero result)
    
    ; Test with AND A (AND with itself)
    ld a, 0AAh      ; A = AAh (1010 1010)
    and a           ; A = AAh AND AAh = AAh (unchanged)
    
    ; ===== TEST 9.2: AND n =====
    ; Test with immediate value
    
    ld a, 0C3h      ; A = C3h (1100 0011)
    and 7Bh         ; A = C3h AND 7Bh = 43h (0100 0011)
    
    ; Test with zero result
    ld a, 0AAh      ; A = AAh (1010 1010)
    and 55h         ; A = AAh AND 55h = 00h (0000 0000)
    
    ; Test with sign flag
    ld a, 0FFh      ; A = FFh (1111 1111)
    and 80h         ; A = FFh AND 80h = 80h (1000 0000) (negative result)
    
    ; ===== TEST 9.3: AND (HL) =====
    ; Test with memory operand
    
    ; Setup for our example
    ld a, 7Bh                 ; Set up test data
    ld (and_hl_data), a       ; Store 7Bh at our test memory location
    ld a, 0C3h                ; A = C3h (1100 0011)
    ld hl, and_hl_data        ; HL points to our test data
    and (hl)                  ; A = C3h AND 7Bh = 43h (0100 0011)
    
    ; Test with zero result
    ld a, 0AAh                ; A = AAh (1010 1010)
    ld (and_hl_data), a       ; Store AAh at our test memory location
    ld a, 55h                 ; A = 55h (0101 0101)
    ld hl, and_hl_data        ; HL points to our test data
    and (hl)                  ; A = 55h AND AAh = 00h (0000 0000)
    
    ; ===== TEST 9.4: AND (IX+d) =====
    ; Test with indexed addressing
    
    ; Setup for our example
    ld a, 7Bh                 ; Set up test data
    ld (and_ix_base+5), a     ; Store 7Bh at and_ix_base+5
    ld a, 0C3h                ; A = C3h (1100 0011)
    ld ix, and_ix_base        ; IX points to our base address
    and (ix+5)                ; A = C3h AND 7Bh = 43h (0100 0011)
    
    ; Test with negative displacement
    ld a, 0Fh                 ; Set up test data
    ld (and_ix_base-3), a     ; Store 0Fh at and_ix_base-3
    ld a, 0F0h                ; A = F0h (1111 0000)
    and (ix-3)                ; A = F0h AND 0Fh = 00h (0000 0000)
    
    ; ===== TEST 9.5: AND (IY+d) =====
    ; Test with indexed addressing
    
    ; Setup for our example
    ld a, 7Bh                 ; Set up test data
    ld (and_iy_base+5), a     ; Store 7Bh at and_iy_base+5
    ld a, 0C3h                ; A = C3h (1100 0011)
    ld iy, and_iy_base        ; IY points to our base address
    and (iy+5)                ; A = C3h AND 7Bh = 43h (0100 0011)
    
    ; Test with negative displacement
    ld a, 0Fh                 ; Set up test data
    ld (and_iy_base-3), a     ; Store 0Fh at and_iy_base-3
    ld a, 0F0h                ; A = F0h (1111 0000)
    and (iy-3)                ; A = F0h AND 0Fh = 00h (0000 0000)
    
    ; ========= TEST 10: OR s =========
    ; Operation: A ← A ∨ s
    ; Description: A logical OR operation is performed between the byte specified by the s operand and the
    ; byte contained in the Accumulator; the result is stored in the Accumulator.
    ; The s operand can be any of: r, n, (HL), (IX+d), or (IY+d)
    
    ; Example from documentation:
    ; "If the H Register contains 48h (0100 0100), and the Accumulator contains 12h (0001
    ; 0010), then upon the execution of an OR H instruction, the Accumulator contains 5Ah
    ; (0101 1010)."
    
    ; ===== TEST 10.1: OR r =====
    ; Test OR r with various registers
    
    ; Example from documentation
    ld a, 12h       ; A = 12h (0001 0010) as per the example
    ld h, 48h       ; H = 48h (0100 0100) as per the example
    or h            ; A = A OR H = 5Ah (0101 1010)
    
    ; Final register state:
    ; A = 5Ah (0101 1010) - result of 12h OR 48h
    ; H = 48h (0100 0100) - unchanged
    ; Condition bits:
    ; - S is reset (result is positive)
    ; - Z is reset (result is not zero)
    ; - H is reset (always reset by OR)
    ; - P/V is set (parity is even)
    ; - N is reset
    ; - C is reset
    
    ; Test with other registers
    ld a, 00h       ; A = 00h (0000 0000)
    ld b, 00h       ; B = 00h (0000 0000)
    or b            ; A = 00h OR 00h = 00h (zero result)
    
    ld a, 80h       ; A = 80h (1000 0000)
    ld c, 01h       ; C = 01h (0000 0001)
    or c            ; A = 80h OR 01h = 81h (negative result)
    
    ld a, 0AAh      ; A = AAh (1010 1010)
    ld d, 55h       ; D = 55h (0101 0101)
    or d            ; A = AAh OR 55h = FFh (1111 1111)
    
    ; Test with OR A (OR with itself)
    ld a, 0AAh      ; A = AAh (1010 1010)
    or a            ; A = AAh OR AAh = AAh (unchanged)
    
    ; ===== TEST 10.2: OR n =====
    ; Test with immediate value
    
    ld a, 12h       ; A = 12h (0001 0010)
    or 48h          ; A = 12h OR 48h = 5Ah (0101 1010)
    
    ; Test with zero result
    ld a, 00h       ; A = 00h (0000 0000)
    or 00h          ; A = 00h OR 00h = 00h (0000 0000)
    
    ; Test with sign flag
    ld a, 00h       ; A = 00h (0000 0000)
    or 80h          ; A = 00h OR 80h = 80h (1000 0000) (negative result)
    
    ; ===== TEST 10.3: OR (HL) =====
    ; Test with memory operand
    
    ; Setup for our example
    ld a, 48h                 ; Set up test data
    ld (or_hl_data), a        ; Store 48h at our test memory location
    ld a, 12h                 ; A = 12h (0001 0010)
    ld hl, or_hl_data         ; HL points to our test data
    or (hl)                   ; A = 12h OR 48h = 5Ah (0101 1010)
    
    ; Test with complete coverage (all bits)
    ld a, 55h                 ; A = 55h (0101 0101)
    ld (or_hl_data), a        ; Store 55h at our test memory location
    ld a, 0AAh                ; A = AAh (1010 1010)
    ld hl, or_hl_data         ; HL points to our test data
    or (hl)                   ; A = AAh OR 55h = FFh (1111 1111)
    
    ; ===== TEST 10.4: OR (IX+d) =====
    ; Test with indexed addressing
    
    ; Setup for our example
    ld a, 48h                 ; Set up test data
    ld (or_ix_base+5), a      ; Store 48h at or_ix_base+5
    ld a, 12h                 ; A = 12h (0001 0010)
    ld ix, or_ix_base         ; IX points to our base address
    or (ix+5)                 ; A = 12h OR 48h = 5Ah (0101 1010)
    
    ; Test with negative displacement
    ld a, 55h                 ; Set up test data
    ld (or_ix_base-3), a      ; Store 55h at or_ix_base-3
    ld a, 0AAh                ; A = AAh (1010 1010)
    or (ix-3)                 ; A = AAh OR 55h = FFh (1111 1111)
    
    ; ===== TEST 10.5: OR (IY+d) =====
    ; Test with indexed addressing
    
    ; Setup for our example
    ld a, 48h                 ; Set up test data
    ld (or_iy_base+5), a      ; Store 48h at or_iy_base+5
    ld a, 12h                 ; A = 12h (0001 0010)
    ld iy, or_iy_base         ; IY points to our base address
    or (iy+5)                 ; A = 12h OR 48h = 5Ah (0101 1010)
    
    ; Test with negative displacement
    ld a, 55h                 ; Set up test data
    ld (or_iy_base-3), a      ; Store 55h at or_iy_base-3
    ld a, 0AAh                ; A = AAh (1010 1010)
    or (iy-3)                 ; A = AAh OR 55h = FFh (1111 1111)
    
    ; ========= TEST 11: XOR s =========
    ; Operation: A ← A ⊕ s
    ; Description: The logical exclusive-OR operation is performed between the byte specified by the s oper-
    ; and and the byte contained in the Accumulator; the result is stored in the Accumulator.
    ; The s operand can be any of: r, n, (HL), (IX+d), or (IY+d)
    
    ; Example from documentation:
    ; "If the Accumulator contains 96h (1001 0110), then upon the execution of an XOR 5Dh
    ; (5Dh = 0101 1101) instruction, the Accumulator contains CBh (1100 1011)."
    
    ; ===== TEST 11.1: XOR r =====
    ; Test XOR r with various registers
    
    ; Setup for our example
    ld a, 96h       ; A = 96h (1001 0110) as per the example
    ld b, 5Dh       ; B = 5Dh (0101 1101) as per the example
    xor b           ; A = A XOR B = CBh (1100 1011)
    
    ; Final register state:
    ; A = CBh (1100 1011) - result of 96h XOR 5Dh
    ; B = 5Dh (0101 1101) - unchanged
    ; Condition bits:
    ; - S is set (result is negative)
    ; - Z is reset (result is not zero)
    ; - H is reset (always reset by XOR)
    ; - P/V is set (parity is even)
    ; - N is reset
    ; - C is reset
    
    ; Test with other registers
    ld a, 0FFh      ; A = FFh (1111 1111)
    ld c, 0FFh      ; C = FFh (1111 1111)
    xor c           ; A = FFh XOR FFh = 00h (zero result)
    
    ld a, 0AAh      ; A = AAh (1010 1010)
    ld d, 55h       ; D = 55h (0101 0101)
    xor d           ; A = AAh XOR 55h = FFh (1111 1111)
    
    ld a, 0F0h      ; A = F0h (1111 0000)
    ld e, 70h       ; E = 70h (0111 0000)
    xor e           ; A = F0h XOR 70h = 80h (1000 0000) (negative result)
    
    ; Test with XOR A (XOR with itself)
    ld a, 0AAh      ; A = AAh (1010 1010)
    xor a           ; A = AAh XOR AAh = 00h (always gives zero)
    
    ; ===== TEST 11.2: XOR n =====
    ; Test with immediate value
    
    ; Example from documentation
    ld a, 96h       ; A = 96h (1001 0110)
    xor 5Dh         ; A = 96h XOR 5Dh = CBh (1100 1011)
    
    ; Test with zero result
    ld a, 0AAh      ; A = AAh (1010 1010)
    xor 0AAh        ; A = AAh XOR AAh = 00h (0000 0000)
    
    ; Test with complete coverage (all bits)
    ld a, 55h       ; A = 55h (0101 0101)
    xor 0AAh        ; A = 55h XOR AAh = FFh (1111 1111) (negative result)
    
    ; ===== TEST 11.3: XOR (HL) =====
    ; Test with memory operand
    
    ; Setup for our example
    ld a, 5Dh                 ; Set up test data
    ld (xor_hl_data), a       ; Store 5Dh at our test memory location
    ld a, 96h                 ; A = 96h (1001 0110)
    ld hl, xor_hl_data        ; HL points to our test data
    xor (hl)                  ; A = 96h XOR 5Dh = CBh (1100 1011)
    
    ; Test with self-cancellation
    ld a, 0AAh                ; A = AAh (1010 1010)
    ld (xor_hl_data), a       ; Store AAh at our test memory location
    ld hl, xor_hl_data        ; HL points to our test data
    xor (hl)                  ; A = AAh XOR AAh = 00h (0000 0000)
    
    ; ===== TEST 11.4: XOR (IX+d) =====
    ; Test with indexed addressing
    
    ; Setup for our example
    ld a, 5Dh                 ; Set up test data
    ld (xor_ix_base+5), a     ; Store 5Dh at xor_ix_base+5
    ld a, 96h                 ; A = 96h (1001 0110)
    ld ix, xor_ix_base        ; IX points to our base address
    xor (ix+5)                ; A = 96h XOR 5Dh = CBh (1100 1011)
    
    ; Test with negative displacement
    ld a, 55h                 ; Set up test data
    ld (xor_ix_base-3), a     ; Store 55h at xor_ix_base-3
    ld a, 0AAh                ; A = AAh (1010 1010)
    xor (ix-3)                ; A = AAh XOR 55h = FFh (1111 1111)
    
    ; ===== TEST 11.5: XOR (IY+d) =====
    ; Test with indexed addressing
    
    ; Setup for our example
    ld a, 5Dh                 ; Set up test data
    ld (xor_iy_base+5), a     ; Store 5Dh at xor_iy_base+5
    ld a, 96h                 ; A = 96h (1001 0110)
    ld iy, xor_iy_base        ; IY points to our base address
    xor (iy+5)                ; A = 96h XOR 5Dh = CBh (1100 1011)
    
    ; Test with negative displacement
    ld a, 55h                 ; Set up test data
    ld (xor_iy_base-3), a     ; Store 55h at xor_iy_base-3
    ld a, 0AAh                ; A = AAh (1010 1010)
    xor (iy-3)                ; A = AAh XOR 55h = FFh (1111 1111)
    
    ; ========= TEST 12: CP s =========
    ; Operation: A - s (compare only, A is not modified)
    ; Description: The contents of the s operand are compared with the contents of the Accumulator. If there
    ; is a true compare, the Z flag is set. The execution of this instruction does not affect the
    ; contents of the Accumulator.
    ; The s operand can be any of: r, n, (HL), (IX+d), or (IY+d)
    
    ; Example from documentation:
    ; "If the Accumulator contains 63h, the HL register pair contains 6000h, and memory loca-
    ; tion 6000h contains 60h, the instruction CP (HL) results in the P/V flag in the F Register
    ; resetting."
    
    ; ===== TEST 12.1: CP r =====
    ; Test CP r with various registers
    
    ; Setup for equal comparison
    ld a, 42h       ; A = 42h (66)
    ld b, 42h       ; B = 42h (66)
    cp b            ; Compare A with B (42h - 42h = 0)
    
    ; Final register state:
    ; A = 42h (66) - unchanged
    ; B = 42h (66) - unchanged
    ; Condition bits:
    ; - S is reset (result is not negative)
    ; - Z is set (result is zero - indicating equality)
    ; - H depends on the values compared
    ; - P/V is reset (no overflow)
    ; - N is set (subtraction performed)
    ; - C is reset (no borrow needed)
    
    ; Test with other registers - A > register value
    ld a, 80h       ; A = 80h (128)
    ld c, 01h       ; C = 01h (1)
    cp c            ; Compare A with C (80h - 01h = 7Fh)
    
    ; A < register value (causes borrow/carry)
    ld a, 10h       ; A = 10h (16)
    ld d, 20h       ; D = 20h (32)
    cp d            ; Compare A with D (10h - 20h = F0h)
    
    ; Test with overflow condition
    ld a, 80h       ; A = 80h (-128 signed)
    ld e, 01h       ; E = 01h (1)
    cp e            ; Compare A with E (80h - 01h = 7Fh with overflow)
    
    ; Test with sign flag
    ld a, 01h       ; A = 01h (1)
    ld h, 02h       ; H = 02h (2)
    cp h            ; Compare A with H (01h - 02h = FFh, negative result)
    
    ; Test with zero result by comparing A with itself
    ld a, 0AAh      ; A = AAh (170)
    cp a            ; Compare A with A (AAh - AAh = 00h, zero result)
    
    ; ===== TEST 12.2: CP n =====
    ; Test with immediate value
    
    ; Equal value
    ld a, 42h       ; A = 42h (66)
    cp 42h          ; Compare A with 42h (42h - 42h = 0)
    
    ; A > immediate
    ld a, 0FFh      ; A = FFh (255)
    cp 7Fh          ; Compare A with 7Fh (FFh - 7Fh = 80h)
    
    ; A < immediate (causes borrow/carry)
    ld a, 10h       ; A = 10h (16)
    cp 20h          ; Compare A with 20h (10h - 20h = F0h) with borrow/carry
    
    ; Test with overflow condition
    ld a, 80h       ; A = 80h (-128 signed)
    cp 01h          ; Compare A with 01h (80h - 01h = 7Fh with overflow)
    
    ; ===== TEST 12.3: CP (HL) =====
    ; Example from documentation:
    ; "If the Accumulator contains 63h, the HL register pair contains 6000h, and memory loca-
    ; tion 6000h contains 60h, the instruction CP (HL) results in the P/V flag in the F Register
    ; resetting."
    
    ; Setup for our example
    ld a, 60h                 ; Set up test data
    ld (cp_hl_data), a        ; Store 60h at our test memory location
    ld a, 63h                 ; A = 63h (99) as per the example
    ld hl, cp_hl_data         ; HL points to our test data (like 6000h in example)
    cp (hl)                   ; Compare A with (HL) (63h - 60h = 03h)
    
    ; Final state:
    ; A = 63h (99) - unchanged
    ; HL = address of cp_hl_data (unchanged)
    ; memory at cp_hl_data = 60h (unchanged)
    ; Condition bits:
    ; - S is reset (result is positive)
    ; - Z is reset (result is not zero)
    ; - H depends on the values compared
    ; - P/V is reset (no overflow)
    ; - N is set (subtraction performed)
    ; - C is reset (no borrow needed)
    
    ; Test with equal values
    ld a, 42h                 ; Set up test data
    ld (cp_hl_data), a        ; Store 42h at our test memory location
    ld hl, cp_hl_data         ; HL points to our test data
    cp (hl)                   ; Compare A with (HL) (42h - 42h = 00h)
    
    ; Test with A < (HL) (causes borrow/carry)
    ld a, 20h                 ; A = 20h (32)
    ld (cp_hl_data), a        ; Store value at memory location
    ld a, 10h                 ; A = 10h (16)
    ld hl, cp_hl_data         ; HL points to our test data
    cp (hl)                   ; Compare A with (HL) (10h - 20h = F0h)
    
    ; ===== TEST 12.4: CP (IX+d) =====
    ; Test with indexed addressing
    
    ; Setup for basic comparison
    ld a, 25h                 ; Set up test data
    ld (cp_ix_base+5), a      ; Store 25h at cp_ix_base+5
    ld a, 30h                 ; A = 30h (48)
    ld ix, cp_ix_base         ; IX points to our base address
    cp (ix+5)                 ; Compare A with (IX+5) (30h - 25h = 0Bh)
    
    ; Test with equal values
    ld a, 42h                 ; Set up test data
    ld (cp_ix_base+5), a      ; Store 42h at cp_ix_base+5
    ld ix, cp_ix_base         ; IX points to our base address
    cp (ix+5)                 ; Compare A with (IX+5) (42h - 42h = 00h)
    
    ; Test with negative displacement
    ld a, 20h                 ; Set up test data
    ld (cp_ix_base-3), a      ; Store 20h at cp_ix_base-3
    ld a, 10h                 ; A = 10h (16)
    cp (ix-3)                 ; Compare A with (IX-3) (10h - 20h = F0h)
    
    ; ===== TEST 12.5: CP (IY+d) =====
    ; Test with indexed addressing
    
    ; Setup for basic comparison
    ld a, 25h                 ; Set up test data
    ld (cp_iy_base+5), a      ; Store 25h at cp_iy_base+5
    ld a, 30h                 ; A = 30h (48)
    ld iy, cp_iy_base         ; IY points to our base address
    cp (iy+5)                 ; Compare A with (IY+5) (30h - 25h = 0Bh)
    
    ; Test with equal values
    ld a, 42h                 ; Set up test data
    ld (cp_iy_base+5), a      ; Store 42h at cp_iy_base+5
    ld iy, cp_iy_base         ; IY points to our base address
    cp (iy+5)                 ; Compare A with (IY+5) (42h - 42h = 00h)
    
    ; Test with negative displacement
    ld a, 20h                 ; Set up test data
    ld (cp_iy_base-3), a      ; Store 20h at cp_iy_base-3
    ld a, 10h                 ; A = 10h (16)
    cp (iy-3)                 ; Compare A with (IY-3) (10h - 20h = F0h)
    
    ; ========= TEST 13: INC r =========
    ; Operation: r ← r + 1
    ; Description: Register r is incremented and register r identifies any of the registers A, B, C, D, E, H, or L.
    
    ; Example from documentation:
    ; "If the D Register contains 28h, then upon the execution of an INC D instruction, the D
    ; Register contains 29h."
    
    ; Example from documentation
    ld d, 28h       ; D = 28h (40) as per the example
    inc d           ; Increment D: D = 28h + 1 = 29h
    
    ; Final register state:
    ; D = 29h (41) - result of incrementing 28h
    ; Condition bits:
    ; - S is reset (result is positive)
    ; - Z is reset (result is not zero)
    ; - H is reset (no carry from bit 3)
    ; - P/V is reset (D was not 7Fh before operation)
    ; - N is reset (indicates addition)
    ; - C is not affected
    
    ; Test with other registers
    ld a, 0FFh      ; A = FFh (255)
    inc a           ; A = FFh + 1 = 00h with overflow but carry flag not affected
    
    ld b, 7Fh       ; B = 7Fh (127) - largest positive 8-bit signed number
    inc b           ; B = 7Fh + 1 = 80h (-128) with overflow (P/V set)
    
    ld c, 0FEh      ; C = FEh (254)
    inc c           ; C = FEh + 1 = FFh (negative result, S set)
    
    ld e, 0FFh      ; E = FFh (255)
    inc e           ; E = FFh + 1 = 00h (zero result, Z set)
    
    ld h, 0Fh       ; H = 0Fh (15)
    inc h           ; H = 0Fh + 1 = 10h (carry from bit 3, H set)
    
    ld l, 00h       ; L = 00h (0)
    inc l           ; L = 00h + 1 = 01h (normal increment)
    
    ; ========= TEST 14: INC (HL) =========
    ; Operation: (HL) ← (HL) + 1
    ; Description: The byte contained in the address specified by the contents of the HL register pair is 
    ; incremented.
    
    ; Example from documentation:
    ; "If the HL register pair contains 3434h and address 3434h contains 82h, then upon the
    ; execution of an INC (HL) instruction, memory location 3434h contains 83h."
    
    ; Setup for our example
    ld a, 82h               ; Set up test data
    ld (inc_hl_data), a     ; Store 82h at our test memory location
    ld hl, inc_hl_data      ; HL points to our test data (like 3434h in example)
    inc (hl)                ; Increment byte at (HL): (HL) = 82h + 1 = 83h
    
    ; Final state:
    ; HL = address of inc_hl_data (unchanged)
    ; memory at inc_hl_data = 83h (incremented)
    ; Condition bits:
    ; - S is set (result is negative)
    ; - Z is reset (result is not zero)
    ; - H is reset (no carry from bit 3)
    ; - P/V is reset (value was not 7Fh before operation)
    ; - N is reset (indicates addition)
    ; - C is not affected
    
    ; Test with special cases
    ld a, 0FFh             ; Set up test data
    ld (inc_hl_data), a    ; Store FFh at our test memory location
    inc (hl)               ; Increment byte at (HL): (HL) = FFh + 1 = 00h (zero result)
    
    ld a, 7Fh              ; Set up test data
    ld (inc_hl_data), a    ; Store 7Fh at our test memory location
    inc (hl)               ; Increment byte at (HL): (HL) = 7Fh + 1 = 80h (overflow)
    
    ld a, 0Fh              ; Set up test data
    ld (inc_hl_data), a    ; Store 0Fh at our test memory location
    inc (hl)               ; Increment byte at (HL): (HL) = 0Fh + 1 = 10h (half-carry)
    
    ; ========= TEST 15: INC (IX+d) =========
    ; Operation: (IX+d) ← (IX+d) + 1
    ; Description: The contents of Index Register IX are added to the two's-complement
    ; displacement integer, d, to point to an address in memory. The contents of this address are
    ; then incremented.
    
    ; Example from documentation:
    ; "If Index Register pair IX contains 2020h and memory location 2030h contains byte 34h,
    ; then upon the execution of an INC (IX+10h) instruction, memory location 2030h con-
    ; tains 35h."
    
    ; Setup for our example
    ld a, 34h                 ; Set up test data
    ld (inc_ix_base+16), a    ; Store 34h at inc_ix_base+16 (mimicking 2030h as in example)
    ld ix, inc_ix_base        ; IX points to our base address (like 2020h in example)
    inc (ix+16)               ; Increment byte at (IX+16): (IX+16) = 34h + 1 = 35h
    
    ; Final state:
    ; IX = inc_ix_base (unchanged)
    ; memory at inc_ix_base+16 = 35h (incremented)
    ; Condition bits:
    ; - S is reset (result is positive)
    ; - Z is reset (result is not zero)
    ; - H is reset (no carry from bit 3)
    ; - P/V is reset (value was not 7Fh before operation)
    ; - N is reset (indicates addition)
    ; - C is not affected
    
    ; Test with special cases
    ld a, 0FFh               ; Set up test data
    ld (inc_ix_base+5), a    ; Store FFh at inc_ix_base+5
    inc (ix+5)               ; Increment byte at (IX+5): (IX+5) = FFh + 1 = 00h (zero result)
    
    ld a, 7Fh                ; Set up test data
    ld (inc_ix_base-3), a    ; Store 7Fh at inc_ix_base-3
    inc (ix-3)               ; Increment byte at (IX-3): (IX-3) = 7Fh + 1 = 80h (overflow)
    
    ; ========= TEST 16: INC (IY+d) =========
    ; Operation: (IY+d) ← (IY+d) + 1
    ; Description: The contents of Index Register IY are added to the two's-complement
    ; displacement integer, d, to point to an address in memory. The contents of this address are
    ; then incremented.
    
    ; Example from documentation:
    ; "If Index Register IY are 2020h and memory location 2030h contains byte 34h, then upon
    ; the execution of an INC (IY+10h) instruction, memory location 2030h contains 35h."
    
    ; Setup for our example
    ld a, 34h                 ; Set up test data
    ld (inc_iy_base+16), a    ; Store 34h at inc_iy_base+16 (mimicking 2030h as in example)
    ld iy, inc_iy_base        ; IY points to our base address (like 2020h in example)
    inc (iy+16)               ; Increment byte at (IY+16): (IY+16) = 34h + 1 = 35h
    
    ; Final state:
    ; IY = inc_iy_base (unchanged)
    ; memory at inc_iy_base+16 = 35h (incremented)
    ; Condition bits:
    ; - S is reset (result is positive)
    ; - Z is reset (result is not zero)
    ; - H is reset (no carry from bit 3)
    ; - P/V is reset (value was not 7Fh before operation)
    ; - N is reset (indicates addition)
    ; - C is not affected
    
    ; Test with special cases
    ld a, 0FFh               ; Set up test data
    ld (inc_iy_base+5), a    ; Store FFh at inc_iy_base+5
    inc (iy+5)               ; Increment byte at (IY+5): (IY+5) = FFh + 1 = 00h (zero result)
    
    ld a, 7Fh                ; Set up test data
    ld (inc_iy_base-3), a    ; Store 7Fh at inc_iy_base-3
    inc (iy-3)               ; Increment byte at (IY-3): (IY-3) = 7Fh + 1 = 80h (overflow)
    
    ; ========= TEST 17: DEC m =========
    ; Operation: m ← m - 1
    ; Description: The byte specified by the m operand is decremented.
    ; The m operand can be any of: r, (HL), (IX+d), or (IY+d)
    
    ; Example from documentation:
    ; "If the D Register contains byte 2Ah, then upon the execution of a DEC D instruction, the D
    ; Register contains 29h."
    
    ; ===== TEST 17.1: DEC r =====
    ; Test DEC r with various registers
    
    ; Example from documentation
    ld d, 2Ah       ; D = 2Ah (42) as per the example
    dec d           ; Decrement D: D = 2Ah - 1 = 29h
    
    ; Final register state:
    ; D = 29h (41) - result of decrementing 2Ah
    ; Condition bits:
    ; - S is reset (result is positive)
    ; - Z is reset (result is not zero)
    ; - H is reset (no borrow from bit 4)
    ; - P/V is reset (D was not 80h before operation)
    ; - N is set (indicates subtraction)
    ; - C is not affected
    
    ; Test with other registers
    ld a, 01h       ; A = 01h (1)
    dec a           ; A = 01h - 1 = 00h (zero result, Z set)
    
    ld b, 80h       ; B = 80h (128) - most negative 8-bit signed number
    dec b           ; B = 80h - 1 = 7Fh (127) with overflow (P/V set)
    
    ld c, 00h       ; C = 00h (0)
    dec c           ; C = 00h - 1 = FFh (negative result, S set)
    
    ld e, 10h       ; E = 10h (16)
    dec e           ; E = 10h - 1 = 0Fh (borrow from bit 4, H set)
    
    ld h, 0FFh      ; H = FFh (255)
    dec h           ; H = FFh - 1 = FEh (normal decrement)
    
    ld l, 81h       ; L = 81h (129)
    dec l           ; L = 81h - 1 = 80h (special test case: 80h result sets S but no overflow)
    
    ; ===== TEST 17.2: DEC (HL) =====
    ; Test with memory operand
    
    ; Setup for basic test
    ld a, 2Ah                ; Set up test data
    ld (dec_hl_data), a      ; Store 2Ah at our test memory location
    ld hl, dec_hl_data       ; HL points to our test data
    dec (hl)                 ; Decrement byte at (HL): (HL) = 2Ah - 1 = 29h
    
    ; Final state:
    ; HL = address of dec_hl_data (unchanged)
    ; memory at dec_hl_data = 29h (decremented)
    ; Condition bits:
    ; - S is reset (result is positive)
    ; - Z is reset (result is not zero)
    ; - H is reset (no borrow from bit 4)
    ; - P/V is reset (value was not 80h before operation)
    ; - N is set (indicates subtraction)
    ; - C is not affected
    
    ; Test with special cases
    ld a, 01h               ; Set up test data
    ld (dec_hl_data), a     ; Store 01h at our test memory location
    dec (hl)                ; Decrement byte at (HL): (HL) = 01h - 1 = 00h (zero result)
    
    ld a, 80h               ; Set up test data
    ld (dec_hl_data), a     ; Store 80h at our test memory location
    dec (hl)                ; Decrement byte at (HL): (HL) = 80h - 1 = 7Fh (overflow)
    
    ld a, 10h               ; Set up test data
    ld (dec_hl_data), a     ; Store 10h at our test memory location
    dec (hl)                ; Decrement byte at (HL): (HL) = 10h - 1 = 0Fh (half-borrow)
    
    ; ===== TEST 17.3: DEC (IX+d) =====
    ; Test with indexed addressing
    
    ; Setup for basic test
    ld a, 2Ah                 ; Set up test data
    ld (dec_ix_base+5), a     ; Store 2Ah at dec_ix_base+5
    ld ix, dec_ix_base        ; IX points to our base address
    dec (ix+5)                ; Decrement byte at (IX+5): (IX+5) = 2Ah - 1 = 29h
    
    ; Final state:
    ; IX = dec_ix_base (unchanged)
    ; memory at dec_ix_base+5 = 29h (decremented)
    ; Condition bits:
    ; - S is reset (result is positive)
    ; - Z is reset (result is not zero)
    ; - H is reset (no borrow from bit 4)
    ; - P/V is reset (value was not 80h before operation)
    ; - N is set (indicates subtraction)
    ; - C is not affected
    
    ; Test with special cases
    ld a, 01h                ; Set up test data
    ld (dec_ix_base+10), a   ; Store 01h at dec_ix_base+10
    dec (ix+10)              ; Decrement byte at (IX+10): (IX+10) = 01h - 1 = 00h (zero result)
    
    ld a, 80h                ; Set up test data
    ld (dec_ix_base-3), a    ; Store 80h at dec_ix_base-3 (test negative displacement)
    dec (ix-3)               ; Decrement byte at (IX-3): (IX-3) = 80h - 1 = 7Fh (overflow)
    
    ; ===== TEST 17.4: DEC (IY+d) =====
    ; Test with indexed addressing
    
    ; Setup for basic test
    ld a, 2Ah                 ; Set up test data
    ld (dec_iy_base+5), a     ; Store 2Ah at dec_iy_base+5
    ld iy, dec_iy_base        ; IY points to our base address
    dec (iy+5)                ; Decrement byte at (IY+5): (IY+5) = 2Ah - 1 = 29h
    
    ; Final state:
    ; IY = dec_iy_base (unchanged)
    ; memory at dec_iy_base+5 = 29h (decremented)
    ; Condition bits:
    ; - S is reset (result is positive)
    ; - Z is reset (result is not zero)
    ; - H is reset (no borrow from bit 4)
    ; - P/V is reset (value was not 80h before operation)
    ; - N is set (indicates subtraction)
    ; - C is not affected
    
    ; Test with special cases
    ld a, 01h                ; Set up test data
    ld (dec_iy_base+10), a   ; Store 01h at dec_iy_base+10
    dec (iy+10)              ; Decrement byte at (IY+10): (IY+10) = 01h - 1 = 00h (zero result)
    
    ld a, 80h                ; Set up test data
    ld (dec_iy_base-3), a    ; Store 80h at dec_iy_base-3 (test negative displacement)
    dec (iy-3)               ; Decrement byte at (IY-3): (IY-3) = 80h - 1 = 7Fh (overflow)
    
    ; ========= END TEST AREA =========
    
    jr $          ; Infinite loop

; Data section
hl_data:        ; Data for ADD A, (HL) test
    db 0

ix_base:        ; Base address for ADD A, (IX+d) test
    defs 20, 0   ; Reserve 20 bytes for IX tests

iy_base:        ; Base address for ADD A, (IY+d) test
    defs 20, 0   ; Reserve 20 bytes for IY tests

adc_hl_data:    ; Data for ADC A, (HL) test
    db 0

adc_ix_base:    ; Base address for ADC A, (IX+d) test
    defs 20, 0   ; Reserve 20 bytes for IX tests

adc_iy_base:    ; Base address for ADC A, (IY+d) test
    defs 20, 0   ; Reserve 20 bytes for IY tests

sub_hl_data:    ; Data for SUB (HL) test
    db 0

sub_ix_base:    ; Base address for SUB (IX+d) test
    defs 20, 0   ; Reserve 20 bytes for IX tests

sub_iy_base:    ; Base address for SUB (IY+d) test
    defs 20, 0   ; Reserve 20 bytes for IY tests

sbc_hl_data:    ; Data for SBC A, (HL) test
    db 0

sbc_ix_base:    ; Base address for SBC A, (IX+d) test
    defs 20, 0   ; Reserve 20 bytes for IX tests

sbc_iy_base:    ; Base address for SBC A, (IY+d) test
    defs 20, 0   ; Reserve 20 bytes for IY tests

and_hl_data:    ; Data for AND (HL) test
    db 0

and_ix_base:    ; Base address for AND (IX+d) test
    defs 20, 0   ; Reserve 20 bytes for IX tests

and_iy_base:    ; Base address for AND (IY+d) test
    defs 20, 0   ; Reserve 20 bytes for IY tests

or_hl_data:     ; Data for OR (HL) test
    db 0

or_ix_base:     ; Base address for OR (IX+d) test
    defs 20, 0   ; Reserve 20 bytes for IX tests

or_iy_base:     ; Base address for OR (IY+d) test
    defs 20, 0   ; Reserve 20 bytes for IY tests

xor_hl_data:    ; Data for XOR (HL) test
    db 0

xor_ix_base:    ; Base address for XOR (IX+d) test
    defs 20, 0   ; Reserve 20 bytes for IX tests

xor_iy_base:    ; Base address for XOR (IY+d) test
    defs 20, 0   ; Reserve 20 bytes for IY tests

cp_hl_data:     ; Data for CP (HL) test
    db 0

cp_ix_base:     ; Base address for CP (IX+d) test
    defs 20, 0   ; Reserve 20 bytes for IX tests

cp_iy_base:     ; Base address for CP (IY+d) test
    defs 20, 0   ; Reserve 20 bytes for IY tests

inc_hl_data:    ; Data for INC (HL) test
    db 0

inc_ix_base:    ; Base address for INC (IX+d) test
    defs 32, 0   ; Reserve 32 bytes for IX tests (space for both positive and negative offsets)

inc_iy_base:    ; Base address for INC (IY+d) test
    defs 32, 0   ; Reserve 32 bytes for IY tests (space for both positive and negative offsets)

dec_hl_data:    ; Data for DEC (HL) test
    db 0

dec_ix_base:    ; Base address for DEC (IX+d) test
    defs 32, 0   ; Reserve 32 bytes for IX tests (space for both positive and negative offsets)

dec_iy_base:    ; Base address for DEC (IY+d) test
    defs 32, 0   ; Reserve 32 bytes for IY tests (space for both positive and negative offsets)

stack_bottom:   ; 100 bytes of stack
    defs 100, 0
stack_top:
    END
