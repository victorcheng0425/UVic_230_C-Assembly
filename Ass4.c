/*
 * Assignment4.c
 *
 * Created: 11/22/2019 3:38:29 PM
 * Author : Victor Cheng
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

//n holds the first row variable, set to 000* 0 when program starts
volatile unsigned short n[6] = {0, 0, 0, 42, 0}; //42=* , 48='0'
//count_char holds the cnt value (str)
volatile char count_char[4] = {' ', ' ', 0,'\0'};
//v holds the value (str)
volatile char v_char[7] = {' ', ' ', ' ', ' ', ' ', 0,'\0'}; //32=' '
//unsigned short variable used for calculation
volatile unsigned short count;
volatile unsigned short v;
volatile unsigned short col = 0;
volatile unsigned short blink_flag= 0;
volatile unsigned short button_flag=0;
volatile unsigned short start_flag = 0;
volatile unsigned short col_flag = 0;
volatile char zero[2] = {0};

//check button/adc function, will return a value that used to check button
unsigned short poll_adc(){
	unsigned short adc_result = 0; //16 bits
	
	ADCSRA |= 0x40;
	while((ADCSRA & 0x40) == 0x40); //Busy-wait
	
	unsigned short result_low = ADCL;
	unsigned short result_high = ADCH;
	
	adc_result = (result_high<<8)|result_low;
	return adc_result;
}

//turn integer from int array to string and put in string array
//nothing return when using this function
void str_to_int(){
	unsigned short temp_v = v;
	unsigned short temp_count = count;

	if(temp_v / 100000 +'0' == '0'){
		v_char[0] = ' ';
	}else{
		v_char[0] = temp_v / 100000 + '0';
	}
	
	if(temp_v/10000 - temp_v/100000*10 + '0' == '0' && temp_v / 100000 +'0' == '0'){
		v_char[1] = ' ';
	}else{
		v_char[1] = temp_v/10000 - temp_v/100000*10 + '0';
	}
	
	if(temp_v/1000 - temp_v/10000*10 + '0' == '0' && temp_v/10000 - temp_v/100000*10 + '0' && temp_v / 100000 +'0' == '0'){
		v_char[2] = ' ';
	}else{
		v_char[2] = temp_v/1000 - temp_v/10000*10 + '0';
	}
	
	if(temp_v/100 - temp_v/1000*10 + '0' == '0' && temp_v/1000 - temp_v/10000*10 + '0' == '0' && temp_v/10000 - temp_v/100000*10 + '0' && temp_v / 100000 +'0' == '0'){
		v_char[3] = ' ';
	}else{
		v_char[3] = temp_v/100 - temp_v/1000*10 + '0';
	}

	if(temp_v/10 - temp_v/100*10 + '0' == '0' && temp_v/100 - temp_v/1000*10 + '0' == '0' && temp_v/1000 - temp_v/10000*10 + '0' && temp_v/10000 - temp_v/100000*10 + '0' && temp_v / 100000 +'0' == '0'){
		v_char[4] = ' ';
	}else{
		v_char[4] = temp_v/10 - temp_v/100*10 + '0';
	}

	v_char[5] = temp_v - temp_v/10*10 + '0';
	
	//v_char[4] = 7 + '0';
	v_char[6] = '\0';
	
	if(temp_count/100 + '0' == '0'){
		count_char[0] = ' ';
	}else{
		count_char[0] = temp_count/100 + '0';
	}
	if(temp_count/10 - temp_count/100*10 +'0' == '0' && temp_count/100 + '0' == '0'){
		count_char[1] = ' ';
	}else{
		count_char[1] = temp_count/10 - temp_count/100*10 +'0';
	}
	count_char[2] = temp_count - temp_count/10*10 + '0';
}

//col seq function, update the value in the array
 void col_seq(){
	if(col_flag==0){
		v = n[0]*100 + n[1]*10 + n[2];
		col_flag = 1;
		return;
	}
	if(v==1){
		return;
	}
	if(v%2 == 0){
		v = v / 2;
		count ++;
	}else{
		v = v*3 + 1;
		count ++;
	}
}
	

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
	TCCR3B = (1<<CS32)|(1<<CS30);	// Prescaler of 1024
	TCNT3 = 0xFFFF - 15626;			// Initial count (1 second)
	TIMSK3 = 1<<TOIE3;
	
	TCCR4A = 0;
	TCCR4B = (1<<CS42)|(1<<CS40);	// Prescaler of 1024
	TCNT4 = 0xFFFF - 15626;			// Initial count (1 second)
	TIMSK4 = 1<<TOIE4;

	sei();
	char name[] = "Victor Cheng";
	lcd_xy(0,0);
	lcd_puts(name);
	char class[] = "CSC230-FALL2019";
	lcd_xy(0,1);
	lcd_puts(class);
	_delay_ms(1000);
	char row1[] = " n:000*   SPD:0 ";
	char row2[] = "cnt:  0 v:     0";
	lcd_xy(0,0);
	lcd_puts(row1);
	lcd_xy(0,1);
	lcd_puts(row2);
	
	
	unsigned short temp;
    //while loop used to update display
    while (1) 
    {
		if(blink_flag == 1 && col != 4){
			temp = col + 3;
			lcd_xy(temp,0);
			lcd_putchar(' ');
		}else if(blink_flag == 1 && col == 4){
			temp = col + 10;
			lcd_xy(temp,0);
			lcd_putchar(' ');
		}else{
		temp = n[0] + '0';
		lcd_xy(3,0);
		lcd_putchar(temp);
		temp = n[1] + '0';
		lcd_xy(4,0);
		lcd_putchar(temp);
		temp = n[2] + '0';
		lcd_xy(5,0);
		lcd_putchar(temp);
		temp = n[3];
		lcd_xy(6,0);
		lcd_putchar(temp);
		temp = n[4] + '0';
		lcd_xy(14,0);
		lcd_putchar(temp);
		
		lcd_xy(4,1);
		lcd_puts(count_char);
		
		lcd_xy(10,1);
		lcd_puts(v_char);
		}
		}
}

//check button ISR
ISR(TIMER1_OVF_vect) {
	// Reset the initial count
	TCNT1 = 0xFFFF - 782;
	unsigned short adc_result = poll_adc();
	if(adc_result < ADC_BTN_RIGHT){
		if(col!=4 && button_flag!=1){
			col+=1;
			button_flag = 1;
		}
		
	}else if(adc_result < ADC_BTN_UP){
		if(button_flag != 2){
			if(n[col] == 9){
				n[col] = 0;
			}else if(n[col] == 42){
				if(start_flag == 1){
					col_flag = 0;
					count = 0;
					v = 0;
				}
				start_flag = 1;
			}else{
				n[col] += 1;
			}
			
			button_flag = 2;
			
		}
	}else if(adc_result < ADC_BTN_DOWN){
		if(button_flag != 3){
			if(n[col] == 0){
				n[col] = 9;
			}else if(n[col] == 42){
				if(start_flag == 1){
					col_flag = 0;
					count = 0;
					v = 0;
				}
				start_flag = 1;
			}else{
				n[col] -= 1;
			}
				button_flag = 3;
			
			}
	}else if(adc_result < ADC_BTN_LEFT){
		if(col!=0 && button_flag!=4){
			col-=1;
			button_flag = 4;
		}
	}else if(adc_result < ADC_BTN_SELECT){
		if(button_flag != 5){
			unsigned short temp = n[4];
			n[4] = zero[0];
			zero[0] = temp;
			button_flag = 5;
}

	}else{
		button_flag = 0;
	}
}

//Timer3 change the TCNT3 depends on SPD
//Call col_seq and str_to_int if start_flag is 1
ISR(TIMER3_OVF_vect) {
	// Reset the initial count
	if(n[4] == 1){
		TCNT3 = 0xFFFF - 976;
	}else if(n[4] == 2){
		TCNT3 = 0xFFFF - 1953;
	}else if(n[4] == 3){
		TCNT3 = 0xFFFF - 3906;
	}else if(n[4] == 4){
		TCNT3 = 0xFFFF - 7812;
	}else if(n[4] == 5){
		TCNT3 = 0xFFFF - 15625;
	}else if(n[4] == 6){
		TCNT3 = 0xFFFF - 23437;
	}else if(n[4] == 7){
		TCNT3 = 0xFFFF - 31250;
	}else if(n[4] == 8){
		TCNT3 = 0xFFFF - 39062;
	}else if(n[4] == 9){
		TCNT3 = 0xFFFF - 46875;
	}else{
		return;
	}
	
	if(start_flag == 1){
		col_seq();
		str_to_int();
	//sprintf(cnt, "The count is %u", count);
	}
}

//Timer4 that control blinking
//blink flag in timer4
ISR(TIMER4_OVF_vect) {
	TCNT4 = 0xFFFF - 1953;
		blink_flag = blink_flag ^ 0x01;
}