// TableTrafficLight.c solution to edX lab 10, EE319KLab 5
// Runs on LM4F120 or TM4C123
// Index implementation of a Moore finite state machine to operate a traffic light.  
// Daniel Valvano, Jonathan Valvano
// November 7, 2013
// By Michael Blume and Jordan

/* solution, do not post

 Copyright 2014 by Jonathan W. Valvano, valvano@mail.utexas.edu
    You may use, edit, run or distribute this file
    as long as the above copyright notice remains
 THIS SOFTWARE IS PROVIDED "AS IS".  NO WARRANTIES, WHETHER EXPRESS, IMPLIED
 OR STATUTORY, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE APPLY TO THIS SOFTWARE.
 VALVANO SHALL NOT, IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL,
 OR CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.
 For more information about my classes, my research, and my books, see
 http://users.ece.utexas.edu/~valvano/
 */

// east/west red light connected to PB5
// east/west yellow light connected to PB4
// east/west green light connected to PB3
// north/south facing red light connected to PB2
// north/south facing yellow light connected to PB1
// north/south facing green light connected to PB0
// pedestrian detector connected to PE2 (1=pedestrian present)
// north/south car detector connected to PE1 (1=car present)
// east/west car detector connected to PE0 (1=car present)
// "walk" light connected to PF3 (built-in green LED)
// "don't walk" light connected to PF1 (built-in red LED)
#include <stdint.h>
#include "tm4c123gh6pm.h"
#include "SysTick.h"
#include "TExaS.h"

// Declare your FSM linked structure here
struct State {
	uint32_t Output;
	uint32_t Time;
	uint32_t Next[8];
};
typedef const struct State Stype;
#define GoS						0
#define waitS					1
#define waitSWalk			2
#define waitSBoth			3
#define GoW						4
#define waitW					5
#define waitWWalk			6
#define waitWBoth			7	
#define walkReg				8
#define TogReg1				9
#define TogReg2				10
#define TogReg3				11
#define walkSBoth			12
#define TogSBoth1			13
#define TogSBoth2			14
#define TogSBoth3			15
#define walkWBoth			16
#define TogWBoth1			17
#define TogWBoth2			18
#define TogWBoth3			19
Stype FSM[20]={
	{0x85, 150, {GoS, GoS, waitS, waitS, waitSWalk, waitSWalk, waitSBoth, waitSBoth}},
	{0x89, 50, {GoW, GoW, GoW, GoW, GoW, GoW, GoW, GoW}},
	{0x89, 50, {walkReg, walkReg, walkReg, walkReg, walkReg, walkReg, walkReg, walkReg}},
	{0x89, 50, {walkSBoth, walkSBoth, walkSBoth, walkSBoth, walkSBoth, walkSBoth, walkSBoth, walkSBoth}},
	{0x31, 150, {GoW, waitW, GoW, waitW, waitWWalk, waitWBoth, waitWWalk, waitWBoth}},
	{0x51, 50, {GoS, GoS, GoS, GoS, GoS, GoS, GoS, GoS}},
	{0x51, 50, {walkReg, walkReg, walkReg, walkReg, walkReg, walkReg, walkReg, walkReg}},
	{0x51, 50, {walkWBoth, walkWBoth, walkWBoth, walkWBoth, walkWBoth, walkWBoth, walkWBoth, walkWBoth}},
	{0x92, 100, {TogReg1, TogReg1, TogReg1, TogReg1, TogReg1, TogReg1, TogReg1, TogReg1}},
	{0x91, 50, {TogReg2, TogReg2, TogReg2, TogReg2, TogReg2, TogReg2, TogReg2, TogReg2}},
	{0x90, 25, {TogReg3, TogReg3, TogReg3, TogReg3, TogReg3, TogReg3, TogReg3, TogReg3}},
	{0x91, 50, {GoS, GoS, GoW, GoS, GoS, GoS, GoW, GoS}},
	{0x92, 100, {TogSBoth1, TogSBoth1, TogSBoth1, TogSBoth1, TogSBoth1, TogSBoth1, TogSBoth1, TogSBoth1}},
	{0x91, 50, {TogSBoth2, TogSBoth2, TogSBoth2, TogSBoth2, TogSBoth2, TogSBoth2, TogSBoth2, TogSBoth2}},
	{0x90, 25, {TogSBoth3, TogSBoth3, TogSBoth3, TogSBoth3, TogSBoth3, TogSBoth3, TogSBoth3, TogSBoth3}},
	{0x91, 50, {GoW, GoW, GoW, GoW, GoW, GoW, GoW, GoW}},
	{0x92, 100, {TogWBoth1, TogWBoth1, TogWBoth1, TogWBoth1, TogWBoth1, TogWBoth1, TogWBoth1, TogWBoth1}},
	{0x91, 50, {TogWBoth2, TogWBoth2, TogWBoth2, TogWBoth2, TogWBoth2, TogWBoth2, TogWBoth2, TogWBoth2}},
	{0x90, 25, {TogWBoth3, TogWBoth3, TogWBoth3, TogWBoth3, TogWBoth3, TogWBoth3, TogWBoth3, TogWBoth3}},
	{0x91, 50, {GoS, GoS, GoS, GoS, GoS, GoS, GoS, GoS}},
};

uint32_t state; 
uint32_t input; 
void EnableInterrupts(void);

int main(void){ volatile unsigned long delay;
  TExaS_Init(SW_PIN_PE210, LED_PIN_PB543210); // activate traffic simulation and set system clock to 80 MHz
  SysTick_Init();
  
	SYSCTL_RCGC2_R |= 0x31; //A,E,F clock on
	delay = SYSCTL_RCGC2_R;
	
	GPIO_PORTA_AMSEL_R &= ~0xFC; // PA 7-2 are the output lights
	GPIO_PORTA_PCTL_R &= ~0x0000000FF;
	GPIO_PORTA_DIR_R |= 0xFC;
	GPIO_PORTA_AFSEL_R &= ~0xFC;
	GPIO_PORTA_DEN_R |= 0xFC;
	
	GPIO_PORTE_AMSEL_R &= ~0x07; // PE 2-0 are the inputs
	GPIO_PORTE_PCTL_R &= ~0x0000000FF;
	GPIO_PORTE_DIR_R &= ~0x07;
	GPIO_PORTE_AFSEL_R &= ~0x07;
	GPIO_PORTE_DEN_R |= 0x07;
	
	GPIO_PORTF_AMSEL_R &= ~0x0A;
	GPIO_PORTF_PCTL_R &= ~0x0000000FF;
	GPIO_PORTF_DIR_R |= 0x0A; // PF 1 and 3 are outputs for walk, don't walk
	GPIO_PORTF_AFSEL_R &= ~0x0A;
	GPIO_PORTF_DEN_R |= 0x0A;
	
	state = GoS; // first state is just go south
	
  EnableInterrupts();
  //FSM Engine
  while(1){
		GPIO_PORTA_DATA_R = (FSM[state].Output & 0xFC);
		GPIO_PORTF_DATA_R = (((FSM[state].Output & 0x01) <<1) | ((FSM[state].Output & 0x02) << 2));
		SysTick_Wait10ms(FSM[state].Time);
		input = GPIO_PORTE_DATA_R & 0x07;
		state = FSM[state].Next[input];
  }
}

