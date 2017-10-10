// Sound.c
// This module contains the SysTick ISR that plays sound
// Runs on LM4F120 or TM4C123
// Program written by: Michael and Jordan
// Date Created: 3/6/17 
// Last Modified: 3/20/17 
// Lab number: 6
// Hardware connections
// DAC is Port A 5-2

// Code files contain the actual implemenation for public functions
// this file also contains an private functions and private data
#include <stdint.h>
#include "dac.h"
#include "tm4c123gh6pm.h"


const uint8_t SineWave[32] = {8,9,11,12,13,14,14,15,15,15,14,14,13,12,11,9,8,7,5,4,3,2,2,1,1,1,2,2,3,4,5,7};
uint8_t Index;
	
// **************Sound_Init*********************
// Initialize Systick periodic interrupts
// Called once, with sound initially off
// Input: interrupt period
//           Units to be determined by YOU
//           Maximum to be determined by YOU
//           Minimum to be determined by YOU
// Output: none
void Sound_Init(uint32_t period){
		DAC_Init();
		Index = 0;
		NVIC_ST_CTRL_R = 0;
		NVIC_ST_RELOAD_R = period - 1;
		NVIC_ST_CURRENT_R = 0;
		NVIC_SYS_PRI3_R = (NVIC_SYS_PRI3_R&0x00FFFFFF)|0x20000000; // priority level
		NVIC_ST_CTRL_R = 0x0007;		// enable SysTick with interrupts
}

void SysTick_Handler(void){
		DAC_Out(SineWave[Index]); // output one value each interrupt 
	  Index = (Index+1)&0x1F;
}
// **************Sound_Play*********************
// Start sound output, and set Systick interrupt period 
// Input: interrupt period
//           Units to be determined by YOU
//           Maximum to be determined by YOU
//           Minimum to be determined by YOU
//         input of zero disable sound output
// Output: none
void Sound_Play(uint32_t period){
		if (period == 0){
			NVIC_ST_RELOAD_R = 0;
		} else{
			NVIC_ST_RELOAD_R = period - 1;
			}
}

