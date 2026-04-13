.include "m16def.inc"

RESET:
    ldi r16, low(RAMEND)
    out SPL, r16
    ldi r16, high(RAMEND)
    out SPH, r16

    clr r16
    out DDRA, r16       ; PORTA είσοδος
    ser r16
    out DDRB, r16       ; PORTB έξοδος

MAIN_LOOP:
    in r16, PINA        ; Διάβασμα εισόδου
    clr r17             ; Εδώ η έξοδος PORTB

    ; Υπολογισμός X0 (Bit 0)
    ; X0 = A0 OR B0. Στην PORTA: B0=Bit0, A0=Bit1
    mov r18, r16
    andi r18, 0b00000001 ; Απομόνωση B0 με μασκ
    mov r19, r16
    lsr r19              ; Μετακίνηση A0 από Bit1 στο Bit0
    andi r19, 0b00000001 ; Απομόνωση A0
    or r18, r19          ; r18 = X0
    sbrc r18, 0          ; Αν X0=1 κάνε την επόμενη εντολή αλλιώς σκίπ
    ori r17, (1<<0)      ; θέσε το Bit 0 της εξόδου (θα μπορούσαμε και sbr αντί για ori). Δεν κάνουμε ldi r17, 0b00000001 γιατί θα μεταβάλλαμε άλλα Bits της εξόδου.

    ;Υπολογισμός X1 (Bit 2) 
    ; X1 = (A1 OR B1) AND X0. Στην PORTA: B1=Bit2, A1=Bit3
    mov r20, r16
    andi r20, 0b00000100 ; Απομόνωση B1
    mov r21, r16
    lsr r21              ; Μετακίνηση A1 από Bit3 στο Bit2
    andi r21, 0b00000100 ; Απομόνωση A1
    or r20, r21          ; r20 = (A1 OR B1)

	mov r19, r18         ; r18 έχει το X0 στο Bit 0 , το βάζουμε στο Bit 2 του r19 
    lsl r19              
    lsl r19              

    and r20, r19         ; r20 = (A1 OR B1) AND X0 
    sbrc r20, 2          ; Αν το αποτέλεσμα στο Bit 2 είναι 1 κάνε την επόμενη εντολή αλλιώς σκίπ
    ori r17, (1<<2)      ; Θέσε το Bit 2 της εξόδου

    ; Υπολογισμός X2 (Bit 4)
    ; X2 = A2 & B2. Στην PORTA: B2=Bit4, A2=Bit5
    mov r22, r16
    andi r22, 0b00010000 ; Απομόνωση B2
    mov r23, r16
    lsr r23              ; Μετακίνηση A2 από Bit5 στο Bit4
    andi r23, 0b00010000 ; Απομόνωση A2
    and r22, r23         ; r22 = X2
    sbrc r22, 4          ; Αν X2=1 κάνε την επόμενη εντολή αλλιώς σκίπ
    ori r17, (1<<4)      ; Θέσε το Bit 4 της εξόδου

    ; Υπολογισμός X3 (Bit 6) 
    mov r24, r16
    andi r24, 0b01000000 ; B3 στο Bit 6
    mov r25, r16
    lsr r25              ; A3 από Bit 7 -> Bit 6
    andi r25, 0b01000000 ; A3 στο Bit 6
    and r24, r25         ; r24 = (A3 AND B3) στο Bit 6

    ; X2 ευθυγράμμηση (από το Bit 4 στο Bit 6)
    mov r21, r22         ; r22 έχει το X2 στο Bit 4
    lsl r21              ; Bit 4 -> Bit 5
    lsl r21              ; Bit 5 -> Bit 6

    eor r24, r21         ; (A3 AND B3) XOR X2
    
    sbrc r24, 6
    ori r17, (1<<6)

    out PORTB, r17      ; Εμφάνιση αποτελέσματος
    rjmp MAIN_LOOP