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
   

; Sur l'oscilloscope il nous est indiqué une période de 20 micro secondes et on observe bien
; une inversion toutes les 10 micro secondes comme demandé.   
   
   
; Programme principal ==========================================================
org 0x100   


init: 
    call init_matrix ; on appelle la routine
    call init_timer2 ; init du timer 2
    
    goto wait



wait: 
    
    BANKSEL PIR4
    btfss PIR4, 1 ; on test si le timer overflow, si oui on skip l'instru. suivante
	goto wait ; ici timer pas overflow, on reboucle
    
    bcf PIR4, 1; on clear pour le prochain cycle   
    
    call bip_led ; on toggle 
    
    goto wait
    

    
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
    return
     
    
bip_led:
    BANKSEL LATB
    btg LATB,5         ; On toggle 
    return

end 


