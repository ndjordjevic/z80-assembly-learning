; Z80 Assembly - General-Purpose Arithmetic and CPU Control Instructions
; This file contains tests for the Z80 General-Purpose Arithmetic and CPU Control instructions:
;   1. DAA - Decimal Adjust Accumulator
;   2. CPL - Complement Accumulator
;   3. NEG - Negate Accumulator
;   4. CCF - Complement Carry Flag
;   5. SCF - Set Carry Flag
;   6. NOP - No Operation
;   7. HALT - Halt CPU
;   8. DI - Disable Interrupts
;   9. EI - Enable Interrupts
;  10. IM 0 - Interrupt Mode 0
;  11. IM 1 - Interrupt Mode 1
;  12. IM 2 - Interrupt Mode 2

    DEVICE NOSLOT64K
    SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION

    org 0       ; Program starts at address 0 in memory

main:
    ld sp, stack_top  ; Initialize stack pointer
    
    ; ========= TEST 1: DAA - Decimal Adjust Accumulator =========
    ; Operation: Adjusts A for BCD addition and subtraction
    ; Description: This instruction conditionally adjusts the Accumulator for BCD addition and subtraction
    ; operations. For addition (ADD, ADC, INC) or subtraction (SUB, SBC, DEC, NEG), it corrects the
    ; binary result in the Accumulator to a valid BCD representation.
    
    ; The DAA table indicates the operation performed based on:
    ; - The current value in A (upper and lower digits)
    ; - The H (Half Carry) and C (Carry) flags
    ; - The N (Add/Subtract) flag which indicates the last operation
    
    ; After DAA:
    ; - S is set if MSB of A is 1
    ; - Z is set if A is 0
    ; - H depends on the operation performed by DAA
    ; - P/V is set if A has even parity
    ; - N is not affected
    ; - C depends on the operation performed by DAA
    
    ; Example from documentation:
    ; An addition operation is performed between 15 (BCD) and 27 (BCD)
    ; The binary representations are added in the Accumulator:
    ; 0001 0101 (15 BCD) + 0010 0111 (27 BCD) = 0011 1100 (3Ch)
    ; The sum is ambiguous in BCD. The DAA instruction adjusts this result:
    ; 0011 1100 + 0000 0110 = 0100 0010 (42 BCD)
    
    ; ===== TEST 1.1: DAA after Addition =====
    ; Test the example from documentation: 15 + 27 = 42 in BCD
    
    ld a, 15h      ; A = 15h (15 BCD)
    ld b, 27h      ; B = 27h (27 BCD)
    add a, b       ; A = 15h + 27h = 3Ch (binary result)
    daa            ; Decimal adjust A to get 42h (42 BCD)
    
    ; Final register state:
    ; A = 42h (42 BCD) - correct BCD result of 15 + 27
    ; B = 27h (27 BCD) - unchanged
    ; Condition bits:
    ; - S is reset (result is positive)
    ; - Z is reset (result is not zero)
    ; - H depends on the operation 
    ; - P/V depends on parity of result
    ; - N was reset from the ADD operation
    ; - C is reset (no carry needed for adjustment)
    
    ; Additional test case: 56 + 47 = 103 in BCD (requires carry)
    ld a, 56h      ; A = 56h (56 BCD)
    ld b, 47h      ; B = 47h (47 BCD)
    add a, b       ; A = 56h + 47h = 9Dh (binary result)
    daa            ; Decimal adjust A to get 03h with carry flag set (103 BCD)
    
    ; Result: A = 03h, C = 1 (representing 103 BCD)
    
    ; Test case with single-digit overflow: 9 + 1 = 10 in BCD
    ld a, 09h      ; A = 09h (9 BCD)
    ld b, 01h      ; B = 01h (1 BCD)
    add a, b       ; A = 09h + 01h = 0Ah (binary result)
    daa            ; Decimal adjust A to get 10h (10 BCD)
    
    ; Result: A = 10h (10 BCD)
    
    ; ===== TEST 1.2: DAA after ADC =====
    ; Test with carry: 99 + 99 + 1 = 199 in BCD
    
    ld a, 99h      ; A = 99h (99 BCD)
    ld b, 99h      ; B = 99h (99 BCD)
    scf            ; Set carry flag (C = 1)
    adc a, b       ; A = 99h + 99h + 1 = 33h with carry (binary result)
    daa            ; Decimal adjust A to get 99h with carry (199 BCD)
    
    ; Result: A = 99h, C = 1 (representing 199 BCD)
    
    ; ===== TEST 1.3: DAA after Subtraction =====
    ; Test subtraction: 42 - 17 = 25 in BCD
    
    ld a, 42h      ; A = 42h (42 BCD)
    ld b, 17h      ; B = 17h (17 BCD)
    sub b          ; A = 42h - 17h = 2Bh (binary result)
    daa            ; Decimal adjust A to get 25h (25 BCD)
    
    ; Result: A = 25h (25 BCD)
    
    ; Test subtraction with borrow: 25 - 47 = -22 in BCD
    ld a, 25h      ; A = 25h (25 BCD)
    ld b, 47h      ; B = 47h (47 BCD)
    sub b          ; A = 25h - 47h = DEh (binary result)
    daa            ; Decimal adjust A with proper BCD representation
    
    ; Result will have carry flag set (indicating borrow/negative)
    
    ; ===== TEST 1.4: DAA after SBC =====
    ; Test subtraction with borrow: 42 - 17 - 1 = 24 in BCD
    
    ld a, 42h      ; A = 42h (42 BCD)
    ld b, 17h      ; B = 17h (17 BCD)
    scf            ; Set carry flag (C = 1)
    sbc a, b       ; A = 42h - 17h - 1 = 2Ah (binary result)
    daa            ; Decimal adjust A to get 24h (24 BCD)
    
    ; Result: A = 24h (24 BCD)
    
    ; ===== TEST 1.5: DAA after INC/DEC =====
    ; Test increment: 99 + 1 = 100 in BCD
    
    ld a, 99h      ; A = 99h (99 BCD)
    inc a          ; A = 99h + 1 = 9Ah (binary result)
    daa            ; Decimal adjust A to get 00h with carry (100 BCD)
    
    ; Result: A = 00h, C = 1 (representing 100 BCD)
    
    ; Test decrement: 10 - 1 = 09 in BCD
    ld a, 10h      ; A = 10h (10 BCD)
    dec a          ; A = 10h - 1 = 0Fh (binary result)
    daa            ; Decimal adjust A to get 09h (9 BCD)
    
    ; Result: A = 09h (9 BCD)
    
    ; ===== TEST 1.6: DAA after NEG =====
    ; Test negation: -42 in BCD
    
    ld a, 42h      ; A = 42h (42 BCD)
    neg            ; A = 00h - 42h = BEh (binary result)
    daa            ; Decimal adjust A with proper BCD representation
    
    ; Result will have carry flag set (indicating negative number)
    
    ; ========= TEST 2: CPL - Complement Accumulator =========
    ; Operation: A ← Ā (One's complement)
    ; Description: The contents of the Accumulator (Register A) are inverted (one's complement).
    ; This performs a bitwise NOT operation on the accumulator.
    
    ; After CPL:
    ; - S is not affected
    ; - Z is not affected
    ; - H is set
    ; - P/V is not affected
    ; - N is set
    ; - C is not affected
    
    ; Example from documentation:
    ; If the Accumulator contains 1011 0100 (B4h), then upon the execution of a CPL instruction, 
    ; the Accumulator contains 0100 1011 (4Bh).
    
    ; Setup for our example
    ld a, 0B4h     ; A = B4h (1011 0100) as per the example
    cpl            ; Complement A: A becomes 4Bh (0100 1011)
    
    ; Final register state:
    ; A = 4Bh (0100 1011) - result of complementing B4h
    ; Condition bits:
    ; - S is unchanged
    ; - Z is unchanged
    ; - H is set
    ; - P/V is unchanged
    ; - N is set
    ; - C is unchanged
    
    ; Additional test cases for CPL
    ld a, 00h      ; A = 00h (0000 0000)
    cpl            ; A = FFh (1111 1111)
    
    ld a, 0FFh     ; A = FFh (1111 1111)
    cpl            ; A = 00h (0000 0000)
    
    ld a, 0AAh     ; A = AAh (1010 1010)
    cpl            ; A = 55h (0101 0101)
    
    ; ========= TEST 3: NEG - Negate Accumulator =========
    ; Operation: A ← 0 - A (Two's complement)
    ; Description: The contents of the Accumulator are negated (two's complement). 
    ; This method is the same as subtracting the contents of the Accumulator from zero.
    ; Note: The special case 80h (-128) remains unchanged after negation (in two's complement).
    
    ; After NEG:
    ; - S is set if result is negative; otherwise, it is reset
    ; - Z is set if result is 0; otherwise, it is reset
    ; - H is set if borrow from bit 4; otherwise, it is reset
    ; - P/V is set if Accumulator was 80h before operation; otherwise, it is reset
    ; - N is set
    ; - C is set if Accumulator was not 00h before operation; otherwise, it is reset
    
    ; Example from documentation:
    ; If the Accumulator contains 10011000 (98h), then upon the execution of a NEG instruction, 
    ; the Accumulator contains 01101000 (68h).
    
    ; Setup for our example
    ld a, 98h      ; A = 98h (1001 1000) as per the example
    neg            ; Negate A: A becomes 68h (0110 1000)
    
    ; Final register state:
    ; A = 68h (0110 1000) - result of negating 98h
    ; Condition bits:
    ; - S is reset (result is positive)
    ; - Z is reset (result is not zero)
    ; - H is set (borrow from bit 4)
    ; - P/V is reset (A was not 80h before operation)
    ; - N is set
    ; - C is set (A was not 00h before operation)
    
    ; Additional test cases for NEG
    ld a, 00h      ; A = 00h (0000 0000)
    neg            ; A = 00h (0000 0000) - negating 0 gives 0
    
    ; Final state after negating 00h:
    ; - Z is set (result is zero)
    ; - C is reset (A was 00h before operation)
    
    ld a, 01h      ; A = 01h (0000 0001)
    neg            ; A = FFh (1111 1111) - negating 1 gives -1
    
    ; Final state after negating 01h:
    ; - S is set (result is negative)
    ; - C is set (A was not 00h before operation)
    
    ld a, 80h      ; A = 80h (1000 0000) - special case: most negative number
    neg            ; A = 80h (1000 0000) - remains unchanged
    
    ; Final state after negating 80h:
    ; - S is set (result is negative)
    ; - P/V is set (A was 80h before operation)
    ; - C is set (A was not 00h before operation)
    
    ld a, 0FFh     ; A = FFh (1111 1111) = -1
    neg            ; A = 01h (0000 0001) = 1
    
    ; ========= TEST 4: CCF - Complement Carry Flag =========
    ; Operation: CY ← CY̅ (Inverts carry flag)
    ; Description: The Carry flag (C) in the F Register is inverted.
    
    ; After CCF:
    ; - S is not affected
    ; - Z is not affected
    ; - H contains the previous value of the Carry flag
    ; - P/V is not affected
    ; - N is reset
    ; - C is inverted (set if it was reset, reset if it was set)
    
    ; Test with carry flag initially reset
    scf            ; Set carry flag
    ccf            ; Complement carry flag - now reset
    
    ; Final state:
    ; - H is set (previous carry was set)
    ; - N is reset
    ; - C is reset (was set before)
    
    ; Test with carry flag initially set
    scf            ; Set carry flag
    ccf            ; Complement carry flag - now reset
    ccf            ; Complement carry flag again - now set
    
    ; Final state:
    ; - H is reset (previous carry was reset)
    ; - N is reset
    ; - C is set (was reset before)
    
    ; ========= TEST 5: SCF - Set Carry Flag =========
    ; Operation: CY ← 1
    ; Description: The Carry flag (C) in the F Register is set.
    
    ; After SCF:
    ; - S is not affected
    ; - Z is not affected
    ; - H is reset
    ; - P/V is not affected
    ; - N is reset
    ; - C is set
    
    ; Test with carry flag initially reset
    ccf            ; Complement carry flag to ensure it's reset (if it was set)
    ccf            ; Complement again to ensure it's set (if it was reset)
    scf            ; Set carry flag
    
    ; Final state:
    ; - H is reset
    ; - N is reset
    ; - C is set
    
    ; Test with carry flag already set
    scf            ; Set carry flag
    scf            ; Set carry flag again
    
    ; Final state:
    ; - H is reset
    ; - N is reset
    ; - C is set (still)
    
    ; ========= TEST 6: NOP - No Operation =========
    ; Operation: — (No operation)
    ; Description: The CPU performs no operation during this machine cycle.
    
    ; After NOP:
    ; - No flags are affected
    
    ; Test NOP
    nop            ; No operation
    
    ; Multiple NOPs are sometimes used for timing or padding
    nop
    nop
    nop
    
    ; ========= TEST 7: HALT - Halt CPU =========
    ; Operation: — (CPU operation suspended)
    ; Description: The HALT instruction suspends CPU operation until a subsequent interrupt
    ; or reset is received. While in the HALT state, the processor executes NOPs
    ; to maintain memory refresh logic.
    
    ; After HALT:
    ; - No flags are affected
    
    ; Note: In a real system, HALT would stop execution until an interrupt occurs.
    ; In our test environment, we'll comment it out to continue execution.
    
    ; Uncomment to test HALT functionality:
    ; halt          ; CPU halts until an interrupt occurs
    
    ; ========= TEST 8: DI - Disable Interrupts =========
    ; Operation: IFF ← 0
    ; Description: DI disables the maskable interrupt by resetting the interrupt enable
    ; flip-flops (IFF1 and IFF2).
    
    ; After DI:
    ; - No flags are affected
    ; - Both interrupt enable flip-flops are reset
    
    di             ; Disable maskable interrupts
    
    ; Note: When the CPU executes DI, maskable interrupts are disabled until
    ; subsequently re-enabled by an EI instruction.
    
    ; ========= TEST 9: EI - Enable Interrupts =========
    ; Operation: IFF ← 1
    ; Description: The enable interrupt instruction sets both interrupt enable flip-flops
    ; (IFF1 and IFF2) to logic 1, allowing recognition of any maskable interrupt.
    
    ; After EI:
    ; - No flags are affected
    ; - Both interrupt enable flip-flops are set
    ; - Note: Maskable interrupts are disabled during execution of EI and the following instruction
    
    ei             ; Enable maskable interrupts
    
    ; Note: When the CPU executes EI, maskable interrupts become enabled
    ; after the following instruction completes.
    
    nop            ; Interrupts are still disabled during this instruction
    
    ; At this point, interrupts would be enabled in a real system
    
    ; ========= TEST 10: IM 0 - Interrupt Mode 0 =========
    ; Operation: Set Interrupt Mode 0
    ; Description: The IM 0 instruction sets Interrupt Mode 0. In this mode, the interrupting
    ; device can insert any instruction on the data bus for execution by the CPU.
    ; The first byte of a multi-byte instruction is read during the interrupt acknowledge cycle.
    ; Subsequent bytes are read in by a normal memory read sequence.
    
    ; After IM 0:
    ; - No flags are affected
    ; - Interrupt mode is set to 0
    
    im 0           ; Set interrupt mode 0
    
    ; ========= TEST 11: IM 1 - Interrupt Mode 1 =========
    ; Operation: Set Interrupt Mode 1
    ; Description: The IM 1 instruction sets Interrupt Mode 1. In this mode, the processor
    ; responds to an interrupt by executing a restart at address 0038h.
    
    ; After IM 1:
    ; - No flags are affected
    ; - Interrupt mode is set to 1
    
    im 1           ; Set interrupt mode 1
    
    ; ========= TEST 12: IM 2 - Interrupt Mode 2 =========
    ; Operation: Set Interrupt Mode 2
    ; Description: The IM 2 instruction sets the vectored Interrupt Mode 2. This mode allows
    ; an indirect call to any memory location by an 8-bit vector supplied from the peripheral device.
    ; This vector becomes the least-significant eight bits of the indirect pointer, while the I Register
    ; in the CPU provides the most-significant eight bits. This address points to an address in a
    ; vector table that is the starting address for the interrupt service routine.
    
    ; After IM 2:
    ; - No flags are affected
    ; - Interrupt mode is set to 2
    
    ; Setup I register for IM 2 (in a real system)
    ld a, 0xD0     ; High byte of interrupt vector table (D000h-D0FFh)
    ld i, a        ; Load I register with high byte
    
    im 2           ; Set interrupt mode 2
    
    ; In a real system with IM 2:
    ; 1. When an interrupt occurs, CPU performs an acknowledge cycle
    ; 2. Interrupting device places a byte (vector) on the data bus
    ; 3. CPU forms a 16-bit address using I register as high byte and the vector as low byte
    ; 4. From this address, CPU reads a 16-bit address which is the start of ISR
    ; 5. CPU jumps to that address to service the interrupt
    
    ; ========= END TEST AREA =========
    
    jr $          ; Infinite loop

; Data section
stack_bottom:   ; 100 bytes of stack
    defs 100, 0
stack_top:
    END
