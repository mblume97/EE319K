;****************** main.s ***************
; Program written by: ***Your Names**update this***
; Date Created: 2/14/2017
; Last Modified: 2/14/2017
; Brief description of the program
;   The LED toggles at 8 Hz and a varying duty-cycle
;   Repeat the functionality from Lab2-3 but now we want you to 
;   insert debugging instruments which gather data (state and timing)
;   to verify that the system is functioning as expected.
; Hardware connections (External: One button and one LED)
;  PE1 is Button input  (1 means pressed, 0 means not pressed)
;  PE0 is LED output (1 activates external LED on protoboard)
;  PF2 is Blue LED on Launchpad used as a heartbeat
; Instrumentation data to be gathered is as follows:
; After Button(PE1) press collect one state and time entry. 
; After Buttin(PE1) release, collect 7 state and
; time entries on each change in state of the LED(PE0): 
; An entry is one 8-bit entry in the Data Buffer and one 
; 32-bit entry in the Time Buffer
;  The Data Buffer entry (byte) content has:
;    Lower nibble is state of LED (PE0)
;    Higher nibble is state of Button (PE1)
;  The Time Buffer entry (32-bit) has:
;    24-bit value of the SysTick's Current register (NVIC_ST_CURRENT_R)
; Note: The size of both buffers is 50 entries. Once you fill these
;       entries you should stop collecting data
; The heartbeat is an indicator of the running of the program. 
; On each iteration of the main loop of your program toggle the 
; LED to indicate that your code(system) is live (not stuck or dead).

GPIO_PORTE_DATA_R  EQU 0x400243FC
GPIO_PORTE_DIR_R   EQU 0x40024400
GPIO_PORTE_AFSEL_R EQU 0x40024420
GPIO_PORTE_DEN_R   EQU 0x4002451C

GPIO_PORTF_DATA_R  EQU 0x400253FC
GPIO_PORTF_DIR_R   EQU 0x40025400
GPIO_PORTF_AFSEL_R EQU 0x40025420
GPIO_PORTF_PUR_R   EQU 0x40025510
GPIO_PORTF_DEN_R   EQU 0x4002551C
SYSCTL_RCGCGPIO_R  EQU 0x400FE608
NVIC_ST_CURRENT_R     EQU 0xE000E018
DELAY10			EQU		0x00003D000 ; this is 12.5ms which is 10% of a 8HZ frequency
DELAY80			EQU		0x0001E8000 
DELAY20			EQU		0x00007A000 ; this is 25ms which is 20% of a 8HZ frequency
DELAY40 		EQU 	0X0000F4000
DELAY60			EQU		0x00016E000
DELAY5			EQU		0x0000030CC	 ; this is 0.625ms which is 5% of a 80HZ frequency
DELAY100		EQU		0x000262000
DELAY1 			EQU     0x0000009C3 
DELAY1001		EQU		0x00003D02D 



; RAM Area
       AREA    DATA, ALIGN=2
DataBuffer 		SPACE 	50
TimeBuffer 		SPACE 	50*4
DataPt			SPACE     4
TimePt			SPACE	  4
NEntries		DCB	      0
		   
;-UUU-Declare  and allocate space for your Buffers 
;    and any variables (like pointers and counters) here
	
; ROM Area
       IMPORT  TExaS_Init
       IMPORT  SysTick_Init
;-UUU-Import routine(s) from other assembly files (like SysTick.s) here
       AREA    |.text|, CODE, READONLY, ALIGN=2
       THUMB
       EXPORT  Start

Start
		BL  TExaS_Init ; voltmeter, scope on PD3
	  
		LDR R0, =SYSCTL_RCGCGPIO_R  ; Turn on the clock for Port E and Port F
		LDR R1, [R0]    
		ORR R1, #0x30   
		STR R1, [R0]    
		NOP           
		NOP
		
		LDR R0, =GPIO_PORTE_DIR_R
		LDR R1, [R0]
		BIC	R1, #0x02   ; Make PE1 an input = 0
		ORR R1, #0x01	; Make PE0 an output = 1
		STR R1, [R0]
		
		LDR R0, =GPIO_PORTF_DIR_R
		LDR R1, [R0]
		ORR R1, #0x04	; Make PF2 an output = 1
		STR R1, [R0]
		
		LDR R0, =GPIO_PORTE_AFSEL_R 
		LDR R1, [R0]
		BIC R1, #0x03 	; Turn off alternate functions for Port E
		STR R1, [R0]
	
		LDR R0, =GPIO_PORTF_AFSEL_R 
		LDR R1, [R0]
		BIC R1, #0x04 	; Turn off alternate functions for Port F
		STR R1, [R0]
		
		LDR R0, =GPIO_PORTE_DEN_R
		LDR R1, [R0]
		ORR R1, #0x03   ; Enable PE1,PE0
		STR R1, [R0]
		
		LDR R0, =GPIO_PORTF_DEN_R
		LDR R1, [R0]
		ORR R1, #0x04   ; Enable PF4
		STR R1, [R0]
		
		LDR R0, =GPIO_PORTE_DATA_R  
		LDR R12, =GPIO_PORTF_DATA_R 
		
		BL Debug_Init

	  CPSIE  I    ; TExaS voltmeter, scope runs on interrupts

;R7, R9, AND R10
; THIS IS THE LOOP THAT OF A 20% DUTY CYCLE AT 8HZ
LOOP20 
;		Toggle the heartbeat LED here 
		LDR R11, [R12]
		EOR R11, #0x04
		STR R11, [R12]
		
		LDR R1, [R0]
		EOR R1, #0x01
		STR R1, [R0]
		LDR R2, =DELAY20
		CMP R9, #0
		BEQ DE201
		SUB R9, R9, #1		; This would dump R9 times
		BL Debug_Capture	; (54 instructions * 12.5ns) = 675ns/125ms * 100 = 0.00108% overhead
DE201 	SUBS R2, R2, #1
		BNE DE201
		EOR R1, #0x01
		STR R1, [R0]
		LDR R2, =DELAY80
		CMP R9, #0
		BEQ DE202
		SUB R9, R9, #1		; This would dump R9 times
		BL Debug_Capture
DE202	SUBS R2, R2, #1
		BNE DE202


		LDR R1, [R0]
		AND R5, R1, #0x02 ; R5 contains the current state of the switch (positive logic)
		CMP R6, #0x02 ; Check to see if it has been pressed so we only dump once
		BEQ NEXT20    ; Skip the next few lines if it has been pressed before
	
		ORR R6, R6, R5 ; If it is pressed put 1 in R6 
    	CMP R6, #0x02  ; Check to see if it has been pressed for the first time
        BNE NEXT20    ; If not pressed yet, just loop back
		MOV R9, #1    ; If it is pressed for the first time, we want to dump only once, R9 = 1
		B LOOP20

NEXT20	EOR R8, R5, R6 ; If turned on (R6=1) but then is released, this logic will turn R8 into a 1
		CMP R8, #0x02 
		BNE LOOP20     ; Keep looping without a dump if it has not been released
		MOV R9, #7     ; Once it is released, we want to dump 7 times, R9 = 7
		AND R6, R6, #0
		B LOOP40
	
	
; THIS IS A LOOP OF 40% DUTY CYCLE AT 8HZ		
LOOP40
;		Toggle the heartbeat LED here 
		LDR R11, [R12]
		EOR R11, #0x04
		STR R11, [R12]

		LDR R1, [R0]
		EOR R1, #0x01
		STR R1, [R0]
		LDR R2, =DELAY40
		CMP R9, #0
		BEQ DE401
		SUB R9, R9, #1		; This would dump R9 times
		BL Debug_Capture
DE401 	SUBS R2, R2, #1
		BNE DE401
		EOR R1, #0x01
		STR R1, [R0]
		LDR R2, =DELAY60
		CMP R9, #0
		BEQ DE402
		SUB R9, R9, #1		; This would dump R9 times
		BL Debug_Capture
DE402	SUBS R2, R2, #1
		BNE DE402
		
		LDR R1, [R0]
		AND R5, R1, #0x02 ; R5 contains the current state of the switch (positive logic)
		CMP R6, #0x02 ; Check to see if it has been pressed so we only dump once
		BEQ NEXT40    ; Skip the next few lines if it has been pressed before
		
		ORR R6, R6, R5 ; If it is pressed put 1 in R6 
    	CMP R6, #0x02  ; Check to see if it has been pressed for the first time
        BNE NEXT40    ; If not pressed yet, just loop back
		MOV R9, #1     ; If it is pressed for the first time, we want to dump only once, R9 = 1
		B LOOP40
		
NEXT40	EOR R8, R5, R6 ; If turned on (R6=1) but then is released, this logic will turn R8 into a 1
		CMP R8, #0x02 
		BNE LOOP40
		MOV R9, #7     ; Once it is released, we want to dump 7 times, R9 = 7
		AND R6, R6, #0
		B LOOP60

; THIS IS A LOOP OF 60% DUTY CYCLE AT 8HZ
LOOP60
;		Toggle the heartbeat LED here 
		LDR R11, [R12]
		EOR R11, #0x04
		STR R11, [R12]

		LDR R1, [R0]
		EOR R1, #0x01
		STR R1, [R0]
		LDR R2, =DELAY60
		CMP R9, #0
		BEQ DE601
		SUB R9, R9, #1		; This would dump R9 times
		BL Debug_Capture
DE601 	SUBS R2, R2, #1
		BNE DE601
		EOR R1, #0x01
		STR R1, [R0]
		LDR R2, =DELAY40
	    CMP R9, #0
		BEQ DE602
		SUB R9, R9, #1		; This would dump R9 times
		BL Debug_Capture
DE602	SUBS R2, R2, #1
		BNE DE602
		
	
		LDR R1, [R0]
		AND R5, R1, #0x02 ; R5 contains the current state of the switch (positive logic)
		CMP R6, #0x02 ; Check to see if it has been pressed so we only dump once
		BEQ NEXT60    ; Skip the next few lines if it has been pressed before
		
		ORR R6, R6, R5 ; If it is pressed put 1 in R6 
    	CMP R6, #0x02  ; Check to see if it has been pressed for the first time
        BNE NEXT60    ; If not pressed yet, just loop back
		MOV R9, #1     ; If it is pressed for the first time, we want to dump only once, R9 = 1
		B LOOP60
		
NEXT60	EOR R8, R5, R6 ; If turned on (R6=1) but then is released, this logic will turn R8 into a 1
		CMP R8, #0x02 
		BNE LOOP60
		MOV R9, #7     ; Once it is released, we want to dump 7 times, R9 = 7
		AND R6, R6, #0
		B LOOP80

; THIS IS A LOOP OF 80% DUTY CYCLE AT 8HZ
LOOP80
;		Toggle the heartbeat LED here 
		LDR R11, [R12]
		EOR R11, #0x04
		STR R11, [R12]
		
		LDR R1, [R0]
		EOR R1, #0x01
		STR R1, [R0]
		LDR R2, =DELAY80
		CMP R9, #0
		BEQ DE801
		SUB R9, R9, #1		; This would dump R9 times
		BL Debug_Capture
DE801 	SUBS R2, R2, #1
		BNE DE801
		EOR R1, #0x01
		STR R1, [R0]
		LDR R2, =DELAY20
		CMP R9, #0
		BEQ DE802
		SUB R9, R9, #1		; This would dump R9 times
		BL Debug_Capture
DE802	SUBS R2, R2, #1
		BNE DE802
		
		LDR R1, [R0]
		AND R5, R1, #0x02 ; R5 contains the current state of the switch (positive logic)
		CMP R6, #0x02 ; Check to see if it has been pressed so we only dump once
		BEQ NEXT80    ; Skip the next few lines if it has been pressed before
		
		ORR R6, R6, R5 ; If it is pressed put 1 in R6 
    	CMP R6, #0x02  ; Check to see if it has been pressed for the first time
        BNE NEXT80    ; If not pressed yet, just loop back
		MOV R9, #1    ; If it is pressed for the first time, we want to dump only once, R9 = 1 
		B LOOP80	

NEXT80	EOR R8, R5, R6 ; If turned on (R6=1) but then is released, this logic will turn R8 into a 1
		CMP R8, #0x02 
		BNE LOOP80
		MOV R9, #7    ; Once it is released, we want to dump 7 times, R9 = 7
		AND R6, R6, #0
		B LOOP100

; THIS IS A LOOP OF 100% DUTY CYCLE AT 8HZ
LOOP100
;		Toggle the heartbeat LED here 
		LDR R11, [R12]
		EOR R11, #0x04
		STR R11, [R12]
		
		LDR R1, [R0]
		ORR R1, #0x01
		STR R1, [R0]
		
		LDR R2, =DELAY100
		CMP R9, #0
		BEQ DE1001
		SUB R9, R9, #1		; This would dump R9 times
		BL Debug_Capture

DE1001 	SUBS R2, R2, #1
		BNE DE1001
		
		LDR R1, [R0]
		AND R5, R1, #0x02 ; R5 contains the current state of the switch (positive logic)
		CMP R6, #0x02 ; Check to see if it has been pressed so we only dump once
		BEQ NEXT100    ; Skip the next few lines if it has been pressed before
		
		ORR R6, R6, R5 ; If it is pressed put 1 in R6 
    	CMP R6, #0x02  ; Check to see if it has been pressed for the first time
        BNE NEXT100    ; If not pressed yet, just loop back
		MOV R9, #1     ; If it is pressed for the first time, we want to dump only once, R9 = 1 
		B LOOP100	
		 
NEXT100	EOR R8, R5, R6 ; If turned on (R6=1) but then is released, this logic will turn R8 into a 1
		CMP R8, #0x02 
		BNE LOOP100
		MOV R9, #7     ; Once it is released, we want to dump 7 times, R9 = 7
		AND R6, R6, #0
		B LOOP0

; THIS IS A LOOP OF 0% DUTY CYCLE AT 8HZ
LOOP0	
;		Toggle the heartbeat LED here 
		LDR R11, [R12]
		EOR R11, #0x04
		STR R11, [R12]
		
		LDR R1, [R0]
		BIC R1, #0x01
		STR R1, [R0]
		
		LDR R2, =DELAY100
		CMP R9, #0
		BEQ DE01
		SUB R9, R9, #1		; This would dump R9 times
		BL Debug_Capture
		
DE01	SUBS R2, R2, #1
		BNE DE01
			
		LDR R1, [R0]
		AND R5, R1, #0x02 ; R5 contains the current state of the switch (positive logic)
		CMP R6, #0x02 ; Check to see if it has been pressed so we only dump once
		BEQ NEXT0    ; Skip the next few lines if it has been pressed before
		
			
		ORR R6, R6, R5 ; If it is pressed put 1 in R6 
    	CMP R6, #0x02  ; Check to see if it has been pressed for the first time
        BNE NEXT0    ; If not pressed yet, just loop back
		MOV R9, #1     ; If it is pressed for the first time, we want to dump only once, R9 = 1 
		B LOOP0	
		
NEXT0	EOR R8, R5, R6 ; If turned on (R6=1) but then is released, this logic will turn R8 into a 1
		CMP R8, #0x02 
		BNE LOOP0
		MOV R9, #7     ; Once it is released, we want to dump 7 times, R9 = 7
		AND R6, R6, #0
		B LOOP20

Debug_Init

		PUSH {R0,R1,R2,R3,R4,LR}
		LDR R1, =DataBuffer
		LDR R2, =DataPt
		STR R1, [R2]
		LDR R1, =TimeBuffer
		LDR R2, =TimePt
		STR R1, [R2]
		
		MOV R0, #50
		LDR R1, =DataBuffer
		LDR R2, =TimeBuffer
		LDR R3, =0xFFFFFFFF
		MOV R4, #0xFF
Fill_Array
		STRB R4, [R1]
		STR R3, [R2]
		ADD R1, R1, #1
		ADD R2, R2, #4
		SUBS R0, R0, #1
		BNE Fill_Array
		
		BL SysTick_Init
		
		POP {R0,R1,R2,R3,R4,LR}
		BX LR
	
		
Debug_Capture
		
		PUSH {R0, R1, R2, R3, R4, R5, R6, R7, R8, LR}
		LDR R0, =NEntries
		LDRB R1, [R0]
		CMP R1, #50
		BEQ Done_Capture
		
		LDR R2, =GPIO_PORTE_DATA_R
		LDR R3, [R2]
		LDR R4, =NVIC_ST_CURRENT_R
		LDR R5, [R4]
		
		AND R6, R3, #0x01
		AND R7, R3, #0x02
		LSL R7, #3
		ORR R3, R6, R7
		
		LDR R6, =DataPt ; Store into DataBuffer, increment pointer by 1
		LDR R7, [R6]
		STRB R3, [R7]
		ADD R7, R7, #1
		STR R7, [R6]
		
		LDR R6, =TimePt ; Store into TimeBuffer, increment pointer by 4
		LDR R7, [R6]
		STR R5, [R7]
		ADD R7, R7, #4
		STR R7, [R6]
		
		ADD R1, R1, #1 ; Update NEntries
		STRB R1, [R0]
Done_Capture
		POP {R0, R1, R2, R3, R4, R5, R6, R7, R8, LR}
		BX LR	

      ALIGN      ; make sure the end of this section is aligned
      END        ; end of file

