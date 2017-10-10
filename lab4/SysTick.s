; SysTick.s
; Module written by: Michael Blume and Jordan
; Date Created: 2/14/2017
; Last Modified: 2/14/2017 
; Brief Description: Initializes SysTick

NVIC_ST_CTRL_R        EQU 0xE000E010
NVIC_ST_RELOAD_R      EQU 0xE000E014
NVIC_ST_CURRENT_R     EQU 0xE000E018

        AREA    |.text|, CODE, READONLY, ALIGN=2
        THUMB
; ;-UUU-Export routine(s) from SysTick.s to callers
		EXPORT  SysTick_Init
;------------SysTick_Init------------
; ;-UUU-Complete this subroutine
; Initialize SysTick with busy wait running at bus clock.
; Input: none
; Output: none
; Modifies: none
SysTick_Init
	PUSH {R0,R1,R2,LR}
	LDR R1, =NVIC_ST_CTRL_R
	LDR R0, [R1]
	BIC R0, #0x01
	STR R0, [R1]
	
	LDR R1, =NVIC_ST_RELOAD_R
	LDR R0, =0x00FFFFFF
	STR R0, [R1]
	
	LDR R1, =NVIC_ST_CURRENT_R
	MOV R0, #1
	STR R0, [R1]
	
	LDR R1, =NVIC_ST_CTRL_R
	LDR R0, [R1]
	ORR R0, #0x05
	BIC R0, #0x02
	STR R0, [R1]
    POP {R0,R1,R2,LR}
	
    BX  LR                          ; return


    ALIGN                           ; make sure the end of this section is aligned
    END                             ; end of file
