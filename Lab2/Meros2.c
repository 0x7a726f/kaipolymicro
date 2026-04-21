#define F_CPU 16000000UL
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

volatile int ms_counter = -1;
volatile int target_time = 4000;

ISR(INT0_vect) {
	if (ms_counter >= 0) {
		target_time = 5000; 
		PORTB |= (1 << PB3) | (1 << PB2) | (1 << PB1);
	} 
	else {
		target_time = 4000; 
		PORTB |= (1 << PB2);
	}
	ms_counter = 0;
	EIFR = (1 << INTF0);
}

int main(void) {
	DDRB |= (1 << PB1) | (1 << PB2) | (1 << PB3);
	PORTB &= ~((1 << PB1) | (1 << PB2) | (1 << PB3)); 
	
	DDRD &= ~(1 << PD2);

	EICRA = (1 << ISC01);
	EICRA &= ~(1 << ISC00);

	EIMSK |= (1 << INT0);
	sei();
	
	while(1) {
		if (ms_counter >= 0) {
			_delay_ms(1);
			ms_counter++;
			
			if (target_time == 5000 && ms_counter == 1000) {
				PORTB &= ~((1 << PB1) | (1 << PB3));
			}
			
			if (ms_counter >= target_time) {
				PORTB &= ~(1 << PB2);
				ms_counter = -1;     
			}
		}
	}
	return 0;
}
