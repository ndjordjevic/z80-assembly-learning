; Z80 Assembly - 16-Bit Load Group Instructions Testing
; This file contains tests for the Z80 16-bit load group instructions:
;   1. LD dd, nn - Load immediate value into register pair

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
    
    ; ========= END TEST AREA =========
    
    ; Program halt
    jr $          ; Infinite loop

; Data section
; (Currently empty since we're using immediate values)

stack_bottom:   ; 100 bytes of stack
    defs    100, 0
stack_top:
    END
