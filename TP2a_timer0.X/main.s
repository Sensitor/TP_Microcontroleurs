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
   

; Programme principal ==========================================================
org 0x100   


init: 
    BANKSEL TRISB
    bcf TRISB, 4 ; on config la led LDM1
    
    
    BANKSEL T0CON0
    movlw 0b10001000 ; on enable T0CON0 et mode 8 bits; Postscaler 9
    movwf T0CON0
    
    BANKSEL T0CON1
    movlw 0b01001100 ; on met en Fosc/4 et prescaler en 1:4096
    movwf T0CON1
        
    goto loop

loop: 

   
wait: 
    
    BANKSEL PIR0
    btfss PIR0, 5 ; on test si le timer overflow, si oui on skip l'instru. suivante
	goto wait ; ici timer pas overflow, on reboucle
    
    bcf PIR0, 5; on clear pour le prochain cycle   
    
    call bip_led ; on toggle 
    
    goto loop
    

bip_led:
    BANKSEL LATB
    btg LATB,4          ; On toggle LDM1
    return

end 