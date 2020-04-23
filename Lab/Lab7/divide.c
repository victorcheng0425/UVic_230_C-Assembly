#include <stdio.h>
/*division, using repeated subtractions.
Convert integer 123 to a character array: '1' '2' '3' '\0'
The last character '\0' indicates the end of the character array.
*/
int main()
{
	int dividend = 1234681;
	int quotient = 0;
	int divisor = 10;
	char num_in_char_array[4];
	num_in_char_array[3] = '\0';
	int i = 2;
	do {
		while(dividend >= divisor) {
			quotient++;
			dividend -= divisor;
		}
		num_in_char_array[i--] = dividend + '0';
		dividend = quotient;
		quotient = 0;
	} while(dividend >= divisor);
	num_in_char_array[i] = dividend + '0';
	printf ("%s\n", num_in_char_array);
	return 0;
}
