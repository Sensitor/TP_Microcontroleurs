PROCESSOR 18F25K40
#include <xc.inc>

; Configuration ================================================================
config FEXTOSC = OFF           ; Pas de source d'horloge externe
config RSTOSC = HFINTOSC_64MHZ ; Horloge interne de 64 MHz
config WDTE = OFF              ; Desactiver le watchdog	timer
	
    
PSECT   code, abs
   
; Vecteur de reset =============================================================
org     0x000
goto init 
     
; Vecteur d'interruption haute priorite ========================================
org     0x008
goto High_ISR 

; Vecteur d'interruption basse priorite ========================================
org     0x018
goto Low_ISR    
   
; Programme principal ==========================================================
org 0x100   
   
   
   
; On observe bien un signal rectangulaire rapide avec une fréquence de 50 khz
; Le signal est périodique   


init: 
    call init_matrix ; on appelle la routine
    call init_timer2 ; init du timer 2
    call init_interrupts; init des interruptions
    
    goto wait


   
wait: 
    
    goto wait; boucle infinie
    
    

    
init_matrix: 
    BANKSEL TRISB
    bcf TRISB, 5  ; on init CMD_MATRIX en sortie
    return
    
    
init_timer2:
    BANKSEL T2CON
    movlw 0b11010100; enable, prescaler à 32 et postscaler à 5
    movwf T2CON; 
    
    BANKSEL T2CLKCON
    movlw 0b00000001  ; on met en FOSC/4
    movwf T2CLKCON
    
    BANKSEL T2PR
    movlw 0x00
    movwf T2PR  ; 
     
    
init_interrupts: 
    
    BANKSEL PIE4
    movlw 0b00000010; on config le timer2 en interruption
    movwf PIE4
    
    BANKSEL INTCON
    movlw 0b10100000 ; on enable IPEN; Et les hautes interrupts
    movwf INTCON
    
    BANKSEL IPR4
    movlw 0b00000010; TMR2 en high priority
    movwf IPR4
    
    
    
       
bip_led:
    BANKSEL LATB
    btg LATB,5         ; On toggle 
    
    retfie



High_ISR:
    BANKSEL PIR4
    btfss PIR4,1        ; On vérifie si tmr2 à l'origine de l'interrupt
    retfie              ; Si non on sort

    bcf PIR4,1          ; On clear TMR2IF

    call bip_led        ; On allume la led

    retfie              ; 
    
Low_ISR:  
    retfie
     
end


