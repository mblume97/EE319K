// Lab6.c
// Runs on LM4F120 or TM4C123
// Use SysTick interrupts to implement a 4-key digital piano
// MOOC lab 13 or EE319K lab6 starter
// Program written by: Michael and Jordan
// Date Created: 3/6/17 
// Last Modified: 3/20/17 
// Lab number: 6
// Hardware connections



#include <stdint.h>
#include "tm4c123gh6pm.h"
#include "Sound.h"
#include "Piano.h"
#include "TExaS.h"
#include "DAC.h"

#define C 2389
#define E 3792
#define G 3189

// basic functions defined at end of startup.s
void DisableInterrupts(void); // Disable interrupts
void EnableInterrupts(void);  // Enable interrupts
void Heartbeat_Init(void);

int main(void){      
		TExaS_Init(SW_PIN_PE3210,DAC_PIN_PB3210,ScopeOn);    // bus clock at 80 MHz
		Piano_Init();
		Sound_Init(0);
		// other initialization
		EnableInterrupts();
		Heartbeat_Init();
		uint32_t Input;
		while(1){ 
			uint32_t delay2 = 1000000;
			while (delay2 > 0){
				delay2--;
			}
			GPIO_PORTF_DATA_R ^= 0x04; // Toggle the heartbeat
			Input = Piano_In();
			if (Input == 0x01){
				Sound_Play(C);
			} 
			else if (Input == 0x02){
				Sound_Play(E);
			} 
			else if (Input == 0x04){
				Sound_Play(G);
			}
			else {
				Sound_Play(0);
			}		
		}    
}

void Heartbeat_Init(void){
		volatile uint32_t delay;
		SYSCTL_RCGC2_R |= 0x20;
		delay = SYSCTL_RCGC2_R;
		GPIO_PORTF_DIR_R |= 0x04;  // PF 2 is the hearttbeat
		GPIO_PORTF_AFSEL_R &= ~0x04;
		GPIO_PORTF_DEN_R |= 0x04; 
}


