/*
 * Lab9.c
 *
 * Created: 11/19/2019 2:23:33 PM
 * Author : Victor Cheng
 * ID: V00815317
 */ 

#include <avr/io.h>
#include "CSC230.h"
#include <string.h>
#include <stdio.h>

#define  ADC_BTN_RIGHT 0x032
#define  ADC_BTN_UP 0x0C3
#define  ADC_BTN_DOWN 0x17C
#define  ADC_BTN_LEFT 0x22B
#define  ADC_BTN_SELECT 0x316

unsigned short poll_adc(){
	unsigned short adc_result = 0; //16 bits
	
	ADCSRA |= 0x40;
	while((ADCSRA & 0x40) == 0x40); //Busy-wait
	
	unsigned short result_low = ADCL;
	unsigned short result_high = ADCH;
	
	adc_result = (result_high<<8)|result_low;
	return adc_result;
}


volatile char s[10];
volatile int count = 0;
volatile char cnt[100];

int main(void)
{
	ADCSRA = 0x87;
	ADMUX = 0x40;

	lcd_init();
	
	TCCR1A = 0;
	TCCR1B = (1<<CS12)|(1<<CS10);	// Prescaler of 1024
	TCNT1 = 0xFFFF - 15626;			// Initial count (1 second)
	TIMSK1 = 1<<TOIE1;
	
	TCCR3A = 0;
	TCCR3B = (1<<CS12)|(1<<CS10);	// Prescaler of 1024
	TCNT3 = 0xFFFF - 15626;			// Initial count (1 second)
	TIMSK3 = 1<<TOIE3;
	sei();
	
    /* Replace with your application code */
    while (1) 
    {
		lcd_xy(0,0);
		lcd_puts(s);
		
		lcd_xy(0,1);
		lcd_puts(cnt);
	}
	return 0;
}

ISR(TIMER1_OVF_vect) {
	// Reset the initial count
	TCNT1 = 0xFFFF - 782;
	unsigned short adc_result = poll_adc();
	if(adc_result < ADC_BTN_RIGHT){
		strcpy(s, "Right    "); //can use this one
		}else if(adc_result < ADC_BTN_UP){
		strcpy(s, "Up       "); //can use this one
		}else if(adc_result < ADC_BTN_DOWN){
		strcpy(s, "Down     "); //can use this one
		}else if(adc_result < ADC_BTN_LEFT){
		strcpy(s, "Left     "); //can use this one
		}else if(adc_result < ADC_BTN_SELECT){
		strcpy(s, "Select   "); //can use this one
		}else{
		strcpy(s, "         "); //can use this one
		}
	
}


ISR(TIMER3_OVF_vect) {
	// Reset the initial count
	TCNT3 = 0xFFFF - 15625;
	cnt[0] = '1';
	sprintf(cnt, "The count is %u", count);
	count ++;
}
