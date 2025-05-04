; Z80 Assembly - Rotate and Shift Group Instructions Testing
; This file contains tests for the Z80 Rotate and Shift Group instructions:
;   1. RLCA - Rotate Accumulator Left Circular
;   2. RLA  - Rotate Accumulator Left through Carry
;   3. RRCA - Rotate Accumulator Right Circular 
;   4. RRA  - Rotate Accumulator Right through Carry
;   5. RLC m - Rotate Left Circular (register or memory)
;   6. RL m  - Rotate Left through Carry (register or memory)
;   7. RRC m - Rotate Right Circular (register or memory)
;   8. RR m  - Rotate Right through Carry (register or memory)
;   9. SLA m - Shift Left Arithmetic (register or memory)
;  10. SRA m - Shift Right Arithmetic (register or memory)
;  11. SRL m - Shift Right Logical (register or memory)
;  12. RLD   - Rotate Digit Left (BCD)
;  13. RRD   - Rotate Digit Right (BCD)

    DEVICE NOSLOT64K
    SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION

    org 0       ; Program starts at address 0 in memory

main:
    ld sp, stack_top  ; Initialize stack pointer
    
    ; ========= TEST 1: RLCA - Rotate Accumulator Left Circular =========
    ; Operation: The contents of the Accumulator (Register A) are rotated left 1 bit position.
    ; The sign bit (bit 7) is copied to the Carry flag and also to bit 0.
    
    ; Example from documentation:
    ; "The Accumulator contains the following data:
    ; 76543210
    ; 10001000
    ; Upon the execution of an RLCA instruction, the Accumulator and Carry flag contains:
    ; C76543210
    ; 100010001"
    
    ; ===== TEST 1.1: RLCA with example from manual =====
    ld a, 10001000b   ; A = 88h (10001000) as per the example
    rlca              ; Rotate A left, bit 7 to carry and to bit 0
    
    ; Final register state:
    ; A = 00010001b (11h) - result of rotating 10001000 left
    ; Condition bits:
    ; - S is not affected
    ; - Z is not affected
    ; - H is reset
    ; - P/V is not affected
    ; - N is reset
    ; - C is set to 1 (previous bit 7)
    
    ; ===== TEST 1.2: RLCA with other bit patterns =====
    ; With A = 00000001 (bit 0 set)
    ld a, 00000001b   ; A = 01h
    rlca              ; A = 00000010b, C = 0
    
    ; With A = 10000000 (bit 7 set)
    ld a, 10000000b   ; A = 80h
    rlca              ; A = 00000001b, C = 1
    
    ; With A = 11111111 (all bits set)
    ld a, 11111111b   ; A = FFh
    rlca              ; A = 11111111b, C = 1 (unchanged value, but carry set)
    
    ; With A = 01010101 (alternating bits)
    ld a, 01010101b   ; A = 55h
    rlca              ; A = 10101010b, C = 0
    
    ; ========= TEST 2: RLA - Rotate Accumulator Left through Carry =========
    ; Operation: The contents of the Accumulator (Register A) are rotated left 1 bit position through the Carry flag.
    ; The previous contents of the Carry flag are copied to bit 0.
    
    ; Example from documentation:
    ; "The Accumulator and the Carry flag contains the following data:
    ; C76543210
    ; 101110110
    ; Upon the execution of an RLA instruction, the Accumulator and the Carry flag contains:
    ; C76543210
    ; 011101101"
    
    ; ===== TEST 2.1: RLA with example from manual =====
    ld a, 01110110b   ; A = 76h (01110110) as per example
    scf               ; Set carry flag to 1
    rla               ; Rotate A left through carry
    
    ; Final register state:
    ; A = 11101101b (EDh) - result of rotating 01110110 left through carry (which was 1)
    ; Condition bits:
    ; - S is not affected
    ; - Z is not affected
    ; - H is reset
    ; - P/V is not affected
    ; - N is reset
    ; - C is 0 (previous bit 7)
    
    ; ===== TEST 2.2: RLA with other bit patterns =====
    ; With A = 10000000 (bit 7 set), Carry = 0
    ld a, 10000000b   ; A = 80h
    and a             ; Clear carry flag
    rla               ; A = 00000000b, C = 1
    
    ; With A = 10000000 (bit 7 set), Carry = 1
    ld a, 10000000b   ; A = 80h
    scf               ; Set carry flag
    rla               ; A = 00000001b, C = 1
    
    ; With A = 01111111 (bit 7 clear, others set), Carry = 0
    ld a, 01111111b   ; A = 7Fh
    and a             ; Clear carry flag
    rla               ; A = 11111110b, C = 0
    
    ; With A = 01111111 (bit 7 clear, others set), Carry = 1
    ld a, 01111111b   ; A = 7Fh
    scf               ; Set carry flag
    rla               ; A = 11111111b, C = 0
    
    ; ========= TEST 3: RRCA - Rotate Accumulator Right Circular =========
    ; Operation: The contents of the Accumulator (Register A) are rotated right 1 bit position.
    ; Bit 0 is copied to the Carry flag and also to bit 7.
    
    ; Example from documentation:
    ; "The Accumulator contains the following data:
    ; 76543210
    ; 00010001
    ; Upon the execution of an RRCA instruction, the Accumulator and the Carry flag now contain:
    ; 76543210C
    ; 100110001"
    
    ; ===== TEST 3.1: RRCA with example from manual =====
    ld a, 00010001b   ; A = 11h (00010001) as per example
    rrca              ; Rotate A right, bit 0 to carry and bit 7
    
    ; Final register state:
    ; A = 10001000b (88h) - result of rotating 00010001 right
    ; Condition bits:
    ; - S is not affected
    ; - Z is not affected
    ; - H is reset
    ; - P/V is not affected
    ; - N is reset
    ; - C is set to 1 (previous bit 0)
    
    ; ===== TEST 3.2: RRCA with other bit patterns =====
    ; With A = 00000001 (bit 0 set)
    ld a, 00000001b   ; A = 01h
    rrca              ; A = 10000000b, C = 1
    
    ; With A = 10000000 (bit 7 set)
    ld a, 10000000b   ; A = 80h
    rrca              ; A = 01000000b, C = 0
    
    ; With A = 11111111 (all bits set)
    ld a, 11111111b   ; A = FFh
    rrca              ; A = 11111111b, C = 1 (unchanged value, but carry set)
    
    ; With A = 01010101 (alternating bits)
    ld a, 01010101b   ; A = 55h
    rrca              ; A = 10101010b, C = 1
    
    ; ========= TEST 4: RRA - Rotate Accumulator Right through Carry =========
    ; Operation: The contents of the Accumulator (Register A) are rotated right 1 bit position through the Carry flag.
    ; The previous contents of the Carry flag are copied to bit 7.
    
    ; Example from documentation:
    ; "The Accumulator and the Carry Flag contain the following data:
    ; 76543210C
    ; 111000010
    ; Upon the execution of an RRA instruction, the Accumulator and the Carry flag now contain:
    ; 76543210C
    ; 011100001"
    
    ; ===== TEST 4.1: RRA with example from manual =====
    ld a, 11100001b   ; A = E1h (11100001) as per example
    scf               ; Set carry flag
    rra               ; Rotate A right through carry
    
    ; Final register state:
    ; A = 11110000b (F0h) - result of rotating 11100001 right with carry set
    ; Condition bits:
    ; - S is not affected
    ; - Z is not affected
    ; - H is reset
    ; - P/V is not affected
    ; - N is reset
    ; - C is set to 1 (previous bit 0)
    
    ; ===== TEST 4.2: RRA with other bit patterns =====
    ; With A = 00000001 (bit 0 set), Carry = 0
    ld a, 00000001b   ; A = 01h
    and a             ; Clear carry flag
    rra               ; A = 00000000b, C = 1
    
    ; With A = 00000001 (bit 0 set), Carry = 1
    ld a, 00000001b   ; A = 01h
    scf               ; Set carry flag
    rra               ; A = 10000000b, C = 1
    
    ; With A = 10000000 (bit 7 set), Carry = 0
    ld a, 10000000b   ; A = 80h
    and a             ; Clear carry flag
    rra               ; A = 01000000b, C = 0
    
    ; With A = 10000000 (bit 7 set), Carry = 1
    ld a, 10000000b   ; A = 80h
    scf               ; Set carry flag
    rra               ; A = 11000000b, C = 0
    
    ; ========= TEST 5: RLC m - Rotate Left Circular (register or memory) =========
    ; Operation: The contents of the location m are rotated left 1 bit position.
    ; The contents of bit 7 are copied to the Carry flag and also to bit 0.
    ; The m operand can be any of: r, (HL), (IX+d), or (IY+d)
    
    ; Example from documentation:
    ; "Register r contains the following data:
    ; 76543210
    ; 10001000
    ; Upon the execution of an RLC r instruction, register r and the Carry flag now contain:
    ; C76543210
    ; 100010001"
    
    ; ===== TEST 5.1: RLC r with example from manual =====
    ld b, 10001000b   ; B = 88h (10001000) as per example
    rlc b             ; Rotate B left, bit 7 to carry and to bit 0
    
    ; Final register state:
    ; B = 00010001b (11h) - result of rotating 10001000 left
    ; Condition bits:
    ; - S is reset (result is positive)
    ; - Z is reset (result is not zero)
    ; - H is reset
    ; - P/V depends on parity of result
    ; - N is reset
    ; - C is set to 1 (previous bit 7)
    
    ; ===== TEST 5.2: RLC r with other registers =====
    ; Testing with register C
    ld c, 01010101b   ; C = 55h (01010101)
    rlc c             ; C = 10101010b (AAh), C flag = 0
    
    ; Testing with register D - zero result
    ld d, 00000000b   ; D = 00h (00000000)
    rlc d             ; D = 00000000b (00h), C flag = 0, Z flag set
    
    ; Testing with register E - negative result
    ld e, 01000000b   ; E = 40h (01000000)
    rlc e             ; E = 10000000b (80h), C flag = 0, S flag set
    
    ; Testing with register H - carry and bit 0 both set
    ld h, 10000000b   ; H = 80h (10000000)
    rlc h             ; H = 00000001b (01h), C flag = 1
    
    ; Testing with register L - all bits set, no change in value
    ld l, 11111111b   ; L = FFh (11111111)
    rlc l             ; L = 11111111b (FFh), C flag = 1
    
    ; Testing with register A
    ld a, 10101010b   ; A = AAh (10101010)
    rlc a             ; A = 01010101b (55h), C flag = 1
    
    ; ===== TEST 5.3: RLC (HL) =====
    ; Example from documentation:
    ; "The HL register pair contains 2828h and the contents of memory location 2828h are:
    ; 76543210
    ; 10001000
    ; Upon the execution of an RLC(HL) instruction, memory location 2828h and the
    ; Carry flag now contain:
    ; C76543210
    ; 100010001"
    
    ; Setup for the example
    ld a, 10001000b         ; Value to store at memory location
    ld (rlc_hl_data), a     ; Store in test memory
    ld hl, rlc_hl_data      ; HL points to our test memory location
    rlc (hl)                ; Rotate the byte at (HL) left
    
    ; Final memory state:
    ; Memory at rlc_hl_data = 00010001b (11h) - rotated value
    ; Condition bits as above
    
    ; ===== TEST 5.4: RLC (IX+d) =====
    ; Example from documentation:
    ; "Index Register IX contains 1000h and memory location 1022h contains:
    ; 76543210
    ; 10001000
    ; Upon the execution of an RLC (IX+2h) instruction, memory location 1002h and the
    ; Carry flag now contain:
    ; C76543210
    ; 100010001"
    
    ; Setup for the example
    ld a, 10001000b          ; Value to store at memory location
    ld (rlc_ix_base+2), a    ; Store at IX+2 offset
    ld ix, rlc_ix_base       ; IX points to our base location
    rlc (ix+2)               ; Rotate the byte at (IX+2) left
    
    ; Final memory state:
    ; Memory at rlc_ix_base+2 = 00010001b (11h) - rotated value
    ; Condition bits as above
    
    ; ===== TEST 5.5: RLC (IY+d) =====
    ; Example from documentation:
    ; "Index Register IY contains 1000h and memory location 1002h contain:
    ; 76543210
    ; 10001000
    ; Upon the execution of an RLC (IY+2h) instruction, memory location 1002h and the
    ; Carry flag now contain:
    ; C76543210
    ; 100010001"
    
    ; Setup for the example
    ld a, 10001000b          ; Value to store at memory location
    ld (rlc_iy_base+2), a    ; Store at IY+2 offset
    ld iy, rlc_iy_base       ; IY points to our base location
    rlc (iy+2)               ; Rotate the byte at (IY+2) left
    
    ; Final memory state:
    ; Memory at rlc_iy_base+2 = 00010001b (11h) - rotated value
    ; Condition bits as above
    
    ; ========= TEST 6: RL m - Rotate Left through Carry (register or memory) =========
    ; Operation: The contents of the m operand are rotated left 1 bit position.
    ; The contents of bit 7 are copied to the Carry flag, and the previous contents of the
    ; Carry flag are copied to bit 0.
    ; The m operand can be any of: r, (HL), (IX+d), or (IY+d)
    
    ; Example from documentation:
    ; "The D Register and the Carry flag contain the following data:
    ; C76543210
    ; 010001111
    ; Upon the execution of an RL D instruction, the D Register and the Carry flag now contain:
    ; C76543210
    ; 100011110"
    
    ; ===== TEST 6.1: RL r with example from manual =====
    ld d, 00011111b   ; D = 1Fh (00011111) as per example
    scf               ; Set carry flag (C=1)
    rl d              ; Rotate D left through carry
    
    ; Final register state:
    ; D = 00111110b (3Eh) - result of rotating 00011111 left with carry=1
    ; Condition bits:
    ; - S is reset (result is positive)
    ; - Z is reset (result is not zero)
    ; - H is reset
    ; - P/V depends on parity of result
    ; - N is reset
    ; - C is set to 0 (previous bit 7)
    
    ; ===== TEST 6.2: RL r with other registers =====
    ; Testing with register B - carry in, carry out
    ld b, 10000000b   ; B = 80h (10000000)
    scf               ; Set carry flag (C=1)
    rl b              ; B = 00000001b (01h), C flag = 1
    
    ; Testing with register C - zero result
    ld c, 00000000b   ; C = 00h (00000000)
    and a             ; Clear carry flag (C=0)
    rl c              ; C = 00000000b (00h), C flag = 0, Z flag set
    
    ; Testing with register E - negative result
    ld e, 01000000b   ; E = 40h (01000000)
    scf               ; Set carry flag (C=1)
    rl e              ; E = 10000001b (81h), C flag = 0, S flag set
    
    ; Testing with register H
    ld h, 11111111b   ; H = FFh (11111111)
    and a             ; Clear carry flag (C=0)
    rl h              ; H = 11111110b (FEh), C flag = 1
    
    ; Testing with register L
    ld l, 01010101b   ; L = 55h (01010101)
    scf               ; Set carry flag (C=1)
    rl l              ; L = 10101011b (ABh), C flag = 0
    
    ; Testing with register A
    ld a, 10101010b   ; A = AAh (10101010)
    scf               ; Set carry flag (C=1)
    rl a              ; A = 01010101b (55h), C flag = 1
    
    ; ===== TEST 6.3: RL (HL) =====
    ; Setup test data
    ld a, 10001000b         ; Value to store at memory location
    ld (rl_hl_data), a      ; Store in test memory
    ld hl, rl_hl_data       ; HL points to our test memory location
    scf                     ; Set carry flag (C=1)
    rl (hl)                 ; Rotate the byte at (HL) left through carry
    
    ; Final memory state:
    ; Memory at rl_hl_data = 00010001b (11h) - rotated value with carry in=1
    
    ; ===== TEST 6.4: RL (IX+d) =====
    ; Setup test data
    ld a, 01110000b          ; Value to store at memory location
    ld (rl_ix_base+5), a     ; Store at IX+5 offset
    ld ix, rl_ix_base        ; IX points to our base location
    and a                    ; Clear carry flag (C=0)
    rl (ix+5)                ; Rotate the byte at (IX+5) left through carry
    
    ; Final memory state:
    ; Memory at rl_ix_base+5 = 11100000b (E0h) - rotated value with carry in=0
    
    ; ===== TEST 6.5: RL (IY+d) =====
    ; Setup test data
    ld a, 11111111b          ; Value to store at memory location
    ld (rl_iy_base-3), a     ; Store at IY-3 offset (negative displacement)
    ld iy, rl_iy_base        ; IY points to our base location
    scf                      ; Set carry flag (C=1)
    rl (iy-3)                ; Rotate the byte at (IY-3) left through carry
    
    ; Final memory state:
    ; Memory at rl_iy_base-3 = 11111111b (FFh) - rotated value with carry in=1
    
    ; ========= TEST 7: RRC m - Rotate Right Circular (register or memory) =========
    ; Operation: The contents of the m operand are rotated right 1 bit position.
    ; The contents of bit 0 are copied to the Carry flag and also to bit 7.
    ; The m operand can be any of: r, (HL), (IX+d), or (IY+d)
    
    ; Example from documentation:
    ; "Register A contains the following data:
    ; 76543210
    ; 00110001
    ; Upon the execution of an RRC A instruction, Register A and the Carry flag now contain:
    ; 76543210C
    ; 100110001"
    
    ; ===== TEST 7.1: RRC r with example from manual =====
    ld a, 00110001b   ; A = 31h (00110001) as per example
    rrc a             ; Rotate A right, bit 0 to carry and to bit 7
    
    ; Final register state:
    ; A = 10011000b (98h) - result of rotating 00110001 right
    ; Condition bits:
    ; - S is set (result is negative)
    ; - Z is reset (result is not zero)
    ; - H is reset
    ; - P/V depends on parity of result
    ; - N is reset
    ; - C is set to 1 (previous bit 0)
    
    ; ===== TEST 7.2: RRC r with other registers =====
    ; Testing with register B
    ld b, 01010101b   ; B = 55h (01010101)
    rrc b             ; B = 10101010b (AAh), C flag = 1
    
    ; Testing with register C - zero result
    ld c, 00000000b   ; C = 00h (00000000)
    rrc c             ; C = 00000000b (00h), C flag = 0, Z flag set
    
    ; Testing with register D
    ld d, 00000001b   ; D = 01h (00000001)
    rrc d             ; D = 10000000b (80h), C flag = 1, S flag set
    
    ; Testing with register E
    ld e, 10000000b   ; E = 80h (10000000)
    rrc e             ; E = 01000000b (40h), C flag = 0
    
    ; Testing with register H - all bits set, no change in value
    ld h, 11111111b   ; H = FFh (11111111)
    rrc h             ; H = 11111111b (FFh), C flag = 1
    
    ; Testing with register L
    ld l, 10101010b   ; L = AAh (10101010)
    rrc l             ; L = 01010101b (55h), C flag = 0
    
    ; ===== TEST 7.3: RRC (HL) =====
    ; Setup test data
    ld a, 00110001b         ; Value to store at memory location
    ld (rrc_hl_data), a     ; Store in test memory
    ld hl, rrc_hl_data      ; HL points to our test memory location
    rrc (hl)                ; Rotate the byte at (HL) right
    
    ; Final memory state:
    ; Memory at rrc_hl_data = 10011000b (98h) - rotated value
    
    ; ===== TEST 7.4: RRC (IX+d) =====
    ; Setup test data
    ld a, 10000001b          ; Value to store at memory location
    ld (rrc_ix_base+4), a    ; Store at IX+4 offset
    ld ix, rrc_ix_base       ; IX points to our base location
    rrc (ix+4)               ; Rotate the byte at (IX+4) right
    
    ; Final memory state:
    ; Memory at rrc_ix_base+4 = 11000000b (C0h) - rotated value
    
    ; ===== TEST 7.5: RRC (IY+d) =====
    ; Setup test data
    ld a, 01010101b          ; Value to store at memory location
    ld (rrc_iy_base-1), a    ; Store at IY-1 offset (negative displacement)
    ld iy, rrc_iy_base       ; IY points to our base location
    rrc (iy-1)               ; Rotate the byte at (IY-1) right
    
    ; Final memory state:
    ; Memory at rrc_iy_base-1 = 10101010b (AAh) - rotated value
    
    ; ========= TEST 8: RR m - Rotate Right through Carry (register or memory) =========
    ; Operation: The contents of operand m are rotated right 1 bit position through the Carry flag.
    ; The contents of bit 0 are copied to the Carry flag and the previous contents of the Carry flag
    ; are copied to bit 7.
    ; The m operand can be any of: r, (HL), (IX+d), or (IY+d)
    
    ; Example from documentation:
    ; "The HL register pair contains 4343h and memory location 4343h and the Carry flag contain
    ; the following data:
    ; 76543210C
    ; 110111010
    ; Upon the execution of an RR (HL) instruction, location 4343h and the Carry flag now contain:
    ; 76543210C
    ; 011011101"
    
    ; ===== TEST 8.1: RR (HL) with example from manual =====
    ; Setup for the example
    ld a, 11011101b         ; Value to store at memory location
    ld (rr_hl_data), a      ; Store in test memory
    ld hl, rr_hl_data       ; HL points to our test memory location
    scf                     ; Set carry flag (C=1)
    rr (hl)                 ; Rotate the byte at (HL) right through carry
    
    ; Final memory state:
    ; Memory at rr_hl_data = 11101110b (EEh) - result of rotating 11011101 right with carry=1
    ; Condition bits:
    ; - S is set (result is negative)
    ; - Z is reset (result is not zero)
    ; - H is reset
    ; - P/V depends on parity of result
    ; - N is reset
    ; - C is set to 1 (previous bit 0)
    
    ; ===== TEST 8.2: RR r =====
    ; Testing with register B - carry in, carry out
    ld b, 00000001b   ; B = 01h (00000001)
    scf               ; Set carry flag (C=1)
    rr b              ; B = 10000000b (80h), C flag = 1, S flag set
    
    ; Testing with register C - zero result
    ld c, 00000000b   ; C = 00h (00000000)
    and a             ; Clear carry flag (C=0)
    rr c              ; C = 00000000b (00h), C flag = 0, Z flag set
    
    ; Testing with register D
    ld d, 10000000b   ; D = 80h (10000000)
    scf               ; Set carry flag (C=1)
    rr d              ; D = 11000000b (C0h), C flag = 0, S flag set
    
    ; Testing with register E
    ld e, 11111111b   ; E = FFh (11111111)
    and a             ; Clear carry flag (C=0)
    rr e              ; E = 01111111b (7Fh), C flag = 1
    
    ; Testing with register H
    ld h, 01010101b   ; H = 55h (01010101)
    scf               ; Set carry flag (C=1)
    rr h              ; H = 10101010b (AAh), C flag = 1, S flag set
    
    ; Testing with register L
    ld l, 10101010b   ; L = AAh (10101010)
    and a             ; Clear carry flag (C=0)
    rr l              ; L = 01010101b (55h), C flag = 0
    
    ; Testing with register A
    ld a, 00000000b   ; A = 00h (00000000)
    scf               ; Set carry flag (C=1)
    rr a              ; A = 10000000b (80h), C flag = 0, S flag set
    
    ; ===== TEST 8.3: RR (IX+d) =====
    ; Setup test data
    ld a, 01110000b          ; Value to store at memory location
    ld (rr_ix_base+3), a     ; Store at IX+3 offset
    ld ix, rr_ix_base        ; IX points to our base location
    scf                      ; Set carry flag (C=1)
    rr (ix+3)                ; Rotate the byte at (IX+3) right through carry
    
    ; Final memory state:
    ; Memory at rr_ix_base+3 = 10111000b (B8h) - rotated value with carry in=1
    
    ; ===== TEST 8.4: RR (IY+d) =====
    ; Setup test data
    ld a, 11111111b          ; Value to store at memory location
    ld (rr_iy_base-5), a     ; Store at IY-5 offset (negative displacement)
    ld iy, rr_iy_base        ; IY points to our base location
    and a                    ; Clear carry flag (C=0)
    rr (iy-5)                ; Rotate the byte at (IY-5) right through carry
    
    ; Final memory state:
    ; Memory at rr_iy_base-5 = 01111111b (7Fh) - rotated value with carry in=0
    
    ; ========= TEST 9: SLA m - Shift Left Arithmetic (register or memory) =========
    ; Operation: An arithmetic shift left 1 bit position is performed on the contents of operand m.
    ; The contents of bit 7 are copied to the Carry flag. Bit 0 is reset.
    ; The m operand can be any of: r, (HL), (IX+d), or (IY+d)
    
    ; Example from documentation:
    ; "Register L contains the following data:
    ; 76543210
    ; 10110001
    ; Upon the execution of an SLA L instruction, Register L and the Carry flag now contain:
    ; C76543210
    ; 101100010"
    
    ; ===== TEST 9.1: SLA r with example from manual =====
    ld l, 10110001b   ; L = B1h (10110001) as per example
    sla l             ; Shift L left arithmetic, bit 7 to carry, bit 0 = 0
    
    ; Final register state:
    ; L = 01100010b (62h) - result of shifting 10110001 left
    ; Condition bits:
    ; - S is reset (result is positive)
    ; - Z is reset (result is not zero)
    ; - H is reset
    ; - P/V depends on parity of result
    ; - N is reset
    ; - C is set to 1 (previous bit 7)
    
    ; ===== TEST 9.2: SLA r with other registers =====
    ; Testing with register B
    ld b, 01010101b   ; B = 55h (01010101)
    sla b             ; B = 10101010b (AAh), C flag = 0, S flag set
    
    ; Testing with register C - zero result
    ld c, 00000000b   ; C = 00h (00000000)
    sla c             ; C = 00000000b (00h), C flag = 0, Z flag set
    
    ; Testing with register D
    ld d, 10000000b   ; D = 80h (10000000)
    sla d             ; D = 00000000b (00h), C flag = 1, Z flag set
    
    ; Testing with register E
    ld e, 11111111b   ; E = FFh (11111111)
    sla e             ; E = 11111110b (FEh), C flag = 1, S flag set
    
    ; Testing with register H
    ld h, 01111111b   ; H = 7Fh (01111111)
    sla h             ; H = 11111110b (FEh), C flag = 0, S flag set
    
    ; Testing with register A
    ld a, 10101010b   ; A = AAh (10101010)
    sla a             ; A = 01010100b (54h), C flag = 1
    
    ; ===== TEST 9.3: SLA (HL) =====
    ; Setup test data
    ld a, 10110001b         ; Value to store at memory location
    ld (sla_hl_data), a     ; Store in test memory
    ld hl, sla_hl_data      ; HL points to our test memory location
    sla (hl)                ; Shift the byte at (HL) left arithmetic
    
    ; Final memory state:
    ; Memory at sla_hl_data = 01100010b (62h) - shifted value
    
    ; ===== TEST 9.4: SLA (IX+d) =====
    ; Setup test data
    ld a, 01110000b          ; Value to store at memory location
    ld (sla_ix_base+3), a    ; Store at IX+3 offset
    ld ix, sla_ix_base       ; IX points to our base location
    sla (ix+3)               ; Shift the byte at (IX+3) left arithmetic
    
    ; Final memory state:
    ; Memory at sla_ix_base+3 = 11100000b (E0h) - shifted value
    
    ; ===== TEST 9.5: SLA (IY+d) =====
    ; Setup test data
    ld a, 11111111b          ; Value to store at memory location
    ld (sla_iy_base-2), a    ; Store at IY-2 offset (negative displacement)
    ld iy, sla_iy_base       ; IY points to our base location
    sla (iy-2)               ; Shift the byte at (IY-2) left arithmetic
    
    ; Final memory state:
    ; Memory at sla_iy_base-2 = 11111110b (FEh) - shifted value
    
    ; ========= TEST 10: SRA m - Shift Right Arithmetic (register or memory) =========
    ; Operation: An arithmetic shift right 1 bit position is performed on the contents of operand m.
    ; The contents of bit 0 are copied to the Carry flag and the previous contents of bit 7 remain unchanged.
    ; The m operand can be any of: r, (HL), (IX+d), or (IY+d)
    
    ; Example from documentation:
    ; "Index Register IX contains 1000h and memory location 1003h contains:
    ; 76543210
    ; 10111000
    ; Upon the execution of an SRA (IX+3h) instruction, memory location 1003h and the
    ; Carry flag now contain:
    ; 76543210C
    ; 110111000"
    
    ; ===== TEST 10.1: SRA (IX+d) with example from manual =====
    ; Setup for the example
    ld a, 10111000b          ; Value to store at memory location
    ld (sra_ix_base+3), a    ; Store at IX+3 offset
    ld ix, sra_ix_base       ; IX points to our base location
    sra (ix+3)               ; Shift the byte at (IX+3) right arithmetic
    
    ; Final memory state:
    ; Memory at sra_ix_base+3 = 11011100b (DCh) - result of shifting 10111000 right
    ; Condition bits:
    ; - S is set (result is negative)
    ; - Z is reset (result is not zero)
    ; - H is reset
    ; - P/V depends on parity of result
    ; - N is reset
    ; - C is set to 0 (previous bit 0)
    
    ; ===== TEST 10.2: SRA r =====
    ; Testing with register B - positive to positive
    ld b, 01010101b   ; B = 55h (01010101)
    sra b             ; B = 00101010b (2Ah), C flag = 1
    
    ; Testing with register C - negative to negative
    ld c, 10000000b   ; C = 80h (10000000)
    sra c             ; C = 11000000b (C0h), C flag = 0, S flag set
    
    ; Testing with register D - zero result
    ld d, 00000001b   ; D = 01h (00000001)
    sra d             ; D = 00000000b (00h), C flag = 1, Z flag set
    
    ; Testing with register E
    ld e, 11111111b   ; E = FFh (11111111)
    sra e             ; E = 11111111b (FFh), C flag = 1, S flag set
    
    ; Testing with register H
    ld h, 00100000b   ; H = 20h (00100000)
    sra h             ; H = 00010000b (10h), C flag = 0
    
    ; Testing with register L
    ld l, 10101011b   ; L = ABh (10101011)
    sra l             ; L = 11010101b (D5h), C flag = 1, S flag set
    
    ; Testing with register A
    ld a, 01000001b   ; A = 41h (01000001)
    sra a             ; A = 00100000b (20h), C flag = 1
    
    ; ===== TEST 10.3: SRA (HL) =====
    ; Setup test data
    ld a, 10111000b         ; Value to store at memory location
    ld (sra_hl_data), a     ; Store in test memory
    ld hl, sra_hl_data      ; HL points to our test memory location
    sra (hl)                ; Shift the byte at (HL) right arithmetic
    
    ; Final memory state:
    ; Memory at sra_hl_data = 11011100b (DCh) - shifted value
    
    ; ===== TEST 10.4: SRA (IY+d) =====
    ; Setup test data
    ld a, 01110001b          ; Value to store at memory location
    ld (sra_iy_base-4), a    ; Store at IY-4 offset (negative displacement)
    ld iy, sra_iy_base       ; IY points to our base location
    sra (iy-4)               ; Shift the byte at (IY-4) right arithmetic
    
    ; Final memory state:
    ; Memory at sra_iy_base-4 = 00111000b (38h) - shifted value
    
    ; ========= TEST 11: SRL m - Shift Right Logical (register or memory) =========
    ; Operation: The contents of operand m are shifted right 1 bit position.
    ; The contents of bit 0 are copied to the Carry flag, and bit 7 is reset.
    ; The m operand can be any of: r, (HL), (IX+d), or (IY+d)
    
    ; Example from documentation:
    ; "Register B contains the following data:
    ; 76543210
    ; 10001111
    ; Upon the execution of an SRL B instruction, Register B and the Carry flag now contain:
    ; 76543210C
    ; 010001111"
    
    ; ===== TEST 11.1: SRL r with example from manual =====
    ld b, 10001111b   ; B = 8Fh (10001111) as per example
    srl b             ; Shift B right logical, bit 0 to carry, bit 7 = 0
    
    ; Final register state:
    ; B = 01000111b (47h) - result of shifting 10001111 right
    ; Condition bits:
    ; - S is reset (result is positive)
    ; - Z is reset (result is not zero)
    ; - H is reset
    ; - P/V depends on parity of result
    ; - N is reset
    ; - C is set to 1 (previous bit 0)
    
    ; ===== TEST 11.2: SRL r with other registers =====
    ; Testing with register C
    ld c, 01010101b   ; C = 55h (01010101)
    srl c             ; C = 00101010b (2Ah), C flag = 1
    
    ; Testing with register D - zero result
    ld d, 00000001b   ; D = 01h (00000001)
    srl d             ; D = 00000000b (00h), C flag = 1, Z flag set
    
    ; Testing with register E
    ld e, 10000000b   ; E = 80h (10000000)
    srl e             ; E = 01000000b (40h), C flag = 0
    
    ; Testing with register H
    ld h, 11111111b   ; H = FFh (11111111)
    srl h             ; H = 01111111b (7Fh), C flag = 1
    
    ; Testing with register L
    ld l, 10101010b   ; L = AAh (10101010)
    srl l             ; L = 01010101b (55h), C flag = 0
    
    ; Testing with register A
    ld a, 00000000b   ; A = 00h (00000000)
    srl a             ; A = 00000000b (00h), C flag = 0, Z flag set
    
    ; ===== TEST 11.3: SRL (HL) =====
    ; Setup test data
    ld a, 10001111b         ; Value to store at memory location
    ld (srl_hl_data), a     ; Store in test memory
    ld hl, srl_hl_data      ; HL points to our test memory location
    srl (hl)                ; Shift the byte at (HL) right logical
    
    ; Final memory state:
    ; Memory at srl_hl_data = 01000111b (47h) - shifted value
    
    ; ===== TEST 11.4: SRL (IX+d) =====
    ; Setup test data
    ld a, 11110000b          ; Value to store at memory location
    ld (srl_ix_base+6), a    ; Store at IX+6 offset
    ld ix, srl_ix_base       ; IX points to our base location
    srl (ix+6)               ; Shift the byte at (IX+6) right logical
    
    ; Final memory state:
    ; Memory at srl_ix_base+6 = 01111000b (78h) - shifted value
    
    ; ===== TEST 11.5: SRL (IY+d) =====
    ; Setup test data
    ld a, 10101010b          ; Value to store at memory location
    ld (srl_iy_base-2), a    ; Store at IY-2 offset (negative displacement)
    ld iy, srl_iy_base       ; IY points to our base location
    srl (iy-2)               ; Shift the byte at (IY-2) right logical
    
    ; Final memory state:
    ; Memory at srl_iy_base-2 = 01010101b (55h) - shifted value
    
    ; ========= TEST 12: RLD - Rotate Digit Left (BCD) =========
    ; Operation: The contents of the low-order four bits of memory location (HL) are copied
    ; to the high-order four bits of that same memory location; the previous contents of those
    ; high-order four bits are copied to the low-order four bits of the Accumulator; and the
    ; previous contents of the low-order four bits of the Accumulator are copied to the low-order
    ; four bits of memory location (HL). The contents of the high-order bits of the Accumulator
    ; are unaffected.
    
    ; Example from documentation:
    ; "The HL register pair contains 5000h and the Accumulator and memory location 5000h contain:
    ; 76543210
    ; 01111010  Accumulator
    ; 00110001  (5000h)
    ; Upon the execution of an RLD instruction, the Accumulator and memory location 5000h
    ; now contain:
    ; 76543210
    ; 01110011  Accumulator
    ; 00011010  (5000h)"
    
    ; ===== TEST 12.1: RLD with example from manual =====
    ; Setup for the example
    ld a, 01111010b         ; A = 7Ah (01111010) as per example
    ld (rld_data), a        ; Store initial accumulator value (for reference)
    ld a, 00110001b         ; Value to store at memory location (HL)
    ld (rld_hl_data), a     ; Store in test memory
    ld a, 01111010b         ; Restore A = 7Ah (01111010)
    ld hl, rld_hl_data      ; HL points to our test memory location
    rld                     ; Execute RLD
    
    ; Final state:
    ; A = 01110011b (73h) - high nibble unchanged, low nibble from (HL) high nibble
    ; Memory at rld_hl_data = 00011010b (1Ah) - high nibble from (HL) low nibble, low nibble from A low nibble
    ; Condition bits:
    ; - S is reset (result in A is positive)
    ; - Z is reset (result in A is not zero)
    ; - H is reset
    ; - P/V depends on parity of result in A
    ; - N is reset
    ; - C is not affected
    
    ; ===== TEST 12.2: RLD with other values =====
    ; Test with zeros
    ld a, 00000000b         ; A = 00h
    ld (rld_hl_data), a     ; (HL) = 00h
    rld                     ; A = 00h, (HL) = 00h (unchanged)
    
    ; Test with all bits set
    ld a, 11111111b         ; A = FFh
    ld (rld_hl_data), a     ; (HL) = FFh
    rld                     ; A = 11111111b (FFh), (HL) = 11111111b (FFh)
    
    ; Test with mixed values
    ld a, 10100101b         ; A = A5h
    ld (rld_hl_data), 00111100b ; (HL) = 3Ch
    rld                     ; A = 10100011b (A3h), (HL) = 01100101b (65h)
    
    ; ========= TEST 13: RRD - Rotate Digit Right (BCD) =========
    ; Operation: The contents of the low-order four bits of the Accumulator are copied to the
    ; high-order four bits of memory location (HL); the previous contents of the low-order four
    ; bits of memory location (HL) are copied to the low-order four bits of the Accumulator; and
    ; the previous contents of the high-order four bits of memory location (HL) are copied to the
    ; low-order four bits of memory location (HL). The contents of the high-order bits of the
    ; Accumulator are unaffected.
    
    ; Example from documentation:
    ; "The HL register pair contains 5000h and the Accumulator and memory location 5000h contain:
    ; 76543210
    ; 10000100  Accumulator
    ; 00100000  (5000h)
    ; Upon the execution of an RRD instruction, the Accumulator and memory location 5000h
    ; now contain:
    ; 76543210
    ; 10000000  Accumulator
    ; 01000010  (5000h)"
    
    ; ===== TEST 13.1: RRD with example from manual =====
    ; Setup for the example
    ld a, 10000100b         ; A = 84h (10000100) as per example
    ld (rrd_data), a        ; Store initial accumulator value (for reference)
    ld a, 00100000b         ; Value to store at memory location (HL)
    ld (rrd_hl_data), a     ; Store in test memory
    ld a, 10000100b         ; Restore A = 84h (10000100)
    ld hl, rrd_hl_data      ; HL points to our test memory location
    rrd                     ; Execute RRD
    
    ; Final state:
    ; A = 10000000b (80h) - high nibble unchanged, low nibble from (HL) low nibble
    ; Memory at rrd_hl_data = 01000010b (42h) - high nibble from A low nibble, low nibble from (HL) high nibble
    ; Condition bits:
    ; - S is set (result in A is negative)
    ; - Z is reset (result in A is not zero)
    ; - H is reset
    ; - P/V depends on parity of result in A
    ; - N is reset
    ; - C is not affected
    
    ; ===== TEST 13.2: RRD with other values =====
    ; Test with zeros
    ld a, 00000000b         ; A = 00h
    ld (rrd_hl_data), a     ; (HL) = 00h
    rrd                     ; A = 00h, (HL) = 00h (unchanged)
    
    ; Test with all bits set
    ld a, 11111111b         ; A = FFh
    ld (rrd_hl_data), a     ; (HL) = FFh
    rrd                     ; A = 11111111b (FFh), (HL) = 11111111b (FFh)
    
    ; Test with mixed values
    ld a, 10100101b         ; A = A5h
    ld (rrd_hl_data), 00111100b ; (HL) = 3Ch
    rrd                     ; A = 1010000b (A0h), (HL) = 00111101b (3Dh)
    
    ; ========= END TEST AREA =========
    
    jr $          ; Infinite loop

; Data section
rlc_hl_data:    ; Data for RLC (HL) test
    db 0

rlc_ix_base:    ; Base address for RLC (IX+d) test
    defs 10, 0   ; Reserve 10 bytes for IX tests

rlc_iy_base:    ; Base address for RLC (IY+d) test
    defs 10, 0   ; Reserve 10 bytes for IY tests

rl_hl_data:     ; Data for RL (HL) test
    db 0

rl_ix_base:     ; Base address for RL (IX+d) test
    defs 10, 0   ; Reserve 10 bytes for IX tests

rl_iy_base:     ; Base address for RL (IY+d) test
    defs 10, 0   ; Reserve 10 bytes for IY tests

rrc_hl_data:    ; Data for RRC (HL) test
    db 0

rrc_ix_base:    ; Base address for RRC (IX+d) test
    defs 10, 0   ; Reserve 10 bytes for IX tests

rrc_iy_base:    ; Base address for RRC (IY+d) test
    defs 10, 0   ; Reserve 10 bytes for IY tests

rr_hl_data:     ; Data for RR (HL) test
    db 0

rr_ix_base:     ; Base address for RR (IX+d) test
    defs 10, 0   ; Reserve 10 bytes for IX tests

rr_iy_base:     ; Base address for RR (IY+d) test
    defs 10, 0   ; Reserve 10 bytes for IY tests

sla_hl_data:    ; Data for SLA (HL) test
    db 0

sla_ix_base:    ; Base address for SLA (IX+d) test
    defs 10, 0   ; Reserve 10 bytes for IX tests

sla_iy_base:    ; Base address for SLA (IY+d) test
    defs 10, 0   ; Reserve 10 bytes for IY tests

sra_hl_data:    ; Data for SRA (HL) test
    db 0

sra_ix_base:    ; Base address for SRA (IX+d) test
    defs 10, 0   ; Reserve 10 bytes for IX tests

sra_iy_base:    ; Base address for SRA (IY+d) test
    defs 10, 0   ; Reserve 10 bytes for IY tests

srl_hl_data:    ; Data for SRL (HL) test
    db 0

srl_ix_base:    ; Base address for SRL (IX+d) test
    defs 10, 0   ; Reserve 10 bytes for IX tests

srl_iy_base:    ; Base address for SRL (IY+d) test
    defs 10, 0   ; Reserve 10 bytes for IY tests

rld_data:       ; Store initial A value for RLD test (for reference)
    db 0

rld_hl_data:    ; Data for RLD test
    db 0

rrd_data:       ; Store initial A value for RRD test (for reference)
    db 0

rrd_hl_data:    ; Data for RRD test
    db 0

stack_bottom:   ; 100 bytes of stack
    defs 100, 0
stack_top:
    END
