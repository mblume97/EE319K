; Print.s
; Student names: change this to your names or look very silly
; Last modification date: change this to the last modification date or look very silly
; Runs on LM4F120 or TM4C123
; EE319K lab 7 device driver for any LCD
;
; As part of Lab 7, students need to implement these LCD_OutDec and LCD_OutFix
; This driver assumes two low-level LCD functions
; ST7735_OutChar   outputs a single 8-bit ASCII character
; ST7735_OutString outputs a null-terminated string 

    IMPORT   ST7735_OutChar
    IMPORT   ST7735_OutString
    EXPORT   LCD_OutDec
    EXPORT   LCD_OutFix

    AREA    |.text|, CODE, READONLY, ALIGN=2
    THUMB

  

;-----------------------LCD_OutDec-----------------------
; Output a 32-bit number in unsigned decimal format
; Input: R0 (call by value) 32-bit unsigned number
; Output: none
; Invariables: This function must not permanently modify registers R4 to R11
LCD_OutDec

Remainder 	EQU 	0 ; binding
Count 		EQU 	4
	
	SUB SP, #8
	MOV R12, SP ; stack frame pointer
	MOV R2, #10000 ; 1 000 000 000
	MUL R2, R2, R2 
	MOV R1, #10
	MUL R2, R2, R1
	MOV R1, R0 
	UDIV R0, R1, R2
	MUL R3, R0, R2
	SUB R1, R1, R3
	STR R1, [R12, #Remainder]
	CMP R0, #0
	MOV R3, #0
	STR R3, [R12, #Count]
	BEQ second 	; the first digit is a 0, do not print
	MOV R3, #1	; increase the count
	STR R3, [R12, #Count]
	ADD R0, #0x30
	PUSH {LR}
	BL ST7735_OutChar 	; prints out the first digit
	POP {LR}

second
	MOV R2, #10000 ; 100 000 000
	MUL R2, R2, R2
	LDR R1, [R12, #Remainder]
	UDIV R0, R1, R2
	MUL R3, R0, R2
	SUB R1, R1, R3
	STR R1, [R12, #Remainder]
	LDR R1, [R12, #Count]
	ADD R1, R0
	CMP R1, #0  ; if the count and the curret digit are both zero, we do not print anything
	BEQ third
	MOV R3, #1
	STR R3, [R12, #Count]
	ADD R0, #0x30
	PUSH {LR}
	BL ST7735_OutChar 	; prints out the second digit
	POP {LR}

third
	MOV R2, #1000 ; 10 000 000
	MUL R2, R2, R2 
	MOV R1, #10
	MUL R2, R2, R1
	LDR R1, [R12, #Remainder]
	UDIV R0, R1, R2
	MUL R3, R0, R2
	SUB R1, R1, R3
	STR R1, [R12, #Remainder]
	LDR R1, [R12, #Count]
	ADD R1, R0
	CMP R1, #0  ; if the count and the curret digit are both zero, we do not print anything
	BEQ fourth
	MOV R3, #1
	STR R3, [R12, #Count]
	ADD R0, #0x30
	PUSH {LR}
	BL ST7735_OutChar 	; prints out the second digit
	POP {LR}

fourth
	MOV R2, #1000 ; 1 000 000
	MUL R2, R2, R2 
	LDR R1, [R12, #Remainder]
	UDIV R0, R1, R2
	MUL R3, R0, R2
	SUB R1, R1, R3
	STR R1, [R12, #Remainder]
	LDR R1, [R12, #Count]
	ADD R1, R0
	CMP R1, #0  ; if the count and the curret digit are both zero, we do not print anything
	BEQ fifth
	MOV R3, #1
	STR R3, [R12, #Count]
	ADD R0, #0x30
	PUSH {LR}
	BL ST7735_OutChar 	; prints out the second digit
	POP {LR}

fifth
	MOV R2, #1000 ; 100 000
	MOV R1, #100
	MUL R2, R2, R1 
	LDR R1, [R12, #Remainder]
	UDIV R0, R1, R2
	MUL R3, R0, R2
	SUB R1, R1, R3
	STR R1, [R12, #Remainder]
	LDR R1, [R12, #Count]
	ADD R1, R0
	CMP R1, #0  ; if the count and the curret digit are both zero, we do not print anything
	BEQ sixth
	MOV R3, #1
	STR R3, [R12, #Count]
	ADD R0, #0x30
	PUSH {LR}
	BL ST7735_OutChar 	; prints out the second digit
	POP {LR}

sixth 
	MOV R2, #10000
	LDR R1, [R12, #Remainder]
	UDIV R0, R1, R2
	MUL R3, R0, R2
	SUB R1, R1, R3
	STR R1, [R12, #Remainder]
	LDR R1, [R12, #Count]
	ADD R1, R0
	CMP R1, #0  ; if the count and the curret digit are both zero, we do not print anything
	BEQ seventh
	MOV R3, #1
	STR R3, [R12, #Count]
	ADD R0, #0x30
	PUSH {LR}
	BL ST7735_OutChar 	
	POP {LR}

seventh
	MOV R2, #1000
	LDR R1, [R12, #Remainder]
	UDIV R0, R1, R2
	MUL R3, R0, R2
	SUB R1, R1, R3
	STR R1, [R12, #Remainder]
	LDR R1, [R12, #Count]
	ADD R1, R0
	CMP R1, #0  ; if the count and the curret digit are both zero, we do not print anything
	BEQ eighth
	MOV R3, #1
	STR R3, [R12, #Count]
	ADD R0, #0x30
	PUSH {LR}
	BL ST7735_OutChar 	
	POP {LR}
	
eighth
	MOV R2, #100
	LDR R1, [R12, #Remainder]
	UDIV R0, R1, R2
	MUL R3, R0, R2
	SUB R1, R1, R3
	STR R1, [R12, #Remainder]
	LDR R1, [R12, #Count]
	ADD R1, R0
	CMP R1, #0  ; if the count and the curret digit are both zero, we do not print anything
	BEQ ninth
	MOV R3, #1
	STR R3, [R12, #Count]
	ADD R0, #0x30
	PUSH {LR}
	BL ST7735_OutChar 	
	POP {LR}
	
ninth
	MOV R2, #10
	LDR R1, [R12, #Remainder]
	UDIV R0, R1, R2
	MUL R3, R0, R2
	SUB R1, R1, R3
	STR R1, [R12, #Remainder]
	LDR R1, [R12, #Count]
	ADD R1, R0
	CMP R1, #0  ; if the count and the curret digit are both zero, we do not print anything
	BEQ tenth
	MOV R3, #1
	STR R3, [R12, #Count]
	ADD R0, #0x30
	PUSH {LR}
	BL ST7735_OutChar 	
	POP {LR}

tenth
	LDR R0, [R12, #Remainder]
	ADD R0, #0x30
	PUSH {LR}
	BL ST7735_OutChar 
	POP {LR}
	ADD SP, #8

	BX  LR
	PRESERVE8
;* * * * * * * * End of LCD_OutDec * * * * * * * *

; -----------------------LCD _OutFix----------------------
; Output characters to LCD display in fixed-point format
; unsigned decimal, resolution 0.001, range 0.000 to 9.999
; Inputs:  R0 is an unsigned 32-bit number
; Outputs: none
; E.g., R0=0,    then output "0.000 "
;       R0=3,    then output "0.003 "
;       R0=89,   then output "0.089 "
;       R0=123,  then output "0.123 "
;       R0=9999, then output "9.999 "
;       R0>9999, then output "*.*** "
; Invariables: This function must not permanently modify registers R4 to R11
LCD_OutFix

Remainder2 	EQU 	0 ; binding
	
	MOV R1, #9999
	CMP R0, R1
	BHI Over
;the first digit	
	SUB SP, #4
	MOV R12, SP
	MOV R2, #1000
	MOV R1, R0 
	UDIV R0, R1, R2
	MUL R3, R0, R2
	SUB R1, R1, R3
	STR R1, [R12, #Remainder2]
	ADD R0, #0x30
	PUSH {LR}
	BL ST7735_OutChar 	; prints out the first digit
	POP {LR}
;the decimal point	
	MOV R0, #0x2E
	PUSH {LR}
	BL ST7735_OutChar 	; prints out the decimal point
	POP {LR}
;the second digit
	LDR R1, [R12, #Remainder2]
	MOV R2, #100
	UDIV R0, R1, R2
	MUL R3, R0, R2
	SUB R1, R1, R3
	STR R1, [R12, #Remainder2]
	ADD R0, #0x30
	PUSH {LR}
	BL ST7735_OutChar 	; prints out the second digit
	POP {LR}
;the third digit
	LDR R1, [R12, #Remainder2]
	MOV R2, #10
	UDIV R0, R1, R2
	MUL R3, R0, R2
	SUB R1, R1, R3
	STR R1, [R12, #Remainder2]
	ADD R0, #0x30
	PUSH {LR}
	BL ST7735_OutChar 	; prints out the second digit
	POP {LR}
;the fourth and last digit
	LDR R0, [R12, #Remainder2]
	ADD R0, #0x30
	PUSH {LR}
	BL ST7735_OutChar 	; prints out the second digit
	POP {LR}
	
	ADD SP, #4
	BX   LR

Over
	MOV R0, #0x2A
	PUSH {LR}
	BL ST7735_OutChar
	POP {LR}
	
	MOV R0, #0x2E
	PUSH {LR}
	BL ST7735_OutChar
	POP {LR}
	
	MOV R0, #0x2A
	PUSH {LR}
	BL ST7735_OutChar
	POP {LR}
	
	MOV R0, #0x2A
	PUSH {LR}
	BL ST7735_OutChar
	POP {LR}
	
	MOV R0, #0x2A
	PUSH {LR}
	BL ST7735_OutChar
	POP {LR}
	
	BX LR
	PRESERVE8
  
 
     ALIGN
;* * * * * * * * End of LCD_OutFix * * * * * * * *

     ALIGN                           ; make sure the end of this section is aligned
     END                             ; end of file
