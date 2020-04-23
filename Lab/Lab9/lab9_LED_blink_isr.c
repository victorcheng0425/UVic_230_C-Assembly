/*
 * blink_isr.c
 *
 * Created: 2019-11-11 1:01:03 PM
 * Author : Tom A
 */ 

#include "CSC230.h"

int main(void) {

	// Set up the PORTS	
    DDRL = 0b10101010;
	DDRB = DDRB | 0b00001010;
	
	// Set up Timer 0 
	TCCR1A = 0;
	TCCR1B = (1<<CS12)|(1<<CS10);	// Prescaler of 1024	
	TCNT1 = 0xFFFF - 15626;			// Initial count (1 second)
	TIMSK1 = 1<<TOIE1;
	sei();
	
	// Initialize the first LED on each port
	PORTL = 0b10000000;
	PORTB = PORTB | 0b00001000;
	
	// Busy loop with delay to blink the PORTL LED
    while (1) {
		PORTL = PORTL ^ 0b10100000;
		_delay_ms(1000);
    }
	
}

ISR(TIMER1_OVF_vect) {
	PORTB ^= 0b00001010;		// toggle the LEDs on PORTB
	TCNT1 = 0xFFFF - 15626;		// reset the initial count
}

