; Z80 Assembly - Jump Group Instructions Testing
; This file contains tests for the Z80 Jump Group instructions:
;   1. JP nn - Jump to absolute address
;   2. JP cc, nn - Conditional jump to absolute address
;   3. JR e - Relative jump
;   4. JR C, e - Conditional relative jump if Carry
;   5. JR NC, e - Conditional relative jump if No Carry
;   6. JR Z, e - Conditional relative jump if Zero
;   7. JR NZ, e - Conditional relative jump if Not Zero
;   8. JP (HL) - Jump to address contained in HL
;   9. JP (IX) - Jump to address contained in IX
;  10. JP (IY) - Jump to address contained in IY
;  11. DJNZ e - Decrement B and Jump relative if Not Zero

    DEVICE NOSLOT64K
    SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION

    org 0       ; Program starts at address 0 in memory

main:
    ld sp, stack_top  ; Initialize stack pointer
    
    ; ========= TEST 1: JP nn - Jump to absolute address =========
    ; Operation: PC ← nn
    ; Description: Operand nn is loaded to register pair Program Counter (PC). 
    ; The next instruction is fetched from the location designated by the new contents of the PC.
    
    ; Example: Unconditional jump to a different location
    ld a, 1           ; Set A to 1 to track execution
    jp jp_target_1    ; Jump to jp_target_1
    
    ; This code should be skipped
    ld a, 0FFh        ; If we execute this, A will be FFh which is wrong
    nop
    nop

jp_target_1:
    ; Execution continues here
    ld b, a           ; B = A = 1 (to verify we arrived)
    
    ; Test with backward jump
    ld c, 1           ; Set C to 1 to track execution
    jp jp_target_2    ; Jump forward
    
    ; This is a target for a backward jump later
jp_target_back:
    ; Execution will come here from a backward jump
    ld e, c           ; E = C = 2 (to verify we arrived)
    
    ; Done with this test, move to next test section
    jp test_jp_cc
    
jp_target_2:
    ; Execution continues here
    inc c             ; C = 2
    jp jp_target_back ; Jump backward
    
    ; ========= TEST 2: JP cc, nn - Conditional jump to absolute address =========
    ; Operation: IF cc true, PC ← nn
    ; Description: If condition cc is true, jump to address nn. Otherwise, continue execution.
    ; The conditions are: NZ, Z, NC, C, PO, PE, P, M
test_jp_cc:
    ; Test JP Z,nn - Jump if Zero flag is set
    
    ; Example from documentation:
    ; "If the Carry flag is set and address 1520h contains 03h, then
    ; upon the execution of a JP C, 1520h instruction, the Program Counter contains 1520h"
    
    ; Setup for our example (using alternative address)
    scf               ; Set carry flag
    jp c, jp_carry    ; Jump if Carry flag is set
    
    ; This code should be skipped
    ld a, 0FFh        ; If we execute this, A will be FFh which is wrong
    nop
    nop

jp_carry:
    ; Execution continues here
    ld a, 3           ; A = 3 (to verify we arrived)
    
    ; Test JP NZ,nn - Jump if Zero flag is not set
    xor a             ; A = 0, sets Zero flag
    jp nz, jp_skip_1  ; This should NOT jump (Z flag is set)
    ld d, 1           ; D = 1 (to verify we didn't jump)
    jp jp_zero        ; Jump to next test
jp_skip_1:
    ld d, 0FFh        ; This should not execute
    
jp_zero:
    ; Test JP Z,nn - Jump if Zero flag is set
    xor a             ; A = 0, sets Zero flag
    jp z, jp_took_zero ; This should jump (Z flag is set)
    
    ; This code should be skipped
    ld a, 0FFh        ; If we execute this, A will be FFh which is wrong
    nop
    nop

jp_took_zero:
    ; Execution continues here
    ld a, 4           ; A = 4 (to verify we arrived)
    
    ; Test JP NC,nn - Jump if Carry flag is not set
    and a             ; Clear carry flag
    jp nc, jp_no_carry ; This should jump (C flag is reset)
    
    ; This code should be skipped
    ld a, 0FFh        ; If we execute this, A will be FFh which is wrong
    nop
    nop

jp_no_carry:
    ; Execution continues here
    ld a, 5           ; A = 5 (to verify we arrived)
    
    ; Test JP C,nn - Jump if Carry flag is set (failed condition)
    and a             ; Clear carry flag
    jp c, jp_skip_2   ; This should NOT jump (C flag is reset)
    ld e, 2           ; E = 2 (to verify we didn't jump)
    jp jp_parity      ; Jump to next test
jp_skip_2:
    ld e, 0FFh        ; This should not execute
    
jp_parity:
    ; Test JP PO,nn - Jump if Parity Odd (P/V reset)
    ld a, 01h         ; A = 01h (odd parity)
    jp po, jp_parity_odd ; This should jump (P/V flag is reset)
    
    ; This code should be skipped
    ld a, 0FFh        ; If we execute this, A will be FFh which is wrong
    nop
    nop

jp_parity_odd:
    ; Execution continues here
    ld a, 6           ; A = 6 (to verify we arrived)
    
    ; Test JP PE,nn - Jump if Parity Even (P/V set)
    ld a, 03h         ; A = 03h (even parity)
    jp pe, jp_parity_even ; This should jump (P/V flag is set)
    
    ; This code should be skipped
    ld a, 0FFh        ; If we execute this, A will be FFh which is wrong
    nop
    nop

jp_parity_even:
    ; Execution continues here
    ld a, 7           ; A = 7 (to verify we arrived)
    
    ; Test JP P,nn - Jump if Sign Positive (S reset)
    ld a, 7Fh         ; A = 7Fh (positive)
    jp p, jp_positive ; This should jump (S flag is reset)
    
    ; This code should be skipped
    ld a, 0FFh        ; If we execute this, A will be FFh which is wrong
    nop
    nop

jp_positive:
    ; Execution continues here
    ld a, 8           ; A = 8 (to verify we arrived)
    
    ; Test JP M,nn - Jump if Sign Negative (S set)
    ld a, 80h         ; A = 80h (negative)
    jp m, jp_negative ; This should jump (S flag is set)
    
    ; This code should be skipped
    ld a, 0FFh        ; If we execute this, A will be FFh which is wrong
    nop
    nop

jp_negative:
    ; Execution continues here
    ld a, 9           ; A = 9 (to verify we arrived)
    
    ; Jump to the next test
    jp test_jr

    ; ========= TEST 3: JR e - Relative jump =========
    ; Operation: PC ← PC + e
    ; Description: Relative jump with displacement e (-126 to +129 bytes)
test_jr:
    ; Example from documentation:
    ; "To jump forward five locations from address 480, the following assembly
    ; language statement is used: JR $+5"
    
    ; Setup for our example
    ld a, 10          ; A = 10 (to track execution)
    jr jr_forward     ; Jump forward
    
    ; This code should be skipped
    ld a, 0FFh        ; If we execute this, A will be FFh which is wrong
    nop
    nop

jr_forward:
    ; Execution continues here
    ld b, a           ; B = A = 10 (to verify we arrived)
    
    ; Test with backward jump
    ld c, 10          ; Set C to 10 to track execution
    jr jr_target_2    ; Jump forward
    
    ; This is a target for a backward jump later
jr_target_back:
    ; Execution will come here from a backward jump
    ld e, c           ; E = C = 11 (to verify we arrived)
    
    ; Done with this test, move to next test section
    jr test_jr_c
    
jr_target_2:
    ; Execution continues here
    inc c             ; C = 11
    jr jr_target_back ; Jump backward
    
    ; ========= TEST 4: JR C, e - Conditional relative jump if Carry =========
    ; Operation: If C = 0, continue; If C = 1, PC ← PC + e
    ; Description: Relative jump with displacement e if Carry flag is set
test_jr_c:
    ; Example from documentation:
    ; "The Carry flag is set and it is required to jump back four locations
    ; from 480. The assembly language statement is JR C, $–4"
    
    ; Setup for our example
    scf               ; Set Carry flag
    ld a, 20          ; A = 20 (to track execution)
    jr c, jr_c_taken  ; Jump if Carry is set
    
    ; This code should be skipped
    ld a, 0FFh        ; If we execute this, A will be FFh which is wrong
    nop
    nop

jr_c_taken:
    ; Execution continues here
    ld b, a           ; B = A = 20 (to verify we arrived)
    
    ; Test when condition is not met
    and a             ; Clear Carry flag
    jr c, jr_c_skip   ; This should NOT jump (C flag is reset)
    ld d, 20          ; D = 20 (to verify we didn't jump)
    jr test_jr_nc     ; Jump to next test
jr_c_skip:
    ld d, 0FFh        ; This should not execute
    
    ; ========= TEST 5: JR NC, e - Conditional relative jump if No Carry =========
    ; Operation: If C = 1, continue; If C = 0, PC ← PC + e
    ; Description: Relative jump with displacement e if Carry flag is reset
test_jr_nc:
    ; Example from documentation:
    ; "The Carry Flag is reset and it is required to repeat the jump instruction.
    ; The assembly language statement is JR NC, $"
    
    ; Setup for our example
    and a             ; Clear Carry flag
    ld a, 30          ; A = 30 (to track execution)
    jr nc, jr_nc_taken ; Jump if No Carry
    
    ; This code should be skipped
    ld a, 0FFh        ; If we execute this, A will be FFh which is wrong
    nop
    nop

jr_nc_taken:
    ; Execution continues here
    ld b, a           ; B = A = 30 (to verify we arrived)
    
    ; Test when condition is not met
    scf               ; Set Carry flag
    jr nc, jr_nc_skip ; This should NOT jump (C flag is set)
    ld d, 30          ; D = 30 (to verify we didn't jump)
    jr test_jr_z      ; Jump to next test
jr_nc_skip:
    ld d, 0FFh        ; This should not execute
    
    ; ========= TEST 6: JR Z, e - Conditional relative jump if Zero =========
    ; Operation: If Z = 0, continue; If Z = 1, PC ← PC + e
    ; Description: Relative jump with displacement e if Zero flag is set
test_jr_z:
    ; Example from documentation:
    ; "The Zero Flag is set and it is required to jump forward five locations
    ; from address 300. The assembly language statement is JR Z, $+5"
    
    ; Setup for our example
    xor a             ; A = 0 (and sets Zero flag)
    ld c, 40          ; C = 40 (to track execution)
    jr z, jr_z_taken  ; Jump if Zero is set
    
    ; This code should be skipped
    ld c, 0FFh        ; If we execute this, C will be FFh which is wrong
    nop
    nop

jr_z_taken:
    ; Execution continues here
    ld a, c           ; A = C = 40 (to verify we arrived)
    
    ; Test when condition is not met
    ld a, 1           ; A = 1 (resets Zero flag)
    jr z, jr_z_skip   ; This should NOT jump (Z flag is reset)
    ld d, 40          ; D = 40 (to verify we didn't jump)
    jr test_jr_nz     ; Jump to next test
jr_z_skip:
    ld d, 0FFh        ; This should not execute
    
    ; ========= TEST 7: JR NZ, e - Conditional relative jump if Not Zero =========
    ; Operation: If Z = 1, continue; If Z = 0, PC ← PC + e
    ; Description: Relative jump with displacement e if Zero flag is reset
test_jr_nz:
    ; Example from documentation:
    ; "The Zero Flag is reset and it is required to jump back four locations
    ; from 480. The assembly language statement is JR NZ, $–4"
    
    ; Setup for our example
    ld a, 1           ; A = 1 (resets Zero flag)
    ld c, 50          ; C = 50 (to track execution)
    jr nz, jr_nz_taken ; Jump if Not Zero
    
    ; This code should be skipped
    ld c, 0FFh        ; If we execute this, C will be FFh which is wrong
    nop
    nop

jr_nz_taken:
    ; Execution continues here
    ld a, c           ; A = C = 50 (to verify we arrived)
    
    ; Test when condition is not met
    xor a             ; A = 0 (sets Zero flag)
    jr nz, jr_nz_skip ; This should NOT jump (Z flag is set)
    ld d, 50          ; D = 50 (to verify we didn't jump)
    jr test_jp_hl     ; Jump to next test
jr_nz_skip:
    ld d, 0FFh        ; This should not execute
    
    ; ========= TEST 8: JP (HL) - Jump to address contained in HL =========
    ; Operation: PC ← HL
    ; Description: Jump to the address stored in the HL register pair
test_jp_hl:
    ; Example from documentation:
    ; "If the Program Counter contains 1000h and the HL register pair contains 4800h, 
    ; then upon the execution of a JP (HL) instruction, the Program Counter contains 4800h."
    
    ; Setup for our example
    ld a, 60          ; A = 60 (to track execution)
    ld hl, jp_hl_target ; HL = address of jp_hl_target
    jp (hl)          ; Jump to address in HL
    
    ; This code should be skipped
    ld a, 0FFh        ; If we execute this, A will be FFh which is wrong
    nop
    nop

jp_hl_target:
    ; Execution continues here
    ld b, a           ; B = A = 60 (to verify we arrived)
    
    ; Done with this test, move to next test section
    jp test_jp_ix
    
    ; ========= TEST 9: JP (IX) - Jump to address contained in IX =========
    ; Operation: PC ← IX
    ; Description: Jump to the address stored in the IX register
test_jp_ix:
    ; Example from documentation:
    ; "If the Program Counter contains 1000h and the IX register pair contains 4800h, 
    ; then upon the execution of a JP (IX) instruction, the Program Counter contains 4800h."
    
    ; Setup for our example
    ld a, 70          ; A = 70 (to track execution)
    ld ix, jp_ix_target ; IX = address of jp_ix_target
    jp (ix)          ; Jump to address in IX
    
    ; This code should be skipped
    ld a, 0FFh        ; If we execute this, A will be FFh which is wrong
    nop
    nop

jp_ix_target:
    ; Execution continues here
    ld b, a           ; B = A = 70 (to verify we arrived)
    
    ; Done with this test, move to next test section
    jp test_jp_iy
    
    ; ========= TEST 10: JP (IY) - Jump to address contained in IY =========
    ; Operation: PC ← IY
    ; Description: Jump to the address stored in the IY register
test_jp_iy:
    ; Example from documentation:
    ; "If the Program Counter contains 1000h and the IY register pair contains 4800h, 
    ; then upon the execution of a JP (IY) instruction, the Program Counter contains 4800h."
    
    ; Setup for our example
    ld a, 80          ; A = 80 (to track execution)
    ld iy, jp_iy_target ; IY = address of jp_iy_target
    jp (iy)          ; Jump to address in IY
    
    ; This code should be skipped
    ld a, 0FFh        ; If we execute this, A will be FFh which is wrong
    nop
    nop

jp_iy_target:
    ; Execution continues here
    ld b, a           ; B = A = 80 (to verify we arrived)
    
    ; Done with this test, move to next test section
    jp test_djnz
    
    ; ========= TEST 11: DJNZ e - Decrement B and Jump relative if Not Zero =========
    ; Operation: B ← B - 1; if B = 0, continue; if B ≠ 0, PC ← PC + e
    ; Description: Decrement register B and jump with relative displacement e if B is not zero
test_djnz:
    ; Example from documentation:
    ; A copy routine that uses DJNZ to move up to 80 bytes or until a CR is found
    
    ; Simple example using DJNZ to count down from 5
    ld b, 5          ; Start counter at 5
    ld c, 0          ; Initialize C to 0
djnz_loop:
    inc c            ; Increment C on each iteration
    djnz djnz_loop   ; Decrement B and loop if B != 0
    
    ; At this point, B should be 0 and C should be 5
    ld a, c          ; A = C = 5 (to verify the loop executed correctly)
    
    ; Test DJNZ when B=1 (should not jump)
    ld b, 1          ; B = 1
    ld d, 90         ; D = 90 (to track execution)
    djnz djnz_skip   ; Decrement B to 0 and should NOT jump
    ld e, 90         ; E = 90 (to verify we didn't jump)
    jp test_end      ; Jump to test end
djnz_skip:
    ld e, 0FFh       ; This should not execute
    
test_end:
    ; ========= END TEST AREA =========
    
    ; Verify results are as expected
    ; A = 5 (from DJNZ loop)
    ; B = 0 (after DJNZ loop)
    ; C = 5 (from DJNZ loop)
    ; D = various values from conditional jump tests
    ; E = 90 (from final DJNZ test)
    
    jr $          ; Infinite loop

; Data section
stack_bottom:   ; 100 bytes of stack
    defs 100, 0
stack_top:
    END