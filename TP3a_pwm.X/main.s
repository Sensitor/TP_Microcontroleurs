PROCESSOR 18F25K40
#include <xc.inc>

; Configuration ================================================================
config FEXTOSC = OFF           ; Pas de source d'horloge externe
config RSTOSC = HFINTOSC_64MHZ ; Horloge interne de 64 MHz
config WDTE = OFF              ; Desactiver le watchdog	timer
	
PSECT   code, abs

org 0x000
    goto init

org 0x008
    goto High_ISR

org 0x018
    goto Low_ISR


org 0x100

init:

    movlw 0x07            ; PWM3 function
    BANKSEL RC0PPS
    movwf RC0PPS

    BANKSEL TRISC
    bcf TRISC,0          ; On clear la led0 pour l'enable

    BANKSEL PWM3DCH
    movlw 0b00110010
    movwf PWM3DCH

; Enable PWM3
    BANKSEL PWM3CON
    movlw 0b10000000
    movwf PWM3CON


; TIMER2 en 125 Hz

    BANKSEL T2CON
    movlw 0b11011111  ; prescaler 1:32, postscaler 1:16, 
    movwf T2CON

    BANKSEL T2CLKCON
    movlw 0x01          ; Fosc/4
    movwf T2CLKCON

    BANKSEL T2PR
    movlw 0b11111001 ; PR2 à 249
    movwf T2PR	     ;
   
    
    goto loop

    
    
; Boucle infinie
;------------------------------------------------------------
loop:
    goto loop

; Routines d'interruption ======================================================   
High_ISR:
    retfie

Low_ISR:
    retfie

end
