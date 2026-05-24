/*
 * main.s
 *
 *  Created on: May 24, 2026
 *      Author: karga
 */

.syntax unified
.cpu cortex-m4
.thumb

.global main

.section .text

main:
    movs r0, #10          @ R0 = 10
    movs r1, #3           @ R1 = 3
    lsls r2, r0, #2       @ R2 = R0 << 2 (10 * 4 = 40)
    adds r2, r2, r1       @ R2 = R2 + R1 (40 + 3 = 43)
    movs r1, #5           @ R1 = 5
    subs r2, r2, r1       @ R2 = R2 - R1 (43 - 5 = 38)

    ldr r3, =0x20001000   @ Φόρτωση της διεύθυνσης της RAM στον R3
    str r2, [r3, #0]      @ Αποθήκευση του αποτελέσματος (38) στη RAM

loop:
    b loop                @ Ατέρμονος βρόχος (infinite loop)

