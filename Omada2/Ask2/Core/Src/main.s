/*
 * main.s
 *
 *  Created on: May 24, 2026
 *      Author: Stefanos Kargas
 */


.syntax unified
.cpu cortex-m4
.thumb

.global main

.section .text
.align 2

main:
    @ 1. CLOCK (RCC AHB1ENR)

    ldr r0, =0x40023830      @ Διεύθυνση RCC_AHB1ENR
    ldr r1, [r0]
    orr r1, r1, #0x09        @ Bit 0 (GPIOA EN) + Bit 3 (GPIOD EN) -> 1001b = 0x09
    str r1, [r0]

    @ 2. GPIOA ως OUTPUT (PINS 0-15)

    ldr r0, =0x40020000      @ GPIOA Base
    ldr r1, =0x55555555      @ 01 σε όλα τα 16-bit ζεύγη (General purpose output mode)
    str r1, [r0, #0x00]      @ Εγραφή στο GPIOA_MODER


    @ 3. GPIOD ως INPUT (DEFAULT 0x00000000)

    ldr r2, =0x40020C00      @ GPIOD Base
    movs r1, #0              @ Καθαρισμός για Input mode
    str r1, [r2, #0x00]      @ Γραφή στο GPIOD_MODER

    @ 4. Αρχική κατάσταση LED (Αρχική θέση: LSB -> Bit 0)

    movs r4, #1              @ r4 = Μάσκα LED (0x00000001 -> LED 0 αναμμένο)
    ldr r3, =0x40020014      @ r3 = Διεύθυνση GPIOA_ODR

main_loop:
    @ Ενημέρωση της θύρας εξόδου GPIOA με την τρέχουσα κατάσταση
    str r4, [r3]

    @ 5. POLLING GPIOD_IDR

    ldr r5, [r2, #0x10]      @ Ανάγνωση GPIOD_IDR στο r5

    @ Έλεγχος LSB Pause/Freeze
    tst r5, #0x01            @ Έλεγχος αν το Bit 0 είναι 1
    beq pause_state          @ Αν Bit 0 == 0, παράκαμψη ολίσθησης (Freeze)

    @ Έλεγχος MSB δηλαδή έλεγχος Κατεύθυνσης
    tst r5, #0x8000          @ Έλεγχος αν το Bit 15 είναι 1
    bne shift_right          @ Αν Bit 15 == 1 (ON) -> Κίνηση Δεξιά

shift_left:
    @ left shift

    lsls r4, r4, #1          @ Ολίσθηση αριστερά κατά 1 bit
    uxth r4, r4              @ Αποκοπή στα 16-bits (Zero-extend halfword)
    cmp r4, #0               @ Αν ξεπεράσει το Bit 15, θα γίνει 0
    bne delay_branch
    movs r4, #1              @ Ανακύκλωση: Επιστροφή στο LSB (Bit 0)
    b delay_branch

shift_right:
    @ right shift

    lsrs r4, r4, #1          @ Ολίσθηση δεξιά κατά 1 bit
    cmp r4, #0               @ Αν πέσει κάτω από το LSB (Bit 0), θα γίνει 0
    bne delay_branch
    ldr r4, =0x8000          @ Ανακύκλωση: Επιστροφή στο MSB (Bit 15)
    b delay_branch

pause_state:
    @ Αν είμαστε σε παύση, δεν αλλάζει το r4, απλά ξαναελέγχουμε
    nop

delay_branch:
    @ 6. SOFTWARE DELAY LOOP (Για ορατή κίνηση στο Renode GUI γιατι υπάρχει αρκετά μεγάλο latency και δεν φαίνονται οι εναλλαγές αλλιώς)

    ldr r6, =0x03000000      @ Μέγεθος καθυστέρησης
delay_loop:
    subs r6, r6, #1
    bne delay_loop

    b main_loop              @ Επιστροφή στον κεντρικό βρόχο
