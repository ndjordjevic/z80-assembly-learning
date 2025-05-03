; Z80 Assembly - 16-Bit Load Group Instructions Testing
; This file contains tests for the Z80 16-bit load group instructions:
;   1. LD dd, nn - Load immediate value into register pair
;   2. LD IX, nn - Load immediate value into IX register
;   3. LD IY, nn - Load immediate value into IY register
;   4. LD HL, (nn) - Load HL from direct memory address
;   5. LD dd, (nn) - Load register pair from direct memory address
;   6. LD IX, (nn) - Load IX from direct memory address
;   7. LD IY, (nn) - Load IY from direct memory address
;   8. LD (nn), HL - Store HL to direct memory address
;   9. LD (nn), dd - Store register pair to direct memory address
;  10. LD (nn), IX - Store IX to direct memory address
;  11. LD (nn), IY - Store IY to direct memory address
;  12. LD SP, HL - Load Stack Pointer from HL
;  13. LD SP, IX - Load Stack Pointer from IX
;  14. LD SP, IY - Load Stack Pointer from IY
;  15. PUSH qq - Push register pair onto stack
;  16. PUSH IX - Push IX register onto stack
;  17. PUSH IY - Push IY register onto stack
;  18. POP qq - Pop from stack to register pair
;  19. POP IX - Pop from stack to IX register
;  20. POP IY - Pop from stack to IY register

    DEVICE NOSLOT64K
    SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION

    org 0       ; Program starts at address 0 in memory

main:
    ld sp, stack_top  ; Initialize stack pointer
    
    ; ========= TEST 1: LD dd, nn =========
    ; Operation: dd ← nn
    ; Description: The 16-bit immediate value nn is loaded to register pair dd
    ; Where dd can be BC, DE, HL, or SP
    
    ; Example from documentation:
    ; "Upon the execution of an LD HL, 5000h instruction, the HL register pair contains 5000h."
    
    ; Load immediate values into all register pairs
    ld bc, 1234h      ; BC = 1234h (4660)
    ld de, 5678h      ; DE = 5678h (22136)
    ld hl, 5000h      ; HL = 5000h (20480) - as per the example
    ld sp, 9ABCh      ; SP = 9ABCh (39612)
    
    ; Final register state:
    ; BC = 1234h (4660)
    ; DE = 5678h (22136)
    ; HL = 5000h (20480)
    ; SP = 9ABCh (39612)
    ; Condition bits: Not affected
    
    ; ========= TEST 2: LD IX, nn =========
    ; Operation: IX ← nn
    ; Description: The 16-bit immediate value nn is loaded to index register IX
    
    ; Example from documentation:
    ; "Upon the execution of an LD IX, 45A2h instruction, the index register contains
    ; integer 45A2h."
    
    ld ix, 45A2h      ; IX = 45A2h (17826) - as per the example
    
    ; Final register state:
    ; IX = 45A2h (17826)
    ; Condition bits: Not affected
    
    ; ========= TEST 3: LD IY, nn =========
    ; Operation: IY ← nn
    ; Description: The 16-bit immediate value nn is loaded to index register IY
    
    ; Example from documentation:
    ; "Upon the execution of a LD IY, 7733h instruction, Index Register IY contains the integer
    ; 7733h."
    
    ld iy, 7733h      ; IY = 7733h (30515) - as per the example
    
    ; Final register state:
    ; IY = 7733h (30515)
    ; Condition bits: Not affected
    
    ; ========= TEST 4: LD HL, (nn) =========
    ; Operation: H ← (nn + 1), L ← (nn)
    ; Description: The contents of memory address (nn) are loaded to the low-order portion of register pair
    ; HL (Register L), and the contents of the next highest memory address (nn + 1) are loaded
    ; to the high-order portion of HL (Register H)
    
    ; Example from documentation:
    ; "If address 4545h contains 37h and address 4546h contains A1h, then upon the execution
    ; of an LD HL, (4545h) instruction, the HL register pair contains A137h."
    
    ld hl, (test_addr_4545)     ; HL = (test_addr_4545) = A137h as per the example
    
    ; Final register state:
    ; HL = A137h (41271)
    ; Condition bits: Not affected
    
    ; ========= TEST 5: LD dd, (nn) =========
    ; Operation: ddh ← (nn + 1), ddl ← (nn)
    ; Description: The contents of address (nn) are loaded to the low-order portion of register pair dd, and the
    ; contents of the next highest memory address (nn + 1) are loaded to the high-order portion of dd
    ; Where dd can be BC, DE, HL, or SP
    
    ; Example from documentation:
    ; "If Address 2130h contains 65h and address 2131h contains 78h, then upon the execution
    ; of an LD BC, (2130h) instruction, the BC register pair contains 7865h."
    
    ; We'll use our predefined test data for this example
    ld bc, (test_addr_2130)     ; BC = (test_addr_2130) = 7865h as per the example
    
    ; Final register state:
    ; BC = 7865h (30821)
    ; Condition bits: Not affected
    
    ; ========= TEST 6: LD IX, (nn) =========
    ; Operation: IXh ← (nn + 1), IXl ← (nn)
    ; Description: The contents of the address (nn) are loaded to the low-order portion of Index Register IX,
    ; and the contents of the next highest memory address (nn + 1) are loaded to the high-order
    ; portion of IX
    
    ; Example from documentation:
    ; "If address 6666h contains 92h, and address 6667h contains DAh, then upon the execution
    ; of an LD IX, (6666h) instruction, Index Register IX contains DA92h."
    
    ; We'll use our predefined test data for this example
    ld ix, (test_addr_6666)     ; IX = (test_addr_6666) = DA92h as per the example
    
    ; Final register state:
    ; IX = DA92h (55954)
    ; Condition bits: Not affected
    
    ; ========= TEST 7: LD IY, (nn) =========
    ; Operation: IYh ← (nn + 1), IYl ← (nn)
    ; Description: The contents of address (nn) are loaded to the low-order portion of Index Register IY, and
    ; the contents of the next highest memory address (nn + 1) are loaded to the high-order portion of IY
    
    ; Example from documentation:
    ; "If address 6666h contains 92h, and address 6667h contains DAh, then upon the execution
    ; of an LD IY, (6666h) instruction, Index Register IY contains DA92h."
    
    ; We'll use our predefined test data for this example (the same data as for IX since the example is identical)
    ld iy, (test_addr_6666)     ; IY = (test_addr_6666) = DA92h as per the example
    
    ; Final register state:
    ; IY = DA92h (55954)
    ; Condition bits: Not affected
    
    ; ========= TEST 8: LD (nn), HL =========
    ; Operation: (nn + 1) ← H, (nn) ← L
    ; Description: The contents of the low-order portion of register pair HL (Register L) are loaded to memory
    ; address (nn), and the contents of the high-order portion of HL (Register H) are loaded
    ; to the next highest memory address (nn + 1)
    
    ; Example from documentation:
    ; "If register pair HL contains 483Ah, then upon the execution of an LD (B229h), HL
    ; instruction, address B229h contains 3Ah and address B22Ah contains 48h."
    
    ld hl, 483Ah             ; HL = 483Ah (18490) as per the example
    ld (hl_output_addr), hl  ; Store HL to memory at hl_output_addr and hl_output_addr+1
    
    ; Final state:
    ; HL = 483Ah (18490)
    ; memory at hl_output_addr = 3Ah (58) - low byte of HL
    ; memory at hl_output_addr+1 = 48h (72) - high byte of HL
    ; Condition bits: Not affected
    
    ; ========= TEST 9: LD (nn), dd =========
    ; Operation: (nn + 1) ← ddh, (nn) ← ddl
    ; Description: The low-order byte of register pair dd is loaded to memory address (nn); the upper byte is
    ; loaded to memory address (nn + 1). Register pair dd defines either BC, DE, HL, or SP
    
    ; Example from documentation:
    ; "If register pair BC contains the number 4644h, the instruction LD (1000h), BC results in
    ; 44h in memory location 1000h, and 46h in memory location 1001h."
    
    ld bc, 4644h               ; BC = 4644h (17988) as per the example
    ld (dd_output_addr), bc    ; Store BC to memory at dd_output_addr and dd_output_addr+1
    
    ; Final state:
    ; BC = 4644h (17988)
    ; memory at dd_output_addr = 44h (68) - low byte of BC
    ; memory at dd_output_addr+1 = 46h (70) - high byte of BC
    ; Condition bits: Not affected
    
    ; ========= TEST 10: LD (nn), IX =========
    ; Operation: (nn + 1) ← IXh, (nn) ← IXl
    ; Description: The low-order byte in Index Register IX is loaded to memory address (nn); the upper order
    ; byte is loaded to the next highest address (nn + 1)
    
    ; Example from documentation:
    ; "If Index Register IX contains 5A30h, then upon the execution of an LD (4392h), IX
    ; instruction, memory location 4392h contains number 30h and location 4393h contains
    ; 5Ah."
    
    ld ix, 5A30h                ; IX = 5A30h (23088) as per the example
    ld (ix_output_addr), ix     ; Store IX to memory at ix_output_addr and ix_output_addr+1
    
    ; Final state:
    ; IX = 5A30h (23088)
    ; memory at ix_output_addr = 30h (48) - low byte of IX
    ; memory at ix_output_addr+1 = 5Ah (90) - high byte of IX
    ; Condition bits: Not affected
    
    ; ========= TEST 11: LD (nn), IY =========
    ; Operation: (nn + 1) ← IYh, (nn) ← IYl
    ; Description: The low-order byte in Index Register IY is loaded to memory address (nn); the upper order
    ; byte is loaded to memory location (nn + 1)
    
    ; Example from documentation:
    ; "If Index Register IY contains 4174h, then upon the execution of an LD (8838h), IY
    ; instruction, memory location 8838h contains 74h and memory location 8839h contains
    ; 41h."
    
    ld iy, 4174h                ; IY = 4174h (16756) as per the example
    ld (iy_output_addr), iy     ; Store IY to memory at iy_output_addr and iy_output_addr+1
    
    ; Final state:
    ; IY = 4174h (16756)
    ; memory at iy_output_addr = 74h (116) - low byte of IY
    ; memory at iy_output_addr+1 = 41h (65) - high byte of IY
    ; Condition bits: Not affected
    
    ; ========= TEST 12: LD SP, HL =========
    ; Operation: SP ← HL
    ; Description: The contents of the register pair HL are loaded to the Stack Pointer (SP)
    
    ; Example from documentation:
    ; "If the register pair HL contains 442Eh, then upon the execution of an LD SP, HL
    ; instruction, the Stack Pointer also contains 442Eh."
    
    ; Preserve the current stack pointer first
    ld (old_sp), sp        ; Save current SP value so we can restore it later
    
    ; Now perform the test
    ld hl, 442Eh           ; HL = 442Eh (17454) as per the example
    ld sp, hl              ; SP = HL = 442Eh (17454)
    
    ; Final state:
    ; HL = 442Eh (17454)
    ; SP = 442Eh (17454) - copied from HL
    ; Condition bits: Not affected
    
    ; Restore the original stack pointer
    ld sp, (old_sp)        ; Restore SP to its original value
    
    ; ========= TEST 13: LD SP, IX =========
    ; Operation: SP ← IX
    ; Description: The 2-byte contents of Index Register IX are loaded to the Stack Pointer (SP)
    
    ; Example from documentation:
    ; "If Index Register IX contains 98DAh, then upon the execution of an LD SP, IX instruction,
    ; the Stack Pointer also contains 98DAh."
    
    ; Preserve the current stack pointer
    ld (old_sp2), sp        ; Save current SP value so we can restore it later
    
    ; Now perform the test
    ld ix, 98DAh            ; IX = 98DAh (39130) as per the example
    ld sp, ix               ; SP = IX = 98DAh (39130)
    
    ; Final state:
    ; IX = 98DAh (39130)
    ; SP = 98DAh (39130) - copied from IX
    ; Condition bits: Not affected
    
    ; Restore the original stack pointer
    ld sp, (old_sp2)        ; Restore SP to its original value
    
    ; ========= TEST 14: LD SP, IY =========
    ; Operation: SP ← IY
    ; Description: The 2-byte contents of Index Register IY are loaded to the Stack Pointer SP
    
    ; Example from documentation:
    ; "If Index Register IY contains the integer A227h, then upon the execution of an LD SP, IY
    ; instruction, the Stack Pointer also contains A227h."
    
    ; Preserve the current stack pointer
    ld (old_sp3), sp        ; Save current SP value so we can restore it later
    
    ; Now perform the test
    ld iy, 0A227h           ; IY = A227h (41511) as per the example
    ld sp, iy               ; SP = IY = A227h (41511)
    
    ; Final state:
    ; IY = A227h (41511)
    ; SP = A227h (41511) - copied from IY
    ; Condition bits: Not affected
    
    ; Restore the original stack pointer
    ld sp, (old_sp3)        ; Restore SP to its original value
    
    ; ========= TEST 15: PUSH qq =========
    ; Operation: (SP – 2) ← qqL, (SP – 1) ← qqH
    ; Description: The contents of the register pair qq are pushed to the external memory last-in, first-out
    ; (LIFO) stack. SP is decremented twice.
    
    ; Example from documentation (adapted for BC register pair):
    ; "If the BC register pair contains 2233h and the Stack Pointer contains 1007h, then upon
    ; the execution of a PUSH BC instruction, memory address 1006h contains 22h, memory
    ; address 1005h contains 33h, and the Stack Pointer contains 1005h."
    
    ; Setup for our example - We'll use our own stack area
    ld sp, push_test_stack_top   ; Set up a test stack area
    
    ; We'll use BC register pair instead of AF to make it simpler
    ld bc, 2233h                 ; BC = 2233h (8755) - similar to the example
    push bc                      ; Push BC onto the stack
    
    ; At this point:
    ; - memory at push_test_stack_top-1 contains 22h (high byte of BC)
    ; - memory at push_test_stack_top-2 contains 33h (low byte of BC)
    ; - SP = push_test_stack_top-2
    
    ; Final state:
    ; BC = 2233h (8755)
    ; SP = push_test_stack_top-2
    ; memory at push_test_stack_top-1 = 22h (34) - high byte of BC
    ; memory at push_test_stack_top-2 = 33h (51) - low byte of BC
    ; Condition bits: Not affected by PUSH
    
    ; ========= TEST 16: PUSH IX =========
    ; Operation: (SP – 2) ← IXL, (SP – 1) ← IXH
    ; Description: The contents of Index Register IX are pushed to the external memory last-in, first-out
    ; (LIFO) stack. SP is decremented twice.
    
    ; Example from documentation:
    ; "If Index Register IX contains 2233h and the Stack Pointer contains 1007h, then upon the
    ; execution of a PUSH IX instruction, memory address 1006h contains 22h, memory
    ; address 1005h contains 33h, and the Stack Pointer contains 1005h."
    
    ; Setup for our example - continuing from previous test
    ld ix, 4455h                 ; IX = 4455h (17493) - different value than test 15
    push ix                      ; Push IX onto the stack
    
    ; At this point:
    ; - memory at push_test_stack_top-3 contains 44h (high byte of IX)
    ; - memory at push_test_stack_top-4 contains 55h (low byte of IX)
    ; - SP = push_test_stack_top-4
    
    ; Final state:
    ; IX = 4455h (17493)
    ; SP = push_test_stack_top-4
    ; memory at push_test_stack_top-3 = 44h (68) - high byte of IX
    ; memory at push_test_stack_top-4 = 55h (85) - low byte of IX
    ; Condition bits: Not affected
    
    ; ========= TEST 17: PUSH IY =========
    ; Operation: (SP – 2) ← IYL, (SP – 1) ← IYH
    ; Description: The contents of Index Register IY are pushed to the external memory last-in, first-out
    ; (LIFO) stack. SP is decremented twice.
    
    ; Example from documentation:
    ; "If Index Register IY contains 2233h and the Stack Pointer contains 1007h, then upon the
    ; execution of a PUSH IY instruction, memory address 1006h contains 22h, memory
    ; address 1005h contains 33h, and the Stack Pointer contains 1005h."
    
    ; Setup for our example - continuing from previous test
    ld iy, 6677h                 ; IY = 6677h (26231) - different value than tests 15 and 16
    push iy                      ; Push IY onto the stack
    
    ; At this point:
    ; - memory at push_test_stack_top-5 contains 66h (high byte of IY)
    ; - memory at push_test_stack_top-6 contains 77h (low byte of IY)
    ; - SP = push_test_stack_top-6
    
    ; Final state:
    ; IY = 6677h (26231)
    ; SP = push_test_stack_top-6
    ; memory at push_test_stack_top-5 = 66h (102) - high byte of IY
    ; memory at push_test_stack_top-6 = 77h (119) - low byte of IY
    ; Condition bits: Not affected
    
    ; ========= TEST 18: POP qq (BC) =========
    ; Operation: qqH ← (SP+1), qqL ← (SP)
    ; Description: The top two bytes of the external memory last-in, first-out (LIFO) stack are popped to register 
    ; pair qq. SP is incremented twice.
    
    ; Now we'll pop the values in reverse order from our stack (LIFO - Last In, First Out)
    ; First, pop the value we pushed in TEST 17 (IY = 6677h)
    ld bc, 0000h              ; Clear BC to see the effect
    pop bc                    ; Pop values from stack into BC (should get IY's value: 6677h)
    
    ; At this point:
    ; - BC has been loaded with the values pushed from IY (6677h)
    ; - SP has been incremented to push_test_stack_top-4
    
    ; Final state:
    ; BC = 6677h (26231) - popped from the stack (was pushed from IY)
    ; SP = push_test_stack_top-4
    ; Condition bits: Not affected
    
    ; ========= TEST 19: POP IX =========
    ; Operation: IXH ← (SP+1), IXL ← (SP)
    ; Description: The top two bytes of the external memory last-in, first-out (LIFO) stack are popped to 
    ; Index Register IX. SP is incremented twice.
    
    ; Now pop the value we pushed in TEST 16 (IX = 4455h)
    ld ix, 0000h              ; Clear IX to see the effect
    pop ix                    ; Pop values from stack into IX (should get IX's original value: 4455h)
    
    ; At this point:
    ; - IX has been loaded with its own previously pushed value (4455h)
    ; - SP has been incremented to push_test_stack_top-2
    
    ; Final state:
    ; IX = 4455h (17493) - popped from the stack (was pushed from IX in TEST 16)
    ; SP = push_test_stack_top-2
    ; Condition bits: Not affected
    
    ; ========= TEST 20: POP IY =========
    ; Operation: IYH ← (SP+1), IYL ← (SP)
    ; Description: The top two bytes of the external memory last-in, first-out (LIFO) stack are popped to
    ; Index Register IY. SP is incremented twice.
    
    ; Finally, pop the value we pushed in TEST 15 (BC = 2233h)
    ld iy, 0000h              ; Clear IY to see the effect
    pop iy                    ; Pop values from stack into IY (should get BC's value: 2233h)
    
    ; At this point:
    ; - IY has been loaded with the value originally pushed from BC (2233h)
    ; - SP has been incremented to push_test_stack_top
    
    ; Final state:
    ; IY = 2233h (8755) - popped from the stack (was pushed from BC in TEST 15)
    ; SP = push_test_stack_top
    ; Condition bits: Not affected
    
    ; ========= END TEST AREA =========
    
    ; Program halt
    jr $          ; Infinite loop

; Data section
test_addr_4545:
    dw 0A137h     ; Defines 16-bit word with value A137h (low byte 37h at 4545h, high byte A1h at 4546h)

test_addr_2130:
    dw 7865h      ; Defines 16-bit word with value 7865h (low byte 65h at 2130h, high byte 78h at 2131h)

test_addr_6666:
    dw 0DA92h     ; Defines 16-bit word with value DA92h (low byte 92h at 6666h, high byte DAh at 6667h)

hl_output_addr:
    dw 0000h      ; This will store the 16-bit value from HL (initially zeroed)

dd_output_addr:
    dw 0000h      ; This will store the 16-bit value from register pair dd (initially zeroed)

ix_output_addr:
    dw 0000h      ; This will store the 16-bit value from IX (initially zeroed)

iy_output_addr:
    dw 0000h      ; This will store the 16-bit value from IY (initially zeroed)

old_sp:
    dw 0000h      ; This will store the original stack pointer value

old_sp2:
    dw 0000h      ; This will store the original stack pointer value for TEST 13

old_sp3:
    dw 0000h      ; This will store the original stack pointer value for TEST 14

; Stack areas for testing
pop_test_stack:
    dw 3355h      ; First value to be popped (used in TEST 18 - POP HL)
    dw 3355h      ; Second value to be popped (used in TEST 19 - POP IX)
    dw 3355h      ; Third value to be popped (used in TEST 20 - POP IY)

push_test_stack:
    defs    10, 0   ; 10 bytes for push test stack
push_test_stack_top:

stack_bottom:   ; 100 bytes of stack
    defs    100, 0
stack_top:
    END
