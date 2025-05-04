; Z80 Assembly - 16-Bit Arithmetic Group Instructions Testing
; This file contains tests for the Z80 16-Bit Arithmetic Group instructions:
;   1. ADD HL, ss - Add register pair to HL
;   2. ADC HL, ss - Add with carry register pair to HL
;   3. SBC HL, ss - Subtract with carry register pair from HL
;   4. ADD IX, pp - Add register pair to IX
;   5. ADD IY, rr - Add register pair to IY
;   6. INC ss - Increment register pair
;   7. INC IX - Increment IX register
;   8. INC IY - Increment IY register
;   9. DEC ss - Decrement register pair
;  10. DEC IX - Decrement IX register
;  11. DEC IY - Decrement IY register

    DEVICE NOSLOT64K
    SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION

    org 0       ; Program starts at address 0 in memory

main:
    ld sp, stack_top  ; Initialize stack pointer
    
    ; ========= TEST 1: ADD HL, ss =========
    ; Operation: HL ← HL + ss
    ; Description: The contents of register pair ss (any of register pairs BC, DE, HL, or SP) are added to the
    ; contents of register pair HL and the result is stored in HL.
    ; Register pairs are coded as follows:
    ; BC - 00, DE - 01, HL - 10, SP - 11
    
    ; Example from documentation:
    ; "If register pair HL contains the integer 4242h and register pair DE contains 1111h, then
    ; upon the execution of an ADD HL, DE instruction, the HL register pair contains 5353h."
    
    ; ===== TEST 1.1: ADD HL, BC =====
    ld hl, 4242h    ; HL = 4242h
    ld bc, 1111h    ; BC = 1111h
    add hl, bc     ; HL = HL + BC = 4242h + 1111h = 5353h
    
    ; Final register state:
    ; HL = 5353h - result of 4242h + 1111h
    ; BC = 1111h - unchanged
    ; Condition bits:
    ; - S is not affected
    ; - Z is not affected
    ; - H depends on carry from bit 11
    ; - P/V is not affected
    ; - N is reset (addition)
    ; - C is reset (no carry from bit 15)
    
    ; ===== TEST 1.2: ADD HL, DE =====
    ; Based on the example in documentation
    ld hl, 4242h    ; HL = 4242h as per the example
    ld de, 1111h    ; DE = 1111h as per the example
    add hl, de     ; HL = HL + DE = 4242h + 1111h = 5353h
    
    ; Final register state:
    ; HL = 5353h - result of 4242h + 1111h
    ; DE = 1111h - unchanged
    ; Condition bits as above
    
    ; ===== TEST 1.3: ADD HL, HL =====
    ; Test with HL as source (doubles HL)
    ld hl, 4000h    ; HL = 4000h
    add hl, hl     ; HL = HL + HL = 4000h + 4000h = 8000h
    
    ; Final state:
    ; HL = 8000h - result of 4000h + 4000h
    ; Condition bits:
    ; - S is not affected
    ; - Z is not affected
    ; - H is reset (no carry from bit 11)
    ; - P/V is not affected
    ; - N is reset (addition)
    ; - C is set (carry from bit 15)
    
    ; ===== TEST 1.4: ADD HL, SP =====
    ; Test with stack pointer
    ld hl, 8000h    ; HL = 8000h
    ld sp, 8000h    ; SP = 8000h
    add hl, sp     ; HL = HL + SP = 8000h + 8000h = 0000h (with carry)
    
    ; Final state:
    ; HL = 0000h - result wrapped around due to overflow
    ; SP = 8000h - unchanged
    ; Condition bits:
    ; - S is not affected
    ; - Z is not affected
    ; - H depends on carry from bit 11
    ; - P/V is not affected
    ; - N is reset (addition)
    ; - C is set (carry from bit 15)
    
    ; Test with maximum value
    ld hl, 0FFFFh   ; HL = FFFFh (maximum 16-bit value)
    ld bc, 0001h    ; BC = 0001h
    add hl, bc     ; HL = HL + BC = FFFFh + 0001h = 0000h (with carry)
    
    ; ========= TEST 2: ADC HL, ss =========
    ; Operation: HL ← HL + ss + CY
    ; Description: The contents of register pair ss (any of register pairs BC, DE, HL, or SP) are added with
    ; the Carry flag (C flag in the F Register) to the contents of register pair HL, and the result is
    ; stored in HL.
    ; Register pairs are coded as follows:
    ; BC - 00, DE - 01, HL - 10, SP - 11
    
    ; Example from documentation:
    ; "If register pair BC contains 2222h, register pair HL contains 5437h, and the Carry Flag is
    ; set, then upon the execution of an ADC HL, BC instruction, HL contains 765Ah."
    
    ; ===== TEST 2.1: ADC HL, BC =====
    ; Setup for the example
    ld bc, 2222h    ; BC = 2222h as per the example
    ld hl, 5437h    ; HL = 5437h as per the example
    scf            ; Set carry flag
    adc hl, bc     ; HL = HL + BC + 1 = 5437h + 2222h + 1 = 765Ah
    
    ; Final register state:
    ; HL = 765Ah - result of 5437h + 2222h + 1
    ; BC = 2222h - unchanged
    ; Condition bits:
    ; - S is set (result is negative - bit 15 is 1)
    ; - Z is reset (result is not zero)
    ; - H depends on half-carry from bit 11
    ; - P/V is reset (no overflow)
    ; - N is reset (addition)
    ; - C is reset (no carry from bit 15)
    
    ; ===== TEST 2.2: ADC HL, DE =====
    ; Test with carry propagation
    ld de, 0FFFFh   ; DE = FFFFh (65535)
    ld hl, 0000h    ; HL = 0000h
    scf            ; Set carry flag
    adc hl, de     ; HL = HL + DE + 1 = 0000h + FFFFh + 1 = 10000h (carry out, HL = 0000h)
    
    ; Final state:
    ; HL = 0000h - result wrapped around due to overflow
    ; DE = FFFFh - unchanged
    ; Condition bits:
    ; - S is reset (result is not negative)
    ; - Z is set (result is zero)
    ; - H is set (half-carry from bit 11)
    ; - P/V is reset (no overflow for signed arithmetic)
    ; - N is reset (addition)
    ; - C is set (carry from bit 15)
    
    ; ===== TEST 2.3: ADC HL, HL =====
    ; Test with HL as source (doubles HL plus carry)
    ld hl, 4000h    ; HL = 4000h
    scf            ; Set carry flag
    adc hl, hl     ; HL = HL + HL + 1 = 4000h + 4000h + 1 = 8001h
    
    ; Final state:
    ; HL = 8001h - result of 4000h + 4000h + 1
    ; Condition bits:
    ; - S is set (result is negative - bit 15 is 1)
    ; - Z is reset (result is not zero)
    ; - H is reset (no half-carry from bit 11)
    ; - P/V is set (overflow for signed arithmetic: 16384 + 16384 + 1 = 32769, which exceeds 16-bit signed range)
    ; - N is reset (addition)
    ; - C is reset (no carry from bit 15)
    
    ; ===== TEST 2.4: ADC HL, SP =====
    ; Test with stack pointer
    ld sp, 1234h    ; SP = 1234h
    ld hl, 8000h    ; HL = 8000h (most negative 16-bit signed value)
    scf            ; Set carry flag
    adc hl, sp     ; HL = HL + SP + 1 = 8000h + 1234h + 1 = 9235h
    
    ; Final state:
    ; HL = 9235h - result of 8000h + 1234h + 1
    ; SP = 1234h - unchanged
    ; Condition bits:
    ; - S is set (result is negative - bit 15 is 1)
    ; - Z is reset (result is not zero)
    ; - H depends on half-carry from bit 11
    ; - P/V is reset (no overflow)
    ; - N is reset (addition)
    ; - C is reset (no carry from bit 15)
    
    ; Test with carry flag reset
    ld bc, 1111h    ; BC = 1111h
    ld hl, 2222h    ; HL = 2222h
    or a            ; Clear carry flag (equivalent to 'xor a' followed by 'cp a')
    adc hl, bc     ; HL = HL + BC + 0 = 2222h + 1111h = 3333h
    
    ; Final state:
    ; HL = 3333h - result of 2222h + 1111h
    ; BC = 1111h - unchanged
    ; Condition bits:
    ; - S is reset (result is not negative)
    ; - Z is reset (result is not zero)
    ; - H depends on half-carry from bit 11
    ; - P/V is reset (no overflow)
    ; - N is reset (addition)
    ; - C is reset (no carry from bit 15)
    
    ; ========= TEST 3: SBC HL, ss =========
    ; Operation: HL ← HL - ss - CY
    ; Description: The contents of the register pair ss (any of register pairs BC, DE, HL, or SP) and the Carry
    ; Flag (C flag in the F Register) are subtracted from the contents of register pair HL, and the
    ; result is stored in HL.
    ; Register pairs are coded as follows:
    ; BC - 00, DE - 01, HL - 10, SP - 11
    
    ; Example from documentation:
    ; "If the HL register pair contains 9999h, register pair DE contains 1111h, and the Carry
    ; flag is set, then upon the execution of an SBC HL, DE instruction, HL contains 8887h."
    
    ; ===== TEST 3.1: SBC HL, DE =====
    ; Setup for the example
    ld hl, 9999h    ; HL = 9999h as per the example
    ld de, 1111h    ; DE = 1111h as per the example
    scf            ; Set carry flag
    sbc hl, de     ; HL = HL - DE - 1 = 9999h - 1111h - 1 = 8887h
    
    ; Final register state:
    ; HL = 8887h - result of 9999h - 1111h - 1
    ; DE = 1111h - unchanged
    ; Condition bits:
    ; - S is set (result is negative - bit 15 is 1)
    ; - Z is reset (result is not zero)
    ; - H depends on borrow from bit 12
    ; - P/V is reset (no overflow)
    ; - N is set (subtraction)
    ; - C is reset (no borrow needed)
    
    ; ===== TEST 3.2: SBC HL, BC =====
    ; Test with borrow (carry) propagation
    ld hl, 1000h    ; HL = 1000h
    ld bc, 2000h    ; BC = 2000h
    scf            ; Set carry flag
    sbc hl, bc     ; HL = HL - BC - 1 = 1000h - 2000h - 1 = EFFFh
    
    ; Final state:
    ; HL = EFFFh - result of 1000h - 2000h - 1
    ; BC = 2000h - unchanged
    ; Condition bits:
    ; - S is set (result is negative)
    ; - Z is reset (result is not zero)
    ; - H depends on borrow from bit 12
    ; - P/V depends on overflow
    ; - N is set (subtraction)
    ; - C is set (borrow needed)
    
    ; ===== TEST 3.3: SBC HL, HL =====
    ; Test with HL as source (should give 0 if carry flag is reset, -1 if set)
    ld hl, 5555h    ; HL = 5555h
    scf            ; Set carry flag
    sbc hl, hl     ; HL = HL - HL - 1 = 5555h - 5555h - 1 = FFFFh (-1)
    
    ; Final state:
    ; HL = FFFFh - result of 5555h - 5555h - 1
    ; Condition bits:
    ; - S is set (result is negative)
    ; - Z is reset (result is not zero)
    ; - H is set (borrow from bit 12)
    ; - P/V is reset (no overflow)
    ; - N is set (subtraction)
    ; - C is set (borrow needed for -1)
    
    ; Test with carry flag reset
    ld hl, 8000h    ; HL = 8000h (most negative 16-bit signed value)
    ld bc, 0001h    ; BC = 0001h
    or a            ; Clear carry flag
    sbc hl, bc     ; HL = HL - BC - 0 = 8000h - 0001h = 7FFFh (most positive 16-bit signed value)
    
    ; Final state:
    ; HL = 7FFFh - result of 8000h - 0001h
    ; BC = 0001h - unchanged
    ; Condition bits:
    ; - S is reset (result is positive)
    ; - Z is reset (result is not zero)
    ; - H is set (borrow from bit 12)
    ; - P/V is set (overflow: -32768 - 1 = 32767, which crosses signed boundary)
    ; - N is set (subtraction)
    ; - C is reset (no borrow needed)
    
    ; ===== TEST 3.4: SBC HL, SP =====
    ; Test with stack pointer
    ld sp, 1000h    ; SP = 1000h
    ld hl, 1000h    ; HL = 1000h
    scf            ; Set carry flag
    sbc hl, sp     ; HL = HL - SP - 1 = 1000h - 1000h - 1 = FFFFh (-1)
    
    ; Final state:
    ; HL = FFFFh - result of 1000h - 1000h - 1
    ; SP = 1000h - unchanged
    ; Condition bits:
    ; - S is set (result is negative)
    ; - Z is reset (result is not zero)
    ; - H is set (borrow from bit 12)
    ; - P/V is reset (no overflow)
    ; - N is set (subtraction)
    ; - C is set (borrow needed for -1)
    
    ; ========= TEST 4: ADD IX, pp =========
    ; Operation: IX ← IX + pp
    ; Description: The contents of register pair pp (any of register pairs BC, DE, IX, or SP) are added to the
    ; contents of Index Register IX, and the results are stored in IX.
    ; Register pairs are coded as follows:
    ; BC - 00, DE - 01, IX - 10, SP - 11
    
    ; Example from documentation:
    ; "If Index Register IX contains 333h and register pair BC contains 5555h, then upon the
    ; execution of an ADD IX, BC instruction, IX contains 8888h."
    
    ; ===== TEST 4.1: ADD IX, BC =====
    ; Setup for the example
    ld ix, 0333h    ; IX = 0333h as per the example
    ld bc, 5555h    ; BC = 5555h as per the example
    add ix, bc     ; IX = IX + BC = 0333h + 5555h = 5888h (not 8888h as in example, likely a typo)
    
    ; Final register state:
    ; IX = 5888h - result of 0333h + 5555h
    ; BC = 5555h - unchanged
    ; Condition bits:
    ; - S is not affected
    ; - Z is not affected
    ; - H depends on carry from bit 11
    ; - P/V is not affected
    ; - N is reset (addition)
    ; - C depends on carry from bit 15
    
    ; ===== TEST 4.2: ADD IX, DE =====
    ; Test with carry propagation
    ld ix, 8000h    ; IX = 8000h
    ld de, 8000h    ; DE = 8000h
    add ix, de     ; IX = IX + DE = 8000h + 8000h = 0000h (with carry out)
    
    ; Final state:
    ; IX = 0000h - result wrapped around due to overflow
    ; DE = 8000h - unchanged
    ; Condition bits:
    ; - S is not affected
    ; - Z is not affected
    ; - H depends on carry from bit 11
    ; - P/V is not affected
    ; - N is reset (addition)
    ; - C is set (carry from bit 15)
    
    ; ===== TEST 4.3: ADD IX, IX =====
    ; Test with IX as source (doubles IX)
    ld ix, 4400h    ; IX = 4400h
    add ix, ix     ; IX = IX + IX = 4400h + 4400h = 8800h
    
    ; Final state:
    ; IX = 8800h - result of 4400h + 4400h
    ; Condition bits:
    ; - S is not affected
    ; - Z is not affected
    ; - H is reset (no carry from bit 11)
    ; - P/V is not affected
    ; - N is reset (addition)
    ; - C is set (carry from bit 15)
    
    ; ===== TEST 4.4: ADD IX, SP =====
    ; Test with stack pointer
    ld sp, 1234h    ; SP = 1234h
    ld ix, 5678h    ; IX = 5678h
    add ix, sp     ; IX = IX + SP = 5678h + 1234h = 68ACh
    
    ; Final state:
    ; IX = 68ACh - result of 5678h + 1234h
    ; SP = 1234h - unchanged
    ; Condition bits:
    ; - S is not affected
    ; - Z is not affected
    ; - H depends on carry from bit 11
    ; - P/V is not affected
    ; - N is reset (addition)
    ; - C is reset (no carry from bit 15)
    
    ; ========= TEST 5: ADD IY, rr =========
    ; Operation: IY ← IY + rr
    ; Description: The contents of register pair rr (any of register pairs BC, DE, IY, or SP) are added to the
    ; contents of Index Register IY, and the result is stored in IY.
    ; Register pairs are coded as follows:
    ; BC - 00, DE - 01, IY - 10, SP - 11
    
    ; Example from documentation:
    ; "If Index Register IY contains 333h and register pair BC contains 555h, then upon the exe-
    ; cution of an ADD IY, BC instruction, IY contains 8888h."
    ; (Note: This seems to be a typo, as 333h + 555h = 888h, not 8888h)
    
    ; ===== TEST 5.1: ADD IY, BC =====
    ; Setup for the example (corrected to realistic values)
    ld iy, 0333h    ; IY = 0333h as per the example
    ld bc, 0555h    ; BC = 0555h (the example says 555h, which is correct but could be a typo)
    add iy, bc     ; IY = IY + BC = 0333h + 0555h = 0888h
    
    ; Final register state:
    ; IY = 0888h - result of 0333h + 0555h
    ; BC = 0555h - unchanged
    ; Condition bits:
    ; - S is not affected
    ; - Z is not affected
    ; - H depends on carry from bit 11
    ; - P/V is not affected
    ; - N is reset (addition)
    ; - C depends on carry from bit 15
    
    ; ===== TEST 5.2: ADD IY, DE =====
    ; Test with carry propagation
    ld iy, 0FFFFh   ; IY = FFFFh
    ld de, 0001h    ; DE = 0001h
    add iy, de     ; IY = IY + DE = FFFFh + 0001h = 0000h (with carry out)
    
    ; Final state:
    ; IY = 0000h - result wrapped around due to overflow
    ; DE = 0001h - unchanged
    ; Condition bits:
    ; - S is not affected
    ; - Z is not affected
    ; - H depends on carry from bit 11
    ; - P/V is not affected
    ; - N is reset (addition)
    ; - C is set (carry from bit 15)
    
    ; ===== TEST 5.3: ADD IY, IY =====
    ; Test with IY as source (doubles IY)
    ld iy, 2200h    ; IY = 2200h
    add iy, iy     ; IY = IY + IY = 2200h + 2200h = 4400h
    
    ; Final state:
    ; IY = 4400h - result of 2200h + 2200h
    ; Condition bits:
    ; - S is not affected
    ; - Z is not affected
    ; - H is reset (no carry from bit 11)
    ; - P/V is not affected
    ; - N is reset (addition)
    ; - C is reset (no carry from bit 15)
    
    ; ===== TEST 5.4: ADD IY, SP =====
    ; Test with stack pointer
    ld sp, 5432h    ; SP = 5432h
    ld iy, 1234h    ; IY = 1234h
    add iy, sp     ; IY = IY + SP = 1234h + 5432h = 6666h
    
    ; Final state:
    ; IY = 6666h - result of 1234h + 5432h
    ; SP = 5432h - unchanged
    ; Condition bits:
    ; - S is not affected
    ; - Z is not affected
    ; - H depends on carry from bit 11
    ; - P/V is not affected
    ; - N is reset (addition)
    ; - C is reset (no carry from bit 15)
    
    ; ========= TEST 6: INC ss =========
    ; Operation: ss ← ss + 1
    ; Description: The contents of register pair ss (any of register pairs BC, DE, HL, or SP) are incremented.
    ; Register pairs are coded as follows:
    ; BC - 00, DE - 01, HL - 10, SP - 11
    
    ; Example from documentation:
    ; "If the register pair contains 1000h, then upon the execution of an INC HL instruction, HL
    ; contains 1001h."
    
    ; ===== TEST 6.1: INC BC =====
    ld bc, 1000h    ; BC = 1000h
    inc bc         ; BC = BC + 1 = 1001h
    
    ; Final register state:
    ; BC = 1001h - result of 1000h + 1
    ; No condition bits are affected
    
    ; ===== TEST 6.2: INC DE =====
    ld de, 0FFFFh   ; DE = FFFFh (maximum 16-bit value)
    inc de         ; DE = DE + 1 = 0000h (wraps around)
    
    ; Final state:
    ; DE = 0000h - result wrapped around from FFFFh + 1
    ; No condition bits are affected
    
    ; ===== TEST 6.3: INC HL =====
    ; Example from documentation
    ld hl, 1000h    ; HL = 1000h as per the example
    inc hl         ; HL = HL + 1 = 1001h
    
    ; Final state:
    ; HL = 1001h - result of 1000h + 1
    ; No condition bits are affected
    
    ; ===== TEST 6.4: INC SP =====
    ld sp, 8888h    ; SP = 8888h
    inc sp         ; SP = SP + 1 = 8889h
    
    ; Final state:
    ; SP = 8889h - result of 8888h + 1
    ; No condition bits are affected
    
    ; ========= TEST 7: INC IX =========
    ; Operation: IX ← IX + 1
    ; Description: The contents of Index Register IX are incremented.
    
    ; Example from documentation:
    ; "If Index Register IX contains the integer 3300h, then upon the execution of an INC IX
    ; instruction, Index Register IX contains 3301h."
    
    ; Setup for the example
    ld ix, 3300h    ; IX = 3300h as per the example
    inc ix         ; IX = IX + 1 = 3301h
    
    ; Final register state:
    ; IX = 3301h - result of 3300h + 1
    ; No condition bits are affected
    
    ; Test with maximum value
    ld ix, 0FFFFh   ; IX = FFFFh (maximum 16-bit value)
    inc ix         ; IX = IX + 1 = 0000h (wraps around)
    
    ; Final state:
    ; IX = 0000h - result wrapped around from FFFFh + 1
    ; No condition bits are affected
    
    ; ========= TEST 8: INC IY =========
    ; Operation: IY ← IY + 1
    ; Description: The contents of Index Register IY are incremented.
    
    ; Example from documentation:
    ; "If the index register contains 2977h, then upon the execution of an INC IY instruction,
    ; Index Register IY contains 2978h."
    
    ; Setup for the example
    ld iy, 2977h    ; IY = 2977h as per the example
    inc iy         ; IY = IY + 1 = 2978h
    
    ; Final register state:
    ; IY = 2978h - result of 2977h + 1
    ; No condition bits are affected
    
    ; Test with maximum value
    ld iy, 0FFFFh   ; IY = FFFFh (maximum 16-bit value)
    inc iy         ; IY = IY + 1 = 0000h (wraps around)
    
    ; Final state:
    ; IY = 0000h - result wrapped around from FFFFh + 1
    ; No condition bits are affected
    
    ; ========= TEST 9: DEC ss =========
    ; Operation: ss ← ss - 1
    ; Description: The contents of register pair ss (any of the register pairs BC, DE, HL, or SP) are decremented.
    ; Register pairs are coded as follows:
    ; BC - 00, DE - 01, HL - 10, SP - 11
    
    ; Example from documentation:
    ; "If register pair HL contains 1001h, then upon the execution of an DEC HL instruction, HL
    ; contains 1000h."
    
    ; ===== TEST 9.1: DEC BC =====
    ld bc, 1001h    ; BC = 1001h
    dec bc         ; BC = BC - 1 = 1000h
    
    ; Final register state:
    ; BC = 1000h - result of 1001h - 1
    ; No condition bits are affected
    
    ; ===== TEST 9.2: DEC DE =====
    ld de, 0000h    ; DE = 0000h (minimum 16-bit value)
    dec de         ; DE = DE - 1 = FFFFh (wraps around)
    
    ; Final state:
    ; DE = FFFFh - result wrapped around from 0000h - 1
    ; No condition bits are affected
    
    ; ===== TEST 9.3: DEC HL =====
    ; Example from documentation
    ld hl, 1001h    ; HL = 1001h as per the example
    dec hl         ; HL = HL - 1 = 1000h
    
    ; Final state:
    ; HL = 1000h - result of 1001h - 1
    ; No condition bits are affected
    
    ; ===== TEST 9.4: DEC SP =====
    ld sp, 8889h    ; SP = 8889h
    dec sp         ; SP = SP - 1 = 8888h
    
    ; Final state:
    ; SP = 8888h - result of 8889h - 1
    ; No condition bits are affected
    
    ; ========= TEST 10: DEC IX =========
    ; Operation: IX ← IX - 1
    ; Description: The contents of Index Register IX are decremented.
    
    ; Example from documentation:
    ; "If Index Register IX contains 2006h, then upon the execution of a DEC IX instruction,
    ; Index Register IX contains 2005h."
    
    ; Setup for the example
    ld ix, 2006h    ; IX = 2006h as per the example
    dec ix         ; IX = IX - 1 = 2005h
    
    ; Final register state:
    ; IX = 2005h - result of 2006h - 1
    ; No condition bits are affected
    
    ; Test with minimum value
    ld ix, 0000h    ; IX = 0000h (minimum 16-bit value)
    dec ix         ; IX = IX - 1 = FFFFh (wraps around)
    
    ; Final state:
    ; IX = FFFFh - result wrapped around from 0000h - 1
    ; No condition bits are affected
    
    ; ========= TEST 11: DEC IY =========
    ; Operation: IY ← IY - 1
    ; Description: The contents of Index Register IY are decremented.
    
    ; Example from documentation:
    ; "If Index Register IY contains 7649h, then upon the execution of a DEC IY instruction,
    ; Index Register IY contains 7648h."
    
    ; Setup for the example
    ld iy, 7649h    ; IY = 7649h as per the example
    dec iy         ; IY = IY - 1 = 7648h
    
    ; Final register state:
    ; IY = 7648h - result of 7649h - 1
    ; No condition bits are affected
    
    ; Test with minimum value
    ld iy, 0000h    ; IY = 0000h (minimum 16-bit value)
    dec iy         ; IY = IY - 1 = FFFFh (wraps around)
    
    ; Final state:
    ; IY = FFFFh - result wrapped around from 0000h - 1
    ; No condition bits are affected
    
    ; ========= END TEST AREA =========
    
    jr $          ; Infinite loop

; Data section
stack_bottom:   ; 100 bytes of stack
    defs 100, 0
stack_top:
    END
