.include "m328PBdef.inc"

.def count = r16
.def temp = r24

.org 0x0
    rjmp reset
.org 0x4
    rjmp isr1

reset:
    ldi temp, LOW(RAMEND)
    out SPL, temp
    ldi temp, HIGH(RAMEND)
    out SPH, temp

    ldi temp, 0x1E
    out DDRC, temp
    
    clr temp
    out DDRD, temp
    ldi temp, (1<<PORTD0)
    out PORTD, temp

    ldi temp, (1<<ISC11) | (0<<ISC10)
    sts EICRA, temp

    ldi temp, (1<<INT1)
    out EIMSK, temp

    clr count
    sei

main0:
    mov temp, count
    lsl temp
    out PORTC, temp
    rjmp main0

isr1:
    push r23
    push r24
    push r25
    in r25, SREG
    push r25

    sbis PIND, 0
    rjmp skip_inc

    inc count
    andi count, 0x0F

skip_inc:
    ldi r24, low(16*600)
    ldi r25, high(16*600)

delay1:
    ldi r23, 249
delay2:
    dec r23
    nop
    brne delay2
    sbiw r24, 1
    brne delay1

    ldi temp, (1<<INTF1)
    out EIFR, temp

    pop r25
    out SREG, r25
    pop r25
    pop r24
    pop r23
    reti
