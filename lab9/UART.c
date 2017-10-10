// UART1.c
// Runs on LM4F120/TM4C123
// Use UART1 to implement bidirectional data transfer to and from 
// another microcontroller in Lab 9.  This time, interrupts and FIFOs
// are used.
// Daniel Valvano
// November 17, 2014
// Modified by EE345L students Charlie Gough && Matt Hawk
// Modified by EE345M students Agustinus Darmawan && Mingjie Qiu

/* Lab solution, Do not post
 http://users.ece.utexas.edu/~valvano/
*/

// U1Rx (VCP receive) connected to PC4
// U1Tx (VCP transmit) connected to PC5
#include <stdint.h>
#include "FiFo.h"
#include "UART.h"
#include "tm4c123gh6pm.h"

uint32_t DataLost; 
uint32_t RxCounter = 0;

// Initialize UART1
// Baud rate is 115200 bits/sec
// Make sure to turn ON UART1 Receiver Interrupt (Interrupt 6 in NVIC)
// Write UART1_Handler
void UART_Init(void){

	volatile uint32_t delay; 
	SYSCTL_RCGCUART_R |= 0x0002;	//activate UART1 
	delay = SYSCTL_RCGCUART_R; 
	delay = SYSCTL_RCGCUART_R; 
	delay = SYSCTL_RCGCUART_R;
	delay = SYSCTL_RCGCUART_R; 
	delay = SYSCTL_RCGCUART_R; 
	delay = SYSCTL_RCGCUART_R; 
	delay = SYSCTL_RCGCUART_R; 
	SYSCTL_RCGCGPIO_R |= 0x0004; 	//activate port C
	delay = SYSCTL_RCGCGPIO_R; 
	delay = SYSCTL_RCGCGPIO_R;
	delay = SYSCTL_RCGCGPIO_R;
	delay = SYSCTL_RCGCGPIO_R;
	delay = SYSCTL_RCGCGPIO_R;
	UART1_CTL_R &= ~0x0001; 			//disable UART 
	UART1_IBRD_R = 43; 						//IBRD = int(80000000/(16*115,200))=int(43.40278) *Baud rate = Baud16/16 = (Bus clock frequency)/(16*divider)* 
	UART1_FBRD_R = 26; 						// FBRD = round(0.40278 * 64) = 26
	UART1_LCRH_R = 0x0070;				//8-bit word length, enable FIFO
	UART1_LCRH_R &= ~0x0A;	
	UART1_CC_R &= ~0x0F;
	UART1_CTL_R |= 0x0301;
	GPIO_PORTC_PCTL_R = (GPIO_PORTC_PCTL_R&0xFF00FFFF)+0x00220000; //UART &xFF00FFFF + 0x00220000 
	GPIO_PORTC_AMSEL_R &= ~0x30;	//disable analog function on PC4-5 
	GPIO_PORTC_AFSEL_R |= 0x30;		//enable alternate function on PC4-5 
	GPIO_PORTC_DEN_R |= 0x30;			//enable digital I/O on PC4-5
	
	UART1_IM_R |= 0x10; 
	UART1_IFLS_R = (UART1_IFLS_R&(~0x38))+ 0x10; // check it at half full
	NVIC_PRI1_R = (NVIC_PRI1_R&0xFF0FFFFF)+0x00600000; // prio 3 
	NVIC_EN0_R |= 0x40;
	FiFo_Init();
}

//------------UART1_InChar------------
// input ASCII character from UART
// spin if RxFifo is empty
char UART_InChar(void){  
	while((UART1_FR_R & 0x0010) != 0) {}; //Wait until RXFE = 0 
	return ((unsigned char)(UART1_DR_R&0xFF)); 
}
//------------UART1_OutChar------------
// Output 8-bit to serial port
// Input: letter is an 8-bit ASCII character to be transferred
// Output: none
void UART_OutChar(char data){
  while((UART1_FR_R & 0x0020) != 0) {}; //Wait until TXFF = 0 
	UART1_DR_R = data;
}
//------------UART1_Handler------------
// hardware RX FIFO goes from 7 to 8 or more items
// UART receiver Interrupt is triggered; This is the ISR
void UART1_Handler(void){
	GPIO_PORTF_DATA_R ^= 0x02; // toggle PF1
  GPIO_PORTF_DATA_R ^= 0x02; // toggle PF1
	while ((UART1_FR_R & 0x0010) == 0){
		DataLost = UART1_DR_R;
		FiFo_Put(DataLost);
	}
	RxCounter++;
	UART1_ICR_R = 0x10;
	GPIO_PORTF_DATA_R ^= 0x02; // toggle PF1 
}
