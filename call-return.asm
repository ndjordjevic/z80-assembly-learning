; Z80 Assembly - Call and Return Group Instructions Testing
; This file contains tests for the Z80 Call and Return Group instructions:
;   1. CALL nn - Call to absolute address (subroutine)
;   2. CALL cc, nn - Conditional call to absolute address
;   3. RET - Return from subroutine
;   4. RET cc - Conditional return from subroutine
;   5. RETI - Return from interrupt
;   6. RETN - Return from non-maskable interrupt
;   7. RST p - Restart (call to page zero address)

    DEVICE NOSLOT64K
    SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION

    org 0       ; Program starts at address 0 in memory

main:
    ld sp, stack_top  ; Initialize stack pointer
    
    ; Test sequence
    ; 1. First we'll test CALL and RET
    ; 2. Then we'll test CALL cc and RET cc with different conditions
    ; 3. Then we'll test RST
    ; 4. Finally we'll show examples of RETI and RETN
    
    ; ========= TEST 1: CALL nn - Call to absolute address =========
    ; Operation: (SP-1) ← PCH, (SP-2) ← PCL, PC ← nn
    ; Description: Pushes current PC to stack and jumps to address nn
    
    ; Example from documentation:
    ; "If an instruction fetch sequence begins, the 3-byte instruction CD 3521h is fetched to the CPU
    ; for execution. The mnemonic equivalent of this instruction is CALL 2135h. Upon the execution
    ; of this instruction, memory address 3001h contains 1Ah, address 3000h contains 4Ah, the Stack
    ; Pointer contains 3000h, and the Program Counter contains 2135h, thereby pointing to the address
    ; of the first op code of the next subroutine to be executed."
    
    ld a, 1                 ; A = 1 (to track execution path)
    call subroutine_1       ; Call subroutine
    
    ; After return from subroutine_1
    ld a, 3                 ; A = 3 (to verify we returned correctly)
    
    ; Now test with nested calls
    call nested_outer       ; Call a subroutine that will call another subroutine
    
    ; After return from nested subroutines
    ld a, 6                 ; A = 6 (to verify we returned correctly)
    
    jp test_call_cc         ; Jump to next test
    
subroutine_1:
    ; This is the target of our first CALL test
    ld a, 2                 ; A = 2 (to verify we got here)
    ret                     ; Return to caller
    
nested_outer:
    ; This is the outer subroutine that will call another subroutine
    ld a, 4                 ; A = 4 (to verify we got here)
    call nested_inner       ; Call inner subroutine
    ld a, 5                 ; A = 5 (to verify we returned from inner and continue here)
    ret                     ; Return to main
    
nested_inner:
    ; This is the inner subroutine
    push bc                 ; Save BC (just to demonstrate stack usage)
    ld bc, 1234h            ; BC = 1234h
    pop bc                  ; Restore BC
    ret                     ; Return to outer subroutine
    
    ; ========= TEST 2: CALL cc, nn - Conditional call to absolute address =========
    ; Operation: IF cc true: (SP-1) ← PCH, (SP-2) ← PCL, PC ← nn
    ; Description: If condition cc is true, pushes current PC to stack and jumps to nn
test_call_cc:
    ; Example from documentation:
    ; "The C Flag in the F Register is reset, the Program Counter contains 1A47h, the Stack
    ; Pointer contains 3002h, and memory locations contain the following data.
    ; Location Contents
    ; 1A47h D4h
    ; 1448h 35h
    ; 1A49h 21h
    ; If an instruction fetch sequence begins, the 3-byte instruction D43521h is fetched to the
    ; CPU for execution. The mnemonic equivalent of this instruction is CALL NC, 2135h."
    
    ; ===== TEST 2.1: CALL cc, nn (condition true) =====
    ; First we'll test a conditional call where the condition is true
    
    ; Call if Z flag is set (and it will be)
    xor a                   ; A = 0, sets Z flag
    call z, cond_routine_1  ; Call if Z flag is set
    ld b, 1                 ; B = 1 (verify we returned correctly)
    
    ; Call if C flag is set (and it will be)
    scf                     ; Set carry flag
    call c, cond_routine_2  ; Call if C flag is set
    ld b, 2                 ; B = 2 (verify we returned correctly)
    
    ; ===== TEST 2.2: CALL cc, nn (condition false) =====
    ; Now test a conditional call where the condition is false
    
    ; Don't call if Z flag is reset (and it will be)
    ld a, 1                 ; A = 1, resets Z flag
    call z, dont_call_1     ; Call if Z flag is set (it's not, so we shouldn't call)
    ld c, 1                 ; C = 1 (this should execute)
    
    ; Don't call if C flag is reset (and it will be)
    and a                   ; Clear carry flag
    call c, dont_call_2     ; Call if C flag is set (it's not, so we shouldn't call)
    ld c, 2                 ; C = 2 (this should execute)
    
    ; ===== TEST 2.3: Other condition flags =====
    ; Test with P/V and Sign flags
    
    ; Call if parity even (PV set)
    ld a, 03h               ; A = 03h (even parity)
    call pe, parity_routine ; Call if PV flag is set
    ld d, 1                 ; D = 1 (verify we returned correctly)
    
    ; Call if sign negative (S set)
    ld a, 80h               ; A = 80h (negative)
    call m, sign_routine    ; Call if S flag is set
    ld d, 2                 ; D = 2 (verify we returned correctly)
    
    ; Don't call if parity odd (PV reset)
    ld a, 01h               ; A = 01h (odd parity)
    call pe, dont_call_3    ; Call if PV flag is set (it's not, so we shouldn't call)
    ld e, 1                 ; E = 1 (this should execute)
    
    ; Don't call if sign positive (S reset)
    ld a, 7Fh               ; A = 7Fh (positive)
    call m, dont_call_4     ; Call if S flag is set (it's not, so we shouldn't call)
    ld e, 2                 ; E = 2 (this should execute)
    
    jp test_ret_cc          ; Jump to next test
    
cond_routine_1:
    ld a, 10                ; A = 10 (to verify we got here)
    ret                     ; Return to caller
    
cond_routine_2:
    ld a, 20                ; A = 20 (to verify we got here)
    ret                     ; Return to caller
    
dont_call_1:
    ; This routine shouldn't be called
    ld a, 0FFh              ; A = FFh
    ret                     ; Return to caller
    
dont_call_2:
    ; This routine shouldn't be called
    ld a, 0FFh              ; A = FFh
    ret                     ; Return to caller
    
parity_routine:
    ld a, 30                ; A = 30 (to verify we got here)
    ret                     ; Return to caller
    
sign_routine:
    ld a, 40                ; A = 40 (to verify we got here)
    ret                     ; Return to caller
    
dont_call_3:
    ; This routine shouldn't be called
    ld a, 0FFh              ; A = FFh
    ret                     ; Return to caller
    
dont_call_4:
    ; This routine shouldn't be called
    ld a, 0FFh              ; A = FFh
    ret                     ; Return to caller
    
    ; ========= TEST 3: RET cc - Conditional return from subroutine =========
    ; Operation: If cc true: PCL ← (SP), PCH ← (SP+1)
    ; Description: If condition cc is true, pops stack value into PC
test_ret_cc:
    ; Example from documentation:
    ; "The S flag in the F Register is set, the Program Counter contains 3535h, the Stack Pointer
    ; contains 2000h, memory location 2000h contains B5h, and memory location 2001h contains 18h.
    ; Upon the execution of a RET M instruction, the Stack Pointer contains 2002h and the Program
    ; Counter contains 18B5h, thereby pointing to the address of the next program op code to be fetched."
    
    ; First, we'll call several subroutines that will return conditionally
    
    ; ===== TEST 3.1: RET cc (condition true) =====
    ; Call subroutines that will return conditionally when the condition is true
    
    call ret_if_z           ; Call routine that returns if Z flag is set
    ld b, 10                ; B = 10 (verify we returned from all routines)
    
    call ret_if_c           ; Call routine that returns if C flag is set
    ld b, 20                ; B = 20 (verify we returned from all routines)
    
    call ret_if_pe          ; Call routine that returns if PV flag is set
    ld b, 30                ; B = 30 (verify we returned from all routines)
    
    call ret_if_m           ; Call routine that returns if S flag is set
    ld b, 40                ; B = 40 (verify we returned from all routines)
    
    ; ===== TEST 3.2: RET cc (condition false) =====
    ; Call subroutines that will not return conditionally when the condition is false
    ; but will then return unconditionally
    
    call ret_not_if_z       ; Call routine that continues if Z flag is reset, then returns
    ld c, 10                ; C = 10 (verify we returned from all routines)
    
    call ret_not_if_c       ; Call routine that continues if C flag is reset, then returns
    ld c, 20                ; C = 20 (verify we returned from all routines)
    
    call ret_not_if_pe      ; Call routine that continues if PV flag is reset, then returns
    ld c, 30                ; C = 30 (verify we returned from all routines)
    
    call ret_not_if_m       ; Call routine that continues if S flag is reset, then returns
    ld c, 40                ; C = 40 (verify we returned from all routines)
    
    jp test_rst             ; Jump to next test
    
ret_if_z:
    xor a                   ; A = 0, sets Z flag
    ret z                   ; Return if Z flag is set (it is, so return)
    ld a, 0FFh              ; This shouldn't execute
    ret                     ; This shouldn't execute
    
ret_if_c:
    scf                     ; Set carry flag
    ret c                   ; Return if C flag is set (it is, so return)
    ld a, 0FFh              ; This shouldn't execute
    ret                     ; This shouldn't execute
    
ret_if_pe:
    ld a, 03h               ; A = 03h (even parity)
    ret pe                  ; Return if PV flag is set (it is, so return)
    ld a, 0FFh              ; This shouldn't execute
    ret                     ; This shouldn't execute
    
ret_if_m:
    ld a, 80h               ; A = 80h (negative)
    ret m                   ; Return if S flag is set (it is, so return)
    ld a, 0FFh              ; This shouldn't execute
    ret                     ; This shouldn't execute
    
ret_not_if_z:
    ld a, 1                 ; A = 1, resets Z flag
    ret z                   ; Return if Z flag is set (it's not, so continue)
    ld a, 50                ; A = 50 (to verify we didn't return)
    ret                     ; Unconditional return
    
ret_not_if_c:
    and a                   ; Clear carry flag
    ret c                   ; Return if C flag is set (it's not, so continue)
    ld a, 60                ; A = 60 (to verify we didn't return)
    ret                     ; Unconditional return
    
ret_not_if_pe:
    ld a, 01h               ; A = 01h (odd parity)
    ret pe                  ; Return if PV flag is set (it's not, so continue)
    ld a, 70                ; A = 70 (to verify we didn't return)
    ret                     ; Unconditional return
    
ret_not_if_m:
    ld a, 7Fh               ; A = 7Fh (positive)
    ret m                   ; Return if S flag is set (it's not, so continue)
    ld a, 80                ; A = 80 (to verify we didn't return)
    ret                     ; Unconditional return
    
    ; ========= TEST 4: RST p - Restart (call to page zero address) =========
    ; Operation: (SP-1) ← PCH, (SP-2) ← PCL, PCH ← 0, PCL ← p
    ; Description: Pushes current PC to stack and jumps to restart address p in page 0
test_rst:
    ; Example from documentation:
    ; "If the Program Counter contains 15B3h, then upon the execution of an RST 18h (object
    ; code 1101111) instruction, the PC contains 0018h as the address of the next fetched op code."
    
    ; RST instruction allows jumping to one of eight addresses in page 0:
    ; RST 00h - jumps to 0000h
    ; RST 08h - jumps to 0008h
    ; RST 10h - jumps to 0010h
    ; RST 18h - jumps to 0018h
    ; RST 20h - jumps to 0020h
    ; RST 28h - jumps to 0028h
    ; RST 30h - jumps to 0030h
    ; RST 38h - jumps to 0038h
    
    ; Since our code starts at 0000h, we need to be careful not to create an infinite loop.
    ; We'll set up restart handlers at each restart address.
    ; For this test, we'll only use a few of them to avoid excessive code.
    
    ; Jump past all the restart handlers
    jp setup_rst_handlers
    
    ; Restart handlers at page 0
    org 08h                 ; Address 0008h
rst_08h_handler:
    ld a, 8                 ; A = 8 (to verify we got to RST 08h handler)
    ret                     ; Return to caller
    
    org 10h                 ; Address 0010h
rst_10h_handler:
    ld a, 16                ; A = 16 (to verify we got to RST 10h handler)
    ret                     ; Return to caller
    
    org 28h                 ; Address 0028h
rst_28h_handler:
    ld a, 40                ; A = 40 (to verify we got to RST 28h handler)
    ret                     ; Return to caller
    
    org 30h                 ; Address 0030h
rst_30h_handler:
    ld a, 48                ; A = 48 (to verify we got to RST 30h handler)
    
    ; Test nested RST
    rst 28h                 ; Call RST 28h handler
    ld b, a                 ; B = A = 40 (verify RST 28h handler was called)
    ld a, 49                ; A = 49
    ret                     ; Return to caller
    
    ; Continue with the main code after all handlers
setup_rst_handlers:
    ; Now test the RST instruction
    rst 08h                 ; Call RST 08h handler
    ld b, a                 ; B = A = 8 (verify RST 08h handler was called)
    
    rst 10h                 ; Call RST 10h handler
    ld c, a                 ; C = A = 16 (verify RST 10h handler was called)
    
    rst 30h                 ; Call RST 30h handler (which will call another RST)
    ld d, a                 ; D = A = 49 (verify RST 30h handler was called)
    
    jp test_reti_retn       ; Jump to next test
    
    ; ========= TEST 5: RETI & RETN - Return from interrupt and NMI =========
    ; RETI - Operation: Return from interrupt
    ; RETN - Operation: Return from non-maskable interrupt
    ; Description: Returns from an interrupt service routine. RETI also notifies
    ; I/O devices that interrupt is done. RETN also restores IFF1 from IFF2.
test_reti_retn:
    ; In a real system, these instructions would be used at the end of interrupt
    ; handlers. Since we aren't testing real interrupt behavior here, we'll just
    ; call the interrupt handler routines directly to show the syntax and operation.
    
    ; ===== TEST 5.1: RETI =====
    ; Call a routine that simulates an interrupt handler with RETI
    call simulate_int_handler
    ld a, 100               ; A = 100 (to verify we returned correctly)
    
    ; ===== TEST 5.2: RETN =====
    ; Call a routine that simulates a non-maskable interrupt handler with RETN
    call simulate_nmi_handler
    ld a, 200               ; A = 200 (to verify we returned correctly)
    
    jp test_end             ; Jump to end of test
    
simulate_int_handler:
    ; This routine simulates an interrupt handler that ends with RETI
    ld a, 99                ; A = 99 (to verify we executed this routine)
    
    ; In a real interrupt handler, we might do something like:
    push bc                 ; Save registers
    push de
    ; ... handle the interrupt ...
    pop de                  ; Restore registers
    pop bc
    
    reti                    ; Return from interrupt
    
simulate_nmi_handler:
    ; This routine simulates a non-maskable interrupt handler that ends with RETN
    ld a, 199               ; A = 199 (to verify we executed this routine)
    
    ; In a real NMI handler, we might do something like:
    push bc                 ; Save registers
    push de
    ; ... handle the NMI ...
    pop de                  ; Restore registers
    pop bc
    
    retn                    ; Return from non-maskable interrupt
    
test_end:
    ; ========= END TEST AREA =========
    
    ; Verify results are as expected
    ; A, B, C, D, E have various values set during tests
    
    jr $                    ; Infinite loop

; Data section
stack_bottom:    ; 100 bytes of stack
    defs 100, 0
stack_top:
    END
