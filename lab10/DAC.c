// dac.c
// This software configures DAC output
// Runs on LM4F120 or TM4C123
// Program written by: Michael and Jordan
// Date Created: 3/6/17 
// Last Modified: 3/20/17 
// Hardware connections
// PB2-5 are used

#include <stdint.h>
#include "tm4c123gh6pm.h"
// Code files contain the actual implemenation for public functions
// this file also contains an private functions and private data

// **************DAC_Init*********************
// Initialize 4-bit DAC, called once 
// Input: none
// Output: none
void DAC_Init(void){
	volatile uint32_t delay;
		SYSCTL_RCGCGPIO_R |= 0x02; // Port A
		delay = SYSCTL_RCGCGPIO_R;
		GPIO_PORTB_DIR_R |= 0x3C;
		GPIO_PORTB_AFSEL_R &= ~0x3C;
		GPIO_PORTB_DEN_R |= 0x3C; 
}

// **************DAC_Out*********************
// output to DAC
// Input: 4-bit data, 0 to 15 
// Output: none
void DAC_Out(uint32_t data){
		GPIO_PORTB_DATA_R = (data << 2);
} 
