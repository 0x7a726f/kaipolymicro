#include <avr/io.h>

int main(void) {
	DDRA = 0x00; // Είσοδος
	DDRC = 0xFF; // Έξοδος (PORTC)

	while (1) {
		unsigned char val = PINA;
		
		if (val > 99) {
			PORTC = 0xFF;
			} else {
			unsigned char tens = val / 10;    // Δεκάδες
			unsigned char units = val % 10;   // Μονάδες
			
			// Δεκάδες στα υψηλά 4 bits και μονάδες στα χαμηλά
			PORTC = (tens << 4) | units;
		}
	}
}

