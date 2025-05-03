; Z80 Assembly - Exchange, Block Transfer and Search Group Instructions Testing
; This file contains tests for the Z80 Exchange, Block Transfer and Search Group instructions:
;   1. EX DE, HL - Exchange the contents of DE and HL register pairs

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
    
    ; ========= END TEST AREA =========
    
    ; Program halt
    jr $          ; Infinite loop

; Data section

stack_bottom:   ; 100 bytes of stack
    defs    100, 0
stack_top:
    END
