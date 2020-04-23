/*
 * lcd_isr.c
 *
 * Created: 2019-11-11 1:01:03 PM
 * Author : Tom A
 */ 

#include <avr/io.h>
#include "CSC230.h"

#define NUM_PATTERNS 6

char *pattern[NUM_PATTERNS] = { "*   ",
								" *  ",
								"  * ",
								"   *",
								"  * ",
								" *  " };

volatile uint8_t current = 0;

int main(void) {
	
	// Set up LCD
	lcd_init();
	
	// Set up Timer 0 
	TCCR1A = 0;
	TCCR1B = (1<<CS12)|(1<<CS10);	// Prescaler of 1024	
	TCNT1 = 0xFFFF - 15626;			// Initial count (1 second)
	TIMSK1 = 1<<TOIE1;
	sei();
	
	// Busy loop with delay to blink the PORTL LED
    while (1) {
		lcd_xy(0,0);
		lcd_puts(pattern[current]);
    }
	
}

ISR(TIMER1_OVF_vect) {
	// Reset the initial count
	TCNT1 = 0xFFFF - 15626;

	// Update a variable
	if(current < NUM_PATTERNS-1) {
		current++;
	} else {
		current = 0;
	}
}

