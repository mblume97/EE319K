// Sound.h
// Runs on TM4C123 or LM4F120
// Prototypes for basic functions to play sounds from the
// original Space Invaders.
// Jonathan Valvano
// November 17, 2014

#include <stdint.h>

void Sound_Init(void);
void Timer1A_Handler(void);
void Sound_Play(const uint8_t *pt, uint32_t count);
void Sound_Swoosh(void);
void Sound_Win(void);
void Sound_CardFlip(void);
void Sound_Click(void);
void Sound_Lose(void);
void Sound_Beep(void);

