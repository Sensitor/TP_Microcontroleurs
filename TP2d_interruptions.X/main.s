PROCESSOR 18F25K40
#include <xc.inc>

; ================================================================
; Config
; ================================================================
    config FEXTOSC = OFF
    config RSTOSC  = HFINTOSC_64MHZ
    config WDTE    = OFF


; ================================================================
; Définition des variables 
; ================================================================
Comp_L   equ 0x20     ; Compteur 



PSECT code, abs


; ================================================================
; Vecteurs
; ================================================================
org 0x000
    goto init_system

org 0x008
    goto High_ISR

org 0x018
    goto Low_ISR


; ================================================================
; Initialisation du microcontrôleur
; ================================================================
org 0x100

init_system:
    bcf TRISB, 4
    call init_timer0
    

    call init_timer2

    call init_chenillard
    call init_interrupts

    goto wait

init_timer0: 
    BANKSEL TRISB
    bcf TRISB, 4 ; on config la led LDM1
    
    
    BANKSEL T0CON0
    movlw 0b10000100 ; on enable T0CON0 et mode 8 bits; Postscaler 9
    movwf T0CON0
    
    BANKSEL T0CON1
    movlw 0b01001111 ; on met en Fosc/4 et prescaler en 1:32768
    movwf T0CON1    

    
        
    BANKSEL TMR0H
    movlw 0b01111100 ; Set TMR0H to 124
    movwf TMR0H	 
    return
    
    
init_chenillard: 
    ; On met tout le port C en sortie
    BANKSEL TRISC
    movlw 0x00
    movwf TRISC

    ; On allume la led la plus à gauche
    BANKSEL LATC
    movlw 0x01
    movwf LATC

    
    movlw 0x19        ; Le nombre d'itérations nécessaires
    movwf 0x21

    clrf Comp_L; On clear le compteur
    return
    

init_timer2:
    BANKSEL T2CON
    movlw 0b11011001; enable, prescaler à 32 et postscaler à 10
    movwf T2CON; 
    
    BANKSEL T2CLKCON
    movlw 0b00000001  ; on met en FOSC/4
    movwf T2CLKCON
    
    BANKSEL T2PR
    movlw 0b11111001
    movwf T2PR  ;   
    return
    
    
init_interrupts: 
    
    BANKSEL PIE4
    movlw 0b00000010; on config le timer2 en interruption
    movwf PIE4
    
    BANKSEL INTCON
    movlw 0b11100000 ; on enable IPEN; Et GIE et PIE
    movwf INTCON
    
    BANKSEL IPR4
    movlw 0b00000010; TMR2 en high priority
    movwf IPR4
    
    BANKSEL PIE0
    movlw 0b00100000 ; Timer0 interrupt
    movwf PIE0	     ; 
    
    BANKSEL IPR0
    movlw 0b00000000 ; Low priority
    movwf IPR0
    return
    

wait: 
    goto wait

    
    
chenillard_move:
    
    INCF Comp_L, F ; On incrémente le compteur
    
    movf Comp_L,W
    
    CPFSEQ 0x21	 ; On sort si le compteur n'est pas au seuil
    retfie
    
    ; Sinon on change la led
    BANKSEL LATC
    rlncf LATC
    clrf Comp_L
    retfie

    
    
    
bip_led:
    BANKSEL LATB
    btg LATB,4         ; On toggle 
    
    retfie
    
    
    
; Routines d'interruption ======================================================    




High_ISR:
    BANKSEL PIR4
    btfss PIR4,1        ; On vérifie si tmr2 à l'origine de l'interrupt
    retfie              ; Si non on sort

    bcf PIR4,1          ; On clear TMR2IF

    goto chenillard_move        ; On move le chenillard

    retfie              ; 
    

Low_ISR:  
    
    
    BANKSEL PIR0
    btfss PIR0,5      ; On vérifie si tmr2 à l'origine de l'interrupt
    retfie              ; Si non on sort

    bcf PIR0,5          ; On clear TMR2IF

    goto bip_led     ; On move le chenillard

    retfie              ;

end