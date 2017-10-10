// Lab9.c
// Runs on LM4F120 or TM4C123
// Student names: change this to your names or look very silly
// Last modification date: change this to the last modification date or look very silly
// Last Modified: 4/10/2017 

// Analog Input connected to PE2=ADC1
// displays on Sitronox ST7735
// PF3, PF2, PF1 are heartbeats
// UART1 on PC4-5
// * Start with where you left off in Lab8. 
// * Get Lab8 code working in this project.
// * Understand what parts of your main have to move into the UART1_Handler ISR
// * Rewrite the SysTickHandler
// * Implement the s/w FiFo on the receiver end 
//    (we suggest implementing and testing this first)

#include <stdint.h>

#include "ST7735.h"
#include "TExaS.h"
#include "ADC.h"
#include "print.h"
#include "tm4c123gh6pm.h"
#include "UART.h"
#include "FiFo.h"

//*****the first three main programs are for debugging *****
// main1 tests just the ADC and slide pot, use debugger to see data
// main2 adds the LCD to the ADC and slide pot, ADC data is on Nokia
// main3 adds your convert function, position data is no Nokia

void DisableInterrupts(void); // Disable interrupts
void EnableInterrupts(void);  // Enable interrupts

#define PF1       (*((volatile uint32_t *)0x40025008))
#define PF2       (*((volatile uint32_t *)0x40025010))
#define PF3       (*((volatile uint32_t *)0x40025020))
uint32_t Data;      // 12-bit ADC
uint32_t Position;  // 32-bit fixed-point 0.001 cm

uint32_t ADCStatus;
uint32_t ADCMail;
uint32_t TxCounter = 0;

// Initialize Port F so PF1, PF2 and PF3 are heartbeats
void PortF_Init(void){
	volatile uint32_t delay;
	SYSCTL_RCGCGPIO_R |= 0x20; // turn on clock for Port F
	delay = SYSCTL_RCGCGPIO_R;
	GPIO_PORTF_DIR_R |= 0x0E;
	GPIO_PORTF_AFSEL_R &= ~0x0E;
	GPIO_PORTF_DEN_R |= 0x0E;
}

void SysTick_Init(void){
		NVIC_ST_CTRL_R = 0;
		NVIC_ST_RELOAD_R = 2000000; //40 Mhz
		NVIC_ST_CURRENT_R = 0;
//		NVIC_SYS_PRI3_R = (NVIC_SYS_PRI3_R&0x00FFFFFF)|0x20000000; // priority level
		NVIC_ST_CTRL_R = 0x0007;		// enable SysTick with interrupts
}

// Get fit from excel and code the convert routine with the constants
// from the curve-fit
uint32_t Convert(uint32_t input){
 	uint32_t pos;
  pos = ((input * (4513))/10000)-147;
	return pos;
}


// final main program for bidirectional communication
// Sender sends using SysTick Interrupt
// Receiver receives using RX
char data;

int main(void){ 
  
  TExaS_Init();       // Bus clock is 80 MHz 
  ST7735_InitR(INITR_REDTAB);
  ADC_Init();    // initialize to sample ADC
  PortF_Init();
  UART_Init();       // initialize UART
	SysTick_Init();
  EnableInterrupts();
  while(1){
		while (FiFo_Get(&data) == 0) {} // wait until there is data			
		if ((data != 0x02) && (data != 0x03) && (data != 0x0D)){
			ST7735_OutChar(data);
		} else if (data == 0x03) {
			ST7735_OutString(" cm"); 
		}	else if (data == 0x02) {
			ST7735_SetCursor(0,0);
		}
	}
}

/* SysTick ISR
*/
void SysTick_Handler(void){ // every 25 ms
		uint8_t ADC_Temp[8];
		uint8_t i;
	
		GPIO_PORTF_DATA_R ^= 0x04;
		ADCMail = ADC_In();
		GPIO_PORTF_DATA_R ^= 0x04; //toggle PF2 twice
		ADCMail = Convert(ADCMail);
	
		ADC_Temp[0] = 0x02; 
		ADC_Temp[1] = (ADCMail/1000); 
		ADCMail -= 1000*ADC_Temp[1]; 
		ADC_Temp[1] += 0x30; 
		ADC_Temp[2] = 0x2E; 
		ADC_Temp[3] = ADCMail/100; 
		ADCMail -= 100*ADC_Temp[3]; 
		ADC_Temp[3] += 0x30; 
		ADC_Temp[4] = ADCMail/10; 
		ADCMail -= 10*ADC_Temp[4]; 
		ADC_Temp[4] += 0x30; 
		ADC_Temp[5] = ADCMail; 
		ADC_Temp[5] += 0x30; 
		ADC_Temp[6] = 0x0D; 
		ADC_Temp[7] = 0x03; 
		for(i=0; i<8; i++){ 
			UART_OutChar(ADC_Temp[i]); 
		} 
		TxCounter++;
		GPIO_PORTF_DATA_R ^= 0x04;
}


uint32_t Status[20];             // entries 0,7,12,19 should be false, others true
char GetData[10];  // entries 1 2 3 4 5 6 7 8 should be 1 2 3 4 5 6 7 8
int main2(void){ // Make this main to test FiFo
  FiFo_Init(); // Assuming a buffer of size 6
  for(;;){
    Status[0]  = FiFo_Get(&GetData[0]);  // should fail,    empty
    Status[1]  = FiFo_Put(1);            // should succeed, 1 
    Status[2]  = FiFo_Put(2);            // should succeed, 1 2
    Status[3]  = FiFo_Put(3);            // should succeed, 1 2 3
    Status[4]  = FiFo_Put(4);            // should succeed, 1 2 3 4
    Status[5]  = FiFo_Put(5);            // should succeed, 1 2 3 4 5
    Status[6]  = FiFo_Put(6);            // should succeed, 1 2 3 4 5 6
    Status[7]  = FiFo_Put(7);            // should fail,    1 2 3 4 5 6 
    Status[8]  = FiFo_Get(&GetData[1]);  // should succeed, 2 3 4 5 6
    Status[9]  = FiFo_Get(&GetData[2]);  // should succeed, 3 4 5 6
    Status[10] = FiFo_Put(7);            // should succeed, 3 4 5 6 7
    Status[11] = FiFo_Put(8);            // should succeed, 3 4 5 6 7 8
    Status[12] = FiFo_Put(9);            // should fail,    3 4 5 6 7 8 
    Status[13] = FiFo_Get(&GetData[3]);  // should succeed, 4 5 6 7 8
    Status[14] = FiFo_Get(&GetData[4]);  // should succeed, 5 6 7 8
    Status[15] = FiFo_Get(&GetData[5]);  // should succeed, 6 7 8
    Status[16] = FiFo_Get(&GetData[6]);  // should succeed, 7 8
    Status[17] = FiFo_Get(&GetData[7]);  // should succeed, 8
    Status[18] = FiFo_Get(&GetData[8]);  // should succeed, empty
    Status[19] = FiFo_Get(&GetData[9]);  // should fail,    empty
  }
}

