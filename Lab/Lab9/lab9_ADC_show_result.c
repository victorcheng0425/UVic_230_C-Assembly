/* lab09_show_adc_result.c
   CSC 230 - Summer 2018
   
   This program demonstrates how to poll the ADC with C code.
   The main loop polls the ADC and displays the result on the LCD
   screen in hex.

   B. Bird - 07/21/2018
*/


#include "CSC230.h"

#define  ADC_BTN_RIGHT 0x032
#define  ADC_BTN_UP 0x0C3
#define  ADC_BTN_DOWN 0x17C
#define  ADC_BTN_LEFT 0x22B
#define  ADC_BTN_SELECT 0x316
	


//A short is 16 bits wide, so the entire ADC result can be stored
//in an unsigned short.
unsigned short poll_adc(){
	unsigned short adc_result = 0; //16 bits
	
	ADCSRA |= 0x40;
	while((ADCSRA & 0x40) == 0x40); //Busy-wait
	
	unsigned short result_low = ADCL;
	unsigned short result_high = ADCH;
	
	adc_result = (result_high<<8)|result_low;
	return adc_result;
}





void short_to_hex(unsigned short v, char* str){
	char hex_chars[] = "0123456789ABCDEF";
	str[0] = '0';
	str[1] = 'x';
	str[2] = hex_chars[(v>>12)&0xf];
	str[3] = hex_chars[(v>>8)&0xf];
	str[4] = hex_chars[(v>>4)&0xf];
	str[5] = hex_chars[v&0xf];
	str[6] = '\0';
}


int main(){
	
	//ADC Set up
	ADCSRA = 0x87;
	ADMUX = 0x40;

	lcd_init();
	


	while(1){
		unsigned short adc_result = poll_adc();
		char s[10];
		short_to_hex(adc_result,s);
		lcd_xy(0,0);
		lcd_puts(s);
		_delay_ms(500);
	}
	
	return 0;
	
}
