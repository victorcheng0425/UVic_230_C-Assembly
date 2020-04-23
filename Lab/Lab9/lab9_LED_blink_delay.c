/*
 * blink_delay.c
 *
 * Created: 2019-11-11 1:01:03 PM
 * Author : Tom A
 */ 

#include "CSC230.h"

int main(void) {
	
    DDRL = 0b10101010;
	PORTL = 0b10000000;
	
    while (1) {
		PORTL = PORTL ^ 0b10100000;
		_delay_ms(1000);
    }
	
}

