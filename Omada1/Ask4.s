.include "m16def.inc"

RESET:
    ldi r16, high(RAMEND)
    out SPH, r16
    ldi r16, low(RAMEND)
    out SPL, r16

    clr r16
    out DDRA, r16    ; PORTA είσοδος
    ser r16
    out DDRC, r16    ; PORTC έξοδος

MAIN:
    in r16, PINA     ; Αριθμός input
    
    ; Έλεγχος αν  > 99 
    cpi r16, 100
    brsh OVERFLOW    ; Αν r16 >= 100 -> OVERFLOW

    ; Εύρεση Δεκάδων και Μονάδων
    clr r17          ; r17 οι Δεκάδες (μετρητής)
LOOP_10:
    cpi r16, 10      ; Σύγκρινε με το 10
    brlo FINISH      ; Αν είναι < 10, το r16 έχει τις μονάδες
    subi r16, 10     ; Αφαίρεσε 10
    inc r17          ; Αύξησε τις δεκάδες
    rjmp LOOP_10

FINISH:
    ; r17 = δεκάδες, r16 = μονάδες
    swap r17         ; Μετακινεί τα 4 LSB στα 4 MSB
    or r17, r16      ; Ενώνει δεκάδες και μονάδες
    out PORTC, r17   ; Έξοδος
    rjmp MAIN

OVERFLOW:
    ldi r16, 0xFF    ; Output 1111 1111
    out PORTC, r16
    rjmp MAIN