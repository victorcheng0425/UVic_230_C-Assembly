/* lab09_count_sprintf.c
   CSC 230 - Summer 2018
   
   A program which counts up from zero at
   approximately one second intervals.

   B. Bird - 07/21/2018
*/


#include "CSC230.h"
#include <string.h> //Include the standard library string functions



int main(){
	
	//Call LCD init (should only be called once)
	lcd_init();
	
	char str[100];

	int counter = 0;
	while(1){

		sprintf(str, "The count is %d", counter);		

		lcd_xy(0,0);
		lcd_puts(str);

		counter++;

		_delay_ms(1000);
			
	}




	return 0;
	
}
