// Piano.c
// This software configures the off-board piano keys
// Runs on LM4F120 or TM4C123
// Program written by: Michael and Jordan
// Date Created: 3/6/17 
// Last Modified: 3/6/17 
// Lab number: 6
// Hardware connections
// Piano keys are Port E 0-2

// Code files contain the actual implemenation for public functions
// this file also contains an private functions and private data
#include <stdint.h>
#include "tm4c123gh6pm.h"

// **************Piano_Init*********************
// Initialize piano key inputs, called once 
// Input: none 
// Output: none
void Piano_Init(void){
		volatile uint32_t delay;
		SYSCTL_RCGC2_R |= 0x10; // port E
		delay = SYSCTL_RCGC2_R;
		GPIO_PORTE_DIR_R &= ~0x0F; //PE 0-2 are inputs, set to 0
		GPIO_PORTE_AFSEL_R &= ~0x0F;
		GPIO_PORTE_DEN_R |= 0x0F;
}

// **************Piano_In*********************
// Input from piano key inputs 
// Input: none 
// Output: 0 to 7 depending on keys
// 0x01 is just Key0, 0x02 is just Key1, 0x04 is just Key2
uint32_t Piano_In(void){
		uint32_t input;
		input = GPIO_PORTE_DATA_R & 0x07;
		return input;
}
