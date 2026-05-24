#include <avr/io.h>


int main(void) {
    DDRA = 0x00; // Είσοδος
    DDRB = 0xFF; // Έξοδος

    while (1) {
        unsigned char port_in = PINA;
        unsigned char b0, a0, b1, a1, b2, a2, b3, a3;
        unsigned char x0, x1, x2, x3;
        unsigned char result = 0;

        // Απομόνωση και ευθυγράμμιση όλων στο Bit 0 
        b0 = (port_in >> 0) & 1; a0 = (port_in >> 1) & 1;
        b1 = (port_in >> 2) & 1; a1 = (port_in >> 3) & 1;
        b2 = (port_in >> 4) & 1; a2 = (port_in >> 5) & 1;
        b3 = (port_in >> 6) & 1; a3 = (port_in >> 7) & 1;

        // Λογικές Πράξεις (όλα είναι πλέον 0 ή 1)
        x0 = (a0 | b0);
        x1 = (a1 | b1) & x0;
        x2 = (a2 & b2);
        x3 = (a3 & b3) ^ x2;

        // Αποτέλεσμα στο PORTB
        if (x0) result |= (1 << 0); // Bit 0
        if (x1) result |= (1 << 2); // Bit 2
        if (x2) result |= (1 << 4); // Bit 4
        if (x3) result |= (1 << 6); // Bit 6

        PORTB = result;
    }
}
