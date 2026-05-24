.include "m16def.inc"

.cseg
.org 0x0000
    rjmp RESET

RESET:
    ; 1. Αρχικοποίηση Stack Pointer
    ldi r16, high(RAMEND)
    out SPH, r16
    ldi r16, low(RAMEND)
    out SPL, r16

    ; 2. Ρύθμιση Θυρών
    clr r16             
    out DDRB, r16       ; PORTB ως είσοδος (00000000)
    ser r16             
    out DDRD, r16       ; PORTD ως έξοδος (11111111)

MAIN_LOOP:
    in r17, PINB        ; Είσοδος PORTB στον r17
    
    ; Υπολογισμός Εναλλαγών
    clr r18             ; r18: Μετρητής εναλλαγών 
    ldi r19, 7          ; Θα κάνουμε 7 συγκρίσεις μεταξύ γειτονικών bits
    mov r20, r17        ; Αντίγραφο της εισόδου για επεξεργασία

COUNT_CHANGES:
    mov r21, r20        ; r21 = τρέχουσα κατάσταση
    lsr r20             ; Ολίσθηση του r20 δεξιά για να φέρουμε το επόμενο bit
    eor r21, r20        ; Exclusive OR: Αν τα γειτονικά bits διαφέρουν, το LSB του r21 γίνεται 1
    sbrc r21, 0         ; Αν το bit 0 του r21 είναι 1 μην κάνεις σκιπ την κάτω
    inc r18             ; ’υξηση του μετρητή εναλλαγών
    
    dec r19             ; Μείωση μετρητή επαναλήψεων
    brne COUNT_CHANGES

    ; Δημιουργία Εξόδου PORTD
    clr r22             ; r22: Το byte εξόδου
    tst r18             ; Έλεγχος αν ο μετρητής είναι 0
    breq WRITE_OUTPUT   ; Αν δεν υπάρχουν εναλλαγές, βγες 00000000

    ldi r19, 8          ; Μετρητής για το χτίσιμο του byte εξόδου
SET_BITS_LOOP:
    sec                 ; Θέσε το Carry = 1
    ror r22             ; Rotate Right through Carry (το 1 μπαίνει από τα αριστερά στο MSB)
    dec r18             ; Μείωσε το πλήθος των bits που απομένουν
    breq WRITE_OUTPUT   ; Αν τελειώσαμε με τα bits, πήγαινε στην έξοδο
    dec r19
    brne SET_BITS_LOOP

WRITE_OUTPUT:
    out PORTD, r22      ; Εμφάνιση του αποτελέσματος στην PORTD
    rjmp MAIN_LOOP      ; Συνεχής λειτουργία