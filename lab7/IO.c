// IO.c
// This software configures the switch and LED
// You are allowed to use any switch and any LED, 
// although the Lab suggests the SW1 switch PF4 and Red LED PF1
// Runs on LM4F120 or TM4C123
// Program written by: Michael and Jordan
// Date Created: 
// Last Modified:  
// Lab number: 7

#include "tm4c123gh6pm.h"
#include <stdint.h>

//------------IO_Init------------
// Initialize GPIO Port for a switch and an LED
// Input: none
// Output: none
void IO_Init(void) {
		volatile uint32_t delay;
		SYSCTL_RCGC2_R |= 0x20; // port F on
		delay = SYSCTL_RCGC2_R;
		GPIO_PORTF_DIR_R &= ~0x10; //PF4 is an input, set to 0
		GPIO_PORTF_DIR_R |= 0x02; //PF1 is an output, set to 1
		GPIO_PORTF_AFSEL_R &= ~0x12;
	  GPIO_PORTF_PUR_R |= 0x10; // Activate the pull up resistor
		GPIO_PORTF_DEN_R |= 0x12;
 // --UUU-- Code to initialize PF4 and PF1
}

//------------IO_HeartBeat------------
// Toggle the output state of the  LED.
// Input: none
// Output: none
void IO_HeartBeat(void) {
		GPIO_PORTF_DATA_R ^= 0x02; // Toggle the heartbeat
 // --UUU-- PF1 is heartbeat
}


//------------IO_Touch------------
// wait for release and press of the switch
// Delay to debounce the switch
// Input: none
// Output: none
void IO_Touch(void) {
 // --UUU-- wait for release; delay for 20ms; and then wait for press
		while ((GPIO_PORTF_DATA_R & 0x10) == 0x00){} // Wait for the release
	
		uint32_t volatile Time;
		uint32_t N = 20; // 20ms delay
		while(N){
			Time = 72724*2/91;  // 1msec, tuned at 80 MHz
			while(Time){
				Time--;
			}
			N--;
		}
		
		while ((GPIO_PORTF_DATA_R & 0x10) == 0x10){} // Wait for the press
	
}	

